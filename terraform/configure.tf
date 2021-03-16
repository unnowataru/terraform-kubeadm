resource "null_resource" "ha_hosts" {
  count = var.prov_vm_num_ha
  
  triggers = {
    cluster_instance_ids = join(",", vsphere_virtual_machine.vm.*.name)
  }

  connection {
    host      = "${element(vsphere_virtual_machine.vm.*.default_ip_address, count.index)}"
    type      = "ssh"
    user      = var.template_user
    password  = var.template_user_password
  }

  provisioner "remote-exec" {
    inline = [
      "echo '${vsphere_virtual_machine.vm[0].default_ip_address} ${vsphere_virtual_machine.vm[0].name} ${vsphere_virtual_machine.vm[0].name}.${var.pram_domain_name}' >> /etc/hosts ",
      "echo '${vsphere_virtual_machine.vm_1[0].default_ip_address} ${vsphere_virtual_machine.vm_1[0].name} ${vsphere_virtual_machine.vm_1[0].name}.${var.pram_domain_name}' >> /etc/hosts ",
      "echo '${vsphere_virtual_machine.vm_1[1].default_ip_address} ${vsphere_virtual_machine.vm_1[1].name} ${vsphere_virtual_machine.vm_1[1].name}.${var.pram_domain_name}' >> /etc/hosts ",
      "echo '${vsphere_virtual_machine.vm_1[2].default_ip_address} ${vsphere_virtual_machine.vm_1[2].name} ${vsphere_virtual_machine.vm_1[2].name}.${var.pram_domain_name}' >> /etc/hosts ",
      "echo '${vsphere_virtual_machine.vm_1[3].default_ip_address} ${vsphere_virtual_machine.vm_1[3].name} ${vsphere_virtual_machine.vm_1[3].name}.${var.pram_domain_name}' >> /etc/hosts ",
      "echo '${vsphere_virtual_machine.vm_1[4].default_ip_address} ${vsphere_virtual_machine.vm_1[4].name} ${vsphere_virtual_machine.vm_1[4].name}.${var.pram_domain_name}' >> /etc/hosts ",
      "echo '${vsphere_virtual_machine.vm_1[5].default_ip_address} ${vsphere_virtual_machine.vm_1[5].name} ${vsphere_virtual_machine.vm_1[5].name}.${var.pram_domain_name}' >> /etc/hosts ",
      "echo '${vsphere_virtual_machine.vm[0].default_ip_address} ${var.k8s_domain_name} ${var.k8s_domain_name}.${var.pram_domain_name}' >> /etc/hosts ",
    ]
    
  }
}


resource "null_resource" "kube_hosts" {
  count = var.prov_vm_num
  
  triggers = {
    cluster_instance_ids = join(",", vsphere_virtual_machine.vm_1.*.name)
  }

  connection {
    host      = "${element(vsphere_virtual_machine.vm_1.*.default_ip_address, count.index)}"
    type      = "ssh"
    user      = var.template_user
    password  = var.template_user_password
  }

  provisioner "remote-exec" {
    inline = [
      "echo '${vsphere_virtual_machine.vm[0].default_ip_address} ${vsphere_virtual_machine.vm[0].name} ${vsphere_virtual_machine.vm[0].name}.${var.pram_domain_name}' >> /etc/hosts ",
      "echo '${vsphere_virtual_machine.vm_1[0].default_ip_address} ${vsphere_virtual_machine.vm_1[0].name} ${vsphere_virtual_machine.vm_1[0].name}.${var.pram_domain_name}' >> /etc/hosts ",
      "echo '${vsphere_virtual_machine.vm_1[1].default_ip_address} ${vsphere_virtual_machine.vm_1[1].name} ${vsphere_virtual_machine.vm_1[1].name}.${var.pram_domain_name}' >> /etc/hosts ",
      "echo '${vsphere_virtual_machine.vm_1[2].default_ip_address} ${vsphere_virtual_machine.vm_1[2].name} ${vsphere_virtual_machine.vm_1[2].name}.${var.pram_domain_name}' >> /etc/hosts ",
      "echo '${vsphere_virtual_machine.vm_1[3].default_ip_address} ${vsphere_virtual_machine.vm_1[3].name} ${vsphere_virtual_machine.vm_1[3].name}.${var.pram_domain_name}' >> /etc/hosts ",
      "echo '${vsphere_virtual_machine.vm_1[4].default_ip_address} ${vsphere_virtual_machine.vm_1[4].name} ${vsphere_virtual_machine.vm_1[4].name}.${var.pram_domain_name}' >> /etc/hosts ",
      "echo '${vsphere_virtual_machine.vm_1[5].default_ip_address} ${vsphere_virtual_machine.vm_1[5].name} ${vsphere_virtual_machine.vm_1[5].name}.${var.pram_domain_name}' >> /etc/hosts ",
      "echo '${vsphere_virtual_machine.vm[0].default_ip_address} ${var.k8s_domain_name} ${var.k8s_domain_name}.${var.pram_domain_name}' >> /etc/hosts ",
    ]
    
  }
}


resource "null_resource" "co_haproxy" {
  count = var.prov_vm_num_ha
  
  triggers = {
    cluster_instance_ids = join(",", vsphere_virtual_machine.vm.*.name)
  }

  connection {
    host      = "${element(vsphere_virtual_machine.vm.*.default_ip_address, count.index)}"
    type      = "ssh"
    user      = var.template_user
    password  = var.template_user_password
  }

/*
    provisioner "file" {
    source      = "${data.template_file.haproxyconf.rendered}"
    destination = "/etc/haproxy/haproxy.cfg"
  }
*/

  provisioner "remote-exec" {
    inline = [
      "${data.template_file.haproxyconf.rendered}",
    ]
    
  }
}

data "template_file" "haproxyconf" {
  template = "${file("${path.module}/file/haproxy.tpl")}"

  vars = {
    domain_name = "${var.pram_domain_name}"
    vm_0        = "${vsphere_virtual_machine.vm_1[0].name}"
    vm_1        = "${vsphere_virtual_machine.vm_1[1].name}"
    vm_2        = "${vsphere_virtual_machine.vm_1[2].name}"
     
  }
}


resource "null_resource" "kubeadminconf" {
  count = var.prov_vm_num
  
  triggers = {
    cluster_instance_ids = join(",", vsphere_virtual_machine.vm_1.*.name)
  }

  connection {
    host      = "${element(vsphere_virtual_machine.vm_1.*.default_ip_address, count.index)}"
    type      = "ssh"
    user      = var.template_user
    password  = var.template_user_password
  }

/*
  provisioner "file" {
    source      = "${data.template_file.kubeadmconf.rendered}"
    destination = "/kubeadm/kubeadm-config.yaml"
  }
*/
  provisioner "remote-exec" {
    inline = [
      "${data.template_file.kubeadmconf.rendered}",
    ]
    
  }

}

data "template_file" "kubeadmconf" {
  template = "${file("${path.module}/file/kubeadm-config.tpl")}"

  vars = {
    k8s_domain = "${var.k8s_domain_name}"
    pram_domain_name = "${var.pram_domain_name}"
  }
}
