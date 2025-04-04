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

-- Ej 2
DROP SCHEMA ddbba;
GO

CREATE SCHEMA ddbba;
GO


-- Ej 3
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
CREATE TABLE ddbba.Persona (
	persona_id INT IDENTITY(1,1) PRIMARY KEY,
	primer_nombre VARCHAR(20) NOT NULL,
	segundo_nombre VARCHAR(20),
	apellido VARCHAR(20) NOT NULL,
	dni CHAR(9) NOT NULL UNIQUE,
	tel CHAR(15) NOT NULL,
	localidad VARCHAR(10) NOT NULL,
	fnac DATE NOT NULL,
	CONSTRAINT validar_dni CHECK (LEN(dni) = 9 AND dni NOT LIKE '^[0-9]{9}$')
)
GO

-- AUXILIAR DROPS
DROP TABLE ddbba.Inscripcion
DROP TABLE ddbba.Curso
DROP TABLE ddbba.Materia
DROP TABLE ddbba.Persona
DROP TABLE ddbba.Vehiculo

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

CREATE TABLE ddbba.Materia (
	materia_id INT IDENTITY(1,1) PRIMARY KEY,
	nombre VARCHAR(50)
)
GO

CREATE TABLE ddbba.Curso (
	curso_id INT IDENTITY(1,1) PRIMARY KEY,
	nro INT NOT NULL,
	materia_id INT NOT NULL,
	dia_id INT NOT NULL,
	turno_id INT NOT NULL,
	CONSTRAINT FKmateria_curso FOREIGN KEY (materia_id) REFERENCES ddbba.Materia(materia_id),
	CONSTRAINT FKturno_curso FOREIGN KEY (turno_id) REFERENCES ddbba.Turnos(ID),
	CONSTRAINT FKdia_curso FOREIGN KEY (dia_id) REFERENCES ddbba.Dias(ID)
)
GO

CREATE TABLE ddbba.Inscripcion (
	persona_id INT,
	curso_id INT,
	rol VARCHAR(10) CHECK (rol IN ('Alumno', 'Docente')),
	PRIMARY KEY (persona_id,curso_id),
	CONSTRAINT persona_id FOREIGN KEY (persona_id) REFERENCES ddbba.Persona(persona_id),
	CONSTRAINT curso_id FOREIGN KEY (curso_id) REFERENCES ddbba.Curso(curso_id)
);

-- Ej 6

INSERT INTO ddbba.Persona (primer_nombre, segundo_nombre, apellido, dni, localidad, fnac)
VALUES ('Juan', 'Carlos', 'Pérez', '123456789', 'Buenos Aires', '1990-05-10');

INSERT INTO ddbba.Persona (primer_nombre, segundo_nombre, apellido, dni, localidad, fnac)
VALUES ('Pedro', 'José', 'González', '12345678', 'Córdoba', '1985-11-20');

INSERT INTO ddbba.Persona (primer_nombre, segundo_nombre, apellido, dni, localidad, fnac)
VALUES ('Ana', 'Lucía', 'Martínez', 'ABCD12345', 'Mendoza', '2000-02-15');

INSERT INTO ddbba.Vehiculo (patente)
VALUES ('ABC 123');

INSERT INTO ddbba.Vehiculo (patente)
VALUES ('ABCD 1234');

INSERT INTO ddbba.Vehiculo (patente)
VALUES ('123 ABC');

INSERT INTO ddbba.Materia (nombre)
VALUES ('Matemáticas');

-- Primero insertamos la materia
INSERT INTO ddbba.Materia (nombre)
VALUES ('Física');

-- Luego insertamos el curso
INSERT INTO ddbba.Curso (nro, materia_id)
VALUES (101, 1);

INSERT INTO ddbba.Curso (nro, materia_id)
VALUES (102, 999);  -- Suponiendo que el materia_id 999 no existe

-- Primero insertamos los registros necesarios
INSERT INTO ddbba.Persona (primer_nombre, apellido, dni, localidad, fnac)
VALUES ('Carlos', 'Sánchez', '987654321', 'Rosario', '1995-03-25');

INSERT INTO ddbba.Materia (nombre)
VALUES ('Historia');

INSERT INTO ddbba.Curso (nro, materia_id)
VALUES (201, 1);

-- Luego insertamos la inscripción
INSERT INTO ddbba.Inscripcion (persona_id, curso_id, rol)
VALUES (1, 1, 'Alumno');

-- Inserción de inscripción de una persona como Docente
INSERT INTO ddbba.Inscripcion (persona_id, curso_id, rol)
VALUES (1, 1, 'Docente');

-- Intento de inserción con rol no válido
INSERT INTO ddbba.Inscripcion (persona_id, curso_id, rol)
VALUES (1, 1, 'Estudiante');  -- Rol no permitido

-- Intento de inscripción duplicada (la misma persona en el mismo curso)
INSERT INTO ddbba.Inscripcion (persona_id, curso_id, rol)
VALUES (1, 1, 'Alumno');

-- Intento de inscripción a un curso inexistente (curso_id 999 no existe)
INSERT INTO ddbba.Inscripcion (persona_id, curso_id, rol)
VALUES (1, 999, 'Alumno');

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
	('Moron');

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
		SET @primer_nombre = (SELECT TOP 1 Nombre FROM ddbba.Nombres ORDER BY NEWID());
		SET @segundo_nombre = (SELECT TOP 1 Nombre FROM ddbba.Nombres WHERE Nombre NOT LIKE @primer_nombre ORDER BY NEWID());
		SET @apellido = (SELECT TOP 1 Apellido FROM ddbba.Apellidos ORDER BY NEWID());
		SET @dni = FORMAT(ABS(CHECKSUM(NEWID())) % 1000000000, '000000000');
		SET @tel = CAST(ABS(CHECKSUM(NEWID())) % 9000000000 + 1000000000 AS VARCHAR(10));
		SET @localidad = (SELECT TOP 1 Localidad FROM ddbba.Localidades ORDER BY NEWID());
		SET @fnac = DATEADD(DAY,RAND() * (365 * 55), '1950-01-01');

		INSERT INTO ddbba.Persona VALUES
		(@primer_nombre,@segundo_nombre,@apellido,@dni,@tel,@localidad,@fnac)

		SET @i = @i + 1;
	END

	EXEC ddbba.SP_insertarLog '','INSERCION'

END;

-- Ej 8

DECLARE @cant INT
SET @cant = 1000
EXEC ddbba.SP_crearAlumnos @cant

SELECT *
FROM ddbba.registro

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