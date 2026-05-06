#!/bin/bash

# Update packages
sudo apt update -y

# Install Java
 sudo apt install fontconfig openjdk-21-jre -y

# Install Jenkins
sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian/jenkins.io-2026.key
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc]" \
  https://pkg.jenkins.io/debian binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt update
sudo apt install jenkins -y

# Start Jenkins
sudo systemctl enable jenkins
sudo systemctl start jenkins

# Install Docker
sudo apt install docker.io -y

sudo systemctl start docker
sudo systemctl enable docker

# Give Jenkins Docker permission
sudo usermod -aG docker jenkins
sudo usermod -aG docker ubuntu

# Install Node.js
curl -fsSL https://nodesource.com | sudo -E bash - && sudo apt-get install -y nodejs
