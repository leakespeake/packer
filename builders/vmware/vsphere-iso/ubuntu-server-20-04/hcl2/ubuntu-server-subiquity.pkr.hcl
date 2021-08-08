###################################################
# LOCALS                                       
###################################################
locals {
  iso_path = "[${var.datastore}] ${var.iso_filepath}/${var.iso_filename}"
  vm_name = "${var.vm_name}-${formatdate("YYYYMMDD'T'hhmmss", timestamp())}Z"
  buildtime = formatdate("YYYY-MM-DD hh:mm ZZZ", timestamp())
}

###################################################
# VARIABLES                                       
###################################################
variable boot_command {
  type = string
  description = "The keys to type when the VM is first booted in order to start the OS installer. This is typed after boot_wait, which gives the VM some time to load."
  default = <<-EOF
  <enter><wait2><enter><wait><f6><esc><wait>
  autoinstall ds=nocloud;
  <enter>
  EOF
}

variable floppy_files {
  type = list(string)
  description = "The local files to be mounted to the VM floppy drive. At a minimum, the cloud-init user-data and meta-data files should be included."
  default = [
    "./http/ubuntu-server-subiquity/user-data",
    "./http/ubuntu-server-subiquity/meta-data",
  ]
}

variable disk_controller_type {
  type = string
  description = "The virtual disk controller type."
  default = "pvscsi"
}

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

variable datastore {
  type = string
  description = "The vSAN, VMFS, or NFS datastore for virtual disk and ISO file storage. Required for clusters, or if the target host has multiple datastores."
  default = "NAS-datastore-01"
}

variable network {
  type = string
  description = "The network segment or port group name to which the primary virtual network adapter will be connected."
  default = "VM Network"
}

variable folder {
  type = string
  description = "The VM folder in which the VM template will be created."
  default = "Templates"
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

variable iso_filename {
  type = string
  description = "The file name of the guest OS ISO image installation media."
  default = "ubuntu-20.04.2-live-server-amd64.iso"
}

variable iso_filepath {
  type = string
  description = "The file path within your datastore to your ISO image installation media."
  default = "/iso"
}

variable ssh_username {
  type = string
  description = "The username to use to authenticate over SSH."
  default = "ubuntu"
}

variable ssh_password {
  type = string
  description = "The plaintext password to use to authenticate over SSH - refer to the user-data cloud-config file for hashed value."
}

variable vm_name {
  type = string
  description = "The name of the new VM template to create."
  default = "ubuntu-server-20-04-2"
}

variable vm_version {
  type = number
  description = "The VM virtual hardware version."
  default = 19
}

###################################################
# BUILDERS                                       
###################################################
source vsphere-iso ubuntu-server {
  CPUs = 2
  RAM = 4096
  RAM_reserve_all = true
  boot_command = [
    var.boot_command,
  ]
  boot_wait = "3s"
  convert_to_template = true
  floppy_files = var.floppy_files
  floppy_label = "cidata"
  guest_os_type = "ubuntu64Guest"
  
  # essential for VMs in a nested environment
  NestedHV = true  
  
  cluster = var.cluster
  datacenter = var.datacenter
  datastore = var.datastore
  folder = var.folder
  host = var.host

  disk_controller_type = [
    var.disk_controller_type,
  ]
  iso_paths = [
    local.iso_path,
  ]
  network_adapters {
    network = var.network
    network_card = "vmxnet3"
  }

  vcenter_server = var.vcenter_server
  username = var.vcenter_username
  password = var.vcenter_password
  insecure_connection = var.insecure_connection
  
  ssh_username = var.ssh_username
  ssh_password = var.ssh_password
  ssh_port = 22
  ssh_timeout = "30m"
  ssh_handshake_attempts = "100000"
  shutdown_command = "echo '${var.ssh_password}' | sudo -S -E shutdown -P now"
  shutdown_timeout = "15m"

  storage {
    disk_size = 15360
    disk_controller_index = 0
    disk_thin_provisioned = true
  }
  
  vm_name = local.vm_name
  vm_version = var.vm_version
  notes = "Built by HashiCorp Packer on ${local.buildtime}."
}

###################################################
# PROVISIONERS                                       
###################################################
build {
  sources = [
    "source.vsphere-iso.ubuntu-server",
  ]

  provisioner "shell" {
    scripts = [
      "./http/scripts/bootstrap.sh",
      "./http/scripts/cleanup.sh"
    ]
  }
}
