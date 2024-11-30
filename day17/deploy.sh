#!/bin/bash

../deploy.sh

kubectl apply -f ../day16/metric-server.yaml
