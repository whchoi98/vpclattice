#!/bin/bash

source ./helper.sh

source ./env.sh

touch ${LOG_FILE}
chmod a+rw ${LOG_FILE}

./init.sh

./eks-tool-set.sh

./eks-cluster.sh "${CLUSTER1_NAME}" "${VPC1_FILTER}"

#./eks-cluster.sh "${CLUSTER2_NAME}" "${VPC2_FILTER}"

./envsubst-script.sh

# source ~/.bashrc

cat ~/env.sh
