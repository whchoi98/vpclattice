#!/bin/bash

set -x

kubectl delete httproute c1-assets -n assets

kubectl delete httproute c1-carts -n carts

kubectl delete httproute c1-catalog -n catalog

kubectl delete gateway etail-store-gateway -n default

kubectl delete -f rs-deploy-app-c1.yaml 

# kubectl delete -f rs-deploy-app-c2.yaml 
