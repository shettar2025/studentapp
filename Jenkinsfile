pipeline {
    environment {
        AWS_REGION = 'eu-north-1'
        ACCOUNT_ID = '438987840260'
        ECR_REPO = 'studentapp-repo'
        ECR_URL = "438987840260.dkr.ecr.eu-north-1.amazonaws.com/studentapp-repo"
        IMAGE_NAME = 'studentapp:latest'
    }

    agent any

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
                sh 'docker build -t studentapp:latest .'
            }
        }

        stage('Login to ECR') {
            steps {
                sh '''
                aws ecr get-login-password --region $AWS_REGION | \
                docker login --username AWS \
                --password-stdin $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
                '''
            }
        }

        stage('Tag Docker Image') {
            steps {
                sh '''
                docker tag studentapp:latest $ECR_URL:latest
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
