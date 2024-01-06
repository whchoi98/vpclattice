#!/bin/sh

source ./helper.sh

CLUSTER_NAME=$1

wget https://raw.githubusercontent.com/aws/aws-application-networking-k8s/main/examples/deploy-namesystem.yaml
wget https://raw.githubusercontent.com/aws/aws-application-networking-k8s/main/examples/gatewayclass.yaml

kubectl --context "${CLUSTER_NAME}" apply -f deploy-namesystem.yaml

export LATTICE_POLICY_ARN=$(aws iam list-policies --query "Policies[?PolicyName=='${LATTICE_POLICY}'].Arn" --output text)
echo "${LATTICE_POLICY_ARN}"

eksctl create iamserviceaccount \
--cluster="${CLUSTER_NAME}" \
--namespace=aws-application-networking-system \
--name=gateway-api-controller \
--attach-policy-arn="${LATTICE_POLICY_ARN}" \
--override-existing-serviceaccounts \
--region "${AWS_REGION}" \
--approve

aws ecr-public get-login-password --region us-east-1 | helm registry login --username AWS --password-stdin public.ecr.aws

helm --kube-context "${CLUSTER_NAME}"  upgrade --install gateway-api-controller \
   oci://public.ecr.aws/aws-application-networking-k8s/aws-gateway-controller-chart\
   --version=v0.0.8 \
   --set=aws.region="$AWS_REGION" --set=serviceAccount.create=false --namespace aws-application-networking-system

kubectl --context "${CLUSTER_NAME}" apply -f gatewayclass.yaml -n default
