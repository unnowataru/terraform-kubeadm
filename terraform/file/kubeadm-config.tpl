cat <<-EOF > /kubeadm/kubeadm-config.yaml
apiVersion: kubeadm.k8s.io/v1beta2
kind: ClusterConfiguration
kubernetesVersion: stable
controlPlaneEndpoint: "${k8s_domain}.${pram_domain_name}:6443"
networking:
  podSubnet: 192.168.0.0/16
EOF