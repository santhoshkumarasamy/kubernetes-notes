#!/bin/bash

kubectl delete svc/mydb
kubectl delete svc/myservice
kubectl delete deploy/db-deploy
kubectl delete deploy/nginx-deploy
kubectl delete pod/app-pod