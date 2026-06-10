CREATE USER 'admin'@'localhost'
IDENTIFIED BY 'Admin123!';

CREATE USER 'gerente'@'localhost'
IDENTIFIED BY 'Gerente123!';

CREATE USER 'cajero'@'localhost'
IDENTIFIED BY 'Cajero123!';

-- ------------
-- Admin
GRANT ALL PRIVILEGES
ON BancoDB.*
TO 'admin'@'localhost';

FLUSH PRIVILEGES;

-- ------------
-- Gerente
GRANT SELECT
ON BancoDB.*
TO 'gerente'@'localhost';

-- ------------
-- Csm el Cajero
GRANT SELECT
ON BancoDB.Clientes
TO 'cajero'@'localhost';

GRANT SELECT
ON BancoDB.Cuentas
TO 'cajero'@'localhost';

GRANT SELECT
ON BancoDB.Empleados
TO 'cajero'@'localhost';

GRANT SELECT
ON BancoDB.Sucursales
TO 'cajero'@'localhost';



GRANT EXECUTE
ON PROCEDURE BancoDB.SP_RegistrarCliente
TO 'cajero'@'localhost';

GRANT EXECUTE
ON PROCEDURE BancoDB.SP_ActualizarCliente
TO 'cajero'@'localhost';

GRANT EXECUTE
ON PROCEDURE BancoDB.SP_AbrirCuenta
TO 'cajero'@'localhost';

GRANT EXECUTE
ON PROCEDURE BancoDB.SP_RegistrarDeposito
TO 'cajero'@'localhost';

GRANT EXECUTE
ON PROCEDURE BancoDB.SP_RegistrarRetiro
TO 'cajero'@'localhost';

GRANT EXECUTE
ON PROCEDURE BancoDB.SP_RealizarTransferencia
TO 'cajero'@'localhost';

-- ------------
-- Permiso de reportes
GRANT EXECUTE
ON PROCEDURE BancoDB.SP_ReporteClientesSucursal
TO 'gerente'@'localhost';

GRANT EXECUTE
ON PROCEDURE BancoDB.SP_ReporteMovimientosCuenta
TO 'gerente'@'localhost';



-- ------------------
-- Ver permisos

SHOW GRANTS FOR 'admin'@'localhost';

SHOW GRANTS FOR 'gerente'@'localhost';

SHOW GRANTS FOR 'cajero'@'localhost';