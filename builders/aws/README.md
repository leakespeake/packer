# AWS
Useful information for using the AWS builder

**AWS CREDENTIALS**

For the example.json Packer build, we can pass in our AWS credentials either at the **packer build** command;

```
packer build \
  -var 'aws_access_key=YOUR ACCESS KEY' \
  -var 'aws_secret_key=YOUR SECRET KEY' \
  example.json
```

Or as a variable within example.json - these environment variables must exist within **~/.bashrc**

```
  "variables": {
    "aws_access_key": "{{env `AWS_ACCESS_KEY_ID`}}",
    "aws_secret_key": "{{env `AWS_SECRET_ACCESS_KEY`}}",
``` 

___

**CHOOSING THE SOURCE AMI TO BUILD FROM**

The source AMI's are specific to their region - have your preferred region selected in AWS, then;

EC2 > IMAGES > AMIs... change Owned By Me to Public Images... use the Filters like Platform, Architecture etc to choose the Image you want. Copy the AMI Name and Owner.

___

**TERRAFORM CONSIDERATIONS**

When creating our AWS resource via **main.tf** - the salient parts will be;

- the **AMI ID** of the new Packer image
- matching the region of the AMI ID in the **providers** code block
- the **user_data** argument to pass a shell script to start the intended service(s)
- a **security group** to allow ingress rules for the intended service(s) and SSH

___

**SSH ACCESS TO THE NEW EC2 INSTANCE**

Use the **ssh -i** command to connect - must specify the following;

- the path and file name of the private key (.pem)
- the user name for the AMI
- the public DNS name

```
ssh -i /path/my-key-pair.pem ec2-user@ec2-198-51-100-1.compute-1.amazonaws.com
```

___

**CLEANING UP**

AMIs are made up of EC2 snapshots which are stored in S3. There is a cost associated with storing these snapshots so, although unlikely to be a major cost, you'll want to clean them up periodically. It's a simple 2 step process in the AWS console;

[1] You must first deregister the AMI;

EC2 > IMAGES > AMIs... select AMI > Actions > Deregister

[2] Then delete the associated snapshot via;

EC2 > Snapshots... select snapshot > Actions > Delete

Also **terraform destroy** any test EC2 instances
