#!/bin/bash

kubectl apply -f ../day8/deployment.yaml
kubectl apply -f ./nodeport.yaml
kubectl create -f ./clusterIp.yaml
kubectl create -f ./loadBalancer.yaml