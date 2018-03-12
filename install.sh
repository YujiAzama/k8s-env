#!/bin/bash

if [ ${EUID:-${UID}} != 0 ]; then
    echo 'Not superuser.'
    exit
fi

# Install Docker CE
echo "Install Docker CE"
apt-get remove docker docker-engine docker.io

apt-get update

apt-get install apt-transport-https ca-certificates curl software-properties-common -y

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

apt-key fingerprint 0EBFCD88

add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

apt-get update

apt-get install -y docker-ce

# Install kubectl via curl
echo "Install kubectl"
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl

chmod +x ./kubectl

mv ./kubectl /usr/local/bin/kubectl

# Install kubelet and kubeadm
echo "Install kubelet and kubeadm"
apt-get update && apt-get install -y apt-transport-https

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -

cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF

apt-get update

apt-get install -y kubelet kubeadm

# Off fail Swap
sed -i -e "5i Environment=\"KUBELET_EXTRA_ARGS=--fail-swap-on=false\"" /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
systemctl daemon-reload
systemctl restart kubelet

# Reset kubeadm
kubeadm reset

echo "source <(kubectl completion bash)" >> /etc/profile
source <(kubectl completion bash)

echo "Install done."
