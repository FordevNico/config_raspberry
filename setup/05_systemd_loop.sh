#!/bin/bash
set -e
echo "==== Configurando servicio loop.py ===="
cat <<EOF | sudo tee /etc/systemd/system/loop.service
[Unit]
Description=Loop de sensores para monitoreo
After=network.target

[Service]
ExecStart=/home/monitoring/venv/bin/python /home/monitoring/loop.py
WorkingDirectory=/home/monitoring/
EnvironmentFile=/home/monitoring/.env
Restart=always

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable loop.service
sudo systemctl start loop.service
