#!/bin/bash
set -e

echo "==== Instalando Tailscale para Debian Bookworm (modo 4G seguro) ===="

# Paso 1: Arreglar DNS temporalmente si está bloqueado
echo "==> Asegurando configuración de DNS..."
sudo chattr -i /etc/resolv.conf || true
echo -e "nameserver 1.1.1.1\nnameserver 8.8.8.8" | sudo tee /etc/resolv.conf >/dev/null
sudo chattr +i /etc/resolv.conf

# Paso 2: Instalar repositorio oficial (bookworm)
echo "==> Agregando repositorio de Tailscale..."
curl -fsSL https://pkgs.tailscale.com/stable/debian/bookworm.gpg | gpg --dearmor | \
  sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null

echo "deb [signed-by=/usr/share/keyrings/tailscale-archive-keyring.gpg] https://pkgs.tailscale.com/stable/debian bookworm main" | \
  sudo tee /etc/apt/sources.list.d/tailscale.list

sudo apt update
sudo apt install -y tailscale

# Paso 3: Crear servicio systemd personalizado para evitar fallos por DNS
echo "==> Creando servicio tailscale-4g seguro..."
sudo tee /etc/systemd/system/tailscale-4g.service > /dev/null <<EOF
[Unit]
Description=Tailscale daemon adaptado para conexión 4G (SIM7600)
After=network.target

[Service]
ExecStart=/usr/sbin/tailscaled --state=/var/lib/tailscale/tailscaled.state
Restart=always
RestartSec=10
Environment="TS_NO_RESOLV_CONF=true"

[Install]
WantedBy=multi-user.target
EOF

# Paso 4: Habilitar el servicio de daemon
echo "==> Activando tailscaled de forma segura..."
sudo systemctl daemon-reload
sudo systemctl enable --now tailscale-4g

echo ""
echo "==== ✅ Tailscale está listo para autenticarse. ===="
echo "==> Ejecuta manualmente el siguiente paso para conectar el dispositivo:"
echo ""
echo "   sudo tailscale up --accept-dns=false"
echo ""
