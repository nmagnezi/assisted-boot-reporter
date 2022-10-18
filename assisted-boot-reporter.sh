#!/usr/bin/env bash

# TODO REMOVE
export PULL_SECRET=''
export CLUSTER_ID='fffea722-a425-490e-a9ca-ba920bc2e6c0'
export INFRA_ENV_ID='7c477a6e-7586-48e5-ae70-b2d67a17a114'
export HOST_ID='68eb088b-7529-4fb6-8dcd-70760abeeb29'


export LOG_SEND_ITERATION_MINUTES=10
export SERVICE_TIMEOUT_MINUTES=60
export ASSISTED_API_BASE_PATH="api/assisted-install/v2"

function log() {
  echo "$(date '+%F %T') ${HOSTNAME} $2[$$]: level=$1 msg=\"$3\""
}

function log_info() {
  log "info" "$1" "$2"
}

function log_error() {
  log "error" "$1" "$2"
}

function init_variables() {
  func_name=${FUNCNAME[0]}
  init_failed="false"

  # THIS PART IS WIP
  export PULL_SECRET_TOKEN=$(echo $PULL_SECRET | jq -r '.auths."cloud.openshift.com".auth')

  if [ "$ASSISTED_SERVICE_URL" == "" ]; then
    init_failed="true"
    log_error "${func_name}" "ASSISTED_SERVICE_URL is empty."
  elif [ "${ASSISTED_SERVICE_URL: -1}" == "/" ]; then
    export ASSISTED_SERVICE_URL="${ASSISTED_SERVICE_URL::-1}"
  fi

  if [ "$PULL_SECRET_TOKEN" == "" ]; then
    init_failed="true"
    log_error "${func_name}" "PULL_SECRET_TOKEN is empty."
  fi

  if [ "$CLUSTER_ID" == "" ]; then
    init_failed="true"
    log_error "${func_name}" "CLUSTER_ID is empty."
  fi

  if [ "$INFRA_ENV_ID" == "" ]; then
    init_failed="true"
    log_error "${func_name}" "INFRA_ENV_ID is empty."
  fi

  if [ "$HOST_ID" == "" ]; then
    init_failed="true"
    log_error "${func_name}" "HOST_ID is empty."
  fi

  if [ "$init_failed" == "true" ]; then
    log_error "${func_name}" "Failed to initialize variables. Exiting."
    exit 1
  fi
}

function collect_and_upload_logs() {
  func_name=${FUNCNAME[0]}

  log_info "${func_name}" "Collecting logs."
  # WIP - collect logs here.
  log_info "${func_name}" "Uploading logs."

  curl -s \
    -X POST \
    -F upload=@tmp.log \
     "$ASSISTED_SERVICE_URL/$ASSISTED_API_BASE_PATH/clusters/$CLUSTER_ID/logs?logs_type=host&infra_env_id=$INFRA_ENV_ID&host_id=$HOST_ID"
  echo



}

function main() {
  func_name=${FUNCNAME[0]}
  count=$((SERVICE_TIMEOUT_MINUTES/LOG_SEND_ITERATION_MINUTES))

  for i in $(seq $count)
  do
      log_info "${func_name}" "Upload logs attempt ${i}/${count}"
      collect_and_upload_logs
      log_info "${func_name}" "Sleeping for ${LOG_SEND_ITERATION_MINUTES} minutes until the next attempt."
      sleep $((SERVICE_TIMEOUT_MINUTES*60))
  done
}


(
log_info assisted-boot-reporter "assisted-boot-reporter start"
init_variables
main
log_info assisted-boot-reporter "assisted-boot-reporter end"

) 2>&1 | tee -a assisted-boot-reporter.log