#!/bin/bash
# command ./eksctl_shell.sh
# eksctl yaml 실행

source ~/.bash_profile
cat << EOF > ~/environment/vpclattice/cloud9/vpclattice_eks.yaml
---
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig

metadata:
  name: ${CLUSTER_NAME}
  region: ${AWS_REGION}
  version: "${EKS_VERSION}"  
vpc: 
  id: ${vpc_ID}
  subnets:
    public:
      PublicSubnet01:
        az: ${AWS_REGION}a
        id: ${PublicSubnet01}
      PublicSubnet02:
        az: ${AWS_REGION}b
        id: ${PublicSubnet02}
      PublicSubnet03:
        az: ${AWS_REGION}c
        id: ${PublicSubnet03}
    private:
      PrivateSubnet01:
        az: ${AWS_REGION}a
        id: ${PrivateSubnet01}
      PrivateSubnet02:
        az: ${AWS_REGION}b
        id: ${PrivateSubnet02}
      PrivateSubnet03:
        az: ${AWS_REGION}c
        id: ${PrivateSubnet03}

managedNodeGroups:
- name: nodegroup
  minSize: 3
  maxSize: 6
  desiredCapacity: 3
  instanceType: ${NODE_INSTANCE_TYPE}
  subnets:
    - ${PrivateSubnet01}
    - ${PrivateSubnet02}
    - ${PrivateSubnet03}
  privateNetworking: true
  ssh:
    enableSsm: true
  labels: {role: workshop}
  tags:
    nodegroup-role: workshop
  volumeSize: 200
  volumeType: gp3
    amiFamily: AmazonLinux2
  iam:
    attachPolicyARNs:
    withAddonPolicies:
        autoScaler: true
        cloudWatch: true
        ebs: true
        fsx: true
        efs: true        
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
EOF
