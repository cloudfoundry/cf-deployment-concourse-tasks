#!/bin/bash
set -eux

export BOSH_USER
export BOSH_PASSWORD
BOSH_USER=$(cat "username/${USERNAME_FILE_PATH}")
BOSH_TARGET=$(cat "target/${TARGET_FILE_PATH}")
BOSH_MANIFEST="manifest/${MANIFEST_FILE_PATH}"
BOSH_CA_CERT="ca-cert/${CA_CERT_FILE_PATH}"
DEPLOYMENT_NAME=$(grep -E "^name:" "$BOSH_MANIFEST" | awk '{print $2}')
RELEASE_NAME=$(grep final_name release/config/final.yml | awk '{print $2}')

set +u
DEPLOYMENT_VARS_STORE=""
if [[ ! -z "$DEPLOYMENT_VARS_STORE_PATH" ]]; then
  DEPLOYMENT_VARS_STORE="manifest-properties/${DEPLOYMENT_VARS_STORE_PATH}"
fi

set -u
set +x
echo "BOSH_PASSWORD=\$(cat password/${PASSWORD_FILE_PATH})"
BOSH_PASSWORD=$(cat "password/${PASSWORD_FILE_PATH}")
set -x

function commit_vars_store {
  pushd manifest-properties
    if [[ -n $(git status --porcelain) ]]; then
      git config user.name "CF MEGA BOT"
      git config user.email "cf-mega@pivotal.io"
      git add .
      git commit -m "Update vars store"
    fi
  popd

  shopt -s dotglob
  cp -R manifest-properties/* updated-vars-store/
}

trap commit_vars_store EXIT

cat << EOF > ops.yml
---
- type: replace
  path: /releases/name=${RELEASE_NAME}
  value:
    name: ${RELEASE_NAME}
    version: create
    url: file://$(pwd)/release
EOF

VARS_STORE_FLAG=""
if [[ ! -z "${DEPLOYMENT_VARS_STORE}" ]]; then
  VARS_STORE_FLAG="--vars-store ${DEPLOYMENT_VARS_STORE} -v system_domain=${SYSTEM_DOMAIN}"
fi

OPS_FILE_FLAG="-o ops.yml"
if [[ -f "manifest/${OPS_FILE}" ]]; then
  grep -v "\-\-\-" "manifest/${OPS_FILE}" >> ops.yml
fi

bosh -n interpolate ${VARS_STORE_FLAG} ${OPS_FILE_FLAG} --var-errs ${BOSH_MANIFEST} > /dev/null

if [ ! -z "${DEPLOYMENT_VARS_STORE}" ]; then
  set +x
  CF_PASSWORD=$(bosh int ${DEPLOYMENT_VARS_STORE} --path=/uaa_scim_users_admin_password)
  cat manifest-properties/integration_config_template.json | \
    sed "s/REPLACE_ME/\"${CF_PASSWORD}\"/" \
    > manifest-properties/integration_config.json
  set -x
fi

bosh \
  -n \
  -d "${DEPLOYMENT_NAME}" \
  -e "${BOSH_TARGET}" \
  --ca-cert="${BOSH_CA_CERT}" \
  deploy \
  ${VARS_STORE_FLAG} \
  ${OPS_FILE_FLAG} \
  "${BOSH_MANIFEST}"
