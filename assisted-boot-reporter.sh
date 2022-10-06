#!/usr/bin/env bash

export LOG_SEND_ITERATION_MINUTES=10
export SERVICE_TIMEOUT_MINUTES=60

function log() {
  echo "$(date '+%F %T') level=$1 $2"
}

function log_info() {
  log "info" "$1"
}

function log_error() {
  log "error" "$1"
}

function init_variables() {
  init_failed="false"

  export PULL_SECRET_TOKEN=$(echo $PULL_SECRET | jq -r '.auths."cloud.openshift.com".auth')
  export INFRA_ENV_ID=''
  export HOST_ID=''

  if [ "$PULL_SECRET_TOKEN" == "" ]; then
    init_failed="true"
    log_error "PULL_SECRET_TOKEN is empty."
  fi
  if [ "$INFRA_ENV_ID" == "" ]; then
    init_failed="true"
    log_error "INFRA_ENV_ID is empty."
  fi
  if [ "$HOST_ID" == "" ]; then
    init_failed="true"
    log_error "HOST_ID is empty."
  fi

  if [ "$init_failed" == "true" ]; then
    log_error "Failed to initialize variables. Exiting.."
    exit 1
  fi
}

function main() {
  echo sleep LOG_SEND_ITERATION_MINUTES
  # curl -X POST https://api.openshift.com/api/assisted-install/v2/clusters/<id>/hosts -H "X-Secret-Key: <PULL_SECRET_TOKEN>"
}



(
log_info "assisted-boot-reporter start"

init_variables
log_info "assisted-boot-reporter end"

) 2>&1 | tee -a assisted-boot-reporter.log