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
archivo = BASE_DIR / "data" / "transacciones_raw.csv"

df = pd.read_csv(archivo)

df = df.drop_duplicates(subset=["MovimientoID"])

sql = """
INSERT INTO Transacciones
(
    MovimientoID,
    TransferenciaID,
    Fecha,
    Monto,
    Descripcion,
    TipoTransID,
    CuentaID,
    EmpleadoID
)
VALUES
(
    :idmov,
    :idtrans,
    :fecha,
    :monto,
    :descripcion,
    :tipo,
    :cuenta,
    :empleado
)
"""
##########################################
trans_map = {
    "DEPOSITO": 1,
    "RETIRO": 2,
    "TRANSFERENCIA_SALIDA": 3,
    "TRANSFERENCIA_ENTRADA": 4
}


with engine.begin() as conn:

    for _, row in df.iterrows():

        conn.execute(
            text(sql),
            {
                "idmov": int(row["MovimientoID"]),
                "idtrans": (
                    None
                    if pd.isna(row["TransferenciaID"])
                    else str(row["TransferenciaID"])
                ),
                "fecha": row["Fecha"],
                "monto": float(row["Monto"]),
                "descripcion": row["Descripcion"],
                "tipo": trans_map[row["TipoTransaccion"]],
                "cuenta": int(row["CuentaID"]),
                "empleado": int(row["EmpleadoID"])
            }
        )

print("Transacciones migradas")