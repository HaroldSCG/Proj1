from sqlalchemy import create_engine
import pandas as pd

-- Conexion a MySQL
engine = create_engine(
    "mysql+pymysql://root:root@localhost/BancoDB"
)

-- Leer archivos CSV de data
BASE_DIR = Path(__file__).resolve().parent.parent
archivo = BASE_DIR / "data" / "sucursales_raw.csv"

df = pd.read_csv(archivo)
df = df.drop_duplicates(subset=["SucursalID"])

for _, row in df.iterrows():

    sql = """
    INSERT INTO Sucursales
    (
        SucursalID,
        Nombre,
        Direccion,
        Telefono
    )
    VALUES (%s,%s,%s,%s)
    """

    engine.execute(
        sql,
        (
            int(row["SucursalID"]),
            row["SucursalNombre"],
            row["SucursalDireccion"],
            row["SucursalTelefono"]
        )
    )

------------------------------------------
archivo = BASE_DIR / "data" / "clientes_raw.csv"
df = pd.read_csv(archivo)
df = df.drop_duplicates(subset=["ClienteID"])

for _, row in df.iterrows():

    sql = """
    INSERT INTO Clientes
    (
        ClienteDNI,
        Nombre,
        FechaNacimiento,
        Direccion,
        ClienteTelefono,
        Correo
    )
    VALUES (%s,%s,%s,%s,%s,%s)
    """

    engine.execute(
        sql,
        (
            int(row["ClienteDNI"]),
            row["ClienteNombre"],
            row["ClienteFechaNacimiento"],
            row["ClienteDireccion"],
            row["ClienteTelefono"],
            row["ClienteCorreo"]
        )
    )

------------------------------------------