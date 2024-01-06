#!/bin/bash

source ./helper.sh

source ./env.sh

CLUSTER_NAME=${CLUSTER1_NAME}

eksctl utils write-kubeconfig --cluster ${CLUSTER_NAME}

kubectl config get-contexts -o name

context=$(kubectl config get-contexts -o name | grep ${CLUSTER_NAME}.)

kubectl config rename-context ${context} ${CLUSTER_NAME}

