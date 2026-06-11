CREATE DATABASE IF NOT EXISTS BancoDB;
USE BancoDB;

-- Eliminar tablas en orden inverso (respetando FK)
DROP TABLE IF EXISTS Transacciones;
DROP TABLE IF EXISTS Transferencias;
DROP TABLE IF EXISTS Cuentas;
DROP TABLE IF EXISTS Empleados;
DROP TABLE IF EXISTS Clientes;
DROP TABLE IF EXISTS Sucursales;
DROP TABLE IF EXISTS TransaccionTipo;
DROP TABLE IF EXISTS CargoEmpleado;
DROP TABLE IF EXISTS CuentaTipo;

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

-- ==========================================
-- COMENTARIOS PARA EL DICCIONARIO DE DATOS
-- ==========================================

ALTER TABLE CuentaTipo COMMENT = 'Catálogo de los diferentes tipos de cuentas bancarias.';
ALTER TABLE CargoEmpleado COMMENT = 'Catálogo de los cargos que puede tener un empleado dentro del banco.';
ALTER TABLE TransaccionTipo COMMENT = 'Catálogo de los tipos de transacciones permitidas en el sistema.';
ALTER TABLE Sucursales COMMENT = 'Información detallada de las sucursales bancarias.';
ALTER TABLE Clientes COMMENT = 'Información personal y de contacto de los clientes del banco.';
ALTER TABLE Empleados COMMENT = 'Datos de los empleados que laboran en las distintas sucursales.';
ALTER TABLE Cuentas COMMENT = 'Cuentas bancarias asociadas a los clientes, detallando su saldo y estado.';
ALTER TABLE Transferencias COMMENT = 'Registro general de transferencias realizadas entre cuentas.';
ALTER TABLE Transacciones COMMENT = 'Historial detallado de movimientos (depósitos, retiros, transferencias) por cuenta.';

-- Agregando ejemplos de descripciones en columnas clave (DataGrip los leerá automáticamente)
ALTER TABLE Clientes 
    MODIFY ClienteDNI INT COMMENT 'Documento Nacional de Identidad del cliente (Llave Primaria)',
    MODIFY Correo VARCHAR(150) NOT NULL COMMENT 'Correo electrónico único del cliente';

ALTER TABLE Cuentas
    MODIFY SaldoActual DECIMAL(15,2) NOT NULL DEFAULT 0.00 COMMENT 'Saldo disponible actual en la cuenta, validado para no ser negativo.',
    MODIFY EstadoCuenta ENUM('ACTIVA','INACTIVA','CERRADA') NOT NULL DEFAULT 'ACTIVA' COMMENT 'Estado de vigencia de la cuenta.';

ALTER TABLE Transacciones
    MODIFY Monto DECIMAL(15,2) NOT NULL COMMENT 'Cantidad monetaria operada en la transacción (Mayor a 0)',
    MODIFY MovimientoID BIGINT COMMENT 'ID del movimiento (Llave Primaria)';

