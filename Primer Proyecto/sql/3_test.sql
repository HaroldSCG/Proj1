
CALL SP_RegistrarCliente(
10001,
'Jose Morales',
'2001-03-12',
'Colonia Centro 5-21',
'55510001',
'jose.morales@mail.com'
);

CALL SP_RegistrarCliente(
10002,
'Maria Lopez',
'1998-06-20',
'Zona 7',
'55510002',
'maria.lopez@mail.com'
);

CALL SP_RegistrarCliente(
10003,
'Carlos Ramirez',
'1995-09-10',
'Mixco',
'55510003',
'carlos.ramirez@mail.com'
);

SELECT * FROM Clientes;

CALL SP_AbrirCuenta(
10001,
'Ahorro',
5000.00,
1
);

CALL SP_AbrirCuenta(
10002,
'Corriente',
3000.00,
1
);

CALL SP_AbrirCuenta(
10003,
'Ahorro',
7000.00,
2
);

SELECT *
FROM Cuentas;

INSERT INTO Empleados
VALUES
(501,'Ana Torres',1,1),
(502,'Luis Perez',2,1),
(503,'Mario Garcia',1,2);

SELECT *
FROM Empleados;

CALL SP_RegistrarDeposito(
1,
1000.00,
'Deposito en ventanilla',
501
);

SELECT SaldoActual
FROM Cuentas
WHERE CuentaID = 2;


-- Error
CALL SP_RegistrarDeposito(
1,
-100,
'Deposito invalido',
501
);
-- Correcto
CALL SP_RegistrarRetiro(
1,
500,
'Retiro ATM',
501
);
SELECT SaldoActual
FROM Cuentas
WHERE CuentaID = 1;

CALL SP_RegistrarRetiro(
2,
7000,
'Retiro enorme',
501
);

SELECT CuentaID,SaldoActual
FROM Cuentas;

CALL SP_RealizarTransferencia(
1,
2,
1000
);

SELECT CuentaID,SaldoActual
FROM Cuentas;

SELECT *
FROM Transacciones
ORDER BY Fecha DESC;


CALL SP_ActualizarCliente(
10001,
'Zona 10',
'55599999',
'jose.actualizado@mail.com'
);

SELECT *
FROM Clientes
WHERE ClienteDNI = 10001;

CALL SP_ReporteMovimientosCuenta(
1,
'2025-01-01',
'2030-12-31'
);

CALL SP_CerrarCuenta(2);

SELECT * FROM Cuentas WHERE CuentaID=2;