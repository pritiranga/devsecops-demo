#!/bin/bash

# Update the package index
echo "Updating package index..."
sudo apt-get update -y

# Install Ruby
echo "Installing Ruby..."
sudo apt-get install ruby -y

# Install Wget
echo "Installing wget..."
sudo apt-get install wget -y

# Download the CodeDeploy agent installer
echo "Downloading CodeDeploy agent installer..."
cd /home/ubuntu
wget https://aws-codedeploy-eu-north-1.s3.eu-north-1.amazonaws.com/latest/install

# Make the installer executable
echo "Making the installer executable..."
chmod +x ./install

# Run the installation script
echo "Running the installation script..."
sudo ./install auto

# Verify the installation
echo "Verifying CodeDeploy agent installation..."
sudo service codedeploy-agent status

# Start the CodeDeploy agent if it is not running
echo "Starting CodeDeploy agent..."
sudo service codedeploy-agent start

# Enable the CodeDeploy agent to start on boot
echo "Enabling CodeDeploy agent to start on boot..."
sudo systemctl enable codedeploy-agent

echo "CodeDeploy agent installation and setup complete."
