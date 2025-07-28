#!/bin/bash
set -e
echo "==== Clonando y desplegando proyecto desde Git ===="

# 1. Elimina si ya existía (opcional, para evitar conflictos)
if [ -d /home/monitoring ]; then
    echo "Directorio /home/monitoring ya existe. Eliminando..."
    sudo rm -rf /home/monitoring
fi

# 2. Clonar el repo en carpeta destino
git clone https://github.com/FordevNico/config_raspberry.git /home/monitoring

# 3. Entrar al directorio y configurar entorno virtual
cd /home/monitoring
echo "==== Creando entorno virtual ===="
python3 -m venv venv
source venv/bin/activate

# 4. Instalar dependencias
echo "==== Instalando dependencias ===="
pip install --upgrade pip
pip install -r requirements.txt

# 5. Crear archivo de entorno (manual)
echo "==== Edita el archivo .env según el dispositivo ===="
nano .env
