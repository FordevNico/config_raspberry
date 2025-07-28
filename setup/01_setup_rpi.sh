#!/bin/bash
set -e
echo "==== Configurando Raspberry Pi ===="
sudo timedatectl set-timezone America/Santiago
sudo apt update && sudo apt full-upgrade -y
sudo apt install -y git curl unzip ppp usb-modeswitch minicom screen python3-venv python3-pip
