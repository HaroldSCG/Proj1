from sqlalchemy import create_engine, text
from dotenv import load_dotenv
import os

load_dotenv()

DB_USER = os.getenv("DB_USER")
DB_PASSWORD = os.getenv("DB_PASSWORD")
DB_HOST = os.getenv("DB_HOST")
DB_NAME = os.getenv("DB_NAME")

engine = create_engine(
    f"mysql+pymysql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}/{DB_NAME}"
)
respuesta = input(
    "¿Desea eliminar todos los datos migrados? (s/n): "
)

if respuesta.lower() != "s":
    print("Ccancelado.")
    exit()

try:
    print("\n========================================")
    print(" Deletes")
    with engine.begin() as conn:

        print(" FK...")

        conn.execute(text("SET FOREIGN_KEY_CHECKS = 0"))

        print("Transferencias...")
        conn.execute(text("DELETE FROM Transferencias"))

        print("Transacciones...")
        conn.execute(text("DELETE FROM Transacciones"))

        print("Cuentas...")
        conn.execute(text("DELETE FROM Cuentas"))

        print("Empleados...")
        conn.execute(text("DELETE FROM Empleados"))

        print("Clientes...")
        conn.execute(text("DELETE FROM Clientes"))

        print("Sucursales...")
        conn.execute(text("DELETE FROM Sucursales"))

        print("AUTO_INCREMENT...")

        conn.execute(text("SET FOREIGN_KEY_CHECKS = 1"))

    print("\nBase de datos limpiada correctamente.")

except Exception as e:

    print("\nERROR")
    print(str(e))