import os
import sys
import subprocess
from pathlib import Path

from dotenv import load_dotenv
from sqlalchemy import create_engine, text


# ==========================================
# CONFIGURACIÓN
# ==========================================

load_dotenv()

DB_USER = os.getenv("DB_USER")
DB_PASSWORD = os.getenv("DB_PASSWORD")
DB_HOST = os.getenv("DB_HOST")
DB_NAME = os.getenv("DB_NAME")


# ==========================================
# VALIDAR VARIABLES DE ENTORNO
# ==========================================

print("\n========================================")
print(" Configuracion de .env")
print("========================================")

variables = {
    "DB_USER": DB_USER,
    "DB_PASSWORD": DB_PASSWORD,
    "DB_HOST": DB_HOST,
    "DB_NAME": DB_NAME
}

faltantes = [k for k, v in variables.items() if not v]

if faltantes:
    print("\nERROR: Variables faltantes en .env")
    for variable in faltantes:
        print(f"   - {variable}")

    sys.exit(1)

print("-- Variables de entorno cargadas correctamente --")


print("\n========================================")
print(" Conexion MySQL")
print("========================================")

try:

    engine = create_engine(
        f"mysql+pymysql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}/{DB_NAME}"
    )

    with engine.connect() as conn:
        conn.execute(text("SELECT 1"))

    print("Conexión exitosa")

except Exception as e:

    print("\nERROR DE CONEXIÓN")
    print("----------------------------------------")
    print(str(e))
    print("----------------------------------------")

    sys.exit(1)

migrations = [
    "1_sucursales.py",
    "2_clientes.py",
    "3_empleados.py",
    "4_cuentas.py",
    "5_transferencias.py",
    "6_transacciones.py"
]

base_dir = Path(__file__).resolve().parent

print("\n========================================")
print(" Migraciones")
print("========================================")

for migration in migrations:

    archivo = base_dir / migration

    print(f"\nEjecutando: {migration}")
    print("-" * 40)

    if not archivo.exists():

        print(f"ERROR: No existe {migration}")
        sys.exit(1)

    try:

        resultado = subprocess.run(
            [sys.executable, str(archivo)],
            capture_output=True,
            text=True
        )

        if resultado.returncode != 0:

            print(f"FALLÓ: {migration}")

            if resultado.stderr:
                print("\nDETALLE DEL ERROR:")
                print(resultado.stderr)

            sys.exit(1)

        print("OK")

        if resultado.stdout.strip():
            print(resultado.stdout)

    except Exception as e:

        print(f"ERROR EJECUTANDO {migration}")
        print(str(e))
        sys.exit(1)


# ==========================================
# FIN
# ==========================================

print("\n========================================")
print(" Finish migrations")
print("========================================")
print("Todas las migraciones fueron ejecutadas correctamente.")