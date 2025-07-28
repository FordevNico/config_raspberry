from pymodbus.client import ModbusTcpClient
from pymodbus.exceptions import ModbusIOException
import time

class ModbusConn():
    def __init__(self, PLC_IP: str, PLC_PORT: int) -> None:
        self.client = ModbusTcpClient(PLC_IP, port=PLC_PORT)

    # Lectura de Coils
    def read_coils(self, number: int = 1):
        active_coils = self.client.read_coils(0, number)
        return active_coils.bits

    # Lectura de registros
    def read_data(self, start_adress: int = 0, num_registers: int = 3):
        registros = self.client.read_holding_registers(
            address=start_adress, count=num_registers)
        return registros.registers[1::2]

    # Escritura de Coils (Encender o Apagar Bits)
    def write_coils(self, coild_number: int = 0, coil_value: bool = False):
        resultado_coil = self.client.write_coil(coild_number, coil_value)
        return resultado_coil

    # Escritura de datos unicos en registros
    def write_unique_data(self, start_adress: int = 0, values=0):
        write = self.client.write_register(start_adress, values)

    # Escritura de datos multiples como listas en registros
    def write_multiple_data(self, start_adress: int = 0, values=[0]):
        write = self.client.write_registers(start_adress, values)

    def client_close(self):
        self.client.close()
        # print('Conexión PLC cerrada')
