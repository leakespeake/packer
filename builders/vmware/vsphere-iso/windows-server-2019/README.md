# Packer template creation for Windows Server 2019

This repository contains the Packer template and supporting files to deploy Windows Server 2019 in VMware vSphere (with vCenter), using the vsphere-iso builder for the Vmware platform.

Packer uses the JSON template to create the VM image directly on the vSphere server via the vSphere API, then perform an unattended install and configuration of Windows Server 2019. The same build format can be easily re-applied for Windows 10, Server 2016 etc. 

Once the new VM image is created, the intention is to then use Terraform to deploy new instances from it and further configure with Ansible (patching etc).

---

## VERSIONS
-   Packer 1.6.6
-   vSphere 6.7

---

## PRE-REQUISITES

-   DHCP server – essential for the WinRM communicator - this allows the Packer builder to obtain an IP then communicate with the VM (from your remote Packer instance) over WinRM and complete the provisioning tasks. A simple Ubuntu instance on the intended subnet can run isc-dhcp-server – easy to install and configure a small DHCP scope – details here; https://www.techrepublic.com/article/how-to-setup-a-dhcp-server-with-ubuntu-server-18-04/ 

-   Best answer file creation option - for the specific Windows OS version – use https://www.windowsafg.com/ to select config options then save as autounattend.xml to modify further if desired with VSC (tweaks likely)

-   Secondary option for answer file creation - Windows System Image Manager (SIM) feature from the Windows Assessment and Deployment Kit (ADK) - SIM listed under "Deployment Tools" – only install this option - download here; https://docs.microsoft.com/en-us/windows-hardware/get-started/adk-install 

-   Windows OS ISO uploaded to the intended vSphere datastore folder. Preferably a non-evaluation ISO of Windows OS as these require additional steps to activate with the product key rendering the autounattend key useless.

-   Assummed we have Vmware tools for Windows already existing in /vmimages/tools-isoimages/windows.iso

---

## CONTENT

-   **win-server-2019.json** - Packer template file
-   **autounattend.xml** - answer file for unattended Windows setup
-   **/scripts** - various configuration scripts called in order via the answer file

## USAGE

```
packer validate win-server-2019.json
packer build win-server-2019.json
```
Passwords are stated as user defined variables in the builders block and are then called from environment variables in the variables block – example below;

```
{
    "builders": [
        {
            "winrm_password": "{{user `winadmin-password`}}",
```
```            
    "variables": {
        "winadmin-password": "{{env `WINADMIN-PASSWORD`}}"
```
This negates the need to store these values in GitHub when we commit them and increases the portability of the code. If running Packer in Powershell, set them locally via;

```
setx WINADMIN-PASSWORD {password}
```
Close and re-open Powershell then view all environment vaiables via; **dir env:**

Or add your exports if running from Bash.

We could also feed these values in via -var when we run the packer build command then clear the history. Also note that we intend to change to autologon Administrator password of ‘packer’ when we deploy new VMs from this image template, either with Terraform or Ansible for post configuration tasks.
