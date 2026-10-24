pipeline {
    agent any

    environment {
        // Automatically colorizes Packer console output in Jenkins
        PACKER_LOG  = '1'
        PKR_VAR_ssh_password_hash = credentials('vm-ssh-password-hash')
    }

    stages {
        stage('Checkout') {
            steps {
                // Pulls down your Packer configuration files (.pkr.hcl)
                checkout scm
            }
        }

        stage('Packer Init') {
            steps {
                // Downloads required plugins (like the vSphere plugin)
                sh 'packer init .'
            }
        }

        stage('Packer Validate') {
            steps {
                // Validates syntax and configuration before building
                sh 'packer validate .'
            }
        }

        stage('Packer Build') {
            steps {
                // Executes the build pipeline
                // Passing variables safely from the Jenkins environment block
                sh 'packer build -var "ssh_password_hash=${PKR_VAR_ssh_password_hash}" .'
            }
        }
    }

    post {
        always {
            // Clean up workspace workspace artifacts
            cleanWs()
        }
        success {
            echo 'Packer build completed successfully!'
        }
        failure {
            echo 'Packer build failed. Check console output for debugging logs.'
        }
    }
}
