-- Ej 1
CREATE DATABASE LuciaDeTitto
ON
PRIMARY (
	NAME = 'LuciaDeTitto_data',
	FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\LuciaDeTitto_data.mdf',
	MAXSIZE = UNLIMITED,
	FILEGROWTH = 5MB
)
LOG ON (
	NAME = 'LuciaDeTitto_log',
	FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\LuciaDeTitto_log.ldf',
	MAXSIZE = UNLIMITED,
	FILEGROWTH = 1MB
);

-- Ej 2
CREATE SCHEMA ddbba;

-- Ej 3
CREATE TABLE ddbba.registro (
id INT IDENTITY(1,1) PRIMARY KEY,
fecha DATETIME DEFAULT GETDATE(),
hora TIME DEFAULT GETDATE(),
texto varchar(50),
modulo varchar(10)
);

-- Ej 4
CREATE PROCEDURE ddbba.insertarLog
	@modulo varchar(50),
	@texto varchar(10)
AS
BEGIN
	IF @texto = ''
	BEGIN
		SET @texto = 'N/A'
	END
	INSERT INTO ddbba.registro
	VALUES (@texto, @modulo)
END;

CREATE TRIGGER ddbba.tgInsertarLog
ON ddbba.registro
AFTER INSERT, DELETE, UPDATE
AS
BEGIN
	DECLARE @modulo VARCHAR(50);
	DECLARE @texto VARCHAR(10);

	IF EXISTS (SELECT * FROM INSERTED) AND EXISTS (SELECT * FROM DELETED)
	BEGIN
		SET @modulo = (SELECT modulo FROM INSERTED)
		SET @texto = 'Registro insertado'
		EXEC ddbba.insertarLog @modulo, @texto
	END

	IF EXISTS (SELECT * FROM INSERTED)
	BEGIN
		SET @modulo = (SELECT modulo FROM INSERTED)
		SET @texto = 'Registro insertado'
		EXEC ddbba.insertarLog @modulo, @texto
	END

	IF EXISTS (SELECT * FROM DELETED)
	BEGIN
		SET @modulo = (SELECT modulo FROM DELETED)
		SET @texto = 'Registro insertado'
		EXEC ddbba.insertarLog @modulo, @texto
	END
END
