#!/bin/bash

#source ./helper.sh
source ~/.bash_profile

cat << EOF > ~/environment/vpclattice/cloud9/lattice_eks02.yaml
---
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig

metadata:
  name: ${CLUSTER2_NAME}
  region: ${AWS_REGION}
  version: "${EKS_VERSION}"

vpc: 
  id: ${CLUSTER_VPC_ID}
  subnets:
    public:
      PublicSubnet01:
        az: ${AWS_REGION}a
        id: ${CLIENTS_PublicSubnet01}
      PublicSubnet02:
        az: ${AWS_REGION}b
        id: ${CLIENTS_PublicSubnet02}
      PublicSubnet03:
        az: ${AWS_REGION}c
        id: ${CLIENTS_PublicSubnet03}
    private:
      PrivateSubnet01:
        az: ${AWS_REGION}a
        id: ${CLIENTS_PrivateSubnet01}
      PrivateSubnet02:
        az: ${AWS_REGION}b
        id: ${CLIENTS_PrivateSubnet02}
      PrivateSubnet03:
        az: ${AWS_REGION}c
        id: ${CLIENTS_PrivateSubnet03}

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
  minSize: 3
  maxSize: 3
  desiredCapacity: 3
  instanceType: ${NODE_INSTANCE_TYPE}
  subnets:
    - ${CLIENTS_PrivateSubnet01}
    - ${CLIENTS_PrivateSubnet02}
    - ${CLIENTS_PrivateSubnet03}
  volumeSize: 20
  volumeType: gp3
  privateNetworking: true
  ssh:
    enableSsm: true
  labels:
    nodegroup-type: "${private_mgmd_node}"
  tags:
    nodegroup-role: workshop
  iam:
    attachPolicyARNs:
    withAddonPolicies:
      autoScaler: true
      cloudWatch: true
      ebs: true
      fsx: true
      efs: true

EOF


cd ~/environment/vpclattice/cloud9/
eksctl create cluster -f lattice_eks01.yaml --dry-run