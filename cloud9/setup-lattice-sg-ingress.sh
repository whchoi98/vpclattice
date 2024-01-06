#!/bin/sh

source ./helper.sh

set +e

CLUSTER_NAME=$1

PREFIX_LIST_ID=$(aws ec2 describe-managed-prefix-lists --query "PrefixLists[?PrefixListName=="\'com.amazonaws.$AWS_REGION.vpc-lattice\'"].PrefixListId" | jq -r '.[]')
MANAGED_PREFIX=$(aws ec2 get-managed-prefix-list-entries --prefix-list-id $PREFIX_LIST_ID --output json  | jq -r '.Entries[0].Cidr')
CLUSTER_SG=$(aws eks describe-cluster --name $CLUSTER_NAME --output json| jq -r '.cluster.resourcesVpcConfig.clusterSecurityGroupId')

aws ec2 authorize-security-group-ingress --group-id $CLUSTER_SG --cidr $MANAGED_PREFIX --protocol -1

wget https://raw.githubusercontent.com/aws/aws-application-networking-k8s/main/examples/recommended-inline-policy.json

aws iam create-policy \
   --policy-name $LATTICE_POLICY \
   --policy-document file://recommended-inline-policy.json
