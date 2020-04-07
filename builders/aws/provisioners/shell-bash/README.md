# Shell provisioner examples
All provisioning tasks done via the Bash shell - using these methods;

- inline - multi-line Bash script embedded inside the Packer template JSON

```
"type": "shell",
"inline": 
```

- external - state the seperate shell script name

```
"type": "shell",
"script": "bootstrap.sh" 
```

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
    ami             = "packer-example1" # (the ami_name stated in the Packer template)
    instance_type   = "t2.micro"

    user_data = <<-EOF
                #!/bin/bash
                sudo service apache2 start
                EOF
}
