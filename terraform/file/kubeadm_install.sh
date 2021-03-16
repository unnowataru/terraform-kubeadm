#!/bin/sh

sudo swapoff -a
sudo sed -i '/swap/s/^/#/' /etc/fstab

sudo systemctl stop firewalld && systemctl disable firewalld

sudo setenforce 0
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

sudo yum install -y yum-utils device-mapper-persistent-data lvm2
sudo yum-config-manager --add-repo \
  https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install -y containerd.io-1.2.13 docker-ce-19.03.11 docker-ce-cli-19.03.11
sudo mkdir /etc/docker
sudo cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2",
  "storage-opts": [
    "overlay2.override_kernel_check=true"
  ]
}
EOF
sudo mkdir -p /etc/systemd/system/docker.service.d
sudo systemctl daemon-reload
sudo systemctl restart docker
sudo systemctl enable docker
sudo modprobe br_netfilter

sudo cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

sudo sysctl --system

sudo cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kube*
EOF

sudo yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
sudo yum install -y wget bash-completion
sudo mkdir /kubeadm && cd /kubeadm
sudo touch /kubeadm/kubeadm-config.yaml
sudo wget https://docs.projectcalico.org/manifests/calico.yaml
sudo echo "source <(kubectl completion bash)" >> ~/.bashrc 
sudo systemctl enable --now kubelet

exit 0
