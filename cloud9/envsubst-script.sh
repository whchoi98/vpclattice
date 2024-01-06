#!/bin/bash

source ./helper.sh

VPC1_ID=$(aws ec2 describe-vpcs --region "$AWS_REGION"  --filters "${VPC1_FILTER}" | jq -r '.Vpcs[].VpcId')
VPC2_ID=$(aws ec2 describe-vpcs --region "$AWS_REGION"  --filters "${VPC2_FILTER}" | jq -r '.Vpcs[].VpcId')

export_to_env VPC1_ID "${VPC1_ID}"
export_to_env VPC2_ID "${VPC2_ID}"

envsubst < rs-deploy-app-c1-var.yaml > rs-deploy-app-c1.yaml

envsubst < rs-assets-http-route-var.yaml > assets-http-route-c1.yaml

envsubst < rs-cart-http-route-var.yaml > cart-http-route-c1.yaml

envsubst < rs-catalog-http-route-var.yaml > catalog-http-route-c1.yaml
