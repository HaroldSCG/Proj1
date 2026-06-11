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
archivo = BASE_DIR / "data" / "cuentas_raw.csv"

df = pd.read_csv(archivo)

df = df.drop_duplicates(subset=["CuentaID"])

sql = """
INSERT INTO Cuentas
(
    CuentaID,
    FechaApertura,
    SaldoActual,
    EstadoCuenta,
    TipoCuentaID,
    ClienteDNI,
    SucursalID
)
VALUES
(
    :id,
    :fecha,
    :saldo,
    :estado,
    :tipo,
    :cliente,
    :sucursal
)
"""
#########################################
tipo_cuenta_map = {
    "Ahorro": 1,
    "Corriente": 2
}

with engine.begin() as conn:

    for _, row in df.iterrows():

        conn.execute(
            text(sql),
            {
                "id": int(row["CuentaID"]),
                "fecha": row["FechaApertura"],
                "saldo": float(row["SaldoActual"]),
                "estado": row["EstadoCuenta"],
                "tipo": tipo_cuenta_map[row["TipoCuenta"]],
                "cliente": int(row["ClienteDNI"]),
                "sucursal": int(row["SucursalID"])
            }
        )

print("Cuentas migradas")