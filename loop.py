import time
import json
import plc_control
from structure import plc_map
from decouple import config
from logger import get_logger
from datetime import datetime, timezone

# === Configuración ===
ARCHIVO_DATOS = config("ARCHIVO_DATOS")
PLC_IP = config("PLC_IP")
PLC_PORT = config("PLC_PORT", cast=int)
TIME_SLEEP = config("TIME_SLEEP", default=60, cast=int)

logger = get_logger()

# === Funciones ===
def conectar_plc():
    while True:
        try:
            conn = plc_control.ModbusConn(PLC_IP, PLC_PORT)
            conn.read_data(num_registers=2)
            logger.info("Conexión establecida con el PLC.")
            return conn
        except Exception as e:
            logger.warning(f"Error al conectar con el PLC: {e}. Reintentando en {TIME_SLEEP} segundos...")
            time.sleep(TIME_SLEEP)

def construir_batch(dato):
    batch = []
    
    for idx, config in plc_map.items():
        valor = dato[idx]
        tipo_dato = config["tipo_dato"]
        
        fecha_actual = datetime.now(timezone.utc).isoformat()

        payload = {
            "dispositivo": config["id_dispositivo"],
            "tipo_senal": config["tipo_senal"],
            "valor_num": None,
            "valor_bool": None,
            "valor_texto": None,
            "fecha_hora": fecha_actual
        }

        if tipo_dato == "bool":
            payload["valor_bool"] = bool(valor)
        elif tipo_dato == "num":
            payload["valor_num"] = float(valor)
        elif tipo_dato == "texto":
            payload["valor_texto"] = str(valor)

        batch.append(payload)
    return batch

def leer_sensor(conn):
    try:
        dato = conn.read_data(num_registers=100)
        return construir_batch(dato)
    
    except Exception as e:
        logger.error(f"Error al leer datos: {e}")
        return None


if __name__ == "__main__":
    conn = conectar_plc()
    while True:
        datos = leer_sensor(conn)
        if datos:
            try:
                with open(ARCHIVO_DATOS, "a") as f:
                    json.dump(datos, f)
                    f.write("\n")
                logger.info("Batch de datos guardado.")
                time.sleep(TIME_SLEEP)
            except Exception as e:
                logger.error(f"Error al guardar datos: {e}")
        else:
            logger.warning("No se recibieron datos del PLC. Reintentando conexión...")
            conn = conectar_plc()
        
