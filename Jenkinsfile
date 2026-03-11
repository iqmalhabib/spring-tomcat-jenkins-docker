pipeline {
    agent any

    triggers {
        githubPush()
    }

    environment {
        APP_IMAGE     = "springapp"
        APP_CONTAINER = "springapp-container"
        APP_PORT      = "8082"
    }

    stages {

        stage('Checkout') {
            steps {
                echo ">>> Cloning source code from GitHub..."
                checkout scm
                echo "Branch: ${env.GIT_BRANCH}"
                echo "Commit: ${env.GIT_COMMIT}"
            }
        }

        stage('Build JAR') {
            steps {
                echo ">>> Building Spring Boot JAR..."
                bat 'mvn clean package -DskipTests -B'
            }
            post {
                success { echo "JAR build SUCCESS" }
                failure { echo "JAR build FAILED" }
            }
        }

        stage('Test') {
            steps {
                bat 'mvn test -B'
            }
            post {
                always {
                    junit allowEmptyResults: true,
                          testResults: 'target/surefire-reports/*.xml'
                }
            }
        }

        stage('Docker Build') {
            steps {
                echo ">>> Building Docker image..."
                bat "docker build -t %APP_IMAGE%:%BUILD_NUMBER% -t %APP_IMAGE%:latest ."
            }
        }

        stage('Deploy') {
            steps {
                echo ">>> Deploying Spring Boot container..."
                bat "docker stop %APP_CONTAINER% || exit 0"
                bat "docker rm   %APP_CONTAINER% || exit 0"
                bat "docker run -d --name %APP_CONTAINER% --restart unless-stopped -p %APP_PORT%:8080 %APP_IMAGE%:latest"
                echo ">>> App running at http://localhost:${APP_PORT}"
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
            bat 'docker image prune -f || exit 0'
        }
    }
}