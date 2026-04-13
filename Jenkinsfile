pipeline {
    agent any

    stages {
        stage ('Checkout') {
            steps {
                checkout ([
                    $class: 'GitSCM',
                    branches: [[name: '*/main']],
                    userRemoteConfigs: [[
                       url: 'https://github.com/shettar2025/studentapp.git',
                       credentialsId: 'git-creds'
                    ]]
                ])
            }
        }

        stage ('Build') {
            steps {
                sh 'mvn clean install'
            }
        }

        stage  ('Test') {
            steps {
                sh 'mvn test'
            }
        }

       stage ('Deploy to Artifactory') {
            steps {
                configFileProvider([configFile(fileId: '3ec92838-88d3-46ff-a698-2c596f46fd54', variable: 'MAVEN_SETTINGS'
                )]) {
                    sh 'mvn deploy -s $MAVEN_SETTINGS'
                }
            }
        }

     stage('Download Latest SNAPSHOT WAR and Deploy') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'jfrog-creds', 
                    usernameVariable: 'JFROG_USER', 
                    passwordVariable: 'JFROG_PASS'
                )]) {
                    script {
                        def baseUrl = "http://13.48.147.62:8081/artifactory/libs-snapshot-local"
                        def groupPath = "com/example/studentapp"
                        def artifactId = "studentapp"
                        def version = "1.2-SNAPSHOT"
                        def metadataUrl = "${baseUrl}/${groupPath}/${version}/maven-metadata.xml"

                        sh """
                            set -e

                            echo "Fetching Maven metadata from Artifactory..."
                            curl -u "\$JFROG_USER:\$JFROG_PASS" -s "${metadataUrl}" -o metadata.xml

                            echo "Parsing metadata.xml for timestamp and build number..."
                            TIMESTAMP=\$(grep -oPm1 '(?<=<timestamp>)[^<]+' metadata.xml)
                            BUILDNUM=\$(grep -oPm1 '(?<=<buildNumber>)[^<]+' metadata.xml)

                            echo "TIMESTAMP: \$TIMESTAMP"
                            echo "BUILD NUMBER: \$BUILDNUM"

                            WAR_NAME=${artifactId}-1.2-\${TIMESTAMP}-\${BUILDNUM}.war
                            ARTIFACT_URL=${baseUrl}/${groupPath}/${version}/\$WAR_NAME

                            echo "WAR to download: \$WAR_NAME"
                            echo "Downloading from: \$ARTIFACT_URL"

                            curl -u "\$JFROG_USER:\$JFROG_PASS" -o /tmp/\$WAR_NAME \$ARTIFACT_URL

                            echo "Stopping Tomcat..."
                            sudo /opt/tomcat/tomcat11/bin/shutdown.sh || echo 'Tomcat may already be stopped'

                            echo "Removing old WAR..."
                            sudo rm -f /opt/tomcat/tomcat11/webapps/${artifactId}.war

                            echo "Deploying new WAR to Tomcat webapps..."
                            sudo cp /tmp/\$WAR_NAME /opt/tomcat/tomcat11/webapps/${artifactId}.war

                            echo "Starting Tomcat..."
                            sudo /opt/tomcat/tomcat11/bin/startup.sh || echo 'Tomcat startup might need manual check'

                            echo "Deployment completed successfully: \$WAR_NAME"
                        """
                    }
                }
            }
        }
    }
} 
