BancoDB

Proyecto desarrollado para el curso de Sistemas de Bases de Datos 2.

El sistema implementa una base de datos bancaria normalizada en Tercera Forma Normal (3FN), incluyendo procedimientos almacenados para la gestión de clientes, cuentas, depósitos, retiros, transferencias, reportes, control de usuarios, migración de datos desde archivos CSV y generación de respaldos.

Requisitos
Python

Verificar dependencias instaladas:

pip check

Instalar dependencias necesarias:

pip install python-dotenv
MySQL

Verificar que mysqldump se encuentre instalado y disponible en el sistema:

mysqldump --version
Configuración

Antes de ejecutar el proyecto:

Crear una copia del archivo .env.example.
Renombrarlo a .env.
Configurar las credenciales de conexión a MySQL.

Ejemplo:

MYSQL_HOST=localhost
MYSQL_PORT=3306
MYSQL_USER=root
MYSQL_PASSWORD=root
MYSQL_DATABASE=BancoDB
Estructura del Proyecto
Proyecto/
│
├── data/
│   ├── clientes_raw.csv
│   ├── cuentas_raw.csv
│   ├── empleados_raw.csv
│   ├── sucursales_raw.csv
│   └── transacciones_raw.csv
│
├── sql/
│   ├── 1_database.sql
│   ├── 2_incremental_1.sql
│   ├── 2_incremental_2.sql
│   ├── 2_incremental_3.sql
│   ├── 3_test.sql
│   └── 4_users.sql
│
├── migrations/
│   ├── migrar_clientes.py
│   ├── migrar_cuentas.py
│   ├── migrar_empleados.py
│   ├── migrar_sucursales.py
│   └── migrar_transacciones.py
│
├── backups/
│
├── tests_acid/
│   ├── test_deadlock.py
│   └── test_transferenciaConcurrente.py
│
├── reset.py
├── run.py
├── full_backup.py
└── README.md
Instalación de la Base de Datos

Los scripts SQL deben ejecutarse en el siguiente orden.

1. Crear estructura de la base de datos

Ejecutar:

1_database.sql

Este script crea:

Base de datos.
Tablas.
Restricciones.
Índices.
Catálogos básicos.
2. Crear procedimientos almacenados

Ejecutar:

2_incremental_1.sql
2_incremental_2.sql
2_incremental_3.sql

Estos archivos contienen los nueve procedimientos almacenados requeridos por el proyecto.

3. Crear usuarios y permisos

Ejecutar:

4_users.sql

Este script crea los usuarios:

admin
gerente
cajero

y asigna sus respectivos privilegios.

4. Validación del sistema

Opcionalmente ejecutar:

3_test.sql

Este archivo contiene pruebas para validar el funcionamiento de los procedimientos almacenados.

Migración de Datos

Los datos originales se encuentran en la carpeta:

data/
Reiniciar la Base de Datos

Para eliminar y recrear la estructura completa:

python reset.py
Ejecutar Migraciones

Para cargar los datos desde los archivos CSV:

python run.py

Este script ejecuta automáticamente todas las migraciones en el orden correcto para respetar las relaciones y restricciones de integridad referencial.

Respaldos
Generar Respaldo Completo

Ejecutar:

python full_backup.py

El sistema generará automáticamente un archivo de respaldo dentro de:

backups/

Ejemplo:

backups/
└── respaldo_comp.sql
Restaurar Respaldo

Desde MySQL:

mysql -u usuario -p BancoDB < respaldo_comp.sql
Procedimientos Almacenados

El sistema incluye los siguientes procedimientos:

Procedimiento	Descripción
SP_AbrirCuenta	Apertura de nuevas cuentas
SP_RegistrarDeposito	Registro de depósitos
SP_RegistrarRetiro	Registro de retiros
SP_RealizarTransferencia	Transferencias entre cuentas
SP_ReporteClientesSucursal	Reporte de clientes por sucursal
SP_CerrarCuenta	Cierre de cuentas
SP_RegistrarCliente	Registro de clientes
SP_ActualizarCliente	Actualización de datos de clientes
SP_ReporteMovimientosCuenta	Estado de cuenta por rango de fechas
Usuarios del Sistema
Usuario	Función
admin	Administración completa del sistema
gerente	Consultas y reportes
cajero	Operaciones bancarias diarias
Pruebas de Concurrencia

Las pruebas de concurrencia y propiedades ACID se encuentran en:

tests_acid/

Archivos disponibles:

test_deadlock.py
test_transferenciaConcurrente.py

Estas pruebas permiten validar:

Atomicidad
Consistencia
Aislamiento
Durabilidad
Bloqueos de registros
Manejo de concurrencia
Transferencias simultáneas
Notas
Se recomienda ejecutar primero los scripts SQL y posteriormente las migraciones.
Verificar que el servidor MySQL se encuentre activo antes de ejecutar los scripts Python.
El proyecto fue desarrollado utilizando MySQL como motor de base de datos relacional y Python para la migración de datos desde archivos CSV.CREATE DATABASE IF NOT EXISTS BancoDB;
USE BancoDB;

-- CuentaTipo

CREATE TABLE CuentaTipo (
    TipoCuentaID INT PRIMARY KEY AUTO_INCREMENT,
    NombreTipoCuenta VARCHAR(50) NOT NULL UNIQUE
);

-- CargoEmpleado

CREATE TABLE CargoEmpleado (
    CargoID INT PRIMARY KEY AUTO_INCREMENT,
    NombreCargo VARCHAR(50) NOT NULL UNIQUE
);

-- TransaccionTipo

CREATE TABLE TransaccionTipo (
    TipoTransID INT PRIMARY KEY AUTO_INCREMENT,
    NombreTipoTrans VARCHAR(50) NOT NULL UNIQUE
);

-- Sucursales

CREATE TABLE Sucursales (
    SucursalID INT PRIMARY KEY,
    Nombre VARCHAR(100) NOT NULL,
    Direccion VARCHAR(255) NOT NULL,
    Telefono VARCHAR(20)
);

-- Clientes

CREATE TABLE Clientes (
    ClienteDNI INT PRIMARY KEY,
    Nombre VARCHAR(100) NOT NULL,
    FechaNacimiento DATE NOT NULL,
    Direccion VARCHAR(255),
    ClienteTelefono VARCHAR(20),
    Correo VARCHAR(150) UNIQUE not null
);

-- Empleados

CREATE TABLE Empleados (
    EmpleadoID INT PRIMARY KEY,
    EmpleadoNombre VARCHAR(100) NOT NULL,
    CargoID INT NOT NULL,
    SucursalID INT NOT NULL,

    CONSTRAINT FK_Empleado_Cargo
        FOREIGN KEY (CargoID)
        REFERENCES CargoEmpleado(CargoID),

    CONSTRAINT FK_Empleado_Sucursal
        FOREIGN KEY (SucursalID)
        REFERENCES Sucursales(SucursalID)
);

-- Cuentas

CREATE TABLE Cuentas (
    CuentaID INT PRIMARY KEY ,
    FechaApertura DATE NOT NULL,
    FechaCierre DATE NULL,
    SaldoActual DECIMAL(15,2) NOT NULL DEFAULT 0.00 CHECK 	(SaldoActual >= 0),
    EstadoCuenta ENUM('ACTIVA','INACTIVA','CERRADA') NOT NULL DEFAULT 'ACTIVA',
    TipoCuentaID INT NOT NULL,
    ClienteDNI INT NOT NULL,
    SucursalID INT NOT NULL,

    CONSTRAINT FK_Cuenta_TipoCuenta
        FOREIGN KEY (TipoCuentaID)
        REFERENCES CuentaTipo(TipoCuentaID),

    CONSTRAINT FK_Cuenta_Cliente
        FOREIGN KEY (ClienteDNI)
        REFERENCES Clientes(ClienteDNI),

    CONSTRAINT FK_Cuenta_Sucursal
        FOREIGN KEY (SucursalID)
        REFERENCES Sucursales(SucursalID)
);

-- Transferencias

CREATE TABLE Transferencias (
    TransferenciaID VARCHAR(50) PRIMARY KEY,
    Fecha DATETIME NOT NULL
);

-- Transacciones

CREATE TABLE Transacciones (
    MovimientoID BIGINT PRIMARY KEY,

    TransferenciaID VARCHAR(50) NULL,

    Fecha DATETIME NOT NULL,
    Monto DECIMAL(15,2) NOT NULL CHECK (Monto > 0),
    Descripcion VARCHAR(255),

    TipoTransID INT NOT NULL,
    CuentaID INT NOT NULL,
    EmpleadoID INT NOT NULL,

    CONSTRAINT FK_Transaccion_Transferencia
        FOREIGN KEY (TransferenciaID)
        REFERENCES Transferencias(TransferenciaID),

    CONSTRAINT FK_Transaccion_Tipo
        FOREIGN KEY (TipoTransID)
        REFERENCES TransaccionTipo(TipoTransID),

    CONSTRAINT FK_Transaccion_Cuenta
        FOREIGN KEY (CuentaID)
        REFERENCES Cuentas(CuentaID),

    CONSTRAINT FK_Transaccion_Empleado
        FOREIGN KEY (EmpleadoID)
        REFERENCES Empleados(EmpleadoID)
);
CREATE INDEX IDX_Cuentas_Cliente
ON Cuentas(ClienteDNI);
CREATE INDEX IDX_Cuentas_Sucursal
ON Cuentas(SucursalID);
CREATE INDEX IDX_Empleados_Sucursal
ON Empleados(SucursalID);
CREATE INDEX IDX_Transacciones_Cuenta
ON Transacciones(CuentaID);
CREATE INDEX IDX_Transacciones_Fecha
ON Transacciones(Fecha);
CREATE INDEX IDX_Transacciones_Transferencia
ON Transacciones(TransferenciaID);
CREATE INDEX IDX_Transacciones_Tipo
ON Transacciones(TipoTransID);

INSERT INTO CuentaTipo (NombreTipoCuenta)
VALUES
('Ahorro'), ('Corriente');

INSERT INTO CargoEmpleado (NombreCargo)
VALUES
('Cajero'), ('Ejecutivo'), ('Cajero Jr');

INSERT INTO TransaccionTipo (NombreTipoTrans)
VALUES
('DEPOSITO'), ('RETIRO'), ('TRANSFERENCIA_SALIDA'), ('TRANSFERENCIA_ENTRADA');

