#!/bin/bash

set -x

kubectl delete -f gatewayclass.yaml -n default

helm delete gateway-api-controller -n aws-application-networking-system

eksctl delete iamserviceaccount --cluster=${CLUSTER_NAME} --namespace=aws-application-networking-system --name=gateway-api-controller

kubectl delete ns aws-application-networking-system

# Get all the cname record sets in the hosted zone
RECORD_SETS=$(aws route53 list-resource-record-sets --hosted-zone-id $PRIVATE_HOSTED_ZONE_ID --query "ResourceRecordSets[?Type == 'CNAME']" --region ${AWS_REGION})

# Loop through each record set and delete it
for record_set in $(echo "${RECORD_SETS}" | jq -r '.[] | @base64'); do
  json=$(echo "${record_set}" | base64 --decode | jq -r '.')
  aws route53 change-resource-record-sets --hosted-zone-id $PRIVATE_HOSTED_ZONE_ID --change-batch "{\"Changes\":[{\"Action\":\"DELETE\",\"ResourceRecordSet\":$json}]}"
done

# Delete the hosted zone
aws route53 delete-hosted-zone --id "${PRIVATE_HOSTED_ZONE_ID}" --region "${AWS_REGION}"
