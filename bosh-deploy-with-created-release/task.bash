#!/bin/bash -eux

function check_input_params() {
  set +x
  if [ -z "$MANIFEST_FILE" ]; then
    echo "MANIFEST_FILE has not been set"
    exit 1
  fi

  if [ -z "$VARS_STORE_PATH" ]; then
    echo "VARS_STORE_PATH has not been set"
    exit 1
  fi

  if [ -z "$SYSTEM_DOMAIN" ]; then
    echo "SYSTEM_DOMAIN has not been set"
    exit 1
  fi
  set -x
}

function commit_vars_store {
  pushd vars-store
    if [[ -n $(git status --porcelain) ]]; then
      git config user.name "CI Bot"
      git config user.email "cf-release-integration@pivotal.io"
      git add .
      git commit -m "Update vars-store after deploy"
    fi
  popd

  shopt -s dotglob
  cp -R vars-store/* updated-vars-store/
}

function check_unmodified_addresses() {
  set +x
  local interpolated_manifest
  interpolated_manifest="${1}"

  local unmodified_addresses
  set +e
  unmodified_addresses=$(cat "${interpolated_manifest}" | grep -E '10\.0\.31\.190|10\.0\.47\.190|10\.0\.63\.190|10\.0\.31\.191|10\.0\.47\.191|10\.0\.31\.193')
  set -e

  if [ -n "${unmodified_addresses}" ]; then
    echo "Here are all the unmodified static IP addresses left in this manifest after applying all bosh operations:"
    echo "${unmodified_addresses}"
  fi
  set -x
}

function setup_bosh_env_vars() {
  set +x
  export BOSH_CA_CERT=$(mktemp)
  bbl --state-dir=bbl-state/${BBL_STATE_DIR} director-ca-cert > "${BOSH_CA_CERT}"
  export BOSH_ENVIRONMENT=$(bbl --state-dir=bbl-state/${BBL_STATE_DIR} director-address)
  export BOSH_CLIENT=$(bbl --state-dir=bbl-state/${BBL_STATE_DIR} director-username)
  export BOSH_CLIENT_SECRET=$(bbl --state-dir=bbl-state/${BBL_STATE_DIR} director-password)
  set -x
}

function bosh_deploy() {
  local root_dir
  root_dir="${1}"

  local bosh_manifest
  bosh_manifest="cf-deployment/${MANIFEST_FILE}"

  local deployment_name
  deployment_name=$(grep -E "^name:" "$bosh_manifest" | awk '{print $2}')

  local arguments
  arguments="--vars-store vars-store/${VARS_STORE_PATH} -v system_domain=${SYSTEM_DOMAIN} -o create-provided-release.yml"

  local release_name
  release_name=$(grep final_name release/config/final.yml | awk '{print $2}')

  cat << EOF > create-provided-release.yml
---
- type: replace
  path: /releases/name=${release_name}
  value:
    name: ${release_name}
    version: create
    url: file://${root_dir}/release
EOF

  for op in ${OPS_FILES}
  do
    arguments="${arguments} -o ops-files/${op}"
  done

  local interpolated_manifest
  interpolated_manifest=$(mktemp)

  bosh -n interpolate ${arguments} --var-errs "${bosh_manifest}" > "${interpolated_manifest}"

  check_unmodified_addresses "${interpolated_manifest}"

  bosh \
    -n \
    -d "${deployment_name}" \
    deploy \
    "${interpolated_manifest}"
}

function main() {
  local root_dir
  root_dir="${1}"

  check_input_params
  setup_bosh_env_vars
  bosh_deploy "${root_dir}"
}

trap commit_vars_store EXIT

main "${PWD}"
