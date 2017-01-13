#!/bin/bash
set -eux

# Load up bosh target information from files in resources
BOSH_ENVIRONMENT=$(cat "target/${TARGET_FILE}")  && export BOSH_ENVIRONMENT
BOSH_USER=$(cat username/"${USERNAME_FILE}")     && export BOSH_USER
set +x
BOSH_CA_CERT="ca-cert/${CA_CERT_FILE}"           && export BOSH_CA_CERT
BOSH_PASSWORD=$(cat "password/${PASSWORD_FILE}") && export BOSH_PASSWORD
set -x

# Read potentially variable stemcell paramaters out of cf-deployment with bosh
OS=$(bosh interpolate --path=/stemcells/alias=default/os cf-deployment/cf-deployment.yml)
VERSION=$(bosh interpolate --path=/stemcells/alias=default/version cf-deployment/cf-deployment.yml)

# Hardcode a couple of stable stemcell paramaters
STEMCELLS_URL="https://bosh.io/d/stemcells"
BOSH_AGENT="go_agent"

# Ask bosh if it already has our OS / version stemcell combination
# As of this writing, the new bosh cli doesn't have --skip-if-exists
set +e
EXISTING_STEMCELL=$(bosh stemcells | grep "$OS" | awk '{print $2}' | tr -d "\*" | grep ^"$VERSION"$ )
set -e

STEMCELL_NAME="bosh"

if [ "$INFRASTRUCTURE" = "aws" ]; then
  STEMCELL_NAME="$STEMCELL_NAME-aws-xen-hvm"
elif [ "$INFRASTRUCTURE" = "google" ]; then
  STEMCELL_NAME="$STEMCELL_NAME-google-kvm"
elif [ "$INFRASTRUCTURE" = "boshlite" ]; then
  STEMCELL_NAME="$STEMCELL_NAME-warden-boshlite"
elif [ "$INFRASTRUCTURE" = "bosh-lite" ]; then
  STEMCELL_NAME="$STEMCELL_NAME-warden-boshlite"
elif [ "$INFRASTRUCTURE" = "vsphere" ]; then
  STEMCELL_NAME="$STEMCELL_NAME-vsphere-esxi"
fi

STEMCELL_NAME="$STEMCELL_NAME-$OS-$BOSH_AGENT"
FULL_STEMCELL_URL="$STEMCELLS_URL/$STEMCELL_NAME?v=$VERSION"

# If bosh already has our stemcell, exit 0
if [ "$EXISTING_STEMCELL" ]; then
  echo "Task bosh-upload-stemcell:"
  echo "Stemcell '$STEMCELL_NAME/$VERSION' already exists.  Exiting..."
  exit 0
fi

# ... otherwise, begin the upload process
set +x
bosh \
  -n \
  upload-stemcell \
  "$FULL_STEMCELL_URL"
set -x

