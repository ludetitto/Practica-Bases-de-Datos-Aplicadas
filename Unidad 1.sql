

-- Ej 1
CREATE DATABASE DreamTeam
ON
PRIMARY (
	NAME = 'DreamTeam_data',
	FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\DreamTeam_data.mdf',
	MAXSIZE = UNLIMITED,
	FILEGROWTH = 5MB
)
LOG ON (
	NAME = 'DreamTeam_log',
	FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\DreamTeam_log.ldf',
	MAXSIZE = UNLIMITED,
	FILEGROWTH = 1MB
);
--Opcion b
CREATE DATABASE DreamTeam;


-- Ej 2
DROP SCHEMA ddbba;
GO

CREATE SCHEMA ddbba;
GO


-- Ej 3
--TABLA REGISTRO

CREATE TABLE ddbba.registro (
	id INT IDENTITY(1,1) PRIMARY KEY,
	fechayhora DATETIME DEFAULT GETDATE(),
	texto varchar(50),
	modulo varchar(10)
);
GO

-- Ej 4

DROP PROCEDURE IF EXISTS ddbba.SP_insertarLog
GO

CREATE PROCEDURE ddbba.SP_insertarLog
	@modulo varchar(50),
	@texto varchar(10)
AS
BEGIN
	IF @modulo = ''
	BEGIN
		SET @modulo = 'N/A'
	END
	INSERT INTO ddbba.registro(texto,modulo)
	VALUES (@texto, @modulo)
END;
GO

-- Ej 5

--TABLA PERSONA
IF OBJECT_ID('ddbba.Persona','U') IS NOT NULL
	DROP TABLE ddbba.Persona;
GO

CREATE TABLE ddbba.Persona (
	persona_id INT IDENTITY(1,1) PRIMARY KEY,
	primer_nombre VARCHAR(20) NOT NULL,
	segundo_nombre VARCHAR(20),
	apellido VARCHAR(20) NOT NULL,
	dni CHAR(9) NOT NULL UNIQUE,
	tel VARCHAR(15) NOT NULL,
	localidad VARCHAR(20) NOT NULL,
	fnac DATE NOT NULL,
	vehiculo_id INT NULL,
	CONSTRAINT validar_dni CHECK (dni LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
    CONSTRAINT validar_tel CHECK (LEN(tel) BETWEEN 7 AND 15 AND REPLACE(tel, ' ', '') NOT LIKE '%[^0-9]%')
)
GO
--TABLA VEHICULO

IF OBJECT_ID('ddbba.Vehiculo','U') IS NOT NULL
	DROP TABLE ddbba.Vehiculo;
GO

CREATE TABLE ddbba.Vehiculo (
	vehiculo_id INT IDENTITY(1,1) PRIMARY KEY,
	patente VARCHAR(8) NOT NULL UNIQUE,
	CONSTRAINT validar_patente CHECK (
		patente LIKE '[A-Za-z][A-Za-z][A-Za-z] [0-9][0-9][0-9]'
		OR
		patente LIKE '[A-Za-z][A-Za-z] [0-9][0-9][0-9] [A-Za-z][A-Za-z]'
		)
)
GO

--relación opcional una persona puede tener un Vehiculo.
ALTER TABLE ddbba.Persona
ADD CONSTRAINT FK_Persona_Vehiculo 
FOREIGN KEY (vehiculo_id) REFERENCES ddbba.Vehiculo(vehiculo_id);
GO

--TABLA MATERIA
IF OBJECT_ID('ddbba.Materia', 'U') IS NOT NULL
	DROP TABLE ddbba.Materia;
GO

CREATE TABLE ddbba.Materia (
	materia_id INT IDENTITY(1,1) PRIMARY KEY,
	nombre VARCHAR(50)
)
GO

IF OBJECT_ID('ddbba.Curso', 'U') IS NOT NULL
	DROP TABLE ddbba.Curso;
GO

CREATE TABLE ddbba.Curso (
	curso_id INT IDENTITY(1,1) PRIMARY KEY,
	nro INT NOT NULL,
	materia_id INT NOT NULL,
	dia char(10) NOT NULL,
	turno varchar(10) NOT NULL,
	CONSTRAINT FKmateria_curso FOREIGN KEY (materia_id) REFERENCES ddbba.Materia(materia_id),
	CONSTRAINT verify_dia CHECK(
		dia IN ('Lunes','Martes','Miercoles','Jueves','Viernes','Sabado','Domingo','','')
	),
	CONSTRAINT verify_turno CHECK(
		turno IN ('mañana','tarde','noche')
	)
)
GO

IF OBJECT_ID('ddbba.Inscripcion', 'U') IS NOT NULL
	DROP TABLE ddbba.Inscripcion;
GO

CREATE TABLE ddbba.Inscripcion (
	persona_id INT,
	curso_id INT,
	rol VARCHAR(10) CHECK (rol IN ('Alumno', 'Docente')),
	PRIMARY KEY (persona_id,curso_id),
	CONSTRAINT persona_id FOREIGN KEY (persona_id) REFERENCES ddbba.Persona(persona_id),
	CONSTRAINT curso_id FOREIGN KEY (curso_id) REFERENCES ddbba.Curso(curso_id)
);


--Eliminar todas las tablas en el siguiente orden
IF OBJECT_ID('ddbba.Inscripcion', 'U') IS NOT NULL
	DROP TABLE ddbba.Inscripcion;
GO
IF OBJECT_ID('ddbba.Curso', 'U') IS NOT NULL
	DROP TABLE ddbba.Curso;
GO
IF OBJECT_ID('ddbba.Materia', 'U') IS NOT NULL
	DROP TABLE ddbba.Materia;
GO
IF OBJECT_ID('ddbba.Persona','U') IS NOT NULL
	DROP TABLE ddbba.Persona;
GO
IF OBJECT_ID('ddbba.Vehiculo','U') IS NOT NULL
	DROP TABLE ddbba.Vehiculo;
GO

-- Ej 6

-- Registro de Materia para referenciar en Curso
INSERT INTO ddbba.Materia (nombre) VALUES ('MateriaPrueba');

INSERT INTO ddbba.Persona (primer_nombre, apellido, dni, tel, localidad, fnac)
VALUES ('Test', 'DNI_Corto', '12345678', '1234567', 'Ciudad', '2000-01-01'); 
-- Error esperado: Conflicto con CHECK constraint "validar_dni" (longitud de dni incorrecta).

INSERT INTO ddbba.Persona (primer_nombre, apellido, dni, tel, localidad, fnac)
VALUES ('Test', 'DNI_NoNumerico', 'ABC123456', '1234567', 'Ciudad', '2000-01-01'); 
-- Error esperado: Conflicto con CHECK constraint "validar_dni" (dni debe ser 9 dígitos numéricos).

INSERT INTO ddbba.Persona (primer_nombre, apellido, dni, tel, localidad, fnac)
VALUES ('Test', 'Tel_Corto', '223456789', '12345', 'Ciudad', '2000-01-01'); 
-- Error esperado: Conflicto con CHECK constraint "validar_tel" (longitud menor a 7).

INSERT INTO ddbba.Persona (primer_nombre, apellido, dni, tel, localidad, fnac)
VALUES ('Test', 'Tel_Largo', '323456789', '1234567890123456', 'Ciudad', '2000-01-01'); 
-- Error esperado: Conflicto con CHECK constraint "validar_tel" (longitud mayor a 15).

INSERT INTO ddbba.Persona (primer_nombre, apellido, dni, tel, localidad, fnac)
VALUES ('Test', 'Tel_NoNumerico', '423456789', '12345A789', 'Ciudad', '2000-01-01'); 
-- Error esperado: Conflicto con CHECK constraint "validar_tel" (tel contiene letra/s).

INSERT INTO ddbba.Vehiculo (patente)
VALUES ('AB 1234'); 
-- Error esperado: Conflicto con CHECK constraint "validar_patente" (formato no permitido).

INSERT INTO ddbba.Vehiculo (patente)
VALUES ('ABCD 123'); 
-- Error esperado: "String or binary data would be truncated" (cadena excede el tamaño definido).

INSERT INTO ddbba.Vehiculo (patente)
VALUES ('123 ABC'); 
-- Error esperado: Conflicto con CHECK constraint "validar_patente" (formato inválido).

INSERT INTO ddbba.Curso (nro, materia_id, dia, turno)
VALUES (111, 1, 'Funday', 'mañana');
-- Error esperado: Conflicto con CHECK constraint "verify_dia" (valor 'Funday' no es un día válido).

INSERT INTO ddbba.Curso (nro, materia_id, dia, turno)
VALUES (112, 1, 'Lunes', 'mediodia'); 
-- Error esperado: Conflicto con CHECK constraint "verify_turno" (valor 'mediodia' no es permitido).

INSERT INTO ddbba.Persona (primer_nombre, apellido, dni, tel, localidad, fnac)
VALUES ('Valido', 'Usuario', '555555555', '1234567', 'Ciudad', '1990-01-01');
-- SELECT persona_id FROM ddbba.Persona WHERE dni = '555555555';


INSERT INTO ddbba.Curso (nro, materia_id, dia, turno)
VALUES (200, 1, 'Lunes', 'mañana');
-- SELECT curso_id FROM ddbba.Curso WHERE nro = 200;

INSERT INTO ddbba.Inscripcion (persona_id, curso_id, rol)
VALUES (1, 1, 'Estudiante');
-- Error esperado: Conflicto con CHECK constraint en "rol"

INSERT INTO ddbba.Inscripcion (persona_id, curso_id, rol)
VALUES (1, 1, 'Alumno');

INSERT INTO ddbba.Inscripcion (persona_id, curso_id, rol)
VALUES (1, 1, 'Alumno');
-- Error esperado: Violación de PRIMARY KEY

INSERT INTO ddbba.Inscripcion (persona_id, curso_id, rol)
VALUES (999, 1, 'Alumno');
-- Error esperado: Violación de FOREIGN KEY en persona_id

INSERT INTO ddbba.Inscripcion (persona_id, curso_id, rol)
VALUES (1, 9999, 'Alumno');
-- Error esperado: Violación de FOREIGN KEY en curso_id


-- Ej 7
CREATE TABLE ddbba.Nombres(
	ID INT IDENTITY(1,1) PRIMARY KEY,
	Nombre VARCHAR(20) NOT NULL
);

INSERT INTO ddbba.Nombres VALUES
	('Lucia'),
	('Maria'),
	('Fito'),
	('Andres'),
	('Rodrigo'),
	('Jimena');

CREATE TABLE ddbba.Apellidos(
	ID INT IDENTITY(1,1) PRIMARY KEY,
	Apellido VARCHAR(20) NOT NULL
);

INSERT INTO ddbba.Apellidos VALUES
	('Calamaro'),
	('Fernandez'),
	('Rodriguez'),
	('Paez'),
	('Simpson'),
	('Bueno');

CREATE TABLE ddbba.Localidades(
	ID INT IDENTITY(1,1) PRIMARY KEY,
	Localidad VARCHAR(20) NOT NULL
);

INSERT INTO ddbba.Localidades VALUES
	('Caseros'),
	('San Martin'),
	('Ciudadela'),
	('Moron'),
	('San Justo');
	set nocount on

DROP PROCEDURE IF EXISTS ddbba.SP_crearAlumnos
GO
CREATE PROCEDURE ddbba.SP_crearAlumnos @cantidad INT
AS
BEGIN
	DECLARE @primer_nombre VARCHAR(20);
	DECLARE @segundo_nombre VARCHAR(20);
	DECLARE @apellido VARCHAR(20);
	DECLARE @dni CHAR(9),@i INT;
	DECLARE @tel VARCHAR(15);
	DECLARE @localidad VARCHAR(10);
	DECLARE @fnac DATE;

	SET @i = 0;

	WHILE @i < @cantidad
	BEGIN
		--Seleccion aleatoria de nombre y apellido
		SET @primer_nombre = (SELECT TOP 1 Nombre FROM ddbba.Nombres ORDER BY NEWID());
		SET @segundo_nombre = (SELECT TOP 1 Nombre FROM ddbba.Nombres WHERE Nombre NOT LIKE @primer_nombre ORDER BY NEWID());
		SET @apellido = (SELECT TOP 1 Apellido FROM ddbba.Apellidos ORDER BY NEWID());
		
		--Generacion de dni de 9 digitos
		SET @dni = FORMAT(ABS(CHECKSUM(NEWID())) % 1000000000, '000000000');
		
		--generacion de telefono
		SET @tel = CAST(ABS(CHECKSUM(NEWID())) % 9000000000 + 1000000000 AS VARCHAR(10));

		--Seleccion aleatoria de localidad
		SET @localidad = (SELECT TOP 1 Localidad FROM ddbba.Localidades ORDER BY NEWID());
		
		SET @fnac = DATEADD(DAY,RAND() * (365 * 55), '1950-01-01');

		INSERT INTO ddbba.Persona (primer_nombre, segundo_nombre, apellido, dni, tel, localidad, fnac)
		VALUES (@primer_nombre, @segundo_nombre, @apellido, @dni, @tel, @localidad, @fnac);


		SET @i = @i + 1;
	END

	EXEC ddbba.SP_insertarLog '','INSERCION'

END;

-- Ej 8
--Eliminar y resetear autoincrement
DELETE FROM ddbba.Persona;
DBCC CHECKIDENT ('ddbba.Persona', RESEED, 0);
GO

DECLARE @cant INT
SET @cant = 1000
EXEC ddbba.SP_crearAlumnos @cant

SELECT * FROM ddbba.Persona

SELECT TOP 20 * FROM ddbba.Persona



-- Ej 9
DROP VIEW IF EXISTS CTE_duplicados
GO

WITH CTE_duplicados AS (
    SELECT 
		persona_id, 
		primer_nombre, 
		segundo_nombre, 
		apellido, 
		ROW_NUMBER() OVER (PARTITION BY primer_nombre, segundo_nombre, apellido ORDER BY persona_id) AS nroFila
	FROM ddbba.Persona
)

DELETE FROM ddbba.Persona
WHERE persona_id IN (SELECT persona_id
					 FROM CTE_duplicados
					 WHERE nroFila > 1)
GO

EXEC ddbba.SP_insertarLog '','ELIMINACION'
GO

SELECT *
FROM ddbba.Persona

-- Ej 10

INSERT INTO ddbba.Materia VALUES
	('Análisis Matemático'),
	('Física I'),
	('Bases de Datos'),
	('Sistemas Operativos')

CREATE TABLE ddbba.Turnos (
	ID INT IDENTITY(1,1) PRIMARY KEY,
	Franja CHAR(6) NOT NULL
);

INSERT INTO ddbba.Turnos VALUES
	('Mañana'),
	('Tarde'),
	('Noche');

CREATE TABLE ddbba.Dias (
	ID INT IDENTITY(1,1) PRIMARY KEY,
	Dia CHAR(9) NOT NULL
);

INSERT INTO ddbba.Dias VALUES
	('Lunes'),
	('Martes'),
	('Miercoles'),
	('Jueves'),
	('Viernes'),
	('Sábados');


DROP PROCEDURE IF EXISTS ddbba.SP_crearCursos
GO

CREATE PROCEDURE ddbba.SP_crearCursos
AS
BEGIN

	DECLARE @materia VARCHAR(30);
	DECLARE @turno CHAR(6);
	DECLARE @nro INT, @materia_id INT;
	DECLARE @dia CHAR(9)
	DECLARE @i INT,@cantidad INT

	DECLARE materia_cursor CURSOR FOR
    SELECT materia_id
    FROM ddbba.Materia;

    OPEN materia_cursor

	FETCH NEXT FROM materia_cursor INTO @materia_id;

    WHILE @@FETCH_STATUS = 0
    BEGIN

		SET @i = 0;
		SET @cantidad = FLOOR(RAND() * 5 + 1)

		WHILE @i < @cantidad
		BEGIN
			SET @nro = FLOOR(RAND() * 9000) + 1000
			SET @turno = (SELECT TOP 1 ID FROM ddbba.Turnos ORDER BY NEWID());
			SET @dia = (SELECT TOP 1 ID FROM ddbba.Dias ORDER BY NEWID());
			INSERT INTO ddbba.Curso(nro,materia_id,turno_id,dia_id)
			VALUES(
				@nro,
				@materia_id,
				@turno,
				@dia
			)

			SET @i = @i + 1;
		END

		FETCH NEXT FROM materia_cursor INTO @materia_id;
    END;

    CLOSE materia_cursor;
    DEALLOCATE materia_cursor;

	EXEC ddbba.SP_insertarLog '','INSERCION'

END

EXEC ddbba.SP_crearCursos

SELECT *
FROM ddbba.Curso

DELETE ddbba.Curso

-- Ej 11
-- Haciendo las inscripciones

DROP PROCEDURE ddbba.SP_crearInscripciones
GO

CREATE PROCEDURE ddbba.SP_crearInscripciones
AS
BEGIN

    DECLARE @cantidad INT,@cantMaterias INT;

	SET @cantidad = FLOOR(RAND() * 20) + 1
	SET @cantMaterias = FLOOR(RAND() * 4) + 1

	WHILE @cantidad > 0
	BEGIN
		INSERT INTO ddbba.Inscripcion (persona_id, curso_id, rol)
		SELECT TOP (@cantMaterias)
			p.persona_id, 
			c.curso_id, 
			CASE 
				WHEN RAND() > 0.5 THEN 'Docente'
				ELSE 'Alumno'
			END AS rol
		FROM ddbba.Persona p
		CROSS JOIN ddbba.Curso c
		WHERE NOT EXISTS (
			SELECT 1
			FROM ddbba.Inscripcion i
			WHERE i.curso_id = c.curso_id
			AND i.persona_id = p.persona_id
		)
		AND NOT EXISTS (
			SELECT 1
			FROM ddbba.Inscripcion i
			INNER JOIN ddbba.Curso cu ON i.curso_id = cu.curso_id
			WHERE i.persona_id = p.persona_id
			AND cu.dia_id = c.dia_id
			AND cu.turno_id = c.turno_id
		)
    
		AND c.curso_id = c.curso_id
		ORDER BY NEWID();

		SET @cantidad = @cantidad - 1
	END

    EXEC ddbba.SP_insertarLog '', 'INSERCION';
END;

DELETE ddbba.Inscripcion

EXEC ddbba.SP_crearInscripciones

SELECT * FROM ddbba.Curso

SELECT i.persona_id, rol, t.Franja, d.Dia FROM ddbba.Inscripcion i
INNER JOIN ddbba.Curso c ON c.curso_id = i.curso_id
INNER JOIN ddbba.Turnos t ON t.ID = c.turno_id
INNER JOIN ddbba.Dias d ON d.ID = c.dia_id
GROUP BY i.persona_id, rol, t.Franja, d.Dia

-- Ej 12
DROP VIEW ddbba.V_comisiones
GO

CREATE VIEW ddbba.V_comisiones
WITH SCHEMABINDING
AS
	SELECT 
		c.nro,
		c.materia_id,
		m.nombre,
		CONCAT(p.apellido,', ', p.primer_nombre, ' ', p.segundo_nombre) as 'Apellido, Nombres'
	FROM ddbba.Curso c
	JOIN ddbba.Materia m ON m.materia_id = c.materia_id
	JOIN ddbba.Inscripcion i ON i.curso_id = c.curso_id
	JOIN ddbba.Persona p ON p.persona_id = i.persona_id
	WHERE i.rol LIKE 'Alumno'

-- a)
ALTER TABLE ddbba.Persona
ALTER COLUMN primer_nombre VARCHAR(40); -- ERROR: The object 'V_comisiones' is dependent on column 'primer_nombre'.

-- b)
ALTER TABLE ddbba.Persona
ADD edad INT; -- NO hay error.

-- c)
ALTER TABLE ddbba.Persona
ADD cuil CHAR(15) NOT NULL; -- ERROR: .ALTER TABLE only allows columns to be added that can contain nulls, or have a DEFAULT definition specified, or the column being added is an identity or timestamp column, or alternatively if none of the previous conditions are satisfied the table must be empty to allow addition of this column. Column 'cuil' cannot be added to non-empty table 'Persona' because it does not satisfy these conditions.

-- d)
SELECT * FROM ddbba.V_comisiones -- Si, es posible.