# GCP (googlecompute)
Useful information for using the GCP builder

**PACKER EXAMPLE - GCP BUILDER**

For the example.json build...

## GCESYSPREP - WINDOWS TEMPLATES

When using a vanilla Windows OS ISO with the **googlecompute** builder, we must run GCESysprep during the **provisioners** phase of the build to prepare the system for duplication. Include the following in a Powershell provisioner (the **-no_shutdown** flag is important to prevent sysprep from restarting the image. Without this argument Packer fails the build as it assumes something has gone wrong);

```
GCESysprep -no_shutdown
```
When using public GCP Windows images, Google retains them in a generalized state. That means that the final stages of Windows setup – including SID generation – have not been run yet, and are only run when you first start up a new VM instance. This is one of many reasons why cloud instances of Windows take longer than Linux to startup. If we use these public Windows images as a base for a customized image, we must use GCESysprep to prepare the system for duplication.