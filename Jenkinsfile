pipeline {
    agent any

    triggers {
        githubPush()
    }

    environment {
        APP_IMAGE     = "tomcat-jenkins"
        APP_CONTAINER = "tomcat-jenkins-container"
        APP_PORT      = "8082"
    }

    stages {

        // ── 1. Checkout ──────────────────────────────────────
        stage('Checkout') {
            steps {
                echo ">>> Cloning source code from GitHub..."
                checkout scm
                echo "Branch: ${env.GIT_BRANCH}"
                echo "Commit: ${env.GIT_COMMIT}"
            }
        }

        // ── 2. Build JAR ─────────────────────────────────────
        stage('Build JAR') {
            steps {
                echo ">>> Building Spring Boot JAR..."
                bat 'mvn clean package -DskipTests -B'
                echo ">>> JAR ready: target/tomcat-jenkins.jar"
            }
        }

        // ── 3. Test ──────────────────────────────────────────
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

        // ── 4. Docker Build ───────────────────────────────────
        stage('Docker Build') {
            steps {
                echo ">>> Building Docker image..."
                bat "docker build -t %APP_IMAGE%:%BUILD_NUMBER% -t %APP_IMAGE%:latest ."
            }
        }

        // ── 5. Deploy ─────────────────────────────────────────
        // Spring Boot JAR already has embedded Tomcat inside.
        // No need for a separate Tomcat container.
        stage('Deploy') {
            steps {
                echo ">>> Deploying Spring Boot container (embedded Tomcat on port ${APP_PORT})..."
                bat "docker stop %APP_CONTAINER% || echo container not running"
                bat "docker rm   %APP_CONTAINER% || echo container not found"
                bat "docker run -d --name %APP_CONTAINER% --restart unless-stopped -p %APP_PORT%:8082 %APP_IMAGE%:latest"
                echo ">>> App running at http://localhost:${APP_PORT}"
            }
        }

        // ── 6. Smoke Test ─────────────────────────────────────
        stage('Smoke Test') {
            steps {
                echo ">>> Waiting for app to start..."
                bat 'ping -n 15 127.0.0.1 > nul'
                bat "curl -f http://localhost:%APP_PORT%/health && echo SMOKE TEST PASSED || echo SMOKE TEST FAILED"
            }
        }
    }

    post {
        success {
            echo "SUCCESS - App: http://localhost:${APP_PORT}/health"
        }
        failure {
            echo "PIPELINE FAILED - check stage logs above"
        }
        always {
            bat 'docker image prune -f || echo prune skipped'
        }
    }
}