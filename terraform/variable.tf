#Variable
##Define Variables for Platform
variable "vsphere_user" {}           #vsphereのユーザー名
variable "vsphere_password" {}       #vsphereのパスワード
variable "vsphere_vc_server" {}         #vCenterのFQDN/IPアドレス
variable "vsphere_datacenter" {}     #vsphereのデータセンター
variable "vsphere_datastore" {}      #vsphereのデータストア
variable "vsphere_cluster" {}        #vsphereのクラスター
variable "vsphere_network_1" {}        #vsphereのネットワーク
variable "vsphere_resource_pool" {}  #ResourcePool名
variable "vsphere_template_name" {}  #プロビジョニングするテンプレート

/*
##ESXホストやネットワークを追加した場合はコメントアウトをはずす
variable "vsphere_host_1" {}         #ESXhost1
variable "vsphere_host_2" {}         #ESXhost2
variable "vsphere_host_3" {}         #ESXhost3
variable "vsphere_host_4" {}         #ESXhost4
variable "vsphere_network_2" {}        #vsphereのネットワーク
*/

##Network param
variable "pram_domain_name" {}         #仮想マシンが参加するドメイン名
variable "pram_ipv4_subnet" {}         #仮想マシンのネットワークのサブネット
variable "pram_ipv4_gateway" {}        #仮想マシンのネットワークのデフォルトゲートウェイ
variable "pram_dns_server" {}          #仮想マシンが参照するDNSサーバー
variable "pram_ipv4_class" {}          #利用できるクラスCの値を指定
variable "pram_ipv4_host" {}           #プロビジョニングする仮想マシンに割り当てるIPアドレスの最初の値

##Kubernetes node spec
variable "prov_vm_num" {}            #プロビジョニングする仮想マシンの数
variable "prov_vmname_prefix" {}     #プロビジョニングする仮想マシンの接頭語
variable "prov_cpu_num" {}           #プロビジョニングする仮想マシンのCPUの数
variable "prov_mem_num" {}           #プロビジョニングする仮想マシンのメモリのMB

##HA Proxy Spec
variable "prov_vm_num_ha" {}            #プロビジョニングする仮想マシンの数
variable "prov_vmname_prefix_ha" {}     #プロビジョニングする仮想マシンの接頭語
variable "prov_cpu_num_ha" {}           #プロビジョニングする仮想マシンのCPUの数
variable "prov_mem_num_ha" {}           #プロビジョニングする仮想マシンのメモリのMB

##OS Template User  
variable "template_user" {}
variable "template_user_password" {}

##Kubeadm Cluster Name
variable "k8s_domain_name" {}
  

