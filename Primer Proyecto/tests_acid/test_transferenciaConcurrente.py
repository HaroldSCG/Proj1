from sqlalchemy import create_engine, text
from dotenv import load_dotenv
import threading
import os
import time

load_dotenv()

DB_USER = os.getenv("DB_USER")
DB_PASSWORD = os.getenv("DB_PASSWORD")
DB_HOST = os.getenv("DB_HOST")
DB_NAME = os.getenv("DB_NAME")

engine = create_engine(
    f"mysql+pymysql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}/{DB_NAME}"
)

ORIGEN = 1001
DESTINO = 1002
MONTO = 10.00
NUM_HILOS = 20

errores = []
exitos = 0

lock = threading.Lock()


def transferir(numero):

    global exitos

    try:

        with engine.begin() as conn:

            conn.execute(
                text(
                    """
                    CALL SP_RealizarTransferencia(
                        :origen,
                        :destino,
                        :monto
                    )
                    """
                ),
                {
                    "origen": ORIGEN,
                    "destino": DESTINO,
                    "monto": MONTO
                }
            )

        with lock:
            exitos += 1

        print(f"[OK] Transferencia {numero}")

    except Exception as e:

        with lock:
            errores.append(str(e))

        print(f"[ERROR] Transferencia {numero}")


respuesta = input(
    f"¿Ejecutar {NUM_HILOS} transferencias simultáneas? (s/n): "
)

if respuesta.lower() != "s":
    print("Cancelado.")
    exit()

print("\n========================================")
print(" PRUEBA DE CONCURRENCIA")
print("========================================")

with engine.connect() as conn:

    saldo_inicial = conn.execute(
        text("""
        SELECT SUM(SaldoActual)
        FROM Cuentas
        WHERE CuentaID IN (:a,:b)
        """),
        {
            "a": ORIGEN,
            "b": DESTINO
        }
    ).scalar()

print(f"Saldo total inicial: {saldo_inicial}")

threads = []

inicio = time.time()

for i in range(NUM_HILOS):

    t = threading.Thread(
        target=transferir,
        args=(i + 1,)
    )

    threads.append(t)
    t.start()

for t in threads:
    t.join()

fin = time.time()

with engine.connect() as conn:

    saldo_final = conn.execute(
        text("""
        SELECT SUM(SaldoActual)
        FROM Cuentas
        WHERE CuentaID IN (:a,:b)
        """),
        {
            "a": ORIGEN,
            "b": DESTINO
        }
    ).scalar()

print("\n========================================")
print(" RESULTADOS")
print("========================================")

print(f"Transferencias exitosas : {exitos}")
print(f"Errores encontrados     : {len(errores)}")

print(f"Saldo inicial : {saldo_inicial}")
print(f"Saldo final   : {saldo_final}")

if saldo_inicial == saldo_final:

    print("\n[OK] No se perdió dinero")

else:

    print("\n[ALERTA] Los saldos no coinciden")

print(f"\nTiempo total: {fin - inicio:.2f} segundos")

if errores:

    print("\nPrimer error detectado:")
    print(errores[0])