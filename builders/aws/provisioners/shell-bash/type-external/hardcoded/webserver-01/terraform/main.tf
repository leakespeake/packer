# DEPLOY SINGLE SERVER - USING CUSTOM PACKER BUILT AMI (running Ubuntu, PHP / Apache2)

# Allow any Terraform 12.x version - show via; terraform version
terraform {
  required_version = ">= 0.12, < 0.13"
}

# Set the provider as AWS - ensure the region matches the same region of the Packer built AMI you will use
provider "aws" {
    region = "us-east-2"
    version = "~> 2.0"
}

# Create a t2.micro spec EC2 instance using the AMI ID of the custom Packer image
# Pass it the ID of the security group below using a RESOURCE ATTRIBUTE REFERENCE - <PROVIDER=aws>_<TYPE=security_group>_.<NAME=apache-instance1>.<ATTRIBUTE=id>
resource "aws_instance" "packer-example1" {
    ami             = "ami-05f38bb80749f11ba"   # Packer AMI ID
    instance_type   = "t2.micro"
    vpc_security_group_ids = [aws_security_group.apache-instance1.id]

# Pass a shell script to User Data to start the Apache service upon startup
# Uses Terraforms HEREDOC SYNTAX of <<-EOF and EOF to create multi line strings without inserting newline characters

    user_data = <<-EOF
                #!/bin/bash
                sudo service apache2 start
                EOF

    tags = {
        Name = "Barrys 1st Packer AMI"
    }
}

# Create a security group resource named 'apache-instance1' to allow inbound traffic on tcp/8080 from anyone (0.0.0.0/0)  
resource "aws_security_group" "apache-instance1" {
    name = "packer-example1"
    
    ingress {
        from_port   = 80                    # Listening on any port less than 1024 requires root priviledges (security risk)
        to_port     = 80                    # Default Apache port
        protocol    = "tcp"
        cidr_blocks = ["92.238.177.185/32"]
        #cidr_blocks = ["0.0.0.0/0"]
        }

    ingress {
        from_port   = 22                  
        to_port     = 22                   
        protocol    = "tcp"
        cidr_blocks = ["92.238.177.185/32"]
        #cidr_blocks = ["0.0.0.0/0"]
        }
}