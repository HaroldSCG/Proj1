-- MySQL dump 10.13  Distrib 8.0.45, for Win64 (x86_64)
--
-- Host: localhost    Database: BancoDB_test
-- ------------------------------------------------------
-- Server version	8.0.45

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `cargoempleado`
--

DROP TABLE IF EXISTS `cargoempleado`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cargoempleado` (
  `CargoID` int NOT NULL AUTO_INCREMENT,
  `NombreCargo` varchar(50) NOT NULL,
  PRIMARY KEY (`CargoID`),
  UNIQUE KEY `NombreCargo` (`NombreCargo`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cargoempleado`
--

LOCK TABLES `cargoempleado` WRITE;
/*!40000 ALTER TABLE `cargoempleado` DISABLE KEYS */;
INSERT INTO `cargoempleado` VALUES (1,'Cajero'),(3,'Cajero Jr'),(2,'Ejecutivo');
/*!40000 ALTER TABLE `cargoempleado` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `clientes`
--

DROP TABLE IF EXISTS `clientes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `clientes` (
  `ClienteDNI` int NOT NULL,
  `Nombre` varchar(100) NOT NULL,
  `FechaNacimiento` date NOT NULL,
  `Direccion` varchar(255) DEFAULT NULL,
  `ClienteTelefono` varchar(20) DEFAULT NULL,
  `Correo` varchar(150) NOT NULL,
  PRIMARY KEY (`ClienteDNI`),
  UNIQUE KEY `Correo` (`Correo`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `clientes`
--

LOCK TABLES `clientes` WRITE;
/*!40000 ALTER TABLE `clientes` DISABLE KEYS */;
INSERT INTO `clientes` VALUES (10001,'Jose Morales','2001-03-12','Colonia Centro 5-21','55510001','jose.morales@mail.com'),(10002,'Maria Lopez','1999-07-08','Colonia Jardin 1-10','55510002','maria.lopez@mail.com'),(10003,'Carlos Diaz','1995-11-30','Barrio Norte 3-44','55510003','carlos.diaz@mail.com'),(10004,'Ana Ramirez','2002-01-25','Colonia Norte 4-22','55510004','ana.ramirez@mail.com'),(10005,'Pedro Castro','1990-05-14','Colonia Sur 8-12','55510005','pedro.castro@mail.com'),(10006,'Sofia Vega','1998-09-09','Colonia Sur 3-09','55510006','sofia.vega@mail.com');
/*!40000 ALTER TABLE `clientes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cuentas`
--

DROP TABLE IF EXISTS `cuentas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cuentas` (
  `CuentaID` int NOT NULL,
  `FechaApertura` date NOT NULL,
  `FechaCierre` date DEFAULT NULL,
  `SaldoActual` decimal(15,2) NOT NULL DEFAULT '0.00',
  `EstadoCuenta` enum('ACTIVA','INACTIVA','CERRADA') NOT NULL DEFAULT 'ACTIVA',
  `TipoCuentaID` int NOT NULL,
  `ClienteDNI` int NOT NULL,
  `SucursalID` int NOT NULL,
  PRIMARY KEY (`CuentaID`),
  KEY `FK_Cuenta_TipoCuenta` (`TipoCuentaID`),
  KEY `IDX_Cuentas_Cliente` (`ClienteDNI`),
  KEY `IDX_Cuentas_Sucursal` (`SucursalID`),
  CONSTRAINT `FK_Cuenta_Cliente` FOREIGN KEY (`ClienteDNI`) REFERENCES `clientes` (`ClienteDNI`),
  CONSTRAINT `FK_Cuenta_Sucursal` FOREIGN KEY (`SucursalID`) REFERENCES `sucursales` (`SucursalID`),
  CONSTRAINT `FK_Cuenta_TipoCuenta` FOREIGN KEY (`TipoCuentaID`) REFERENCES `cuentatipo` (`TipoCuentaID`),
  CONSTRAINT `cuentas_chk_1` CHECK ((`SaldoActual` >= 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cuentas`
--

LOCK TABLES `cuentas` WRITE;
/*!40000 ALTER TABLE `cuentas` DISABLE KEYS */;
INSERT INTO `cuentas` VALUES (1001,'2025-11-20',NULL,3800.00,'ACTIVA',1,10001,1),(1002,'2025-12-05',NULL,900.00,'ACTIVA',2,10002,1),(1003,'2025-10-02',NULL,3750.00,'ACTIVA',1,10003,2),(1004,'2025-09-18',NULL,3800.00,'ACTIVA',1,10004,2),(1005,'2025-08-12',NULL,800.00,'ACTIVA',2,10005,3),(1006,'2025-07-30',NULL,0.00,'INACTIVA',1,10006,3);
/*!40000 ALTER TABLE `cuentas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cuentatipo`
--

DROP TABLE IF EXISTS `cuentatipo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cuentatipo` (
  `TipoCuentaID` int NOT NULL AUTO_INCREMENT,
  `NombreTipoCuenta` varchar(50) NOT NULL,
  PRIMARY KEY (`TipoCuentaID`),
  UNIQUE KEY `NombreTipoCuenta` (`NombreTipoCuenta`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cuentatipo`
--

LOCK TABLES `cuentatipo` WRITE;
/*!40000 ALTER TABLE `cuentatipo` DISABLE KEYS */;
INSERT INTO `cuentatipo` VALUES (1,'Ahorro'),(2,'Corriente');
/*!40000 ALTER TABLE `cuentatipo` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `empleados`
--

DROP TABLE IF EXISTS `empleados`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `empleados` (
  `EmpleadoID` int NOT NULL,
  `EmpleadoNombre` varchar(100) NOT NULL,
  `CargoID` int NOT NULL,
  `SucursalID` int NOT NULL,
  PRIMARY KEY (`EmpleadoID`),
  KEY `FK_Empleado_Cargo` (`CargoID`),
  KEY `IDX_Empleados_Sucursal` (`SucursalID`),
  CONSTRAINT `FK_Empleado_Cargo` FOREIGN KEY (`CargoID`) REFERENCES `cargoempleado` (`CargoID`),
  CONSTRAINT `FK_Empleado_Sucursal` FOREIGN KEY (`SucursalID`) REFERENCES `sucursales` (`SucursalID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `empleados`
--

LOCK TABLES `empleados` WRITE;
/*!40000 ALTER TABLE `empleados` DISABLE KEYS */;
INSERT INTO `empleados` VALUES (501,'Ana Torres',1,1),(502,'Luis Perez',2,1),(503,'Carla Gomez',1,2),(504,'Marco Ruiz',1,3);
/*!40000 ALTER TABLE `empleados` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sucursales`
--

DROP TABLE IF EXISTS `sucursales`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sucursales` (
  `SucursalID` int NOT NULL,
  `Nombre` varchar(100) NOT NULL,
  `Direccion` varchar(255) NOT NULL,
  `Telefono` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`SucursalID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sucursales`
--

LOCK TABLES `sucursales` WRITE;
/*!40000 ALTER TABLE `sucursales` DISABLE KEYS */;
INSERT INTO `sucursales` VALUES (1,'Centro','Av Principal 10-55','55520001'),(2,'Norte','Calzada Norte 7-90','55520002'),(3,'Sur','Blvd Sur 2-15','55520003');
/*!40000 ALTER TABLE `sucursales` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `transacciones`
--

DROP TABLE IF EXISTS `transacciones`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `transacciones` (
  `MovimientoID` int NOT NULL,
  `TransferenciaID` varchar(50) DEFAULT NULL,
  `Fecha` datetime NOT NULL,
  `Monto` decimal(15,2) NOT NULL,
  `Descripcion` varchar(255) DEFAULT NULL,
  `TipoTransID` int NOT NULL,
  `CuentaID` int NOT NULL,
  `EmpleadoID` int NOT NULL,
  PRIMARY KEY (`MovimientoID`),
  KEY `FK_Transaccion_Empleado` (`EmpleadoID`),
  KEY `IDX_Transacciones_Cuenta` (`CuentaID`),
  KEY `IDX_Transacciones_Fecha` (`Fecha`),
  KEY `IDX_Transacciones_Transferencia` (`TransferenciaID`),
  KEY `IDX_Transacciones_Tipo` (`TipoTransID`),
  CONSTRAINT `FK_Transaccion_Cuenta` FOREIGN KEY (`CuentaID`) REFERENCES `cuentas` (`CuentaID`),
  CONSTRAINT `FK_Transaccion_Empleado` FOREIGN KEY (`EmpleadoID`) REFERENCES `empleados` (`EmpleadoID`),
  CONSTRAINT `FK_Transaccion_Tipo` FOREIGN KEY (`TipoTransID`) REFERENCES `transacciontipo` (`TipoTransID`),
  CONSTRAINT `FK_Transaccion_Transferencia` FOREIGN KEY (`TransferenciaID`) REFERENCES `transferencias` (`TransferenciaID`),
  CONSTRAINT `transacciones_chk_1` CHECK ((`Monto` > 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `transacciones`
--

LOCK TABLES `transacciones` WRITE;
/*!40000 ALTER TABLE `transacciones` DISABLE KEYS */;
INSERT INTO `transacciones` VALUES (1,NULL,'2026-01-10 00:00:00',1500.00,'Deposito en ventanilla',1,1001,501),(2,NULL,'2026-01-12 00:00:00',200.00,'Retiro en ventanilla',2,1001,501),(3,NULL,'2026-01-15 00:00:00',500.00,'Deposito en ventanilla',1,1002,502),(4,NULL,'2026-01-17 00:00:00',300.00,'Retiro ATM',2,1002,502),(5,NULL,'2026-02-01 00:00:00',2000.00,'Deposito en ventanilla',1,1003,503),(6,NULL,'2026-02-03 00:00:00',450.00,'Retiro en ventanilla',2,1003,503),(7,'TR-100','2026-02-05 00:00:00',800.00,'Transferencia a cuenta 1004',3,1003,503),(8,'TR-100','2026-02-05 00:00:00',800.00,'Transferencia desde cuenta 1003',4,1004,503),(9,NULL,'2026-02-10 00:00:00',1200.00,'Deposito en ventanilla',1,1004,503),(10,NULL,'2026-02-12 00:00:00',900.00,'Deposito en ventanilla',1,1005,504),(11,NULL,'2026-02-15 00:00:00',600.00,'Retiro en ventanilla',2,1005,504),(12,'TR-101','2026-02-20 00:00:00',500.00,'Transferencia a cuenta 1001',3,1005,504),(13,'TR-101','2026-02-20 00:00:00',500.00,'Transferencia desde cuenta 1005',4,1001,501),(14,NULL,'2026-02-25 00:00:00',300.00,'Deposito en ventanilla',1,1006,504),(15,NULL,'2026-02-28 00:00:00',300.00,'Retiro en ventanilla',2,1006,504),(16,NULL,'2026-02-10 00:00:00',1200.00,'Deposito en ventanilla',1,1004,503),(17,NULL,'2026-02-15 00:00:00',600.00,'Retiro en ventanilla',2,1005,504),(18,NULL,'2026-02-20 00:00:00',500.00,'Deposito en ventanilla',1,1001,501);
/*!40000 ALTER TABLE `transacciones` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `transacciontipo`
--

DROP TABLE IF EXISTS `transacciontipo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `transacciontipo` (
  `TipoTransID` int NOT NULL AUTO_INCREMENT,
  `NombreTipoTrans` varchar(50) NOT NULL,
  PRIMARY KEY (`TipoTransID`),
  UNIQUE KEY `NombreTipoTrans` (`NombreTipoTrans`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `transacciontipo`
--

LOCK TABLES `transacciontipo` WRITE;
/*!40000 ALTER TABLE `transacciontipo` DISABLE KEYS */;
INSERT INTO `transacciontipo` VALUES (1,'DEPOSITO'),(2,'RETIRO'),(4,'TRANSFERENCIA_ENTRADA'),(3,'TRANSFERENCIA_SALIDA');
/*!40000 ALTER TABLE `transacciontipo` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `transferencias`
--

DROP TABLE IF EXISTS `transferencias`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `transferencias` (
  `TransferenciaID` varchar(50) NOT NULL,
  `Fecha` datetime NOT NULL,
  PRIMARY KEY (`TransferenciaID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `transferencias`
--

LOCK TABLES `transferencias` WRITE;
/*!40000 ALTER TABLE `transferencias` DISABLE KEYS */;
INSERT INTO `transferencias` VALUES ('nan','2026-01-10 00:00:00'),('TR-100','2026-02-05 00:00:00'),('TR-101','2026-02-20 00:00:00');
/*!40000 ALTER TABLE `transferencias` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-06-10 11:50:18
