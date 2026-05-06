pipeline {
    agent any
    tools {
        nodejs 'node18'
    }
    environment {
        IMAGE_NAME = "shikhardevops/devops-demo-app"
        IMAGE_TAG = "${BUILD_NUMBER}"
        K8S_IP = "YOUR_ACTUAL_IP_HERE" // Added this
    }
    stages {
        stage('Clean Workspace') {
            steps { cleanWs() }
        }
        stage('Clone Code') {
            steps {
                git branch: 'main', url: 'https://github.com/Shikhar-T/devops-demo-app.git'
            }
        }
        stage('Build Docker Image') {
            steps {
                sh 'docker build -t $IMAGE_NAME:$IMAGE_TAG .'
            }
        }
        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
                    sh 'docker push $IMAGE_NAME:$IMAGE_TAG'
                }
            }
        }
        stage('Deploy to Kubernetes') {
            steps {
                sh """
                ssh -o StrictHostKeyChecking=no -i /var/lib/jenkins/my-key.pem ubuntu@18.139.212.156 '
                    kubectl rollout resume deployment/devops-demo-deployment || true
                    kubectl set image deployment/devops-demo-deployment devops-demo-container=$IMAGE_NAME:$IMAGE_TAG
                '
                """
            }
        }
    }
    post {
        success {
            emailext (
                subject: "SUCCESS: Jenkins Build ${BUILD_NUMBER}",
                body: "Job: ${JOB_NAME} | Build: ${BUILD_NUMBER} | Image: ${IMAGE_NAME}:${IMAGE_TAG}",
                to: "trenu068@gmail.com"
            )
        }
        failure {
            emailext (
                subject: "FAILED: Jenkins Build ${BUILD_NUMBER}",
                body: "Build failed. Check logs at ${BUILD_URL}",
                to: "trenu068@gmail.com"
            )
        }
        always { cleanWs() }
    }
}
