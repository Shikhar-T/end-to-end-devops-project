pipeline {
    agent any

    tools {
        nodejs 'node18'
    }

    environment {
        IMAGE_NAME = "shikhardevops/devops-demo-app"
        IMAGE_TAG  = "${BUILD_NUMBER}"
        K8S_SERVER = "18.139.212.156"
    }

    stages {

        stage('Clean Workspace') {
            steps {
                cleanWs()
            }
        }

        stage('Clone App Repo') {
            steps {
                git branch: 'main',
                url: 'https://github.com/Shikhar-T/devops-demo-app.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t $IMAGE_NAME:$IMAGE_TAG .'
            }
        }

        stage('Push Docker Image') {
            steps {

                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {

                    sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'

                    sh 'docker push $IMAGE_NAME:$IMAGE_TAG'
                }
            }
        }

        stage('Clone Kubernetes Manifest Repo') {
            steps {

                dir('k8s-manifests') {

                    git branch: 'main',
                    url: 'https://github.com/Shikhar-T/k8s-manifests.git'
                }
            }
        }

        stage('Update Deployment YAML') {
            steps {

                dir('k8s-manifests') {

                    sh """
                    sed -i 's|image:.*|image: $IMAGE_NAME:$IMAGE_TAG|' deployment.yaml
                    """

                    sh 'cat deployment.yaml'
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {

                sh """
                scp -o StrictHostKeyChecking=no \
                -i /var/lib/jenkins/my-key.pem \
                k8s-manifests/deployment.yaml \
                k8s-manifests/service.yaml \
                ubuntu@$K8S_SERVER:/home/ubuntu/

                ssh -o StrictHostKeyChecking=no \
                -i /var/lib/jenkins/my-key.pem \
                ubuntu@$K8S_SERVER '
                    kubectl apply -f deployment.yaml
                    kubectl apply -f service.yaml
                '
                """
            }
        }
    }

    post {

        success {

            emailext(
                subject: "SUCCESS: Jenkins Build ${BUILD_NUMBER}",
                body: """
                Job: ${JOB_NAME}

                Build Number: ${BUILD_NUMBER}

                Docker Image:
                ${IMAGE_NAME}:${IMAGE_TAG}

                Deployment Successful.
                """,
                to: "trenu068@gmail.com"
            )
        }

        failure {

            emailext(
                subject: "FAILED: Jenkins Build ${BUILD_NUMBER}",
                body: """
                Job: ${JOB_NAME}

                Build Failed.

                Check Jenkins Logs:
                ${BUILD_URL}
                """,
                to: "trenu068@gmail.com"
            )
        }

        always {
            cleanWs()
        }
    }
}
