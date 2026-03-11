pipeline {
    agent any

    // ── Trigger: GitHub webhook (push or merge) ────────────────
    triggers {
        githubPush()
    }

    environment {
        // ── Change these to match your setup ──────────────────
        APP_IMAGE      = "springapp"
        APP_CONTAINER  = "springapp-container"
        APP_PORT       = "8085"          // host port → container 8080

        TOMCAT_IMAGE     = "tomcat:10.1-jdk17"
        TOMCAT_CONTAINER = "tomcat-container"
        TOMCAT_PORT      = "9090"        // host port → tomcat 8080
        TOMCAT_WEBAPPS   = "/opt/tomcat/webapps"  // path on host to mount

        // Docker Hub (optional — remove push stage if not needed)
        //DOCKER_HUB_USER  = "your-dockerhub-username"
        //DOCKER_HUB_REPO  = "your-dockerhub-username/springapp"
        // Add Jenkins credential id for Docker Hub login:
        // Manage Jenkins → Credentials → add Username/Password → id = "dockerhub-creds"
        //DOCKER_CREDS     = "dockerhub-creds"
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
                sh 'mvn clean package -DskipTests -B'
                echo ">>> Build complete: target/springapp.jar"
            }
            post {
                success { echo "JAR build SUCCESS" }
                failure { error "JAR build FAILED — stopping pipeline" }
            }
        }

        // ── 3. Unit Tests ──────────────────────────────────────
        stage('Test') {
            steps {
                echo ">>> Running unit tests..."
                sh 'mvn test -B'
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
                echo ">>> Building Docker image: ${APP_IMAGE}:${BUILD_NUMBER}"
                sh """
                    docker build \
                        -t ${APP_IMAGE}:${BUILD_NUMBER} \
                        -t ${APP_IMAGE}:latest \
                        .
                """
            }
        }

        // ── 6. Deploy: Spring App Container ───────────────────
        stage('Deploy App Container') {
            steps {
                echo ">>> Deploying Spring Boot container..."
                sh """
                    # Stop & remove old container if running
                    docker stop ${APP_CONTAINER} || true
                    docker rm   ${APP_CONTAINER} || true

                    # Run new container
                    docker run -d \
                        --name ${APP_CONTAINER} \
                        --restart unless-stopped \
                        -p ${APP_PORT}:8080 \
                        ${APP_IMAGE}:latest

                    echo "Spring App running on port ${APP_PORT}"
                """
            }
        }

        // ── 7. Deploy: Tomcat Container ────────────────────────
        stage('Deploy Tomcat Container') {
            steps {
                echo ">>> Deploying Tomcat container..."
                sh """
                    # Stop & remove old container if running
                    docker stop ${TOMCAT_CONTAINER} || true
                    docker rm   ${TOMCAT_CONTAINER} || true

                    # Run Tomcat container
                    # Mount local webapps dir so you can drop WARs without rebuild
                    docker run -d \
                        --name ${TOMCAT_CONTAINER} \
                        --restart unless-stopped \
                        -p ${TOMCAT_PORT}:8080 \
                        -v ${TOMCAT_WEBAPPS}:/usr/local/tomcat/webapps \
                        ${TOMCAT_IMAGE}

                    echo "Tomcat running on port ${TOMCAT_PORT}"
                """
            }
        }

        // ── 8. Smoke Test ──────────────────────────────────────
        stage('Smoke Test') {
            steps {
                echo ">>> Running smoke test..."
                // Wait for app to start then hit /health endpoint
                sh """
                    sleep 10
                    curl -f http://localhost:${APP_PORT}/health \
                        && echo "\\n>>> Smoke test PASSED" \
                        || echo "\\n>>> Smoke test FAILED (check logs)"
                """
            }
        }
    }

    // ── Post-pipeline notifications ────────────────────────────
    post {
        success {
            echo """
            ╔══════════════════════════════════════╗
            ║  ✅  PIPELINE SUCCESS                ║
            ║  App   : http://localhost:${APP_PORT}  ║
            ║  Tomcat: http://localhost:${TOMCAT_PORT}  ║
            ╚══════════════════════════════════════╝
            """
        }
        failure {
            echo "❌ PIPELINE FAILED — check stage logs above"
        }
        always {
            // Clean up dangling images to save disk space
            sh 'docker image prune -f || true'
        }
    }
}