output "ha_proxy" {
  description = "VM Names"
  value       = vsphere_virtual_machine.vm.*.name
}

output "ha_proxy_ip" {
  description = "default ip address of the deployed VM"
  value       = vsphere_virtual_machine.vm.*.default_ip_address
}


output "kubernetes_node" {
  description = "VM Names"
  value       = vsphere_virtual_machine.vm_1.*.name
}

output "kubernetes_node_ip" {
  description = "default ip address of the deployed VM"
  value       = vsphere_virtual_machine.vm_1.*.default_ip_address
}

