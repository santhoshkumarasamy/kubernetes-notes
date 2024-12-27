Creating to pods and exposing them
```sh
k run nginx --image=nginx
k run nginx1 --image=nginx

k expose pod nginx --port=80 --target-port=80
l expose pod nginx1 --port=80 --target-port=80

k get pods
k get svc
```

so now lets check the connection

```
k exec -it nginx -- curl nginx1
```

this wil work only if the core dns service of the kubernetes cluster is running
if it is not running then the service name wont be resolved and a error will be thrown

so lets try that

the below command will remove the core dns pods
```
k scale deployment coredns -n kube-system --replicas=0
```
when you describe the codredns pod you can see that there is configmap attached as a volume
and if you describe that config map you will find the below cofigs
```
Data
====
Corefile:
----
.:53 {
    errors
    health {
       lameduck 5s
    }
    ready
    kubernetes cluster.local in-addr.arpa ip6.arpa {
       pods insecure
       fallthrough in-addr.arpa ip6.arpa
       ttl 30
    }
    prometheus :9153
    forward . /etc/resolv.conf {
       max_concurrent 1000
    }
    cache 30 {
       disable success cluster.local
       disable denial cluster.local
    }
    loop
    reload
    loadbalance
}
```
