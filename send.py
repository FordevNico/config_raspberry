import json
import os
import requests
from decouple import config
from logger import get_logger
import time

# === Configuración ===
ARCHIVO_DATOS = config("ARCHIVO_DATOS")
URL_SENALES = config("URL_SENALES")
TOKEN = config("API_TOKEN")
HEADERS = {"Authorization": f"Bearer {TOKEN}"} if TOKEN else {}
CHUNKSIZE = config("CHUNKSIZE", cast=int)

logger = get_logger()

# === Funciones ===


def cargar_batches(path):
    if not os.path.exists(path):
        return []
    with open(path, "r") as f:
        return [json.loads(line) for line in f if line.strip()]


def chunkify(data, size):
    for i in range(0, len(data), size):
        yield data[i:i + size]


def enviar_datos():
    batches = cargar_batches(ARCHIVO_DATOS)
    if not batches:
        logger.info("No hay datos para enviar.")
        return

    plano = [s for batch in batches for s in batch]
    total = len(plano)
    enviados = 0

    for i, chunk in enumerate(chunkify(plano, CHUNKSIZE), start=1):
        try:
            r = requests.post(URL_SENALES, json=chunk,
                              headers=HEADERS, timeout=10)
            r.raise_for_status()
            time.sleep(1)  
            enviados += len(chunk)
            logger.info(f"Chunk {i}: {len(chunk)} señales enviadas.")
        except requests.RequestException as e:
            logger.warning(f"Error al enviar chunk {i}: {e}")
            break

    if enviados == total:
        os.remove(ARCHIVO_DATOS)
        logger.info(f"Archivo eliminado tras enviar {enviados} señales.")
    else:
        logger.warning(
            f"Se enviaron {enviados} de {total} señales. Reintento pendiente.")


if __name__ == "__main__":
    enviar_datos()
