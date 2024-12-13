#!/bin/bash

kind create cluster --name=cka-new --config=cluster-config-v4.yaml

sleep 60

kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.29.1/manifests/calico.yaml
