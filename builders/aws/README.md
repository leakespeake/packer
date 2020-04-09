# AWS
Useful information for using the AWS builder

**PACKER EXAMPLE - AWS BUILDER**
For the example.json build, pass in the AWS credentials - as per;

```
packer build \
  -var 'aws_access_key=YOUR ACCESS KEY' \
  -var 'aws_secret_key=YOUR SECRET KEY' \
  example.json
```

If you have already set the credentials in **~/.aws/credentials** file, you don’t need to pass access keys as variables.

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
Particularly when on a free tier account - to clean up, deregister the AMI via;

EC2 > IMAGES > AMIs... select AMI > Actions > Deregister

Then delete the associated snapshot via;

EC2 > Snapshots... select snapshot > Actions > Delete

Also **terraform destroy** any test EC2 instances
