from sqlalchemy import create_engine, text
import pandas as pd
from pathlib import Path
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

BASE_DIR = Path(__file__).resolve().parent.parent
archivo = BASE_DIR / "data" / "empleados_raw.csv"

df = pd.read_csv(archivo)

df = df.drop_duplicates(subset=["EmpleadoID"])

sql = """
INSERT INTO Empleados
(
    EmpleadoID,
    EmpleadoNombre,
    CargoID,
    SucursalID
)
VALUES
(
    :id,
    :nombre,
    :cargo,
    :sucursal
)
"""

cargo_map = {
    "Cajero": 1,
    "Ejecutivo": 2,
    "Cajero Jr": 3
}

with engine.begin() as conn:

    for _, row in df.iterrows():

        conn.execute(
            text(sql),
            {
                "id": int(row["EmpleadoID"]),
                "nombre": row["EmpleadoNombre"],
                "cargo": cargo_map[row["EmpleadoCargo"]],
                "sucursal": int(row["SucursalID"])
            }
        )

print("Empleados migrados")