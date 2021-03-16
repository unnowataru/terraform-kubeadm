
#Resource
resource "vsphere_virtual_machine" "vm_1" {
  count            = var.prov_vm_num
##   name            = "${var.prov_vmname_prefix}${format("%03d",count.index+1)}"
   name            = "${var.prov_vmname_prefix}${format("%03d",count.index+1)}"
  resource_pool_id = data.vsphere_resource_pool.pool.id
  datastore_id     = data.vsphere_datastore.datastore.id

#Resource for VM Specs
  num_cpus = var.prov_cpu_num
  memory   = var.prov_mem_num
  guest_id = data.vsphere_virtual_machine.template.guest_id

  scsi_type = data.vsphere_virtual_machine.template.scsi_type

  network_interface {
    network_id   = data.vsphere_network.network_1.id
    adapter_type = "vmxnet3"
  }

#Resource for Disks
  disk {
    label            = "disk1"
    size             = data.vsphere_virtual_machine.template.disks.0.size
    eagerly_scrub    = data.vsphere_virtual_machine.template.disks.0.eagerly_scrub
    thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned
  }

#portworx
    disk {
    label            = "disk0"
    size             = 100
    eagerly_scrub    = data.vsphere_virtual_machine.template.disks.0.eagerly_scrub
    thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned
    unit_number      = 1
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id

    # Linked Clone
    #linked_clone     = true

    customize {
        linux_options {
          host_name = "${var.prov_vmname_prefix}${format("%03d",count.index+1)}"
          domain    = var.pram_domain_name
        }        

        network_interface {
          ipv4_address = "${var.pram_ipv4_class}${count.index+var.pram_ipv4_host+1}"
          ipv4_netmask = var.pram_ipv4_subnet
        }
  
        ipv4_gateway    = var.pram_ipv4_gateway
        dns_server_list = [var.pram_dns_server]
    }
  }

  provisioner "remote-exec" {
    script = "file/kubeadm_install.sh"

    connection {
      type      = "ssh"
      host      = self.default_ip_address
      user      = var.template_user
      password  = var.template_user_password
    }
  }

}

