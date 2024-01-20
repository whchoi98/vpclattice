#!/bin/bash

source ./helper.sh

echo "Start Installation and Configuration of Cloud9"

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

for command in jq envsubst aws
  do
    which $command &>/dev/null && echo "$command in path" || echo "$command NOT FOUND"
  done


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

log_text "Success" "Installed of CLI tools successful"
