-- --------------------------------------------
-- PROCEDIMIENTOS TRANSACTIONS
-- --------------------------------------------
-- --------------------------------------------
-- 1 SP_AbrirCuenta --
DELIMITER $$

CREATE PROCEDURE SP_AbrirCuenta(
    IN p_ClienteDNI INT,
    IN p_TipoCuenta VARCHAR(50),
    IN p_SaldoInicial DECIMAL(15,2),
    IN p_SucursalID INT
)
BEGIN

    DECLARE v_TipoCuentaID INT;
    DECLARE v_NuevaCuentaID INT;

    IF p_SaldoInicial < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El saldo inicial no puede ser negativo!';
    END IF;

    START TRANSACTION;

    IF NOT EXISTS (
        SELECT 1
        FROM Clientes
        WHERE ClienteDNI = p_ClienteDNI
    ) THEN

        ROLLBACK;

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cliente no existe';

    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM Sucursales
        WHERE SucursalID = p_SucursalID
    ) THEN

        ROLLBACK;

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Sucursal no existe';

    END IF;

    SELECT TipoCuentaID
    INTO v_TipoCuentaID
    FROM CuentaTipo
    WHERE NombreTipoCuenta = p_TipoCuenta;

    IF v_TipoCuentaID IS NULL THEN

        ROLLBACK;

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Tipo de cuenta invalido';

    END IF;

    SELECT IFNULL(MAX(CuentaID),0) + 1
    INTO v_NuevaCuentaID
    FROM Cuentas;

    INSERT INTO Cuentas(
        CuentaID,
        FechaApertura,
        SaldoActual,
        EstadoCuenta,
        TipoCuentaID,
        ClienteDNI,
        SucursalID
    )
    VALUES(
        v_NuevaCuentaID,
        CURDATE(),
        p_SaldoInicial,
        'ACTIVA',
        v_TipoCuentaID,
        p_ClienteDNI,
        p_SucursalID
    );

    COMMIT;

END$$

DELIMITER ;
-- --------------------------------------------

-- --------------------------------------------
-- 2 SP_RegistrarDeposito
DELIMITER $$
CREATE PROCEDURE SP_RegistrarDeposito(
    IN p_CuentaID INT,
    IN p_Monto DECIMAL(15,2),
    IN p_Descripcion VARCHAR(255),
    IN p_EmpleadoID INT
)
BEGIN
    DECLARE v_MovimientoID INT;
    DECLARE v_TipoDeposito INT;
    IF p_Monto <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Monto invalidp';
    END IF;

    START TRANSACTION;

    SELECT TipoTransID
    INTO v_TipoDeposito
    FROM TransaccionTipo
    WHERE NombreTipoTrans = 'DEPOSITO';
    IF v_TipoDeposito IS NULL THEN

        ROLLBACK;
        
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Tipo DEPOSITO no configurado';

    END IF;

    SELECT CuentaID
    FROM Cuentas
    WHERE CuentaID = p_CuentaID
    FOR UPDATE;

    UPDATE Cuentas
    SET SaldoActual = SaldoActual + p_Monto
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
        v_TipoDeposito,
        p_CuentaID,
        p_EmpleadoID
    );

    COMMIT;

END$$

DELIMITER ;
-- --------------------------------------------

-- --------------------------------------------
-- 3 SP_RealizarTransferenci
DELIMITER $$

CREATE PROCEDURE SP_RealizarTransferencia(
    IN p_CuentaOrigenID INT,
    IN p_CuentaDestinoID INT,
    IN p_Monto DECIMAL(15,2)
)
BEGIN

    DECLARE v_SaldoOrigen DECIMAL(15,2);

    DECLARE v_TipoSalida INT;
    DECLARE v_TipoEntrada INT;

    DECLARE v_Mov1 BIGINT;
    DECLARE v_Mov2 BIGINT;

    DECLARE v_TransferenciaID VARCHAR(50);

    IF p_Monto <= 0 THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Monto inválido';

    END IF;

    START TRANSACTION;

    SELECT SaldoActual
    INTO v_SaldoOrigen
    FROM Cuentas
    WHERE CuentaID = p_CuentaOrigenID
    FOR UPDATE;

    SELECT CuentaID
    FROM Cuentas
    WHERE CuentaID = p_CuentaDestinoID
    FOR UPDATE;

    IF v_SaldoOrigen < p_Monto THEN

        ROLLBACK;

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Saldo insuficiente';

    END IF;

    SELECT TipoTransID
    INTO v_TipoSalida
    FROM TransaccionTipo
    WHERE NombreTipoTrans = 'TRANSFERENCIA_SALIDA';

    SELECT TipoTransID
    INTO v_TipoEntrada
    FROM TransaccionTipo
    WHERE NombreTipoTrans = 'TRANSFERENCIA_ENTRADA';

    SET v_TransferenciaID =
        CONCAT(
            'TRF-',
            DATE_FORMAT(NOW(6),'%Y%m%d%H%i%s'),
            LPAD(MICROSECOND(NOW(6)),6,'0')
        );

    INSERT INTO Transferencias(
        TransferenciaID,
        Fecha
    )
    VALUES(
        v_TransferenciaID,
        NOW()
    );

    UPDATE Cuentas
    SET SaldoActual = SaldoActual - p_Monto
    WHERE CuentaID = p_CuentaOrigenID;

    UPDATE Cuentas
    SET SaldoActual = SaldoActual + p_Monto
    WHERE CuentaID = p_CuentaDestinoID;

    SET v_Mov1 =
        FLOOR(UNIX_TIMESTAMP(NOW(6)) * 1000000);

    SET v_Mov2 = v_Mov1 + 1;

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
        v_Mov1,
        v_TransferenciaID,
        NOW(),
        p_Monto,
        'Transferencia enviada',
        v_TipoSalida,
        p_CuentaOrigenID,
        501
    );

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
        v_Mov2,
        v_TransferenciaID,
        NOW(),
        p_Monto,
        'Transferencia recibida',
        v_TipoEntrada,
        p_CuentaDestinoID,
        501
    );

    COMMIT;

END$$

DELIMITER ;
-- --------------------------------------------
