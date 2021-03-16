# Terraform でvSphere環境に Kubernetesをデプロイ
オンプレのvSphere環境に対して、事前に作成済みのOSテンプレートを利用して、仮想マシンをデプロイ後、多少の手動作業を行いKuberadmによるKubernetesクラスターを作成します。    
TFファイルについて、理解しやすいようにわけて構成しています。  

- terraform.tfvars : 環境のパラメータを指定
- variable.tf : *terraform.tfvars*を元に変数を指定
- vsphere.tf : Terraform実行タイミングでvSphere環境を定義
- haproxy.tf : HAProxyを構成
- kubenode.tf : KubernetesのMaster/Worker Nodeを構成
- output.tf : terraform apply後に作成されたVMを出力

## terraform.tfvars
**編集が必要です**
デプロイする環境に合わせてパラメータを調整します。  

### DNSについて
パブリックなDNS(8.8.8.8など)は利用せず、ローカルで作成しているものを利用してください。  
kubeadmを使ったk8sのインストールを行った後に問題が発生する場合があります。  

### ノードの台数について
HAProxyとKubernetes Nodeの台数は指定されている
- HAProxy: 1
- Kubernetes Node: 6 
で指定をしてください。デフォルト値がその設定です。  

#### 対象の設定  
```
prov_vm_num           = 6  
prov_vm_num_ha        = 1 
```

## variable.tf
*terraform.tfvars*を元に変数を指定します。

## vsphere.tf
vSphereへの接続にために必要な構成情報を設定します。

## haproxy.tf
Kubernetesをマルチノードで構成する場合にLoad Balancerが必要になるため、HAProxyを構成します。  
VMのベースイメージは CentOS7.9です。
**※ 台数をスケールできる設定にしていないため必ず1台で構成**

## kubenode.tf
KubernetesのノードとするVMを作成します。  
VMのベースイメージは CentOS7.9です。
**※ 台数をスケールできる設定にしていないため必ず6台で構成**

## configure.tf
/etc/hostsへの書き込みとhaproxyとkuberadmの設定ファイルを作成します。

## output.tf
terraform apply が完了したタイミングで作成したVMとVMのIPアドレスがOutputとして出力されます。  





