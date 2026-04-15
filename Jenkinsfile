pipeline {
     agent any
    parameters {
        string(name: 'AWS_REGION', defaultValue: 'eu-north-1', description: 'AWS Region')
        string(name: 'ACCOUNT_ID', defaultValue: '', description: 'AWS Account ID')
        string(name: 'ECR_REPO', defaultValue: 'studentapp-repo', description: 'ECR Repo Name')
        string(name: 'IMAGE_TAG', defaultValue: 'latest', description: 'Docker Image Tag')
    }
    environment {
        AWS_REGION = 'eu-north-1'
        ACCOUNT_ID = '438987840260'
        ECR_REPO = 'studentapp-repo'
        ECR_URL = "438987840260.dkr.ecr.eu-north-1.amazonaws.com/studentapp-repo"
        IMAGE_NAME = 'studentapp:latest'
    }
    stages {

        stage('Checkout') {
            steps {
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: '*/main']],
                    userRemoteConfigs: [[
                        url: 'https://github.com/shettar2025/studentapp.git',
                        credentialsId: 'git-creds'
                    ]]
                ])
            }
        }

        stage('Build') {
            steps {
                sh 'mvn clean install'
            }
        }

        stage('Test') {
            steps {
                sh 'mvn test'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t IMAGE_NAME .'
            }
        }

     stage('Login to ECR') {
    steps {
        withCredentials([[
            $class: 'AmazonWebServicesCredentialsBinding',
            credentialsId: 'aws-creds'
        ]]) {
            sh '''
                aws sts get-caller-identity

                aws ecr get-login-password --region $AWS_REGION | \
                docker login --username AWS \
                --password-stdin $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
            '''
        }
    }
}
        stage('Tag Docker Image') {
            steps {
                sh '''
                docker tag $IMAGE_NAME $ECR_URL:$IMAGE_TAG'
               ''' 
            }
        }

        stage('Push to ECR') {
            steps {
                sh '''
                docker push $ECR_URL:latest
              '''  
            }
        }
    }
}
