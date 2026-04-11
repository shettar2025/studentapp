pipeline {
    agent any

    environment {
        AWS_REGION = 'eu-north-1'
        AWS_ACCOUNT_ID = '438987840260'
        ECR_REPO = 'tomcat-app'
        IMAGE_TAG = "${BUILD_NUMBER}"
        JFROG_URL = 'http://56.228.33.195:8081/artifactory'
    }

    stages {

        stage('Checkout') {
            steps {
                git url:'https://github.com/shettar2025/studentapp.git',
                    branch: 'main',
                    credentialsId: 'git-creds'
            }
        }

        stage('Build') {
            steps {
                sh 'mvn clean package'
            }
        }

        stage('Test') {
            steps {
                sh 'mvn test'
            }
        }

        stage('Build & Deploy') {
            steps {
                configFileProvider([configFile(fileId: 'maven-settings', variable: 'MAVEN_SETTINGS')]) {
                    sh 'mvn clean deploy -s $MAVEN_SETTINGS'
                }
            }
     
        stage('Upload to JFrog') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'jfrog-creds',
                    usernameVariable: 'JF_USER',
                    passwordVariable: 'JF_PASS'
                )]) {
                    sh """
                    curl -u $JF_USER:$JF_PASS -T target/studentapp.war \
                    ${JFROG_URL}/libs-release-local/studentapp-${BUILD_NUMBER}.war
                    """
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    docker.build("tomcat-app:${IMAGE_TAG}")
                }
            }
        }

        stage('Login to AWS ECR') {
            steps {
                withCredentials([
                    [$class: 'AmazonWebServicesCredentialsBinding',
                     credentialsId: 'aws-creds']
                ]) {
                    sh """
                    aws ecr get-login-password --region $AWS_REGION | \
                    docker login --username AWS --password-stdin \
                    ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
                    """
                }
            }
        }

        stage('Tag & Push to ECR') {
            steps {
                sh """
                docker tag tomcat-app:${IMAGE_TAG} \
                ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}:${IMAGE_TAG}

                docker push \
                ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}:${IMAGE_TAG}
                """
            }
        }
    }

    post {
        success {
            echo "CI Pipeline completed successfully!"
        }
        failure {
            echo "Pipeline failed!"
        }
    }
}
