-- --------------------------------------------
-- 4 SP_ReporteClientesSucursal
DELIMITER $$

CREATE PROCEDURE SP_ReporteClientesSucursal(
    IN p_NombreSucursal VARCHAR(100)
)
BEGIN

    SELECT
        c.Nombre AS Cliente,
        ct.NombreTipoCuenta AS TipoCuenta,
        cu.SaldoActual AS Saldo
    FROM Cuentas cu
        INNER JOIN Clientes c
            ON cu.ClienteDNI = c.ClienteDNI
        INNER JOIN CuentaTipo ct
            ON cu.TipoCuentaID = ct.TipoCuentaID
        INNER JOIN Sucursales s
            ON cu.SucursalID = s.SucursalID
    WHERE s.Nombre = p_NombreSucursal
    ORDER BY c.Nombre;

END$$

DELIMITER ;
-- --------------------------------------------

-- --------------------------------------------
-- 5 SP_CerrarCuenta
DELIMITER $$

CREATE PROCEDURE SP_CerrarCuenta(
    IN p_CuentaID INT
)
BEGIN

    DECLARE v_Saldo DECIMAL(15,2);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    SELECT SaldoActual
    INTO v_Saldo
    FROM Cuentas
    WHERE CuentaID = p_CuentaID
    FOR UPDATE;

    IF v_Saldo IS NULL THEN

        ROLLBACK;

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La cuenta no existe';

    END IF;

    IF v_Saldo <> 0 THEN

        ROLLBACK;

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La cuenta debe tener saldo 0 para cerrarse';

    END IF;

    UPDATE Cuentas
    SET
        EstadoCuenta = 'CERRADA',
        FechaCierre = CURDATE()
    WHERE CuentaID = p_CuentaID;

    COMMIT;

END$$

DELIMITER ;
-- --------------------------------------------

-- --------------------------------------------
-- 6 SP_RegistrarRetiro

DELIMITER $$

CREATE PROCEDURE SP_RegistrarRetiro(
    IN p_CuentaID INT,
    IN p_Monto DECIMAL(15,2),
    IN p_Descripcion VARCHAR(255),
    IN p_EmpleadoID INT
)
BEGIN

    DECLARE v_Saldo DECIMAL(15,2);
    DECLARE v_TipoRetiro INT;
    DECLARE v_MovimientoID INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    IF p_Monto <= 0 THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Monto inválido';

    END IF;

    START TRANSACTION;

    SELECT SaldoActual
    INTO v_Saldo
    FROM Cuentas
    WHERE CuentaID = p_CuentaID
    FOR UPDATE;

    IF v_Saldo IS NULL THEN

        ROLLBACK;

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La cuenta no existe';

    END IF;

    IF v_Saldo < p_Monto THEN

        ROLLBACK;

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Saldo insuficiente';

    END IF;

    SELECT TipoTransID
    INTO v_TipoRetiro
    FROM TransaccionTipo
    WHERE NombreTipoTrans = 'RETIRO';

    SAVEPOINT antes_retiro;

    UPDATE Cuentas
    SET SaldoActual = SaldoActual - p_Monto
    WHERE CuentaID = p_CuentaID;

    SELECT IFNULL(MAX(MovimientoID),0) + 1
    INTO v_MovimientoID
    FROM Transacciones;

    INSERT INTO Transacciones(
        MovimientoID,
        TransferenciaID,
        Fecha,
        Monto,
        Descripcion,
        TipoTransID,
        CuentaID,
        EmpleadoID
    )
    VALUES(
        v_MovimientoID,
        NULL,
        NOW(),
        p_Monto,
        p_Descripcion,
        v_TipoRetiro,
        p_CuentaID,
        p_EmpleadoID
    );

    COMMIT;

END$$

DELIMITER ;
-- --------------------------------------------