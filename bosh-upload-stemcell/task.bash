#!/bin/bash
set -eux

function setup_bosh_env_vars() {
  set +x
  pushd bbl-state-dir
    export BOSH_CA_CERT="$(bbl director-ca-cert)"
    export BOSH_ENVIRONMENT=$(bbl director-address)
    export BOSH_CLIENT=$(bbl director-username)
    export BOSH_CLIENT_SECRET=$(bbl director-password)
  popd
  set -x
}

function check_input_params() {
  if [ -z "$INFRASTRUCTURE" ]; then
    echo "INFRASTRUCTURE has not been set"
    exit 1
  fi
  local supported_infrastructures
  supported_infrastructures=("aws" "google" "boshlite" "bosh-lite" "vsphere")
  any_matched=false
  for iaas in ${supported_infrastructures[*]}; do
    if [ "${INFRASTRUCTURE}" == "${iaas}" ]; then
      any_matched=true
      break
    fi
  done
  if [ "$any_matched" = false ]; then
    echo "${INFRASTRUCTURE} is not supported; please choose a value from ${supported_infrastructures[*]}"
    exit 1
  fi
}

function upload_stemcell() {
  # Read potentially variable stemcell paramaters out of cf-deployment with bosh
  local os
  os=$(bosh interpolate --path=/stemcells/alias=default/os cf-deployment/cf-deployment.yml)
  local version
  version=$(bosh interpolate --path=/stemcells/alias=default/version cf-deployment/cf-deployment.yml)

  # Hardcode a couple of stable stemcell paramaters
  local stemcells_url
  stemcells_url="https://bosh.io/d/stemcells"
  local bosh_agent
  bosh_agent="go_agent"

  # Ask bosh if it already has our OS / version stemcell combination
  # As of this writing, the new bosh cli doesn't have --skip-if-exists
  set +e
  local existing_stemcell
  existing_stemcell=$(bosh stemcells | grep "${os}" | awk '{print $2}' | tr -d "\*" | grep ^"${version}"$ )
  set -e

  local stemcell_name
  stemcell_name="bosh"

  if [ "$INFRASTRUCTURE" = "aws" ]; then
    stemcell_name="${stemcell_name}-aws-xen-hvm"
  elif [ "$INFRASTRUCTURE" = "google" ]; then
    stemcell_name="${stemcell_name}-google-kvm"
  elif [ "$INFRASTRUCTURE" = "boshlite" ]; then
    stemcell_name="${stemcell_name}-warden-boshlite"
  elif [ "$INFRASTRUCTURE" = "bosh-lite" ]; then
    stemcell_name="${stemcell_name}-warden-boshlite"
  elif [ "$INFRASTRUCTURE" = "vsphere" ]; then
    stemcell_name="${stemcell_name}-vsphere-esxi"
  fi

  stemcell_name="${stemcell_name}-${os}-${bosh_agent}"
  full_stemcell_url="${stemcells_url}/${stemcell_name}?v=${version}"

  # If bosh already has our stemcell, exit 0
  if [ "${existing_stemcell}" ]; then
    echo "Task bosh-upload-stemcell:"
    echo "Stemcell '${stemcell_name}/${version}' already exists.  Exiting..."
    exit 0
  fi

  # ... otherwise, begin the upload process
  #set +x
  bosh --version
  bosh upload-stemcell --help
  bosh login
  echo $BOSH_CA_CERT
  bosh \
    -n \
    upload-stemcell \
    "${full_stemcell_url}"
  set -x
}

function main() {
  check_input_params
  setup_bosh_env_vars
  upload_stemcell
}

main

