pipeline {
    agent any

    triggers {
        githubPush()
    }

    environment {
        APP_IMAGE      = "springapp"
        APP_CONTAINER  = "springapp-container"
        APP_PORT       = "8085"

        TOMCAT_IMAGE     = "tomcat:10.1-jdk17"
        TOMCAT_CONTAINER = "tomcat-container"
        TOMCAT_PORT      = "9090"
    }

    stages {

        // ── 1. Checkout ────────────────────────────────────────
        stage('Checkout') {
            steps {
                echo ">>> Cloning source code from GitHub..."
                checkout scm
                echo "Branch: ${env.GIT_BRANCH}"
                echo "Commit: ${env.GIT_COMMIT}"
            }
        }

        // ── 2. Build JAR with Maven ────────────────────────────
        stage('Build JAR') {
            steps {
                echo ">>> Building Spring Boot JAR..."
                bat 'mvn clean package -DskipTests -B'
                echo ">>> Build complete: target/springapp.jar"
            }
            post {
                success { echo "JAR build SUCCESS" }
                failure { echo "JAR build FAILED" }
            }
        }

        // ── 3. Unit Tests ──────────────────────────────────────
        stage('Test') {
            steps {
                echo ">>> Running unit tests..."
                bat 'mvn test -B'
            }
            post {
                always {
                    junit allowEmptyResults: true,
                          testResults: 'target/surefire-reports/*.xml'
                }
            }
        }

        // ── 4. Build Docker Image ──────────────────────────────
        stage('Docker Build') {
            steps {
                echo ">>> Building Docker image..."
                bat "docker build -t %APP_IMAGE%:%BUILD_NUMBER% -t %APP_IMAGE%:latest ."
            }
        }

        // ── 5. Deploy: Spring App Container ───────────────────
        stage('Deploy App Container') {
            steps {
                echo ">>> Deploying Spring Boot container..."
                bat "docker stop %APP_CONTAINER% || echo container not running"
                bat "docker rm   %APP_CONTAINER% || echo container not found"
                bat "docker run -d --name %APP_CONTAINER% --restart unless-stopped -p %APP_PORT%:8080 %APP_IMAGE%:latest"
            }
        }

        // ── 6. Deploy: Tomcat Container ────────────────────────
        stage('Deploy Tomcat Container') {
            steps {
                echo ">>> Deploying Tomcat container..."
                bat "docker stop %TOMCAT_CONTAINER% || echo container not running"
                bat "docker rm   %TOMCAT_CONTAINER% || echo container not found"
                bat "docker run -d --name %TOMCAT_CONTAINER% --restart unless-stopped -p %TOMCAT_PORT%:8080 %TOMCAT_IMAGE%"
            }
        }
    }

    post {
        success {
            echo "SUCCESS - App: http://localhost:${APP_PORT} | Tomcat: http://localhost:${TOMCAT_PORT}"
        }
        failure {
            echo "PIPELINE FAILED - check stage logs above"
        }
        always {
            bat 'docker image prune -f || echo prune skipped'
        }
    }
}