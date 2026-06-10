from sqlalchemy import create_engine, text
from dotenv import load_dotenv
import threading
import os
import time

load_dotenv()

engine = create_engine(
    f"mysql+pymysql://{os.getenv('DB_USER')}:{os.getenv('DB_PASSWORD')}@{os.getenv('DB_HOST')}/{os.getenv('DB_NAME')}"
)

respuesta = input(
    "¿Probar el deadlock? (s/n): "
)

if respuesta.lower() != "s":
    print("Ccancelado.")
    exit()

def sesion_1():

    try:

        with engine.connect() as conn:

            trans = conn.begin()

            print("Sesion 1: Bloqueando cuenta 1001")

            conn.execute(
                text("""
                SELECT *
                FROM Cuentas
                WHERE CuentaID = 1001
                FOR UPDATE
                """)
            )

            time.sleep(3)

            print("Sesion 1: Intentando bloquear cuenta 1002")

            conn.execute(
                text("""
                SELECT *
                FROM Cuentas
                WHERE CuentaID = 1002
                FOR UPDATE
                """)
            )

            trans.commit()

    except Exception as e:

        print("Sesion 1 ERROR:")
        print(e)


def sesion_2():

    try:

        with engine.connect() as conn:

            trans = conn.begin()

            print("Sesion 2: Bloqueando cuenta 1002")

            conn.execute(
                text("""
                SELECT *
                FROM Cuentas
                WHERE CuentaID = 1002
                FOR UPDATE
                """)
            )

            time.sleep(3)

            print("Sesion 2: Intentando bloquear cuenta 1001")

            conn.execute(
                text("""
                SELECT *
                FROM Cuentas
                WHERE CuentaID = 1001
                FOR UPDATE
                """)
            )

            trans.commit()

    except Exception as e:

        print("\nDEADLOCK DETECTADO")
        print("--------------------")
        print(e)

    try:
        trans.rollback()
    except:
        pass


t1 = threading.Thread(target=sesion_1)
t2 = threading.Thread(target=sesion_2)

t1.start()
t2.start()

t1.join()
t2.join()

print("Prueba terminada")