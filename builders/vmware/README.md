# VMware
The VMware Packer builder is able to create VMware virtual machines for use with any VMware product. Packer comes with multiple builders able to create VMware machines, depending on the strategy you want to use to build the image and supports the following builders;

- **vsphere-iso** - This builder starts from an ISO file, but utilizes the vSphere API rather than the esxcli to build on a remote esx instance. This allows you to build vms even if you do not have SSH access to your vSphere cluster. Requires vCenter Server and creates the template directly in VC via the vSphere API (BEST OPTION).

- **vmware-iso** - Starts from an ISO file, creates a brand new VMware VM, installs an OS, provisions software within the OS, then exports that machine to create an image. This is best for people who want to start from scratch.

- **vmware-vmx** - This builder imports an existing VMware machine (from a VMX file), runs provisioners on top of that VM, and exports that machine to create an image. This is best if you have an existing VMware VM you want to use as the source. As an additional benefit, you can feed the artifact of this builder back into Packer to iterate on a machine.

- **vsphere-clone** - This builder clones a vm from an existing template, then modifies it and saves it as a new template. It uses the vSphere API rather than the esxcli to build on a remote esx instance. This allows you to build vms even if you do not have SSH access to your vSphere cluster.

---

## TEMPLATE DEPLOYMENT WITH TERRAFORM

Before creating our VMware template, it's worth considering what options Terraform can provide for the eventual **vsphere_virtual_machine** resources at the deployment phase.

The following 3 code blocks within our **vsphere_virtual_machine** resource are relevant to Packer;

[1] CLONE - the **clone** block can be used to create a new virtual machine from an existing template and is fetched via the vsphere_virtual_machine data source. This allows us to locate the UUID of the template we want to clone, along with settings for network interface type, SCSI bus type (important on Windows machines), and disk attributes.

[2] CUSTOMIZE - to perform virtual machine customization as a part of the clone process, specify the **customize** block with the respective options, nested within the clone block.

[3] LINUX_OPTIONS / WINDOWS_OPTIONS - nested within the customize block, we then use either **windows_options** or **linux_options** to provide OS specific customization options. NOTE: Windows guests are customized using Sysprep, which results in the machine SID being reset. This action is built into the customize tasks so does not need to be stated.


A very broad example of this code would be;

```
resource "vsphere_virtual_machine" "vm" {
  # ... other configuration ...

  clone {
    template_uuid = "${data.vsphere_virtual_machine.template.id}"

    customize {
      timeout = 0

      windows_options {
        computer_name  = "lab01"
        workgroup      = "lab"
        admin_password = "REDACTED"
      }

      network_interface {}
    }
  }
}

data "vsphere_virtual_machine" "template" {
  name          = "win-server-2019"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}
```
We also use the **linux_options** block for our Linux guests.

Full details here: https://registry.terraform.io/providers/hashicorp/vsphere/latest/docs/resources/virtual_machine