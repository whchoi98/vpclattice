#!/bin/bash
echo "installed eks-cluster01"

echo "------------------------------------------------------"
cd ~/environment/vpclattice/cloud9/
eksctl create cluster -f lattice_eks01.yaml

aws eks --region ${AWS_REGION} update-kubeconfig --name ${CLUSTER1_NAME}

kubectl get nodes

# STACK_NAME=$(eksctl get nodegroup --cluster ${CLUSTER1_NAME} -o json | jq -r '.[].StackName')
# ROLE_NAME=$(aws cloudformation describe-stack-resources --stack-name $STACK_NAME | jq -r '.StackResources[] | select(.ResourceType=="AWS::IAM::Role") | .PhysicalResourceId')
# export_to_env ROLE_NAME ${ROLE_NAME}

eksctl utils associate-iam-oidc-provider --cluster ${CLUSTER1_NAME} --approve --region $AWS_REGION

#log_text "Success" "Completed EKS cluster setup..."

# ROLE_ARN=$(aws iam get-role --role-name WSParticipantRole --query Role.Arn --output text) || true

# eksctl create iamidentitymapping --cluster ${CLUSTER1_NAME} --arn ${ROLE_ARN} --group system:masters --username admin || true

kubectl config get-contexts

#context1=$(kubectl config get-contexts -o name | grep cluster/${CLUSTER1_NAME})  || true
export context1=$(kubectl config get-contexts -o name | grep c1)
kubectl config rename-context ${context1} ${CLUSTER1_NAME}  || true
kubectl config get-contexts

source ~/.bash_profile
#echo "Added console credentials for console access"

echo "installed eks-cluster02"

echo "------------------------------------------------------"

cd ~/environment/vpclattice/cloud9/
eksctl create cluster -f lattice_eks02.yaml
aws eks --region ${AWS_REGION} update-kubeconfig --name ${CLUSTER2_NAME}

kubectl get nodes

# STACK_NAME=$(eksctl get nodegroup --cluster ${CLUSTER1_NAME} -o json | jq -r '.[].StackName')
# ROLE_NAME=$(aws cloudformation describe-stack-resources --stack-name $STACK_NAME | jq -r '.StackResources[] | select(.ResourceType=="AWS::IAM::Role") | .PhysicalResourceId')
# export_to_env ROLE_NAME ${ROLE_NAME}

eksctl utils associate-iam-oidc-provider --cluster ${CLUSTER2_NAME} --approve --region $AWS_REGION

#log_text "Success" "Completed EKS cluster setup..."

# ROLE_ARN=$(aws iam get-role --role-name WSParticipantRole --query Role.Arn --output text) || true

# eksctl create iamidentitymapping --cluster ${CLUSTER1_NAME} --arn ${ROLE_ARN} --group system:masters --username admin || true

kubectl config get-contexts

#context1=$(kubectl config get-contexts -o name | grep cluster/${CLUSTER1_NAME})  || true
export context2=$(kubectl config get-contexts -o name | grep c2.)
kubectl config rename-context ${context2} ${CLUSTER2_NAME}  || true
kubectl config get-contexts

source ~/.bash_profile

echo "installed kube-krew"

echo "------------------------------------------------------"

(
  set -x; cd "$(mktemp -d)" &&
  OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
  ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
  KREW="krew-${OS}_${ARCH}" &&
  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
  tar zxvf "${KREW}.tar.gz" &&
  ./"${KREW}" install krew
)

export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
source ~/.bashrc

echo "installed kube ctx"

echo "------------------------------------------------------"
kubectl krew install ctx


