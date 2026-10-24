# Packer template creation for Ubuntu Server 26.04 LTS (Resolute Raccoon)

This repository contains the Packer files to deploy Ubuntu Server 26.04 in VMware vSphere (with vCenter), using the vsphere-iso builder. 

It uses the Long Term Support (LTS) "live" installer that can refresh itself to the latest version during the live session - this provides you with access to new features and bug fixes without needing to wait for the official point releases throughout the cycle.  

Hashicorp now recommend HCL2 as the preferred way to write Packer configurations. HCL2 enables more descriptive code via comments and variable descriptions as well as pairing more seamlessly with the Terraform HCL2 code practises. Hence, the **.json** files are now replaced with **.pkr.hcl** extensions and format.

The **vsphere-iso** builder creates the template directly in vCenter via the vSphere API. We are utlizing **subiquity** which is Canonical's automated Ubuntu server installation system that leverages cloud-init configuration. The **user-data** file is leveraged to customize Ubuntu's keyboard and timezone to UK. It also installs essential base packages to enhance server ops and optimize Ubuntu for running within vmware via 'open-vm-tools'.

After this customized "build" stage we will use shell scripts (as part of the "provisioners" process) to update and upgrade Ubuntu, then bake in the following;

-   a container manager (docker-ce)

Ansible functionality (python 3.x and openssh-server) is already baked into the base .iso file as seen in the manifest: https://releases.ubuntu.com/resolute/ubuntu-26.04-live-server-amd64.manifest

Once the new VM image is created, the intention is to then use Terraform to deploy new instances from it via the **clone** and **customize** blocks within the **vsphere_virtual_machine** resource. As such I have written a re-usable child module that will standardize these VM deployments to vCenter server;

https://github.com/leakespeake/terraform-reusable-modules/tree/master/vsphere/template-cloning/linux/ubuntu-server-22-04

Further standardized configuration to be achieved by Ansible over SSH.

---

## VERSIONS
-   Packer 1.16.2
-   vSphere 7.0.3

---

## PRE-REQUISITES

-   Canonical's new automated Ubuntu server install system that leverages cloud-init configuration (Subiquity), is not interoperable with VMware's guest customization feature - at time of writing. Specifically it stalls on the network configuration and Terraform will produce a customization error and taint the resource. However, I have implemented a fix that can be seen in the **cleanup.sh** shell script.

-   DHCP – essential for the Packer SSH Communicator - allows the Packer builder to obtain an IP then communicate with the VM (from your remote Packer instance) over SSH to complete the provisioning tasks - obviously requires tcp/22 be open between the local Packer host and the remote VM.

-   Local environment variables to cleanly pass in vCenter and SSH passwords - e.g.: [ $env:PKR_VAR_ssh_password="ubuntu" ] [ export PKR_VAR_ssh_password="ubuntu" ] 

-   Creation of a hashed SSH password via either **mkpasswd --method=SHA-512 --rounds=4096** (bash) or **openssl passwd -6** (macOS)

---

## CONTENT

-   **ubuntu-server-subiquity.pkr.hcl** - Packer template file in HCL2
-   **./cloud-init/** - the cloud-init config files, used to provide all input necessary to build the VM template without manual intervention (build phase)
-   **./scripts/** - a bootstrap script to bake in packages for immediate container and ansible functionality, following by a cleanup script (provisioner phase)

## USAGE

Navigate to `packer/builders/vmware/vsphere-iso/ubuntu-server-26-04/hcl2` then run the following **packer** commands;

```
packer init .
packer validate .
packer build .
```
We use **packer init** to enable automatic install of Packer plugins such as vSphere. These are maintained and installed seperately from the Packer core binary, in a similar fashion to Terraform. 

With **packer build** local tests (outside Jenkins) - this will need to pass the SSH password for the temporary Subiquity user account;

```
PKR_VAR_ssh_password="REDACTED" packer validate .
PKR_VAR_ssh_password="REDACTED" packer build .
```
Note that there are 2 points in the build output to stdout that will sit for some time before continuing - this is normal - they are;

-   **"waiting for IP"** - attains an IP once Subiquity has started running and reaches the DHCP part 
-   **"waiting for SSH to become available"** - Subiquity must first populate the user-data config and reboot before Packer will attempt to use the SSH Communicator to start the provisioning stage and run the shell scripts on the remote instance

## DEBUGGING BUILD ISSUES
Enable Packer’s native debug logging - this will force Packer to dump the raw JSON API payload it is sending to VMware;

```
PACKER_LOG=1 PKR_VAR_ssh_password="REDACTED" packer build .
```

Also note that, when deciding which packages to bake into the template, we can check the manifest for the particular live server .iso selected;

```
wget https://releases.ubuntu.com/resolute/ubuntu-26.04-live-server-amd64.manifest -q -O - | cut -f 1 
```
Here we see "git" (for example) is already included so need not be added to our code. 

We can also confirm the additonal packages after deployment of the new template; 
```
dpkg --get-selections > packages.list
```