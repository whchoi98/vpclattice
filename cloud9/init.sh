#!/bin/bash

source ./helper.sh

echo "Start Installation and Configuration of Cloud9"
cd ~

#sudo yum -y update
sudo yum -y update --skip-broken

echo "AWS CLI Version"

aws --version

aws configure set default.region "${AWS_REGION}"
aws configure get default.region

sudo yum -y install jq gettext bash-completion moreutils

wget https://github.com/mikefarah/yq/releases/download/v4.33.2/yq_linux_amd64

chmod +x ./yq_linux_amd64

sudo mv ./yq_linux_amd64 /usr/local/bin/yq

yq --version

echo "------------------------------------------------------"

cd ~
curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.27.13/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
source <(kubectl completion bash)
echo "source <(kubectl completion bash)" >> ~/.bashrc
kubectl version --short --client
source /etc/bash_completion

sudo yum -y install jq gettext bash-completion moreutils
for command in kubectl jq envsubst aws
  do
    which $command &>/dev/null && echo "$command in path" || echo "$command NOT FOUND"
  done
 
  echo 'yq() {
  docker run --rm -i -v "${PWD}":/workdir mikefarah/yq "$@"
}' | tee -a ~/.bashrc && source ~/.bashrc

K9S_VERSION=$(curl -s https://api.github.com/repos/derailed/k9s/releases/latest | jq -r '.tag_name')
curl -sL https://github.com/derailed/k9s/releases/download/${K9S_VERSION}/k9s_Linux_amd64.tar.gz | sudo tar xfz - -C /usr/local/bin k9s

curl -Lo ec2-instance-selector https://github.com/aws/amazon-ec2-instance-selector/releases/download/v2.4.1/ec2-instance-selector-linux-amd64
chmod +x ec2-instance-selector

sudo mv ec2-instance-selector /usr/local/bin/
ec2-instance-selector --version

echo "Installed EC2 instance selector"

echo "------------------------------------------------------"

echo export AWS_REGION=$(curl -s 169.254.169.254/latest/dynamic/instance-identity/document | jq -r '.region') >> ~/env.sh

echo export ACCOUNT_ID=$(aws sts get-caller-identity --output text --query Account)  >> ~/env.sh

#export C9_IDS=($(aws cloud9 list-environments | jq -r '.environmentIds | join(" ")'))
#export CLOUD9_ID=($(aws cloud9 describe-environments --environment-ids ${C9_IDS} | jq -r '.environments[] | select(.name == "LatticeCloud9") | .id'))

#echo export CLOUD9_ID=${C9_IDS} >> ~/env.sh
echo "Session manager install"

echo "------------------------------------------------------"
curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_64bit/session-manager-plugin.rpm" -o "session-manager-plugin.rpm"
sudo yum install -y session-manager-plugin.rpm

echo "eksctl install"
echo "------------------------------------------------------"
# eksctl 설정 
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin
# eksctl 자동완성 - bash
. <(eksctl completion bash)
eksctl version

echo "Downloaded and installed helm v3.14.4"

echo "------------------------------------------------------"

# curl -sSL https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash

wget https://get.helm.sh/helm-v3.14.4-linux-amd64.tar.gz
tar -zxvf helm-v3.14.4-linux-amd64.tar.gz
sudo cp linux-amd64/helm /usr/local/bin/helm

helm version --short

helm repo add stable https://charts.helm.sh/stable
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

source ~/.bash_profile

