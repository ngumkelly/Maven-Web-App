pipeline {
    agent any
    tools {
        jdk 'jdk17'
        maven 'maven3'
    }   
    environment {
        SCANNER_HOME = tool 'sonar-scanner'
        IMAGE_TAG = "v${BUILD_NUMBER}"
        AWS_REGION = "us-east-1"
        CLUSTER_NAME = 'my-web-cluster'
    }
    stages {
        stage('Clean Workspace') {
            steps {
                cleanWs()
            } 
        }
        stage('Checkout from Github') {
            steps {
                git branch: 'main', url: 'https://github.com/kelly-bright09/Maven-Web-App.git'
            }
        }
        stage('Compile') {
            steps {
                sh "mvn compile"
            } 
        }
        stage('Test') {
            steps {
                sh "mvn test"
            } 
        }
        stage('Trivy FS') {
            steps {
                sh "trivy fs . --format table -o fs.html"
            }
        }
        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonar-server') {
                    sh '''$SCANNER_HOME/bin/sonar-scanner \
                        -Dsonar.projectName=maven-web-app \
                        -Dsonar.projectKey=maven-web-app \
                        -Dsonar.java.binaries=target'''
                }
            }
        }
        stage('Quality Gate') {
            steps {
                timeout(time: 1, unit: 'HOURS') {
                    waitForQualityGate abortPipeline: false, credentialsId: 'sonar-token'
                }
            }
        }
        stage('Build') {
            steps {
                sh "mvn package"
            }
        }
        stage('Publish Artifacts') {
            steps {
                withMaven(globalMavenSettingsConfig: 'maven-web-app', jdk: 'jdk17', maven: 'maven3', mavenSettingsConfig: '', traceability: true) {
                    sh "mvn deploy"
                }
            }
        }
        stage('Docker Build and tag') {
            steps {
                script {
                    withDockerRegistry(credentialsId: 'docker-cred2', toolName: 'docker') {
                        sh "docker build -t kelly09/webapp:$IMAGE_TAG ."
                    }
                }
            }
        }
        stage('Trivy Image Scan') {
            steps {
                sh "trivy image --format table -o image-report.html kelly09/webapp:$IMAGE_TAG"  
            }
        }
        stage('Docker push') {
            steps {
                script {
                    withDockerRegistry(credentialsId: 'docker-cred2', toolName: 'docker') {
                        sh "docker push kelly09/webapp:$IMAGE_TAG"
                    }
                }
            }
        }
        stage('Deploy to EKS with kubectl') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-cred',
                    accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                    secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                ]]) {
                    sh '''
                        echo "Updating kubeconfig for EKS..."
                        aws eks update-kubeconfig --region $AWS_REGION --name $CLUSTER_NAME

                        echo "Replacing image tag in deployment.yaml..."
                        sed "s|IMAGE_TAG|$IMAGE_TAG|g" deployment.yaml > deployment-temp.yaml

                        echo "Applying Kubernetes manifests..."
                        kubectl apply -f deployment-temp.yaml
                        kubectl apply -f service.yaml

                        echo "Checking deployment rollout..."
                        kubectl rollout status deployment/web-app
                    '''
                }
            }
        }
    }
}
