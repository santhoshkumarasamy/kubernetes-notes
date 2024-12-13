Create two security group and 3 intances

### Run the below steps on the Master VM
1) SSH into the Master EC2 server

2)  Disable Swap using the below commands
```bash
swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
```
3) Forwarding IPv4 and letting iptables see bridged traffic

OverlayFS is a filesystem that allows one filesystem to be layered on top of another, which is crucial for container technologies like Docker and Kubernetes. It enables efficient and lightweight container storage by combining multiple layers of filesystem images.

br_netfilter is used for enabling network filtering on Linux bridge devices, which is necessary for Kubernetes networking (and other containerized systems). When this module is loaded, it ensures that network traffic between containers, pods, and other network devices is correctly managed and filtered.

net.bridge.bridge-nf-call-iptables = 1:

This enables the bridge-nf-call-iptables setting, which ensures that network traffic on bridge devices is passed through iptables for filtering.
This is important for container networking in Kubernetes. Without this setting, traffic between containers on different hosts may not be properly handled by iptables, which is necessary for network policies and firewall rules to apply correctly.
net.bridge.bridge-nf-call-ip6tables = 1:

Similar to the previous setting, this enables the bridge-nf-call-ip6tables setting, ensuring that IPv6 traffic on bridge devices is passed through ip6tables.
This is also important for Kubernetes or any containerized environment that may use IPv6 for container networking.
net.ipv4.ip_forward = 1:

This enables IP forwarding for IPv4, allowing the system to forward network packets between network interfaces.
This is required for Kubernetes networking, as it allows containers (and pods) to communicate with each other across different nodes. It enables the routing of traffic between nodes, which is crucial for a functioning Kubernetes cluster.

```
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# sysctl params required by setup, params persist across reboots
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Apply sysctl params without reboot
sudo sysctl --system

# Verify that the br_netfilter, overlay modules are loaded by running the following commands:
lsmod | grep br_netfilter
lsmod | grep overlay

# Verify that the net.bridge.bridge-nf-call-iptables, net.bridge.bridge-nf-call-ip6tables, and net.ipv4.ip_forward system variables are set to 1 in your sysctl config by running the following command:
sysctl net.bridge.bridge-nf-call-iptables net.bridge.bridge-nf-call-ip6tables net.ipv4.ip_forward
```

4) Install container runtime

```
curl -LO https://github.com/containerd/containerd/releases/download/v1.7.14/containerd-1.7.14-linux-amd64.tar.gz
sudo tar Cxzvf /usr/local containerd-1.7.14-linux-amd64.tar.gz
curl -LO https://raw.githubusercontent.com/containerd/containerd/main/containerd.service
sudo mkdir -p /usr/local/lib/systemd/system/
sudo mv containerd.service /usr/local/lib/systemd/system/
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml
sudo systemctl daemon-reload
sudo systemctl enable --now containerd

# Check that containerd service is up and running
systemctl status containerd
```

5) Install runc

```
curl -LO https://github.com/opencontainers/runc/releases/download/v1.1.12/runc.amd64
sudo install -m 755 runc.amd64 /usr/local/sbin/runc
```

6) install cni plugin

```
curl -LO https://github.com/containernetworking/plugins/releases/download/v1.5.0/cni-plugins-linux-amd64-v1.5.0.tgz
sudo mkdir -p /opt/cni/bin
sudo tar Cxzvf /opt/cni/bin cni-plugins-linux-amd64-v1.5.0.tgz
```

7) Install kubeadm, kubelet and kubectl

```
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gpg

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt-get install -y kubelet=1.29.6-1.1 kubeadm=1.29.6-1.1 kubectl=1.29.6-1.1 --allow-downgrades --allow-change-held-packages
sudo apt-mark hold kubelet kubeadm kubectl

kubeadm version
kubelet --version
kubectl version --client
```
>Note: The reason we are installing 1.29, so that in one of the later task, we can upgrade the cluster to 1.30

8) Configure `crictl` to work with `containerd`

```
sudo crictl config runtime-endpoint unix:///var/run/containerd/containerd.sock
chmod 775 /var/run/containerd/containerd.sock
```

9) initialize control plane
Here for the apiserver ardvertise 
You should use the internal IP address of the AWS instance for the --apiserver-advertise-address during the kubeadm init step, as it ensures proper communication between nodes within the VPC, enhances security, and avoids exposing the Kubernetes API server to the public internet

```
sudo kubeadm init --pod-network-cidr=192.168.0.0/16 --apiserver-advertise-address=172.31.89.68 --node-name master
```
>Note: Copy the copy to the notepad that was generated after the init command completion, we will use that later.

10) Prepare `kubeconfig`

```bash
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```
11) Install calico 

```bash
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.0/manifests/tigera-operator.yaml

curl https://raw.githubusercontent.com/projectcalico/calico/v3.28.0/manifests/custom-resources.yaml -O

kubectl apply -f custom-resources.yaml
```

### Perform the below steps on both the worker nodes

- Perform steps 1-8 on both the nodes
- Run the command generated in step 9 on the Master node which is similar to below

```
sudo kubeadm join 172.31.71.210:6443 --token xxxxx --discovery-token-ca-cert-hash sha256:xxx
```
- If you forgot to copy the command, you can execute below command on master node to generate the join command again

```
kubeadm token create --print-join-command
```

