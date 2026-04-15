@Library('jenkins-shared-lib') _

pipeline {
    agent any

    parameters {
        string(name: 'IMAGE_TAG', defaultValue: 'latest')
        string(name: 'APP_NAME', defaultValue: 'studentapp')
    }

    environment {
        IMAGE_NAME = "${params.APP_NAME}"
    }

    stages {

        stage('initialize ') {
            steps {
                script {
                    def config = constant(params.APP_NAME)

                    env.ACCOUNT_ID = config.ACCOUNT_ID
                    env.AWS_REGION = config.AWS_REGION
                    env.ECR_REPO   = config.ECR_REPO
                    env.ECR_URL    = config.ECR_URL
                    env.GIT_URL    = config.GIT_URL
                }
            }
        }

        stage('Checkout') {
            steps {
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: '*/main']],
                    userRemoteConfigs: [[
                        url: "${GIT_URL}",
                        credentialsId: 'git-creds'  //stored in jenkins Credentials
                    ]]
                ])
            }
        }

        stage('Build') {
            steps {
                sh 'mvn clean install -DskipTests'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                docker build -t $IMAGE_NAME:$IMAGE_TAG .
                '''
            }
        }

        stage('Login to ECR') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-creds' //stored in jenkins Credentials
                ]]) {
                    sh '''
                    aws ecr get-login-password --region $AWS_REGION | \
                    docker login --username AWS \
                    --password-stdin $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
                    '''
                }
            }
        }

        stage('Push Image') {
            steps {
                sh '''
                docker tag $IMAGE_NAME:$IMAGE_TAG $ECR_URL:$IMAGE_TAG
                docker push $ECR_URL:$IMAGE_TAG
                '''
            }
        }
    }
}
