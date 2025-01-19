#!/bin/bash

# Update the package index
sudo apt update

# Install required NVIDIA driver packages
sudo apt install -y nvidia-driver-525 nvidia-dkms-525

# Install NVIDIA Container Toolkit
distribution=$(. /etc/os-release; echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
curl -s -L https://nvidia.github.io/libnvidia-container/$distribution/libnvidia-container.list | \
    sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

# Update the package index again after adding the repository
sudo apt update

# Install NVIDIA Container Toolkit
sudo apt install -y nvidia-container-toolkit

# Configure the runtime for Docker
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker

echo "NVIDIA drivers installed. You must reboot the system to activate the drivers."

# Prompt the user to reboot
while true; do
    read -p "Restart now (y/n)? " REBOOT_CHOICE
    case "${REBOOT_CHOICE,,}" in
        y|yes)
            echo "Restarting machine."
            sudo reboot
            break
            ;;
        n|no)
            echo "Skipping reboot."
            exit 0
            ;;
        *)
            echo "Invalid choice. Please enter 'y' or 'n'."
            ;;
    esac
done
