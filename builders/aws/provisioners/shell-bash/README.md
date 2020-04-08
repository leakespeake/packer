# Shell provisioner examples
All provisioning tasks done via the Bash shell - using these methods;

- **inline** - multi-line Bash script embedded inside the Packer template JSON

```
"type": "shell",
"inline": 
```

- **external** - state the path and name of the .sh shell script

```
"type": "shell",
"script": "bootstrap.sh" 
```

___


**webserver1.json**

Creates an Amazon Machine Image (AMI) of an Ubuntu server with Apache, PHP, and a sample PHP app installed. You can build the AMI from this Packer template via;

```
packer build \
  -var 'aws_access_key=YOUR ACCESS KEY' \
  -var 'aws_secret_key=YOUR SECRET KEY' \
  webserver1.json
```

This AMI can be installed on your AWS servers using the following **resource** - note that we use the **user_data** argument, which is a Bash script that executes at startup - required to start the Apache service;

```
resource "aws_instance" "example1" {
    ami             = "**AMI ID** of the new Packer image"
    instance_type   = "t2.micro"
    vpc_security_group_ids = [aws_security_group.instance.id] **state ingress rules for your service ports and SSH**

    user_data = <<-EOF
                #!/bin/bash
                sudo service apache2 start
                EOF
}

We also need to ensure the region stated in the **provider** block matches the region the new AMI resides in;

```
provider "aws" {
    region = "us-east-2"
}
```

___

**SHELL SCRIPT TIPS**

How do I tell what my shell script is doing?

Adding a -x flag to the shebang at the top of the script (#!/bin/sh -x) will echo the script statements as it is executing.

My shell script doesn't work correctly on Ubuntu.

On Ubuntu, the /bin/sh shell is dash. If your script has bash specific commands in it, then append **-e** to the shebang;

**#!/bin/bash -e**

My installs hang when using apt-get or yum.

Add a -y to the command to prevent it from requiring user input

My builds work inconsistently.

Some distributions start the SSH daemon before other core services which can create race conditions. Your first provisioner can tell the machine to wait until it completely boots;

```
  "type": "shell",
  "inline": [ "sleep 10" ]
```
