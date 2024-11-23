![Docker Architecture](./notes/Docker-Architecture.png "Docker Architecture")


Node = Virtual machine

##### POD 

encapsulates the containers
one or more containers withing POD is possible

##### Master Node

API Server is the center of control plane (master node) - which recieves all the communication

Scheduler receives request from API server for Scheduling pods

"Controler managener" - is to make sure everything working fine and monitors the pods
Node Controler
namespace
deployment 
etc 

ETCD = is a Key value data stores
Stores everything - cluster info

Data is updated and retrieved by API server

##### Worker Node

Kubelet = get instruction from API server(control plane - master node) and enables communication between master and worker node
every worker node has kubelet

Kube-proxy

Enables networking within the nodes for enabling communication
has networking tables


##### kubectl

request -> authenticate -> validate -> api server

## Kubernetes Architecture

![image](https://github.com/piyushsachdeva/CKA-2024/assets/40286378/f15fbf28-5d18-4469-8a28-edd13678cbbf)

## Master/Control plane Node V/s Worker Node ( Node is nothing but a Virtual machine)

![image](https://github.com/piyushsachdeva/CKA-2024/assets/40286378/ef04ec3d-9f3a-4ac5-8a6a-31e877bfabf3)

## ApiServer :- Client interacts with the cluster using ApiServer

![image](https://github.com/piyushsachdeva/CKA-2024/assets/40286378/b8aeb299-9fc9-49da-9c87-0a6eb948ebd1)

## Scheduler: decide which pod to be scheduled on which node based on different factors

![image](https://github.com/piyushsachdeva/CKA-2024/assets/40286378/189208b6-a01e-4e3f-baf9-ae9a9d0f3daf)

## Controller Manager

![image](https://github.com/piyushsachdeva/CKA-2024/assets/40286378/9aece452-6d76-452f-9c89-0f7825151312)

## ETCD Server - Key value database that stores the cluster state and configuration

![image](https://github.com/piyushsachdeva/CKA-2024/assets/40286378/81e037e3-78f0-41a7-8589-f2b4ec3af511)

## Kubelet - Node-level agent that helps container management and receives instructions from Api server

![image](https://github.com/piyushsachdeva/CKA-2024/assets/40286378/bd178509-c49c-4206-bc11-147ac91d2713)

## Kube proxy - Pod to pod communication

![image](https://github.com/piyushsachdeva/CKA-2024/assets/40286378/e99ec3f5-5d73-4554-99d4-a7905d463f64)


### Installation of Kind

https://kind.sigs.k8s.io/


#### Kind


kind create cluster --name kubernets

kubectl cluster-info --context kubernets

kubectl get nodes

##### Multi node cluster

cluster-config.yaml
~~~
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
- role: worker
- role: worker
~~~
kind create cluster --name kubernets2 --config cluster-config.yaml

https://kubernetes.io/docs/reference/kubectl/quick-reference/

kind delete cluster --name kubernets
kubectl get nodes --context kind-kubernets2

kubectl config get-contexts


kubectl config set-contect kind-kubernets2

kubectl config use-contect kind-kubernets2


### day 7

Ways to create a pod

1. Imperative - kubectl commands
2. Declarative - config file - json / yaml - desired state of the object
    - kubectl apply / create

------

#### Create a nginx pod
 
Note : run the below command when a cluster is running
```
kubectl run nginx-pod --image=nginx:latest


kubectl explain pod


kubectl create -f kubernetes.yaml
```
![image](./notes/Already-pod-exist.png "Already exist error")

Deleting the runing pod
```
kubectl delete pod nginx-pod
```

kubectl apply command is used to update the existing pods details but it can also be used to create a new pod
```
kubectl apply -f kubernetes.yaml

```

Making error in config file
```
kubectl apply -f error.yaml
```
![image](./notes/day7-error-config.png)

ImagePullBackOff : there was an issue when pulling the image (cause in the file we messed it haha!)

Getting more detials
```
kubectl describe pod nginx-pod 
```

![image](./notes/day7-pod-describe.png)

Now how to fix it within the kubectl

```
kubectl edit pod nginx-pod

pod/nginx-pod edited

```

How to get inside the pod

```
kubectl exec -it nginx-pod -- sh
```

Creating a yaml file is time consuming, so how to make it easy

```
# Dry running 

kubectl run nginx --image=nginx --dry-run=client

# Outputing in yaml format u can change it to Json too

kubectl run nginx --image=nginx --dry-run=client -o yaml
kubectl run nginx --image=nginx --dry-run=client -o yaml > dry-run.yaml

```

Getting pod details
```
kubectl describe pod nginx-pod

Getting pod labels

kubectl get pods nginx-pod --show-label

How to get all the infromation about all the pods
    - this will give IP, NODE etc

kubectl get pods -o wide

this can also be used with get nodes command

kubectl get nodes -o wide

```

### Day 8

Replication controller 
- Application does not crash
- manages replica of a pod

The replication controller file basically have the details of the pods and no of replicas to be maintained
```
# Make sure no pods are running

kubectl apply -f ./replicationController.yaml

```

Difference between replication controller and replica set is
replication controller is a legacy version
Replication controller can only manage the pods which are created as part of it, existing pods can not be included

But with replica set we can manage the existing pods which are not part of it

Field for this use is 

```
selector:
  matchLabels:
    env: demo
```

So we have create a replica set config it throws the below error, saying the version is wrong
![](./day8/replica%20set%20iniatial%20erro.png)

But why

![](./day8/explain%20rs.png)

here this says the version is V1 which we had in the file.
So thats not the right version cause its part of the group "apps"

SO the version should be "apps/v1"

```
# delete the existing replica controller

kubectl delete rc nginx-rc

#or

kubectl delete rc/nginx-rc

```


Now how to change the replication number in replica set

1. Change the config file and apply
2. Edit the live replica set 
```
kubectl edit rs nginx-rs
```
3. Use the kubectl imperative way- using command line 
```
kubectl scale --replicas=3 rs nginx-rs
```

#### Deployment

for example you are running your v1 pods with replica set and you want to update the pods to v2

now the replica set will delete the all the pods and create new pods with newer version

this will disrupt the active user

So this were deployment comes in

"Deployment" wont remove all the pods at same time
it will start from a single pod
updating one pod and the network traffic will be redirected to other pods 
once the upgrade is completed it will move to next pod and the upgraded pod will be added to replica set 
it will start to recieve traffic

- undo the deployment
- roll out to particular version

#### Delete the existing replica set

```
kubectl delete rs nginx-rs
```

#### create deployment configs (manifest)

```
kubectl get deployments

#OR

kubectl get deploy

```

#### Get all the things created
```
kubectl get all
```

![](./notes/Get%20All.png)

#### How to change the image of the pod in the deployment

```
kubectl set image deploy/nginx-deployment \
nginx=nginx:1.9.1

#here the "nginx" means the container name defined the deployment config

kubectl describe deploy/nginx-deployment

kubectl edit deploy/nginx-deployment
```

#### Now we made changes, to view the history 

```
kubectl rollout history deploy/nginx-deployment
```
![](./notes/Rollout%20history.png)

#### Can we undo the changes

```
kubectl rollout undo deploy/nginx-deployment
```

### Day 9