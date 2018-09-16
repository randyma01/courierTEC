﻿/*
Proyecto I: courierTEC (SQL Server 2017)

Bases de Datos Avanzados, Área Acádemica de Administración de Tecnología de Información

Semestre II, 2018

Miembros:
	Karla Araya Corrales
	Maria Paula Ramírez Ortiz
	Hazel Arias Abarca
	Randy Martínez Sandí

Nota:
	Este es el script para la distribución del nodo Cartago de la base
	central courierTEC.

Índice:
		1- Creación de las tablas
		2- Fragmentación de las tablas de couriertecDB
*/

--------------------------------------------------------
----------Inicio: Creación de la base de datos----------
--------------------------------------------------------

CREATE DATABASE couriertecCartagoDB;
GO

---------------------------------------------------
--------------Uso de la base de datos--------------
---------------------------------------------------

USE couriertecCartagoDB;
GO

--------------------------------------------------
----------Inicio: Creación de las tablas----------
--------------------------------------------------

-- Tabla de los CLientes de Cartago --
CREATE TABLE Cliente_Cartago(
	IdCliente INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
	Cedula INT NOT NULL,
	Nombre VARCHAR(15) NOT NULL,
	Apellido VARCHAR(15) NOT NULL,
	Telefono VARCHAR(11) NOT NULL,
	Tipo VARCHAR(11) NOT NULL,
	FechaNacimiento DATE NOT NULL,
	Provincia Nombre VARCHAR (12) NOT NULL,
);
GO

-- Tabla de la Sucursal de Cartago --
CREATE TABLE Sucursal_Cartago(
	IdSucursal INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
	Nombre VARCHAR(30) NOT NULL,
	Telefono VARCHAR(11) NOT NULL,
	Correo VARCHAR(25) NOT NULL,
	Recaudado INT,
);
GO

-- Tabla de los Empleados --
CREATE TABLE Empleado_Cartago(
	IdEmpleado INT NOT NULL IDENTITY(1,1)PRIMARY KEY,
	Nombre VARCHAR(15) NOT NULL,
	Apellido VARCHAR(15) NOT NULL,
	Cedula INT NOT NULL,
);
GO

-- Tabla de los Paquetes --
CREATE TABLE Paquete_Cartago(
	IdPaquete INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
	FechaIngreso DATE NOT NULL,
	Tipo VARCHAR(30) NOT NULL, 				--(ropa, juegetes, herramientas, etc).
	Descripcion VARCHAR(1000) NOT NULL,
	Peso INT NOT NULL,
	Precio INT NOT NULL,
	Monto INT NOT NULL,
	EstadoPaquete VARCHAR (20) NOT NULL 		--(en camino, en sucursal, retirado)
);
GO

-- Tabla de los Clientes por Paquete --
CREATE TABLE Cliente_Paquete_Cartago(
	IdCliente INT NOT NULL,
	IdPaquete INT NOT NULL,
	FOREIGN KEY (IdCliente) REFERENCES Cliente(IdCliente),
	FOREIGN KEY (IdPaquete) REFERENCES Paquete(IdPaquete)
);
GO

---------------------------------------------------
---------------Llenado de las Tablas---------------
------------------(Frgamentación)------------------
---------------------------------------------------

-- Llenando tabla de los Clientes de Cartago --
INSERT INTO couriertecCartagoDB.dbo.Cliente
SELECT TT1.*, TT2.* FROM
(SELECT Cliente.IdCliente, Cedula, Nombre,
Apellido,  Telefono, Tipo, FechaNacimiento FROM Cliente
INNER JOIN Cliente_Sucursal ON Cliente.IdCliente = Cliente_Sucursal.IdCliente
WHERE Cliente_Sucursal.IdSucursal = 2) AS [TT1],
(SELECT Provincia.Nombre AS 'Provincia' FROM Provincia
INNER Join Cliente on Cliente.IdProvincia = Provincia.IdProvincia
INNER JOIN Cliente_Sucursal ON Cliente.IdCliente = Cliente_Sucursal.IdCliente
WHERE Cliente_Sucursal.IdSucursal = 2) AS [TT2];
GO

-- Llenando tabla de la Sucursal de Cartago --
INSERT INTO couriertecCartagoDB.dbo.Sucursal_Cartago
SELECT TT1.* ,TT2.* FROM
(SELECT IdSucursal  AS 'IdSucursal', Nombre AS 'Nombre', Telefono AS 'Telefono', Correo AS 'Correo'
FROM Sucursal WHERE Sucursal.IdSucursal = 2) AS [TT1],
(SELECT SUM(Monto) AS 'Recaudado' FROM Paquete
INNER JOIN Paquete_Sucursal ON Paquete.IdPaquete = Paquete_Sucursal.IdPaquete
WHERE Paquete_Sucursal.IdSucursal = 2) AS [TT2];

GO

-- Llenado tabla de los Empleados Cartago --
INSERT INTO couriertecCartagoDB.dbo.Empleado_Cartago
SELECT Empleado.IdEmpleado, Nombre, Apellido, Cedula
FROM Empleado
WHERE Empleado.IdSucursal = 2;
GO

-- Llenado tabla de los Paquetes de Cartago --
INSERT INTO courierTEC.dbo.Paquete_Cartago
SELECT Paquete.IdPaquete, FechaIngreso, Tipo, Descripcion ,Peso, Precio ,Monto, EstadoPaquete FROM Paquete
INNER JOIN Paquete_Sucursal ON Paquete.IdPaquete = Paquete_Sucursal.IdPaquete
WHERE Paquete_Sucursal.IdSucursal = 2;

-- Llenado tabla de los Paquetes por Cliente de Cartago --
INSERT INTO courierTEC.db.Cliente_Paquete_Cartago
 SELECT Cliente_Paquete.IdCliente, Cliente_Paquete.IdPaquete FROM Cliente_Paquete
INNER JOIN Cliente ON Cliente.IdCliente = Cliente_Paquete.IdCliente
INNER JOIN Cliente_Sucursal ON Cliente.IdCliente = Cliente_Sucursal.IdCliente
WHERE Cliente_Sucursal.IdSucursal = 2
