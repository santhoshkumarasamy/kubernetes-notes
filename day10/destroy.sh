#!/bin/bash

kubectl delete svc/svc-default
kubectl delete svc/svc-demo -n demo
kubectl delete deploy/nginx-test
kubectl delete deploy/nginx-deploy -n demo
