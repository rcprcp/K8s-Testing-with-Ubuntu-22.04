#!/bin/bash -x

# $1 hostname $2 ip

# $1 hostname $2 ip
# if [ -z "$1" ]; then
#     echo "Empty Variable 1 - hostname"
#     exit 1
# fi


# if [ -z "$2" ]; then
#     echo "Empty Variable 2 - ip addrress of this node"
#     exit 2
# fi


# sudo hostnamectl set-hostname $1
# sudo cat <<EOF | sudo tee /etc/hosts
# $1 $2 
# EOF

sudo ufw enable
sudo ufw allow "OpenSSH"

sudo ufw allow 2379:2380/tcp
sudo ufw allow 6443/tcp
sudo ufw allow 10250/tcp
sudo ufw allow 10257/tcp
sudo ufw allow 10259/tcp

sudo systemctl restart ufw
sudo ufw status

# this is so support the worker nodes.
sudo ufw allow 30000:32767/tcp

sudo modprobe overlay
sudo modprobe br_netfilter

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sudo sysctl --system

lsmod | grep br_netfilter
#swap does not exist - no worries.

# install containerd
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
sudo apt install containerd.io

# reconfigure containerd
sudo systemctl stop containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml

sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml

sudo systemctl start containerd
sudo systemctl is-enabled containerd

# prepare to install Kubernetes packages:
sudo apt install apt-transport-https ca-certificates curl -y

sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt update

# install Kubernetes packages:
sudo apt install kubelet kubeadm kubectl -y
##sudo apt-mark hold kubelet kubeadm kubectl

# install flannel...
sudo mkdir -p /opt/bin/
sudo curl -fsSLo /opt/bin/flanneld https://github.com/flannel-io/flannel/releases/download/v0.19.0/flanneld-amd64
sudo chmod +x /opt/bin/flanneld

# pull required images
sudo kubeadm config images pull

echo "#--- if this is the master node... sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=<IP> --cri-socket=unix:///run/containerd/containerd.sock"
echo "#--- kubectl get pods --all-namespaces"
