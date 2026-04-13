pipeline {
    agent any

    stages {
        stage ('Checkout') {
            steps {
                checkout ([
                    $class: 'GitSCM',
                    branches: [[name: '*/main']],
                    userRemoteConfigs: [[
                       url: 'https://github.com/SharathKumar-Project/devops-sampleweb.git',
                       credentialsId: 'github_token'
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
                    credentialsId: 'jfrog_pass', 
                    usernameVariable: 'ART_USER', 
                    passwordVariable: 'ART_PASS'
                )]) {
                    script {
                        def baseUrl = "http://13.48.147.62:8081/artifactory/libs-snapshot-local"
                        def groupPath = "com/example/Studentapp"
                        def artifactId = "Studentapp"
                        def version = "1.2-SNAPSHOT"
                        def metadataUrl = "${baseUrl}/${groupPath}/${version}/maven-metadata.xml"

                        sh """
                            set -e

                            echo "Fetching Maven metadata from Artifactory..."
                            curl -u "\$ART_USER:\$ART_PASS" -s "${metadataUrl}" -o metadata.xml

                            echo "Parsing metadata.xml for timestamp and build number..."
                            TIMESTAMP=\$(grep -oPm1 '(?<=<timestamp>)[^<]+' metadata.xml)
                            BUILDNUM=\$(grep -oPm1 '(?<=<buildNumber>)[^<]+' metadata.xml)

                            echo "TIMESTAMP: \$TIMESTAMP"
                            echo "BUILD NUMBER: \$BUILDNUM"

                            WAR_NAME=${artifactId}-1.2-\${TIMESTAMP}-\${BUILDNUM}.war
                            ARTIFACT_URL=${baseUrl}/${groupPath}/${version}/\$WAR_NAME

                            echo "WAR to download: \$WAR_NAME"
                            echo "Downloading from: \$ARTIFACT_URL"

                            curl -u "\$ART_USER:\$ART_PASS" -o /tmp/\$WAR_NAME \$ARTIFACT_URL

                            echo "Stopping Tomcat..."
                            sudo /usr/tomcat/tomcat11/bin/shutdown.sh || echo 'Tomcat may already be stopped'

                            echo "Removing old WAR..."
                            sudo rm -f /usr/tomcat/tomcat11/webapps/${artifactId}.war

                            echo "Deploying new WAR to Tomcat webapps..."
                            sudo cp /tmp/\$WAR_NAME /usr/tomcat/tomcat11/webapps/${artifactId}.war

                            echo "Starting Tomcat..."
                            sudo /usr/tomcat/tomcat11/bin/startup.sh || echo 'Tomcat startup might need manual check'

                            echo "Deployment completed successfully: \$WAR_NAME"
                        """
                    }
                }
            }
        }
    }
} 
