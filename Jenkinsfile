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
                checkout([$class: 'GitSCM',
                    branches: [[name: 'master']],
                    userRemoteConfigs: [[url: "${GIT_REPO}"]]
                ])
            }
        }

        /* ===================== STASH SOURCE ===================== */
        stage('Stash Source') {
            agent { label 'workernode1' }
            steps {
                stash includes: '**/*', name: 'source-code'
            }
        }

        /* ===================== Build Maven single Stage ===================== */
        stage('Build') {
            agent { label 'workernode2'}
            tools {
                maven 'maven'
            }

            steps {
                unstash 'source-code'
                sh 'mvn clean install -DskipTests'
            
        }


        

        /* ===================== SONARQUBE ===================== */
        stage('SonarQube Analysis') {
            agent { label 'workernode2' }
            steps {
                unstash 'source-code'

                script {
                    def scannerHome = tool 'SonarQubeScanner'
                    withSonarQubeEnv('sonarqube') {
                        
                            
                            }
                        }
                    }
                }
            }

        /*===================== QUALITY GATE ===================== */
        
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
                # Build
                docker build -t ${DOCKERHUB_USER}/${IMAGE}:${BUILD_NUMBER} .
                docker tag ${DOCKERHUB_USER}/${IMAGE}:${BUILD_NUMBER} ${DOCKERHUB_USER}/${IMAGE}:latest

               
                """
            }
        }

        /* ===================== TRIVY SCAN ===================== */
        stage('Trivy Scan') {
            agent { label 'workernode3' }
            steps {
                sh """
                 trivy image --exit-code 0 --severity HIGH,CRITICAL ${DOCKERHUB_USER}/${IMAGE}:${BUILD_NUMBER}
                 
                """
            }
        }

        /* ===================== PUSH TO DOCKER HUB ===================== */
        stage('Push Image') {
            agent { label 'workernode3' }
            steps {
                unstash 'source-code'

                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
                }

                sh """
                docker push ${DOCKERHUB_USER}/${IMAGE}:${BUILD_NUMBER}
                docker push ${DOCKERHUB_USER}/${IMAGE}:latest

                
                """
            }
        }
    }

    post {
        success {
            echo "✅ portal Pipeline SUCCESS"
        }
        failure {
            echo "❌ portal CI Pipeline FAILED"
        }
    }
}
