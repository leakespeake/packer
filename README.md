# packer
Various Packer templates for image builds against vSphere, AWS and GCP - Packer currently supports **SSH** or **WinRM** to upload files, execute scripts, etc - these are configured within the **builders** section. The template JSON file contains the following distinct sections;


**VARIABLES**
Lets you parameterize your templates so that you can keep secrets out of them. Maximizes the portability of the template. Adheres to DRY principles.


**BUILDERS**
Builders are responsible for creating machines and generating images from them for various platforms. There are seperate builders for AWS, GCP, VMware etc.


**PROVISIONERS**
Provisioners use builtin and third-party software to install and configure the machine image after booting. Provisioners prepare the system for use, so common use cases for provisioners include;

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

___


**TIPS**

Capture the output of the image build to a file - useful to note the image ID;

```
packer build example.json 2>&1 | sudo tee output.txt
```

Validate the JSON code;

```
packer validate example.json
```
