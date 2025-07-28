#!/bin/bash
set -e

echo "==== Configurando SIM7600 PPP y conexión automática (Waveshare) ===="

# 1. Crear archivo de configuración PPP (provider)
echo "==== Creando archivo /etc/ppp/peers/provider ===="
sudo tee /etc/ppp/peers/provider > /dev/null <<EOF
/dev/ttyUSB3
115200
connect "/usr/sbin/chat -v -f /etc/chatscripts/sim7600-connect"
disconnect "/usr/sbin/chat -v -f /etc/chatscripts/sim7600-disconnect"
crtscts
modem
noauth
defaultroute
replacedefaultroute
usepeerdns
persist
EOF

# 2. Crear script de conexión (chat)
echo "==== Creando script de conexión /etc/chatscripts/sim7600-connect ===="
sudo tee /etc/chatscripts/sim7600-connect > /dev/null <<EOF
ABORT "BUSY"
ABORT "NO CARRIER"
ABORT "ERROR"
"" AT
OK ATE0
OK AT+CGDCONT=1,"IP","bam.clarochile.cl"
OK ATD*99#
CONNECT ""
EOF

# 3. Crear script de desconexión (simple)
echo "==== Creando script de desconexión /etc/chatscripts/sim7600-disconnect ===="
sudo tee /etc/chatscripts/sim7600-disconnect > /dev/null <<EOF
"" +++ATH
EOF

# 4. Ajustar permisos
sudo chmod +x /etc/chatscripts/sim7600-connect
sudo chmod +x /etc/chatscripts/sim7600-disconnect

# 5. Conectar manualmente por primera vez
echo "==== Iniciando conexión PPP manualmente ===="
sudo pon provider
sleep 5
curl -s ifconfig.me || echo "⚠️ No se pudo obtener IP pública. Revisa el APN, señal o SIM."

# 6. Crear servicio systemd para reconexión automática
echo "==== Creando servicio systemd para conexión automática PPP ===="
sudo tee /etc/systemd/system/ppp-connect.service > /dev/null <<EOF
[Unit]
Description=Conexión automática SIM7600 PPP (Waveshare)
After=network.target

[Service]
ExecStart=/usr/sbin/pon provider
ExecStop=/usr/sbin/poff provider
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# 7. Activar y arrancar el servicio
sudo systemctl daemon-reload
sudo systemctl enable ppp-connect
sudo systemctl start ppp-connect

echo "✅ Conexión PPP activa y habilitada para reinicio automático."
