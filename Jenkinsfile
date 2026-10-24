pipeline {
    agent any

    // Access variable values throughout the pipeline via the 'env' object
    environment {
        // Packer specific variables for automation
        PACKER_LOG = "1" // Enable detailed output for troubleshooting
        PACKER_NO_COLOR = "1" // Keeps the Jenkins console output clean and readable

        // Your exact repository directory path targeting your Packer template
        DIR_PATH = "builders/vmware/vsphere-iso"     
        TEMPLATE_NAME = "ubuntu-server-26-04/hcl2"                     
    }

    stages {
        stage('Init') {
            steps {
                dir("${env.DIR_PATH}/${env.TEMPLATE_NAME}"){
                    // Downloads required plugins (like the vSphere builder plugin)
                    sh "packer init ."
                    sh "packer version"
                    sh "echo \$PWD"
                    sh "whoami"                    
                }
            }
        }                
        stage('Validate') {
            steps {
                dir("${env.DIR_PATH}/${env.TEMPLATE_NAME}"){
                    // Formats and validates syntax before spinning up infrastructure
                    sh "packer fmt -check ."
                    sh "packer validate ."
                }
            }
        }
        stage('Build Template') {
            options {
                // Protects Jenkins from hanging indefinitely during "waiting for IP" 
                // and "waiting for SSH to become available" phases of Subiquity
                timeout(time: 45, unit: 'MINUTES') 
            }
            steps {
                // Sourcing both your local vCenter secret and the SSH user password hash directly from Vault
                withCredentials([
                    vaultString(credentialsId: 'vcenter_password', variable: 'PKR_VAR_vcenter_password'),
                    vaultString(credentialsId: 'vm_ssh_password_hash', variable: 'PKR_VAR_ssh_password_hash')
                ]) {
                    dir("${env.DIR_PATH}/${env.TEMPLATE_NAME}"){
                        // Packer automatically picks up any environment variable prefixed with PKR_VAR_
                        sh "packer build ."
                    }
                }      
            }
        }
    }
    
    post {
        always {
            // Cleans workspace artifacts on your local Jenkins agent to prevent disk space exhaustion
            cleanWs()
        }
    }
}
