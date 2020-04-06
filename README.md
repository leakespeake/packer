# packer
Various packer builds against vSphere, AWS and GCP

**COMMUNICATORS**
The mechanism used to upload files, execute scripts, etc - with the machine being created.

Communicators are configured within the builders section. Packer currently supports **SSH** or **WinRM**

**BUILDERS**
Builders are responsible for creating machines and generating images from them for various platforms. 

There are seperate builders for AWS, GCP, VMware etc.

**PROVISIONERS**
Provisioners use builtin and third-party software to install and configure the machine image after 

booting. Provisioners prepare the system for use, so common use cases for provisioners include;

- installing packages

- patching the kernel

- creating users

- downloading application code

Common provisioners are;

- Ansible

- Shell (bash shell)

- Windows Shell (cmd shell)

**POST PROCESSORS**
Post-processors run after the image is built by the builder and provisioned by the provisioner. 

Post-processors are optional, and they can be used to; 

- upload artifacts

- docker push

- docker tag

- vsphere template creation

**PACKER EXAMPLE - AWS BUILDER**

For the example.json build, pass in the AWS credentials - as per;

```
packer build \
  -var 'aws_access_key=YOUR ACCESS KEY' \
  -var 'aws_secret_key=YOUR SECRET KEY' \
  example.json
```

To clean up, deregister the AMI in AWS via;

IMAGES > AMIs... select AMI > Actions > Deregister

Then delete the associated snapshot via;

EC2 > Snapshots... select snapshot > Actions > Delete
