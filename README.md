# K8s Testing with Ubuntu 22.04 on an EC2 instance

This script installed the required software to run a basic K8s cluster.

Spin an EC2 instance with 2 (or greater) CPUs and 2g (or greater memory).

Update the system to get any necessaery OS or application updates:

``` shell
$ sudo apt update
$ sudo apt upgrade
$ sudo reboot
```

Install this script - K8sInstall.sh - in ubuntu's home directory, then run it as ubuntu.

If all does well, you'll see the suggestion to bring up the control node via  -

Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

Alternatively, if you are the root user, you can run:

  export KUBECONFIG=/etc/kubernetes/admin.conf

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

Then you can join any number of worker nodes by running the following on each as root:

``` shell
kubeadm join 172.31.77.40:6443 --token az66cl.ioresgghjzil3hr2 \
	--discovery-token-ca-cert-hash sha256:580fecefda536d44c05859763e3264d1eb28666a1f1772493dc66c1cbd239f3f 
```

Verify that the master node is running.

``` shell
ubuntu@ip-172-31-77-40:~$ kubectl get nodes 
NAME              STATUS     ROLES           AGE     VERSION
ip-172-31-77-40   NotReady   control-plane   7m12s   v1.25.3
ubuntu@ip-172-31-77-40:~$ kubectl get pods -A
NAMESPACE     NAME                                      READY   STATUS    RESTARTS   AGE
kube-system   coredns-565d847f94-nkcx4                  0/1     Pending   0          7m3s
kube-system   coredns-565d847f94-qwbp7                  0/1     Pending   0          7m3s
kube-system   etcd-ip-172-31-77-40                      1/1     Running   0          7m16s
kube-system   kube-apiserver-ip-172-31-77-40            1/1     Running   0          7m16s
kube-system   kube-controller-manager-ip-172-31-77-40   1/1     Running   0          7m15s
kube-system   kube-proxy-vggjz                          1/1     Running   0          7m3s
kube-system   kube-scheduler-ip-172-31-77-40            1/1     Running   0          7m18s
ubuntu@ip-172-31-77-40:~$ 
```

