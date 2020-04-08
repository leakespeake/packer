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

To clean up, deregister the AMI in AWS via;

IMAGES > AMIs... select AMI > Actions > Deregister

Then delete the associated snapshot via;

EC2 > Snapshots... select snapshot > Actions > Delete

___

**AWS CREDENTIALS**
If you have already set the credentials in **~/.aws/credentials** file, you don’t need to pass access keys as variables.
