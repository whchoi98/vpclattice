#!/bin/bash

source ./helper.sh

CLUSTER_NAME=c1
NODE_INSTANCE_TYPE="m5.large"
EKS_VERSION="1.25"

AZS=($(aws ec2 describe-availability-zones --query 'AvailabilityZones[].ZoneName' --output text --region "$AWS_REGION"))

CLUSTER_VPC_ID=$(aws ec2 describe-vpcs --filters Name=tag:Name,"Values=LatticeWorkshop Clients VPC" | jq -r '.Vpcs[].VpcId')

echo $CLUSTER_VPC_ID

export PUBLIC_SUBNETS_LIST=($(aws ec2 describe-subnets --filters Name=vpc-id,Values=$CLUSTER_VPC_ID --query 'Subnets[?MapPublicIpOnLaunch==`false`].{AZ: AvailabilityZone, SUBNET: SubnetId}' --output json))
export PRIVATE_SUBNETS_LIST=($(aws ec2 describe-subnets --filters Name=vpc-id,Values=$CLUSTER_VPC_ID --query 'Subnets[?MapPublicIpOnLaunch==`true`].{AZ: AvailabilityZone, SUBNET: SubnetId}' --output json))

echo "Identified Public subnets ${PUBLIC_SUBNETS_LIST[@]}"
echo "Identified Private subnets ${PRIVATE_SUBNETS_LIST[@]}"

AZ1=${AZS[0]}
AZ2=${AZS[1]}
AZ3=${AZS[2]}

PUBLIC_SUBNETS[0]=$(echo ${PUBLIC_SUBNETS_LIST[@]} | jq -r --arg AZ "$AZ1" '.[] | select(.AZ == $AZ ).SUBNET')
PUBLIC_SUBNETS[1]=$(echo ${PUBLIC_SUBNETS_LIST[@]} | jq -r --arg AZ "$AZ2" '.[] | select(.AZ == $AZ ).SUBNET')
PUBLIC_SUBNETS[2]=$(echo ${PUBLIC_SUBNETS_LIST[@]} | jq -r --arg AZ "$AZ3" '.[] | select(.AZ == $AZ ).SUBNET')

PRIVATE_SUBNETS[0]=$(echo ${PRIVATE_SUBNETS_LIST[@]} | jq -r --arg AZ "$AZ1" '.[] | select(.AZ == $AZ ).SUBNET')
PRIVATE_SUBNETS[1]=$(echo ${PRIVATE_SUBNETS_LIST[@]} | jq -r --arg AZ "$AZ2" '.[] | select(.AZ == $AZ ).SUBNET')
PRIVATE_SUBNETS[2]=$(echo ${PRIVATE_SUBNETS_LIST[@]} | jq -r --arg AZ "$AZ3" '.[] | select(.AZ == $AZ ).SUBNET')

echo ${PUBLIC_SUBNETS[*]}
echo ${PRIVATE_SUBNETS[*]}

aws ec2 create-tags --resources ${PUBLIC_SUBNETS[0]} --tags Key=kubernetes.io/cluster/${CLUSTER_NAME},Value=shared Key=kubernetes.io/role/elb,Value=1 Key=alpha.eksctl.io/cluster-name,Value=${CLUSTER_NAME}
aws ec2 create-tags --resources ${PUBLIC_SUBNETS[1]} --tags Key=kubernetes.io/cluster/${CLUSTER_NAME},Value=shared Key=kubernetes.io/role/elb,Value=1 Key=alpha.eksctl.io/cluster-name,Value=${CLUSTER_NAME}
aws ec2 create-tags --resources ${PUBLIC_SUBNETS[2]} --tags Key=kubernetes.io/cluster/${CLUSTER_NAME},Value=shared Key=kubernetes.io/role/elb,Value=1 Key=alpha.eksctl.io/cluster-name,Value=${CLUSTER_NAME}

aws ec2 create-tags --resources ${PRIVATE_SUBNETS[0]} --tags Key=kubernetes.io/cluster/${CLUSTER_NAME},Value=shared Key=kubernetes.io/role/internal-elb,Value=1 Key=alpha.eksctl.io/cluster-name,Value=${CLUSTER_NAME}
aws ec2 create-tags --resources ${PRIVATE_SUBNETS[1]} --tags Key=kubernetes.io/cluster/${CLUSTER_NAME},Value=shared Key=kubernetes.io/role/internal-elb,Value=1 Key=alpha.eksctl.io/cluster-name,Value=${CLUSTER_NAME}
aws ec2 create-tags --resources ${PRIVATE_SUBNETS[2]} --tags Key=kubernetes.io/cluster/${CLUSTER_NAME},Value=shared Key=kubernetes.io/role/internal-elb,Value=1 Key=alpha.eksctl.io/cluster-name,Value=${CLUSTER_NAME}

echo "Completed adding EKS tags to be make subnets compliant"

cat << EOF > eksworkshop.yaml
---
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig

metadata:
  name: ${CLUSTER_NAME}
  region: ${AWS_REGION}
  version: "${EKS_VERSION}"

vpc:
  id: ${CLUSTER_VPC_ID}
  subnets:
    public:
      ${AZS[0]}:
          id: ${PUBLIC_SUBNETS[0]}
      ${AZS[1]}:
          id: ${PUBLIC_SUBNETS[1]}
      ${AZS[2]}:
          id: ${PUBLIC_SUBNETS[2]}
    private:
      ${AZS[0]}:
          id: ${PRIVATE_SUBNETS[0]}
      ${AZS[1]}:
          id: ${PRIVATE_SUBNETS[1]}
      ${AZS[2]}:
          id: ${PRIVATE_SUBNETS[2]}

cloudWatch:
    clusterLogging:
        enableTypes: ["api", "audit", "authenticator", "controllerManager", "scheduler"]
iam:
  withOIDC: true
addons:
- name: vpc-cni
  attachPolicyARNs:
    - arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy
- name: coredns
  version: latest
- name: kube-proxy
  version: latest
- name: aws-ebs-csi-driver
  wellKnownPolicies:
    ebsCSIController: true

managedNodeGroups:
- name: nodegroup
  minSize: 2
  maxSize: 3
  desiredCapacity: 3
  instanceType: ${NODE_INSTANCE_TYPE}
  #volumeSize: 20
  privateNetworking: true
  ssh:
    enableSsm: true
  labels: {role: workshop}
  tags:
    nodegroup-role: workshop

EOF

eksctl create cluster -f eksworkshop.yaml

aws eks --region ${AWS_REGION} update-kubeconfig --name ${CLUSTER_NAME}

kubectl get nodes

# STACK_NAME=$(eksctl get nodegroup --cluster ${CLUSTER_NAME} -o json | jq -r '.[].StackName')
# ROLE_NAME=$(aws cloudformation describe-stack-resources --stack-name $STACK_NAME | jq -r '.StackResources[] | select(.ResourceType=="AWS::IAM::Role") | .PhysicalResourceId')
# export_to_env ROLE_NAME ${ROLE_NAME}

eksctl utils associate-iam-oidc-provider --cluster ${CLUSTER_NAME} --approve --region $AWS_REGION

log_text "Success" "Completed EKS cluster setup..."

ROLE_ARN=$(aws iam get-role --role-name WSParticipantRole --query Role.Arn --output text) || true

eksctl create iamidentitymapping --cluster ${CLUSTER_NAME} --arn ${ROLE_ARN} --group system:masters --username admin || true

kubectl config get-contexts -o name

context=$(kubectl config get-contexts -o name | grep cluster/${CLUSTER_NAME})  || true

kubectl config rename-context ${context} ${CLUSTER_NAME}  || true

echo "Added console credentials for console access"
