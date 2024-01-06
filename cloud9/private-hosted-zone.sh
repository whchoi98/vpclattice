#!/bin/bash

source ./helper.sh

PRIVATE_HOSTED_ZONE_ID=$(aws route53 create-hosted-zone --name "${LATTICE_DOMAIN_NAME}" --caller-reference "$(date +%Y%m%d%H%M%S)" --vpc VPCRegion="${AWS_REGION}",VPCId="${VPC1_ID}" --hosted-zone-config PrivateZone=true --query 'HostedZone.Id' --output text)

export_to_env PRIVATE_HOSTED_ZONE_ID "${PRIVATE_HOSTED_ZONE_ID}"

aws route53 associate-vpc-with-hosted-zone --hosted-zone-id "${PRIVATE_HOSTED_ZONE_ID}" --vpc VPCRegion="${AWS_REGION}",VPCId="${VPC2_ID}"
