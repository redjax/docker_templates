#!/bin/bash

sudo dnf install -y akmod-nvidia

curl -s -L https://nvidia.github.io/libnvidia-container/stable/rpm/nvidia-container-toolkit.repo \
    | sudo tee /etc/yum.repos.d/nvidia-container-toolkit.repo

sudo yum install -y nvidia-container-toolkit

sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker

echo "NVIDIA drivers installed. You must reboot the system to activate the drivers."

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
