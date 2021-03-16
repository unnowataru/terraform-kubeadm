# TerraformとKubeadmを使ってvSphere上により簡単に構成する手順 

vSphere上にOSテンプレートを利用してVMを展開し、そのVM上にKubeadmを実行する手前の状態までをTerraformで構成する

## 手順概要  

1. githubからダウンロード
2. vSphere上にOSテンプレートを作成
3. *terraform.tfvars* を編集  
4. *terraform init* でモジュールをダウンロード
5. *terraform plan* で作成されるリソースの確認
6. *terraform apply* でリソースを作成
7. *kubeadm init* を実行してKubernetesクラスターをセットアップする
8. CalicoをデプロイしてNetworkを構成する 

## Githubからダウンロード  
コードをGithubからダウンロードしておきます。  

## vSphere上にOSテンプレートを作成  
terraformではISOイメージからOSを構成することはできません。  
いくつか方法はありますが今回は事前にvSphere上にOSテンプレートを作成しておき、OSテンプレートを元にVMを構成します。  

OSテンプレートの作成方法はvSphereのVMにOSをインストール後、パッケージをインストールし、テンプレート化するのみです。  
Terraformで扱えるように下記の作業を行っておきます。  

| 設定 | 値 |
|:----|:----|
| vSphere上のテンプレート名 | template_centos7.9.2009 | 
| OS | CentOS7.9 |
| ISO Image | CentOS-7-x86_64-DVD-2009.iso | 
| SW Package | Perl |

※ `yum install update -y` を実行しておいてください。  

## *terraform.tfvars* を編集
terraformで接続するvSphere環境の情報や作成するVMの台数やスペック情報を指定します。
台数については編集しないでください。  


## *terraform init* でモジュールをダウンロード
Terraformを実行する前のお作法になるので実施します。  

コマンドは `terraform init` です。

## *terraform plan* で作成されるリソースの確認
TerraformのTFでなにが作成されるかを出力することができます。  
エラーが発生する場合はここで修正を行います。  

コマンドは `terraform plan` です。

## *terraform apply* でリソースを作成
リソースを作成します。

コマンドは 'terraform apply` です。

### apply 完了後
下記のように作成されたVMとそのVMのIPが表示されます。
```
Apply complete! Resources: 21 added, 0 changed, 0 destroyed.

Outputs:

ha_proxy = [
  "kskube-000",
]
ha_proxy_ip = [
  "10.42.117.110",
]
pkubernetes_node = [
  "kskube-001",
  "kskube-002",
  "kskube-003",
  "kskube-004",
  "kskube-005",
  "kskube-006",
]
kubernetes_node_ip = [
  "10.42.117.111",
  "10.42.117.112",
  "10.42.117.113",
  "10.42.117.114",
  "10.42.117.115",
  "10.42.117.116",
]
```


## *kubeadm init* を実行してKubernetesクラスターをセットアップする  
※ここからは作成したVM上で操作で作業します。  
※時間を空けず実行してください。  

作成されたVMの ***-001** にSSHでログインします。ログインユーザー、パスワードはVMテンプレートで指定した値です。  

### Kubernetesの役割設定  
下記のようにノードを構成します。  

| 役割 | ノード |
|:----|:----|
| Master Node (Control Plane) | *-001~003 |
| Worker Node | *-004~006 |  

### Master node 1台目 
***-001**のホストにSSHログインした状態から作業をします。  
下記コマンドを実行します。

`kubeadm init --config=/kubeadm/kubeadm-config.yaml --upload-certs | tee kubeadm-init.out`

完了後に表示される情報をもとに各ノードで作業を実行します。

#### 完了後に出力されるサンプル

```
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

You can now join any number of the control-plane node running the following command on each as root:

  kubeadm join cluster11.ks-pic.local:6443 --token vp02r7.2z3vt14njmrlrcne \
    --discovery-token-ca-cert-hash sha256:fd29a43dde5fcc2229139f1150794625e17b23cc90261b2ac7890ca8ddf21db5 \
    --control-plane --certificate-key 55f7c88e0f49c2e9639195f92201361d000f739c7214109be73c40bd5ddace4f

Please note that the certificate-key gives access to cluster sensitive data, keep it secret!
As a safeguard, uploaded-certs will be deleted in two hours; If necessary, you can use
"kubeadm init phase upload-certs --upload-certs" to reload certs afterward.

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join cluster11.ks-pic.local:6443 --token vp02r7.2z3vt14njmrlrcne \
    --discovery-token-ca-cert-hash sha256:fd29a43dde5fcc2229139f1150794625e17b23cc90261b2ac7890ca8ddf21db5
```

### Master Node 2,3台目  
**-002** と **-003** のノードで実行します。出力した結果の 
*You can now join any number of the control-plane node running the following command on each as root:*
の下部にあるコマンドを各ノードにSSHでログイン後、実行します。  

- サンプル
```
 kubeadm join cluster11.ks-pic.local:6443 --token vp02r7.2z3vt14njmrlrcne \
    --discovery-token-ca-cert-hash sha256:fd29a43dde5fcc2229139f1150794625e17b23cc90261b2ac7890ca8ddf21db5 \
    --control-plane --certificate-key 55f7c88e0f49c2e9639195f92201361d000f739c7214109be73c40bd5ddace4f
```

### Worker Node 全台  
**-004** , **-005** , **-006** のノードで実行します。出力した結果の
*Then you can join any number of worker nodes by running the following on each as root:*  
の下部にあるコマンドを各ノードにSSHでログイン後、実行します。

- サンプル
```
kubeadm join cluster11.ks-pic.local:6443 --token vp02r7.2z3vt14njmrlrcne \
    --discovery-token-ca-cert-hash sha256:fd29a43dde5fcc2229139f1150794625e17b23cc90261b2ac7890ca8ddf21db5
```

### Kubeconfigの設定  
**-001**のノードからKubernetesの操作ができるように Kubeconfig を設定します。  

```
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```


## CalicoをデプロイしてNetworkを構成する   
Kubernetesのネットワークをデプロイします。  

### ノードの状態確認
ノードの状態を確認し、*NotReady*であることを確認します。  
`kubectl get node`

```
# kubectl get node
NAME         STATUS     ROLES                  AGE     VERSION
kskube-001   NotReady   control-plane,master   10m     v1.20.4
kskube-002   NotReady   control-plane,master   9m32s   v1.20.4
kskube-003   NotReady   control-plane,master   8m29s   v1.20.4
kskube-004   NotReady   <none>                 8m44s   v1.20.4
kskube-005   NotReady   <none>                 8m15s   v1.20.4
kskube-006   NotReady   <none>                 8m3s    v1.20.4
```

### デプロイ
下記コマンドを実行します。  

`kubectl apply -f /kubeadm/calico.yaml`

### ノードの状態確認  
改めてノードの状態を確認し、*Ready*となっていることを確認します。  
`kubectl get node`

```
# kubectl get node
NAME         STATUS   ROLES                  AGE   VERSION
kskube-001   Ready    control-plane,master   12m   v1.20.4
kskube-002   Ready    control-plane,master   11m   v1.20.4
kskube-003   Ready    control-plane,master   10m   v1.20.4
kskube-004   Ready    <none>                 10m   v1.20.4
kskube-005   Ready    <none>                 10m   v1.20.4
kskube-006   Ready    <none>                 10m   v1.20.4
```


以上
