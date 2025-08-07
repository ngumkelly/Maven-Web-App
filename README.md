# Continuous Integration (CI) Pipeline with Jenkins

## Overview
This repository contains a **Jenkins-powered Continuous Integration (CI) pipeline** for a **Maven-based web application**. The pipeline ensures an automated, efficient, and secure software development workflow.

## 📌 CI Pipeline Architecture:

![image](https://github.com/user-attachments/assets/02b84b8c-cf03-4a24-a10f-c7b44e639538)



The CI pipeline follows a structured approach:
1. **Developer Stage** - Code is pushed to GitHub
2. **Code Management** - Jenkins checks out the latest code
3. **Build Process** - Maven compiles the application
4. **Testing** - Automated tests are executed using Maven
5. **Security & Quality Analysis** - Trivy scans for vulnerabilities & SonarQube performs static code analysis
6. **Quality Gate** - The code is checked against predefined quality standards
7. **Artifact Management** - Packaged artifacts are stored in Nexus
8. **Containerization** - A Docker image is built and pushed to DockerHub

---

## 🛠 Tools & Technologies Used

| Tool | Purpose |
|------|---------|
| **Jenkins** | Automates the CI/CD pipeline execution |
| **GitHub** | Version control system for source code management |
| **Maven** | Build and dependency management tool |
| **SonarQube** | Static code analysis for quality and security checks |
| **Trivy** | Security scanner for detecting vulnerabilities in dependencies |
| **Nexus** | Artifact repository for storing and managing build artifacts |
| **Docker** | Containerization tool for packaging applications |
| **DockerHub** | Cloud-based repository for storing and sharing Docker images |

---

## 🔄 CI Pipeline Breakdown

### 1️⃣ Developer Stage
- The developer pushes code to GitHub.
- Jenkins detects changes using **webhooks** or scheduled triggers.

### 2️⃣ Code Management
- Jenkins pulls the latest source code from the repository.
- Uses `git checkout` to retrieve the branch for building.

### 3️⃣ Build Process
- Maven compiles the project using:
  ```sh
  mvn compile
  ```
- Ensures all dependencies are properly resolved.

### 4️⃣ Testing
- Runs unit tests using Maven:
  ```sh
  mvn test
  ```
- Ensures that core functionalities are working before deployment.

### 5️⃣ Security & Quality Analysis
- **Trivy Scan**: Scans dependencies for vulnerabilities.
  ```sh
  trivy fs --format table -o fs-report.html .
  ```
- **SonarQube Analysis**: Static code analysis for bugs, code smells, and security issues.
  ```sh
  $SCANNER_HOME/bin/sonar-scanner -Dsonar.projectName=web-app \
      -Dsonar.projectKey=webapp \
      -Dsonar.java.binaries=target
  ```

### 6️⃣ Quality Gate
- Jenkins validates the SonarQube report.
- If the quality gate fails, the pipeline stops execution.

### 7️⃣ Artifact Management
- The application is packaged as a JAR/WAR file:
  ```sh
  mvn package
  ```
- The built artifact is pushed to Nexus:
  ```sh
  mvn deploy
  ```

### 8️⃣ Containerization
- A Docker image is built using:
  ```sh
  docker build -t felix081/web_app:v${BUILD_NUMBER} .
  ```
- The image is scanned using Trivy:
  ```sh
  trivy image --format table -o image-report.html felix081/web_app:v${BUILD_NUMBER}
  ```
- The image is pushed to DockerHub:
  ```sh
  docker push felix081/web_app:v${BUILD_NUMBER}
  ```

---

## 🏗 Setting Up the Pipeline in Jenkins

### Prerequisites
Ensure the following tools are installed on your Jenkins server:
- Jenkins with required plugins: **Git, Pipeline, SonarQube, Docker, Trivy, Nexus, Maven Integration**
- SonarQube server configured
- Nexus repository setup
- Docker installed and authenticated with DockerHub

### Creating a Jenkinsfile
Use the following `Jenkinsfile` to define your pipeline:
```groovy
pipeline {
    agent any
    tools {
        maven 'maven3'
    }
    environment {
        SCANNER_HOME = tool 'sonar-scanner'
        IMAGE_TAG = "v${env.BUILD_NUMBER}"  // Corrected IMAGE_TAG reference
    }

    stages {
        stage('Git Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/felix-momodebe-official/maven-web-app.git'
            }
        }
        stage('Compile') {
            steps {
                sh 'mvn compile'
            }
        }
        stage('Unit Test') {
            steps {
                sh 'mvn test'
            }
        }
        stage('Trivy FS') {
            steps {
                sh 'trivy fs --format table -o fs-report.html .'
            }
        }
        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonar-server') {
                    sh '''$SCANNER_HOME/bin/sonar-scanner -Dsonar.projectName=web-app \
                          -Dsonar.projectKey=webapp \
                          -Dsonar.java.binaries=target'''
                }
            }
        }
        stage('Quality Gate Check') {
            steps {
                timeout(time: 1, unit: 'HOURS') {
                    waitForQualityGate abortPipeline: false, credentialsId: 'sonar-token'
                }
            }
        }
        stage('Maven Build') {
            steps {
                sh 'mvn package'
            }
        }
        stage('Publish Artifact') {
            steps {
                withMaven(globalMavenSettingsConfig: 'webapp', maven: 'maven3', traceability: true) {
                    sh 'mvn deploy'
                }
            }
        }
        stage('Docker Build & Tag') {
            steps {
                script {
                    withDockerRegistry(credentialsId: 'docker-cred') {
                        sh 'docker build -t felix081/web_app:$IMAGE_TAG .'
                    }
                }
            }
        }
        stage('Trivy Image Scan') {
            steps {
                sh 'trivy image --format table -o image-report.html felix081/web_app:$IMAGE_TAG'
            }
        }
        stage('Push Docker Image') {
            steps {
                script {
                    withDockerRegistry(credentialsId: 'docker-cred') {
                        sh 'docker push felix081/web_app:$IMAGE_TAG'
                    }
                }
            }
        }
    }
}
```

---

## 📌 Conclusion
This CI pipeline ensures **automated testing, security checks, and artifact management**, leading to **efficient software delivery**. The process enhances development workflows by reducing manual intervention and ensuring **high code quality** before deployment.

💬 **Have questions? Feel free to ask!** 🚀
