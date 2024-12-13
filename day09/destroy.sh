#!/bin/bash

kubectl delete svc/nodeport-svc
kubectl delete svc/cluster-ip-svc
kubectl delete svc/lb-svc
kubectl delete deploy/nginx-deployment