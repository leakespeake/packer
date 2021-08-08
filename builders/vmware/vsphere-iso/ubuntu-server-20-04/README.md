# Packer template creation for Ubuntu Server 20.04.2 LTS (Focal Fossa)

This repository contains the Packer files to deploy Ubuntu Server 20.04.2 in VMware vSphere (with vCenter), using the vsphere-iso builder. It uses the Long Term Support (LTS) "live" installer that can refresh itself to the latest version during the live session - this provides you with access to new features and bug fixes without needing to wait for the official point releases throughout the cycle. 

Hashicorp now recommend HCL2 as the preferred way to write Packer configurations. HCL2 enables more descriptive code via comments and variable descriptions as well as pairing more seamlessly with the Terraform HCL2 code practises. Hence, the **.json** files are now replaced with **.pkr.hcl** extensions and format.

The **vsphere-iso** builder creates the template directly in vCenter via the vSphere API and we are utlizing **subiquity** which is Canonical's new automated Ubuntu server installation system that leverages cloud-init configuration. After this customized "build" stage we will use shell scripts (as part of the "provisioners" process) to bake in a container manager (docker-ce) along with python 3.x and openssh-server for ansible functionality.

Once the new VM image is created, the intention is to then use Terraform to deploy new instances from it - also performing sysprep as part of the **clone** and **customize** code blocks within the **vsphere_virtual_machine** resource. Further standardized configuration to be achieved by Ansible over SSH.

---

## VERSIONS
-   Packer 1.7.4
-   vSphere 7.0.2

---

## PRE-REQUISITES

-   DHCP – essential for the Packer SSH Communicator - allows the Packer builder to obtain an IP then communicate with the VM (from your remote Packer instance) over SSH to complete the provisioning tasks - obviously requires tcp/22 be open between the local Packer host and the remote VM.

-   Local environment variables to cleanly pass in the vCenter and SSH passwords - example: [ $env:PKR_VAR_ssh_password="ubuntu" ] [ export PKR_VAR_ssh_password="ubuntu" ] 

-   Creation of a hashed SSH password via **mkpasswd --method=SHA-512 --rounds=4096** 


## CONTENT

-   **ubuntu-server-subiquity.pkr.hcl** - Packer template file in HCL2
-   **ubuntu-server.pkrvars.hcl** - variable definition file for non-sensitive variable values you want to persist between builds (i.e. subiquity and legacy autoinstall methods)
-   **/http/ubuntu-server-subiquity** - the cloud-init config files, used to provide all input necessary to build the VM template without manual intervention
-   **/http/scripts** - a bootstrap script to bake in packages for immediate container and ansible functionality, following by a cleanup script

## USAGE

```
packer validate ubuntu-server-subiquity.pkr.hcl
packer build ubuntu-server-subiquity.pkr.hcl
```
