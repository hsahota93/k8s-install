# Following this tutorial: https://www.cherryservers.com/blog/install-kubernetes-on-ubuntu

# 1. Disable swap
sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab

# 2. Change hostname (was done before)
# sudo hostnamectl set-hostname "ubuntu-dev-1"

# 3. Update /etc/host file
# Skipping this because I'm only doing 1 node so everything will just use localhost

# 4. Set up the IPV4 bridge on all nodes
# Skipping this because i'm only on 1 node

# 5. Install kubelet, kubeadm, and kubectl on each node
sudo nala update
sudo nala install -y apt-transport-https ca-certificates curl

# Create key store for kube
sudo mkdir /etc/apt/keyrings

# Getting public key from google
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-archive-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Update nala
sudo nala update

# Actually install kubelet, kubeadm and kubectl
sudo nala install -y kubelet=1.26.5-00 kubeadm=1.26.5-00 kubectl=1.26.5-00

# 6. Install Docker
sudo nala install -y docker.io

# Create containerd
sudo mkdir /etc/containerd
sudo sh -c "containerd config default > /etc/containerd/config.toml"
sudo sed -i 's/ SystemdCgroup = false/ SystemdCgroup = true/' /etc/containerd/config.toml

# Restart services
sudo systemctl restart containerd.service
sudo systemctl restart kubelet.service

# Start kubelet on startup
sudo systemctl enable kubelet.service

# 7. Initalize kube cluster 

# Download required images
sudo kubeadm config images pull

# Set the ip range for the pod network
sudo kubeadm init --pod-network-cidr=10.10.0.0/16

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# 8. Configure kubeclt and Calico
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/tigera-operator.yaml
curl https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/custom-resources.yaml -O
sed -i 's/cidr: 192\.168\.0\.0\/16/cidr: 10.10.0.0\/16/g' custom-resources.yaml
kubectl create -f custom-resources.yaml

# 9. Add worker nodes
# Skipped cause I only have 1 node


#Your Kubernetes control-plane has initialized successfully!
#
#To start using your cluster, you need to run the following as a regular user:
#
#  mkdir -p $HOME/.kube
#  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
#  sudo chown $(id -u):$(id -g) $HOME/.kube/config
#
#Alternatively, if you are the root user, you can run:
#
#  export KUBECONFIG=/etc/kubernetes/admin.conf
#
#You should now deploy a pod network to the cluster.
#Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
#  https://kubernetes.io/docs/concepts/cluster-administration/addons/
#
#Then you can join any number of worker nodes by running the following on each as root:
#
#kubeadm join 192.168.1.173:6443 --token iwvlau.i7zsnxpxpytl1pvx \
#        --discovery-token-ca-cert-hash sha256:9fe8bb79fce5e62fdcad2fd814fee98b7f2f443ed7bf06bf691204e5f663fb5f


# Maybe try this next time: https://www.smoothnet.org/kubernetes-on-linux-with-kubeadm/#requirements