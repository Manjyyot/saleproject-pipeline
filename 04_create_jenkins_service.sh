#!/bin/bash
set -e

echo "[*] Creating Jenkins systemd service..."

sudo tee /etc/systemd/system/jenkins.service > /dev/null <<EOF
[Unit]
Description=Jenkins WAR Service
After=network.target

[Service]
User=ubuntu
ExecStart=/usr/bin/java -jar /home/ubuntu/jenkins/jenkins.war
Restart=always

[Install]
WantedBy=multi-user.target
EOF

echo "[*] Reloading systemd and enabling Jenkins service..."
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable jenkins
sudo systemctl start jenkins

echo "[✓] Jenkins service started. Check with: sudo systemctl status jenkins"
