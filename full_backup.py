from dotenv import load_dotenv
from pathlib import Path
import subprocess
import os
import sys
from datetime import datetime

load_dotenv()


fecha = datetime.now().strftime("%Y%m%d_%H%M%S")

DB_USER = os.getenv("DB_USER")
DB_PASSWORD = os.getenv("DB_PASSWORD")
DB_HOST = os.getenv("DB_HOST")
DB_NAME = os.getenv("DB_NAME")

########################################

faltantes = []
for nombre, valor in {
    "DB_USER": DB_USER,
    "DB_PASSWORD": DB_PASSWORD,
    "DB_HOST": DB_HOST,
    "DB_NAME": DB_NAME
}.items():
    if not valor:
        faltantes.append(nombre)

if faltantes:
    print("ERROR: Variables faltantes en .env")
    for variable in faltantes:
        print(f" - {variable}")
    sys.exit(1)
#########################################
# crea carpeta backups si no existe

BASE_DIR = Path(__file__).resolve().parent
BACKUP_DIR = BASE_DIR / "backups"

BACKUP_DIR.mkdir(exist_ok=True)

archivo_backup = BACKUP_DIR / f"respaldo_comp_{fecha}.sql"

######################################
# MYSQLDUMP

comando = [
    "mysqldump",
    f"-u{DB_USER}",
    f"-p{DB_PASSWORD}",
    f"-h{DB_HOST}",
    DB_NAME
]

print("\n========================================")
print(" RESPALDO COMPLETo")
print("========================================")

try:

    with open(archivo_backup, "w", encoding="utf-8") as salida:

        resultado = subprocess.run(
            comando,
            stdout=salida,
            stderr=subprocess.PIPE,
            text=True
        )

    if resultado.returncode != 0:

        print("Errots al crear respaldo:")
        print(resultado.stderr)
        sys.exit(1)

    print(f"Respaldo creado correctamente:")
    print(archivo_backup)

except FileNotFoundError:

    print(
        "\nERROR: mysqldump no fue encontrado.\n"
        "Verifica que MySQL esté instalado y agregado al PATH."
    )

except Exception as e:

    print("\nERROR")
    print(str(e))