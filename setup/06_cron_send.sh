#!/bin/bash
set -e
echo "==== Configurando cron para send.py ===="
(crontab -l 2>/dev/null; echo "*/5 * * * * cd /home/monitoring && ./venv/bin/python send.py") | crontab -
sudo systemctl enable cron
sudo systemctl start cron
