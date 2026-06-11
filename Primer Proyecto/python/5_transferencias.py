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

df = df.drop_duplicates(subset=["TransferenciaID"])

sql = """
INSERT INTO Transferencias
(
    TransferenciaID,
    Fecha
)
VALUES
(
    :id,
    :fecha
)
"""

###########################################
with engine.begin() as conn:

    for _, row in df.iterrows():

        conn.execute(
            text(sql),
            {
                "id": str(row["TransferenciaID"]),
                "fecha": row["Fecha"]
            }
        )

print("Transferencias migradas")
