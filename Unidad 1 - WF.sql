USE MASTER
GO
IF NOT EXISTS (SELECT name FROM master.dbo.sysdatabases WHERE name = 'PracticaWF')
BEGIN
	CREATE DATABASE PracticaWF
	COLLATE Latin1_general_CI_AI;
END
GO

USE PracticaWF
GO

IF NOT EXISTS(SELECT * FROM sys.schemas WHERE name = 'tablasWF')
BEGIN
	EXEC('CREATE SCHEMA tablasWF')
END
GO

-- CREACION TABLA EMPLEADOS
IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'tablasWF' AND TABLE_NAME = 'Empleados')
BEGIN
	CREATE TABLE tablaswf.Empleados(
	EmpleadoID INT IDENTITY(1,1) PRIMARY KEY,
	Nombre VARCHAR(10),
	Departamento VARCHAR(50),
	Salario DECIMAL(10,2)
	)
END
GO

-- INSERCIÓN DATOS EMPLEADOS
INSERT INTO tablaswf.Empleados(Nombre,Departamento,Salario)
VALUES
	('Juan','Ventas',3000.00),
	('María','Ventas',2800.00),
	('Pedro','Marketing',3200.00),
	('Laura','Marketing',3500.00),
	('Carlos','IT',4000.00);

-- Ej 1
SELECT
	EmpleadoID,
	Nombre,
	Departamento,
	Salario,
	RANK () OVER(ORDER BY Salario DESC) AS 'OrdenEmpleadosSalario'
FROM tablasWF.Empleados
ORDER BY Salario DESC

-- Ej 2
INSERT INTO tablaswf.Empleados (Nombre, Departamento, Salario)
VALUES
('Ramiro', 'Ventas', 1800.00),
('Tomas', 'Ventas', 3200.00),
('Erik', 'Marketing', 1477.00),
('Esteban', 'Marketing', 15000.00),
('Laura', 'IT', 452.00),
('Romina', 'Ventas', 7855.00),
('Susana', 'Ventas', 1233.00),
('Mateo', 'Marketing', 4755.00),
('Nicolas', 'Marketing', 1236.00),
('Federico', 'IT', 260611.00),
('Miguel', 'Ventas', 4688.00),
('Josefina', 'Ventas', 2855.00),
('Franco', 'Marketing', 7456.00),
('Cesar', 'Marketing', 2555.00),
('Patricio', 'IT', 4000.00)

SELECT 
	EmpleadoID,
	Nombre,
	Departamento,
	Salario,
	DENSE_RANK() OVER(PARTITION BY Departamento ORDER BY Salario DESC) AS Ranking
FROM tablasWF.Empleados

-- Ej 3
SELECT 
	EmpleadoID,
	Nombre,
	Departamento,
	Salario,
	NTILE(4) OVER(ORDER BY Salario DESC) AS GrupoSalario
FROM tablasWF.Empleados

-- Ej 4
SELECT
	EmpleadoID,
	Nombre,
	Departamento,
	Salario,
	LAG (Salario,0) OVER(PARTITION BY Departamento ORDER BY Salario ASC)SalarioAnterior,
	LEAD (Salario,0) OVER(PARTITION BY Departamento ORDER BY Salario ASC) AS SiguienteSalario
FROM tablasWF.Empleados

-- Ej 5

-- CREACIÓN TABLAS CLIENTES Y PEDIDOS
IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'tablasWF' AND TABLE_NAME = 'Clientes')
BEGIN
	CREATE TABLE tablaswf.Clientes(
		id_cliente INT IDENTITY(1,1) PRIMARY KEY,
		nombre VARCHAR(50),
		pais VARCHAR(50)
		)
END
GO

IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'tablasWF' AND TABLE_NAME = 'Pedidos')
BEGIN
	CREATE TABLE tablaswf.Pedidos(
		id_pedido INT IDENTITY(1,1) PRIMARY KEY,
		id_cliente INT,
		fecha_pedido DATE,
		monto DECIMAL(10,2),
		FOREIGN KEY(id_cliente) REFERENCES tablaswf.Clientes(id_cliente)
		)
END
GO

-- INSERCIÓN DATOS CLIENTES PEDIDOS
INSERT INTO tablaswf.Clientes (nombre, pais) VALUES 
	('John Doe', 'Argentina'), 
	('Jane Smith', 'Australia'), 
	('Juan García', 'Brasil'), 
	('Maria Hernandez', 'Canadá'), 
	('Michael Johnson', 'China'), 
	('Sophie Martin', 'Dinamarca'), 
	('Ahmad Khan', 'Egipto'), 
	('Emily Brown', 'Francia'), 
	('Hans Müller', 'Alemania'), 
	('Sofia Rossi', 'Italia'), 
	('Takeshi Yamada', 'Japón'), 
	('Javier López', 'México'), 
	('Eva Novak', 'Países Bajos'), 
	('Rafael Silva', 'Portugal'), 
	('Olga Petrova', 'Rusia'), 
	('Fernanda Gonzalez', 'España'), 
	('Mohammed Ali', 'Egipto'), 
	('Lena Schmidt', 'Alemania'), 
	('Yuki Tanaka', 'Japón'), 
	('Lucas Costa', 'Brasil');

-- ERROR DE IDENTITY_INSERT
SET IDENTITY_INSERT tablaswf.Pedidos ON

DECLARE @startDate DATE='2023-01-01'
DECLARE @endDate DATE='2023-12-31'
DECLARE @orderId INT = 1;

WHILE @orderId <= 100
BEGIN
	INSERT INTO tablaswf.Pedidos (id_pedido,id_cliente, fecha_pedido, monto)
	VALUES (
	@orderId,
	((@orderId - 1) % 20) + 1,
	DATEADD(DAY,ABS(CHECKSUM(NEWID())) % (DATEDIFF(DAY,@startDate,@endDate) + 1),@startDate),
	ROUND(RAND(CHECKSUM(NEWID())) * 5000 + 1000,2)
	);
	SET @orderId = @orderId + 1;
END

SELECT
	id_pedido,
	id_cliente,
	monto,
	promedio_monto_cliente,
	RANK() OVER(PARTITION BY id_cliente ORDER BY promedio_monto_cliente ASC) AS posicion_rel_monto_cliente
FROM (
	 SELECT
		id_pedido,
		id_cliente,
		monto,
		AVG(monto) OVER(PARTITION BY id_cliente ORDER BY monto DESC) AS promedio_monto_cliente
	 FROM tablaswf.Pedidos
) AS subconsulta;

-- Ej 6
WITH V_montosxcliente AS(
	SELECT
		c.nombre,
		c.pais,
		SUM(p.monto) AS monto_total_pedidos
	 FROM tablaswf.Clientes c
	 INNER JOIN tablaswf.Pedidos p ON p.id_cliente = c.id_cliente
	 GROUP BY c.nombre, c.pais
)
SELECT
	nombre,
	pais,
	monto_total_pedidos,
	RANK() OVER(PARTITION BY pais ORDER BY monto_total_pedidos ASC) AS ranking_por_pais
FROM V_montosxcliente
ORDER BY pais

-- Ej 7
SELECT
	id_pedido,
	id_cliente,
	fecha_pedido,
	monto,
	(monto - LEAD(monto,1,1) OVER(ORDER BY id_cliente ASC)) AS diferencia_monto
FROM tablaswf.Pedidos
