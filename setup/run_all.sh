#!/bin/bash
set -e
./01_setup_rpi.sh
./02b_sim7600_ppp_autostart.sh
./03_tailscale_autoconnect.sh
./04_deploy_project.sh
./05_systemd_loop.sh
./06_cron_send.sh
echo "==== Ahora debes configurar .env ===="
