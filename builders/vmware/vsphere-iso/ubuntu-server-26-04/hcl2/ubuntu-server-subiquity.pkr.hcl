###################################################
# VERSION CONSTRAINTS                                       
###################################################
# use the 'packer init .' command to enable automatic install of Packer plugins
packer {
  required_version = ">= 1.16.2"
  required_plugins {
    vsphere = {
      version = ">= 1.2.0"
      source  = "github.com/hashicorp/vsphere"
    }
  }
}

###################################################
# LOCALS                                       
###################################################
locals {
  vm_name = "${var.vm_name}-${formatdate("YYYYMMDD'T'hhmmss", timestamp())}Z"
  buildtime = formatdate("YYYY-MM-DD hh:mm ZZZ", timestamp())
}

###################################################
# VARIABLES                                       
###################################################
variable vcenter_server {
  type = string
  description = "The vCenter server hostname, IP, or FQDN. For VMware Cloud on AWS, this should look like: 'vcenter.sddc-[ip address].vmwarevmc.com'."
  default = "vcsa.int.leakespeake.com"
}

variable vcenter_username {
  type = string
  description = "The username for authenticating to vCenter."
  default = "administrator@vsphere.local"
}

variable vcenter_password {
  type = string
  description = "The plaintext password for authenticating to vCenter."
  default = "!D1r3ctL1nk!"
}

variable cluster {
  type = string
  description = "The vSphere cluster where the target VM is created."
  default = "home-cluster-01"
}

variable datacenter {
  type = string
  description = "The vSphere datacenter name. Required if there is more than one datacenter in vCenter."
  default = "home-dc-01"
}

variable network {
  type = string
  description = "The network segment or port group name to which the primary virtual network adapter will be connected."
  default = "VM Network"
}

variable folder {
  type = string
  description = "The VM folder in which the VM template will be created."
  default = "Packer-templates"
}

variable host {
  type = string
  description = "The ESXi host where target VM is created."
  default = "esxi-01.int.leakespeake.com"
}

variable insecure_connection {
  type = bool
  description = "If true, does not validate the vCenter server's TLS certificate."
  default = true
}

variable ssh_username {
  type = string
  description = "The username to use to authenticate over SSH."
  default = "ubuntu"
}

variable ssh_password {
  type = string
  description = "The SSH password for the temporary Subiquity user account - refer to the user-data cloud-config file for hashed value."
  sensitive   = true # Prevents the password from printing out to terminal logs
}

variable vm_name {
  type = string
  description = "The name of the new VM template to create."
  default = "ubuntu-server-26-04-1"
}

variable vm_version {
  type = number
  description = "The VM virtual hardware version - v19 is the max ceiling for vSphere 7.0 U3"
  default = 19
}

###################################################
# BUILDERS                                       
###################################################
source "vsphere-iso" "ubuntu-server" {
  CPUs            = 2
  RAM             = 4096
  RAM_reserve_all = true

  boot_wait  = "10s"
  boot_order = "cdrom,disk"
  boot_command = [
    "e<down><down><down><end>",
    " autoinstall ds=nocloud;s=/cidata/",
    "<F10>",
  ]

  cd_files = ["./cloud-init/*"]
  cd_label = "cidata"

  convert_to_template = true
  guest_os_type       = "ubuntu64Guest"
  NestedHV            = true
  
  cluster    = var.cluster
  datacenter = var.datacenter
  datastore  = "datastore1"  
  folder     = var.folder

  disk_controller_type = ["pvscsi"]
  cdrom_type           = "sata"

  iso_paths = [
    "[NAS-datastore-01] iso/ubuntu-26.04.1-live-server-amd64.iso"
  ]
  iso_target_path      = "packer_cache-v1"

  network_adapters {
    network      = var.network
    network_card = "vmxnet3"
  }

  vcenter_server      = var.vcenter_server
  username            = var.vcenter_username
  password            = var.vcenter_password
  insecure_connection = var.insecure_connection

  ssh_username           = var.ssh_username
  ssh_password           = var.ssh_password  
  ssh_port               = 22
  ssh_timeout            = "30m"
  ssh_handshake_attempts = "10000"
  shutdown_command       = "echo '${var.ssh_password}' | sudo -S -E shutdown -P now"
  shutdown_timeout       = "15m"

  storage {
    disk_size             = 15360
    disk_controller_index = 0
    disk_thin_provisioned = true
  }
  
  vm_name    = local.vm_name
  vm_version = var.vm_version
  notes      = "Built by HashiCorp Packer on ${local.buildtime}."
}

###################################################
# PROVISIONERS                                       
###################################################
build {
  sources = [
    "source.vsphere-iso.ubuntu-server",
  ]
  # Call the provisioning bash scripts to run the bootstrap configuration and post template clean-up tasks
  provisioner "shell" {
    execute_command = "echo '${var.ssh_password}' | sudo -S -E bash '{{ .Path }}'"
    scripts = [
      "./scripts/bootstrap.sh",
      "./scripts/cleanup.sh"
    ]
  }
}
