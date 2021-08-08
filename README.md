![packer](https://user-images.githubusercontent.com/45919758/85199800-320c9c00-b2ea-11ea-86bf-a3e02487cf8f.png)

Packer template creation for on-prem and the cloud - covers Ubuntu Server, CentOS and Windows Server against AWS, GCP and vSphere builders. 

NOTE: As of version 1.7.0, **HCL2** support is no longer in beta and is the preferred way to write Packer configurations. HCL2 enables more descriptive code via comments and variable descriptions as well as pairing more seamlessly with the Terraform HCL2 code practises. As such, the original JSON format will be slowly ported over to HCL2 as the OS templates and code progress in the repo. 

Both JSON and HCL2 formats contain the same distinct configuration sections;


**VARIABLES**

Lets you parameterize your templates so that you can keep secrets out of them. Maximizes the portability of the template. Adheres to DRY principles by customizing the Packer build without changing the main template configuration. HCL2 will load variables in the following order (last one takes precedence if set more than once!);

- PKR_VAR_foo="bar"                 [ $env:PKR_VAR_ssh_password="ubuntu" ] [ export PKR_VAR_ssh_password="ubuntu" ]
- variables.pkrvars.hcl
- variables.auto.pkrvars.hcl
- -var foo="bar"                    [ packer build -var="image_id=ami-abc123" template-OS.pkr.hcl ]

For sensitive values, and in the absence of a secrets management server, use the environment variables option (**PKR_VAR_foo="bar"**) as this will cleanly pass the values in without persisting in command history (**-var foo="bar"**) or risk being committed to GitHub (**.pkrvars.hcl**).

**BUILDERS**

Builders are responsible for creating machines and generating images from them for various platforms. There are seperate builders for AWS, GCP, VMware etc. Packer supports **SSH** (Linux) or **WinRM** (Windows) to upload files, execute scripts, etc - these are configured here.


**PROVISIONERS**

Provisioners use builtin and third-party software to install and configure the machine image after booting. Provisioners prepare the system for use, so common use cases for provisioners include;

- installing packages

- patching the kernel

- creating users

Common provisioners are;

- Ansible                   [dynamically creates an Ansible inventory file configured to use SSH then runs Ansible playbooks]

- Shell                     [bash scripts for Linux - either use **inline** or state a **script** or **scripts** path(s) to upload and execute on the machine via SSH]

- Powershell                [powershell scripts for Windows - either use **inline** or state a **script** or **scripts** path(s) to upload and execute on the machine via WINRM]


**POST PROCESSORS**

Post-processors run after the image is built by the builder and provisioned by the provisioner. These are optional and can be used to; 

- upload artifacts

- docker push

- docker tag

___


## USAGE
```
packer build template-OS.pkr.hcl
packer validate template-OS.pkr.hcl
packer fix template-OS.pkr.hcl > new-template-OS.pkr.hcl
packer build -debug -on-error=ask template-OS.pkr.hcl
```

## DEBUGGING
```
$env:PACKER_LOG=1
$env:PACKER_LOG_PATH="C:\ProgramData\packer\packer_log.txt"

export PACKER_LOG=1
export PACKER_LOG_PATH="C:\ProgramData\packer\packer_log.txt"
```