@Library('jenkins-shared-lib') _
pipeline {
    agent any
    parameters {
        string(name: 'APP_NAME', defaultValue: 'studentapp')
    }
 
    stages {
        stage('Initialize') {
            steps {
                script {
                    def config = constant(params.APP_NAME)
                    env.ACCOUNT_ID = config.ACCOUNT_ID
                    env.AWS_REGION = config.AWS_REGION
                    env.ECR_REPO   = config.ECR_REPO
                    env.ECR_URL    = config.ECR_URL
                    env.GIT_URL    = config.GIT_URL
                  env.IMAGE_NAME = config.IMAGE_NAME
                }
            }
        }

        stage('Checkout') {
            steps {
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: '*/main']],
                    userRemoteConfigs: [[
                        url: "${env.GIT_URL}",
                        credentialsId: 'git-creds'
                    ]]
                ])
            }
        }

        stage('Build and Extract Version from POM') {
            steps {
                sh 'mvn clean install -DskipTests'
                script {
                    env.IMAGE_TAG = sh(
                        script: "mvn help:evaluate -Dexpression=project.version -q -DforceStdout",
                        returnStdout: true
                    ).trim()
                }
                echo "Detected Version: ${env.IMAGE_TAG}"
            }
        }

        stage('Test') {
            steps {
                sh 'mvn test'
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
                    credentialsId: 'aws-creds'
                ]]) {
                    sh '''
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
                docker tag $IMAGE_NAME:$IMAGE_TAG \
      $ECR_URL/$ECR_REPO:$IMAGE_TAG
                '''
            }
}
        stage('Push to ECR') {
            steps {
                       sh '''
        docker push $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO:$IMAGE_TAG
                '''
                }
              }
           }
    post {
        always {
            sh 'docker logout || true'
            sh "docker rmi $IMAGE_NAME:${env.IMAGE_TAG} || true"
        }
    }
}
