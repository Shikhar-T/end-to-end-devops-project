# End-to-End DevOps CI/CD Project on AWS using Terraform, Jenkins, Docker, Kubernetes, Prometheus & Grafana

![Architecture](./screenshots/full-project-architecture.png)

---

# Project Overview

This project demonstrates a complete end-to-end DevOps CI/CD pipeline built using open-source and cloud-native tools.

The goal of this project was to automate:

* Infrastructure provisioning
* Application build & deployment
* Containerization
* Kubernetes deployment
* Monitoring & alerting
* Continuous Integration & Continuous Deployment (CI/CD)

The complete infrastructure was provisioned on AWS EC2 instances using Terraform.

---

#Architecture Flow

```text
Developer Pushes Code to GitHub
            ↓
GitHub Webhook Triggers Jenkins
            ↓
Jenkins Clones Latest Code
            ↓
Docker Image Build
            ↓
Docker Image Push to DockerHub
            ↓
Jenkins SSH into Kubernetes Server
            ↓
Kubernetes Deployment Updated
            ↓
Rolling Update Creates New Pods
            ↓
Application Updated Automatically
            ↓
Prometheus Collects Metrics
            ↓
Grafana Visualizes Monitoring Dashboards
            ↓
Jenkins Sends Email Notifications
```

---

#Tech Stack Used

| Category                | Tools                 |
| ----------------------- | --------------------- |
| Cloud Provider          | AWS EC2               |
| Infrastructure as Code  | Terraform             |
| CI/CD                   | Jenkins               |
| Containerization        | Docker                |
| Container Registry      | DockerHub             |
| Container Orchestration | Kubernetes (Minikube) |
| Monitoring              | Prometheus            |
| Visualization           | Grafana               |
| Alerts                  | Gmail SMTP            |
| Code Repository         | GitHub                |
| Version Control         | Git                   |
---

# Repository Structure

```text
end-to-end-devops-project/
│
├── terraform/
│   ├── jenkins-server/
│   │      ├── main.tf
│   │      ├── variables.tf
│   │      └── install.sh
│   │
│   ├── k8s-server/
│   │      ├── main.tf
│   │      ├── variables.tf
│   │      └── install.sh
│   │
│   └── monitoring-server/
│          ├── main.tf
│          ├── variables.tf
│          └── install.sh
│
├── k8s-manifests/
│      ├── deployment.yaml
│      └── service.yaml
│
├── Jenkinsfile
│
├── screenshots/
│
└── README.md
```

---

#Infrastructure Provisioning using Terraform

Terraform was used to provision multiple EC2 instances:

* Jenkins Server
* Kubernetes Server
* Monitoring Server

## Example Terraform Configuration

```hcl
provider "aws" {
  region = var.aws_region
}

resource "aws_instance" "jenkins_server" {
  ami           = "ami-xxxxxxxx"
  instance_type = "t3.micro"
  key_name      = var.key_name

  tags = {
    Name = "jenkins-server"
  }
}
```

---

#AWS Infrastructure

![AWS EC2 Instances](./screenshots/AWS%20EC2%20instances.png)

---

#Automated Server Setup using install.sh

Bootstrap scripts were used to automate server setup.

The scripts installed:

* Java
* Jenkins
* Docker
* NodeJS
* Minikube
* kubectl
* Prometheus
* Grafana
* Node Exporter

This reduced manual setup effort and made infrastructure reproducible.

---

# Jenkins CI/CD Pipeline

The Jenkins pipeline performs:

1. Clean Workspace
2. Clone Latest Code
3. Build Docker Image
4. Push Docker Image to DockerHub
5. Deploy Latest Image to Kubernetes
6. Send Email Notifications

## Jenkins Pipeline Snippet

```groovy
pipeline {
    agent any

    stages {

        stage('Clone Code') {
            steps {
                git branch: 'main', url: 'https://github.com/YOUR_GITHUB_USERNAME/YOUR_APP_REPO.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t $IMAGE_NAME:$IMAGE_TAG .'
            }
        }

        stage('Push Docker Image') {
            steps {
                sh 'docker push $IMAGE_NAME:$IMAGE_TAG'
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                sh '''
                ssh -o StrictHostKeyChecking=no -i /var/lib/jenkins/my-key.pem ubuntu@K8S_SERVER_IP \
                "kubectl set image deployment/devops-demo-deployment devops-demo-container=$IMAGE_NAME:$IMAGE_TAG"
                '''
            }
        }
    }
}
```

---

# Jenkins Pipeline Success

![Pipeline Success](./screenshots/pipeline_success.png)

---

# Docker Image Build & Push

Docker was used to containerize the application.

Each build generated a unique image tag using Jenkins build numbers.

Example:

```text
shikhardevops/devops-demo-app:5
shikhardevops/devops-demo-app:6
```

This helped maintain image version history and enabled rollback capability.

---

# DockerHub Images

![DockerHub Images](./screenshots/dockerhub_pushed_images.png)

---

#Kubernetes Deployment

The application was deployed on Minikube hosted inside an AWS EC2 instance.

Kubernetes manifests used:

* deployment.yaml
* service.yaml

## deployment.yaml

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: devops-demo-deployment
spec:
  replicas: 2
  selector:
    matchLabels:
      app: devops-demo
  template:
    metadata:
      labels:
        app: devops-demo
    spec:
      containers:
      - name: devops-demo-container
        image: shikhardevops/devops-demo-app:latest
        ports:
        - containerPort: 80
```

---

## service.yaml

```yaml
apiVersion: v1
kind: Service
metadata:
  name: devops-demo-service
spec:
  type: NodePort
  selector:
    app: devops-demo
  ports:
    - port: 80
      targetPort: 80
      nodePort: 30007
```

---

# Kubernetes Commands Output

![Kubernetes Commands](./screenshots/k8s_commands.png)

---

# Accessing Application Output

Since Minikube was hosted inside an EC2 instance, NodePort networking behaved differently in this setup.

To expose the application externally, Kubernetes port-forwarding was used.

## Port Forward Command

```bash
kubectl port-forward service/devops-demo-service 8081:80 --address 0.0.0.0
```

## Access URL

```text
http://<K8S_PUBLIC_IP>:8081
```

---

# Application Output

![Application Output](./screenshots/Application_Output.png)

---

# Monitoring Setup

Monitoring stack used:

* Node Exporter
* Prometheus
* Grafana

## Monitoring Flow

```text
Linux Server
    ↓
Node Exporter
    ↓
Prometheus
    ↓
Grafana Dashboard
```

Prometheus scraped metrics from:

* Jenkins Server
* Kubernetes Server
* Node Exporter

---

# Prometheus Targets

![Prometheus Targets](./screenshots/prometheus-all-up.png)

---

# Grafana Dashboards

## Jenkins Server Monitoring

![Grafana Jenkins](./screenshots/grafana-jenkins%20server.png)

---

## Kubernetes Server Monitoring

![Grafana K8s](./screenshots/grafana-k8s-server.png)

---

## Node Exporter Metrics

![Grafana Node Exporter](./screenshots/grafana-node_exporter.png)

---

# Email Notifications

Jenkins email notifications were configured using Gmail SMTP.

Automatic alerts were sent for:

* Successful builds
* Failed builds

---

# Build Success Mail

![Success Mail](./screenshots/success-mail.png)

---

# Challenges Faced During the Project

## 1. Jenkins Could Not Access Kubernetes API

### Problem

Minikube used internal networking:

```text
192.168.x.x
```

which was not accessible externally from Jenkins.

### Solution

Implemented SSH-based deployment where Jenkins remotely executed kubectl commands on the Kubernetes server.

---

## 2. Gmail SMTP Connection Issue

### Problem

SMTP SSL configuration caused email connection failures.

### Solution

Configured TLS using:

* Port 587
* Gmail App Password

---

## 3. NodePort Accessibility Issue

### Problem

NodePort was not directly accessible due to Minikube networking behavior on EC2.

### Solution

Used:

```bash
kubectl port-forward
```

for external application access.

---

# Final Outcome

This project successfully demonstrated:

- Infrastructure as Code using Terraform
- CI/CD automation using Jenkins
- Docker containerization
- Kubernetes deployment automation
- Monitoring using Prometheus & Grafana
- Email alerting system
- GitHub webhook integration
- Rolling deployments in Kubernetes

---

# Application Repository

Application Source Code Repository:

```text
https://github.com/Shikhar-T/devops-demo-app.git
```

---

# Author

Shikhar Tiwari
