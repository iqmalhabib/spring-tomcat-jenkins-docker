pipeline {
    agent any

    triggers {
        githubPush()
    }

    environment {
        APP_NAME      = "tomcat-jenkins"
        APP_PORT      = "8082"
        // Folder where JAR will be copied and run from
        DEPLOY_DIR    = "C:\\deployments\\tomcat-jenkins"
        JAR_NAME      = "tomcat-jenkins.jar"
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
                echo ">>> JAR ready: target\\tomcat-jenkins.jar"
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

        // ── 4. Stop Old App ───────────────────────────────────
        stage('Stop Old App') {
            steps {
                echo ">>> Stopping old running instance..."
                // Kill any process running on APP_PORT
                bat """
                    for /f "tokens=5" %%a in ('netstat -aon ^| find ":%APP_PORT%" ^| find "LISTENING"') do (
                        echo Killing PID %%a
                        taskkill /F /PID %%a
                    )
                    echo Done stopping old app
                """
            }
        }

        // ── 5. Copy JAR to Deploy Folder ─────────────────────
        stage('Copy JAR') {
            steps {
                echo ">>> Copying JAR to deployment folder..."
                bat "if not exist %DEPLOY_DIR% mkdir %DEPLOY_DIR%"
                bat "copy /Y target\\%JAR_NAME% %DEPLOY_DIR%\\%JAR_NAME%"
                echo ">>> JAR copied to ${DEPLOY_DIR}"
            }
        }

        // ── 6. Run App ────────────────────────────────────────
        stage('Run App') {
            steps {
                echo ">>> Starting Spring Boot app on port ${APP_PORT}..."
                // Start app in background using start /B
                bat """
                    cd %DEPLOY_DIR%
                    start /B java -jar %JAR_NAME% --server.port=%APP_PORT% > app.log 2>&1
                """
                echo ">>> App started! Log: ${DEPLOY_DIR}\\app.log"
            }
        }


    }

    post {
        success {
            echo "SUCCESS - App running at http://localhost:${APP_PORT}/health"
            echo "Logs at: ${DEPLOY_DIR}\\app.log"
        }
        failure {
            echo "PIPELINE FAILED - check stage logs above"
        }
    }
}