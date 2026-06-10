-- --------------------------------------------
-- 7 SP_RegistrarCliente
DELIMITER $$

CREATE PROCEDURE SP_RegistrarCliente(
    IN p_ClienteDNI INT,
    IN p_Nombre VARCHAR(100),
    IN p_FechaNacimiento DATE,
    IN p_Direccion VARCHAR(255),
    IN p_Telefono VARCHAR(20),
    IN p_Correo VARCHAR(150)
)
BEGIN

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    IF EXISTS (
        SELECT 1
        FROM Clientes
        WHERE ClienteDNI = p_ClienteDNI
    ) THEN

        ROLLBACK;

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El cliente ya existe';

    END IF;

    INSERT INTO Clientes(
        ClienteDNI,
        Nombre,
        FechaNacimiento,
        Direccion,
        ClienteTelefono,
        Correo
    )
    VALUES(
        p_ClienteDNI,
        p_Nombre,
        p_FechaNacimiento,
        p_Direccion,
        p_Telefono,
        p_Correo
    );

    COMMIT;

END$$

DELIMITER ;
-- --------------------------------------------

-- --------------------------------------------
-- 8 SP_ActualizarCliente
DELIMITER $$

CREATE PROCEDURE SP_ActualizarCliente(
    IN p_ClienteDNI INT,
    IN p_Direccion VARCHAR(255),
    IN p_Telefono VARCHAR(20),
    IN p_Correo VARCHAR(150)
)
BEGIN

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    IF NOT EXISTS (
        SELECT 1
        FROM Clientes
        WHERE ClienteDNI = p_ClienteDNI
    ) THEN

        ROLLBACK;

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cliente no encontrado';

    END IF;

    UPDATE Clientes
    SET
        Direccion = p_Direccion,
        ClienteTelefono = p_Telefono,
        Correo = p_Correo
    WHERE ClienteDNI = p_ClienteDNI;

    COMMIT;

END$$

DELIMITER ;
-- --------------------------------------------

-- --------------------------------------------
-- 9 SP_ReporteMovimientosCuenta

DELIMITER $$

CREATE PROCEDURE SP_ReporteMovimientosCuenta(
    IN p_CuentaID INT,
    IN p_FechaInicio DATE,
    IN p_FechaFin DATE
)
BEGIN

    SELECT
        t.Fecha,
        t.Descripcion,
        t.Monto,
        tt.NombreTipoTrans AS TipoTransaccion
    FROM Transacciones t
        INNER JOIN TransaccionTipo tt
            ON t.TipoTransID = tt.TipoTransID
    WHERE t.CuentaID = p_CuentaID
        AND DATE(t.Fecha)
            BETWEEN p_FechaInicio
            AND p_FechaFin
    ORDER BY t.Fecha;

END$$

DELIMITER ;

-- --------------------------------------------