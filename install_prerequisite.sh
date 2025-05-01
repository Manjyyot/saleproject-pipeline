#!/bin/bash
set -euo pipefail

# Function to print section headers
log() {
    echo
    echo "====> $1"
}

# System Update & Upgrade
log "Updating and upgrading system packages"
sudo apt update && sudo apt upgrade -y

# Java Installation
log "Installing Java 17 JDK"
sudo apt install -y openjdk-17-jdk
java -version

# Jenkins Setup
log "Setting up Jenkins directory and downloading WAR"
JENKINS_DIR="$HOME/jenkins"
JENKINS_WAR_URL="https://get.jenkins.io/war-stable/2.492.1/jenkins.war"
mkdir -p "$JENKINS_DIR"
cd "$JENKINS_DIR"
wget -O jenkins.war "$JENKINS_WAR_URL"

# Git Installation
log "Installing Git"
sudo apt install -y git

# Clone or update Terraform repo
log "Cloning or updating Terraform repository"
REPO_NAME="SaleProject"
REPO_URL="https://github.com/Manjyyot/SaleProject.git"

cd "$HOME"

if [ -d "$REPO_NAME" ]; then
    if [ -d "$REPO_NAME/.git" ]; then
        log "Updating existing Git repository: $REPO_NAME"
        cd "$REPO_NAME"
        git pull origin main
        cd ..
    else
        echo "Warning: '$REPO_NAME' exists but is not a Git repository. Skipping update."
    fi
else
    git clone "$REPO_URL"
fi

# Docker Installation
log "Installing Docker"
sudo apt install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
  https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io

log "Adding Jenkins & Ubuntu user to Docker group"
sudo usermod -aG docker ubuntu || true
sudo usermod -aG docker jenkins || true

log "Enabling and starting Docker"
sudo systemctl enable docker
sudo systemctl start docker

log "Setup complete."
