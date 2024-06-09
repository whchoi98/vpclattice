
#!/bin/bash
echo "export ACCOUNT_ID=$(aws sts get-caller-identity --region ap-northeast-2 --output text --query Account)" | tee -a ~/.bash_profile
#echo "export AWS_REGION=$(curl -s 169.254.169.254/latest/dynamic/instance-identity/document | jq -r '.region')" | tee -a ~/.bash_profile
echo "export AWS_REGION=$(TOKEN=`curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"` && curl -H "X-aws-ec2-metadata-token: $TOKEN" -v curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | jq .region -r)" | tee -a ~/.bash_profile
echo "export CLUSTER1_NAME=c1" | tee -a ~/.bash_profile
echo "export CLUSTER2_NAME=c2" | tee -a ~/.bash_profile
export VPC_NAME='LatticeWorkshop-Clients-VPC'
export VPC2_NAME='LatticeWorkshop-Rates-VPC'
echo "export VPC_NAME=${VPC_NAME}" | tee -a ~/.bash_profile
echo "export VPC2_NAME=${VPC2_NAME}" | tee -a ~/.bash_profile
export LATTICE_DOMAIN_NAME="lattice.io"
echo "export LATTICE_DOMAIN_NAME=${LATTICE_DOMAIN_NAME}" | tee -a ~/.bash_profile
echo "export EKS_VERSION='1.27'" | tee -a ~/.bash_profile
echo "export NODE_INSTANCE_TYPE='m5.xlarge'" | tee -a ~/.bash_profile

#echo "export VPC2_NAME='LatticeWorkshop Rates VPC' | tee -a ~/.bash_profile
#echo "export VPC2_FILTER="Name=tag:Name,Values='$VPC2_NAME'" | tee -a ~/.bash_profile
#echo "export ASSETS_HOSTNAME="assets-${CLUSTER1_NAME}" | tee -a ~/.bash_profile
#echo "export CART_HOSTNAME="cart-${CLUSTER1_NAME}" | tee -a ~/.bash_profile
#echo "export CATALOG_HOSTNAME="catalog-${CLUSTER1_NAME}" | tee -a ~/.bash_profile
#echo "export CHECKOUT_HOSTNAME="checkout-${CLUSTER2_NAME}" | tee -a ~/.bash_profile
#echo "export ASSETS_FQDN="${ASSETS_HOSTNAME}.${LATTICE_DOMAIN_NAME}" | tee -a ~/.bash_profile
#echo "export CART_FQDN="${CART_HOSTNAME}.${LATTICE_DOMAIN_NAME}" | tee -a ~/.bash_profile
#echo "export CATALOG_FQDN="${CATALOG_HOSTNAME}.${LATTICE_DOMAIN_NAME}" | tee -a ~/.bash_profile
#echo "export CHECKOUT_FQDN="${CHECKOUT_HOSTNAME}.${LATTICE_DOMAIN_NAME}" | tee -a ~/.bash_profile




