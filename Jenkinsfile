pipeline {
    agent none

    options {
        timestamps()
        disableConcurrentBuilds()
        buildDiscarder(logRotator(numToKeepStr: '10'))
    }

    environment {
        DOCKERHUB_USER = "lakshvar96"
        IMAGE = "onlineshopping"
        GIT_REPO = "https://github.com/Lakshmanan1996/online-shopping-system.git"
    }

    stages {

        /* ===================== CHECKOUT ===================== */
        stage('Checkout Code') {
            agent { label 'workernode1' }
            steps {
                git branch: 'master', url: "${GIT_REPO}"
            }
        }

        /* ===================== STASH ===================== */
        stage('Stash Source') {
            agent { label 'workernode1' }
            steps {
                stash includes: '**/*', name: 'source-code'
            }
        }

        /* ===================== BUILD ===================== */
        stage('Build') {
            steps {
                echo "No build needed for PHP project"
            }
        }

        /* ===================== SONARQUBE ===================== */
        stage('SonarQube Analysis') {
            agent { label 'workernode2' }

            steps {
                unstash 'source-code'

                script {
                    def scannerHome = tool 'SonarQubeScanner'
                    withSonarQubeEnv('sonarqube') {
                        sh """
                        ${scannerHome}/bin/sonar-scanner \
                        -Dsonar.projectKey=shopping \
                        -Dsonar.sources=. \
                        -Dsonar.java.binaries=target
                        """
                    }
                }
            }
        }

        /* ===================== QUALITY GATE ===================== */
        stage('Quality Gate') {
            agent { label 'workernode2' }
            steps {
                timeout(time: 2, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        /* ===================== DOCKER BUILD ===================== */
        stage('Docker Build') {
            agent { label 'workernode3' }

            steps {
                unstash 'source-code'

                sh """
                docker build -t ${DOCKERHUB_USER}/${IMAGE}:${BUILD_NUMBER} .
                docker tag ${DOCKERHUB_USER}/${IMAGE}:${BUILD_NUMBER} ${DOCKERHUB_USER}/${IMAGE}:latest
                """
            }
        }

        /* ===================== TRIVY ===================== */
        stage('Trivy Scan') {
            agent { label 'workernode3' }

            steps {
                sh """
                trivy image --exit-code 0 --severity HIGH,CRITICAL ${DOCKERHUB_USER}/${IMAGE}:${BUILD_NUMBER}
                """
            }
        }

        /* ===================== PUSH ===================== */
        stage('Push Image') {
            agent { label 'workernode3' }

            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {

                    sh """
                    echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                    docker push ${DOCKERHUB_USER}/${IMAGE}:${BUILD_NUMBER}
                    docker push ${DOCKERHUB_USER}/${IMAGE}:latest
                    """
                }
            }
        }
    }

    post {
        success {
            echo "✅ CI/CD Pipeline SUCCESS"
        }
        failure {
            echo "❌ CI/CD Pipeline FAILED"
        }
    }
}
