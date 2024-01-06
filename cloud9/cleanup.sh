#!/bin/bash

function cleanup_eks-cluster.sh() {
       eksctl delete cluster --region="${AWS_REGION}" --name="${CLUSTER_NAME}"
}
