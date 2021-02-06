![packer](https://user-images.githubusercontent.com/45919758/85199800-320c9c00-b2ea-11ea-86bf-a3e02487cf8f.png)

Packer template creations for on-prem and the cloud - for Ubuntu, CentOS, CoreOS and Windows Server against AWS, GCP and vSphere builders. 

The template JSON file contains the following distinct sections;


**VARIABLES**

Lets you parameterize your templates so that you can keep secrets out of them. Maximizes the portability of the template. Adheres to DRY principles.


**BUILDERS**

Builders are responsible for creating machines and generating images from them for various platforms. There are seperate builders for AWS, GCP, VMware etc. Packer supports **SSH** (Linux) or **WinRM** (Windows) to upload files, execute scripts, etc - these are configured here.


**PROVISIONERS**

Provisioners use builtin and third-party software to install and configure the machine image after booting. Provisioners prepare the system for use, so common use cases for provisioners include;

- installing packages

- patching the kernel

- creating users

- downloading application code


Common provisioners are;

- Ansible

- Shell (bash)

- Powershell


**POST PROCESSORS**

Post-processors run after the image is built by the builder and provisioned by the provisioner. 
Post-processors are optional, and they can be used to; 

- upload artifacts

- docker push

- docker tag

- vsphere template creation

___


## USAGE
```
packer build template-OS.json
packer validate template-OS.json
packer fix template-OS.json > new-template-OS.json
packer build template-OS.json 2>&1 | sudo tee output.txt

