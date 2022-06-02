# Packer template creation for Ubuntu Server 22.04 LTS (Jammy Jellyfish)

This repository contains the Packer files to deploy Ubuntu Server 22.04 in VMware vSphere (with vCenter), using the vsphere-iso builder. 

It uses the Long Term Support (LTS) "live" installer that can refresh itself to the latest version during the live session - this provides you with access to new features and bug fixes without needing to wait for the official point releases throughout the cycle.  

Hashicorp now recommend HCL2 as the preferred way to write Packer configurations. HCL2 enables more descriptive code via comments and variable descriptions as well as pairing more seamlessly with the Terraform HCL2 code practises. Hence, the **.json** files are now replaced with **.pkr.hcl** extensions and format.

The **vsphere-iso** builder creates the template directly in vCenter via the vSphere API. We are utlizing **subiquity** which is Canonical's automated Ubuntu server installation system that leverages cloud-init configuration. The **user-data** file is leveraged to customize Ubuntu's keyboard and timezone to UK. It also installs essential base packages to enhance server ops and optimize Ubuntu for running within vmware via 'open-vm-tools'.

After this customized "build" stage we will use shell scripts (as part of the "provisioners" process) to update and upgrade Ubuntu, then bake in the following;

-   a container manager (docker-ce)
-   ansible functionality (python 3.x and openssh-server)

Once the new VM image is created, the intention is to then use Terraform to deploy new instances from it via the **clone** and **customize** blocks within the **vsphere_virtual_machine** resource. As such I have written a re-usable child module that will standardize these VM deployments to vCenter server;

https://github.com/leakespeake/terraform-reusable-modules/tree/master/vsphere/template-cloning/linux/ubuntu-server-22-04

Further standardized configuration to be achieved by Ansible over SSH.

---

## VERSIONS
-   Packer 1.8.1
-   vSphere 7.0.4

---

## PRE-REQUISITES

-   Canonical's new automated Ubuntu server install system that leverages cloud-init configuration (Subiquity), is not interoperable with VMware's guest customization feature - at time of writing. Specifically it stalls on the network configuration and Terraform will produce a customization error and taint the resource. However, I have implemented a fix that can be seen in the **cleanup.sh** shell script.

-   DHCP – essential for the Packer SSH Communicator - allows the Packer builder to obtain an IP then communicate with the VM (from your remote Packer instance) over SSH to complete the provisioning tasks - obviously requires tcp/22 be open between the local Packer host and the remote VM.

-   Local environment variables to cleanly pass in vCenter and SSH passwords - e.g.: [ $env:PKR_VAR_ssh_password="ubuntu" ] [ export PKR_VAR_ssh_password="ubuntu" ] 

-   Creation of a hashed SSH password via **mkpasswd --method=SHA-512 --rounds=4096** 

---

### CHANGES SINCE UBUNTU 20.04

[1] Floppy method unavailable - since there is no floppy driver in the ubuntu-22.04 installer anymore, to pass in user-data and meta-data we have to use the CD configuration via **cd_files** which is a list of files to place onto a CD that is mounted when the VM is booted. This option assumes you have a command line tool installed that can handle the iso creation - Packer will use either **hdiutil** for macOS or **oscdimg** that forms part of the Windows ADK.

[2] SSH Communicator produced the following error;
```
[DEBUG] SSH handshake err: ssh: handshake failed: ssh: unable to authenticate, attempted methods [none password], no supported methods remain
[DEBUG] Detected authentication error. Increasing handshake attempts
```
Packer's SSH keys are too insecure for Ubuntu 22.04 to accept since RSA/SHA-1 was deprecated in the latest OpenSSH release (baked into 22.04). This was fixed in Packer core version 1.8.1.

---

## CONTENT

-   **ubuntu-server-subiquity.pkr.hcl** - Packer template file in HCL2
-   **./cloud-init/** - the cloud-init config files, used to provide all input necessary to build the VM template without manual intervention (build phase)
-   **./scripts/** - a bootstrap script to bake in packages for immediate container and ansible functionality, following by a cleanup script (provisioner phase)

## USAGE

We now use the **packer init {build-file-name}.pkr.hcl** command to enable automatic install of Packer plugins. These are maintained and installed seperately from the Packer core binary, in a similar fashion to Terraform.

```
packer init ubuntu-server-subiquity.pkr.hcl
packer validate ubuntu-server-subiquity.pkr.hcl
packer build ubuntu-server-subiquity.pkr.hcl
```
Note that there are 2 points in the build output to stdout that will sit for some time before continuing - this is normal - they are;

-   **"waiting for IP"** - attains an IP once Subiquity has started running and reaches the DHCP part 
-   **"waiting for SSH to become available"** - Subiquity must first populate the user-data config and reboot before Packer will attempt to use the SSH Communicator to start the provisioning stage and run the shell scripts on the remote instance

Also note that, when deciding which packages to bake into the template, we can check the manifest for the particular live server .iso selected;

```
wget https://releases.ubuntu.com/jammy/ubuntu-22.04-live-server-amd64.manifest -q -O - | cut -f 1 
```
Here we see "git" (for example) is already included so need not be added to our code. 

We can also confirm the additonal packages after deployment of the new template; 
```
dpkg --get-selections > packages.list
```