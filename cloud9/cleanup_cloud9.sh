#!/bin/bash

source ./helper.sh

set +e

eksctl delete cluster --region="${AWS_REGION}" --name="${CLUSTER1_NAME}"

log_text "Success" "Cleanup successfully..."

