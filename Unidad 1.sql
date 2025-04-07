

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

	EXEC ddbba.SP_insertarLog 'ALUMNOS','INSERCION'

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
--Resuelto con CTE
WITH CTE_duplicados AS (
    SELECT 
		persona_id, 
		primer_nombre, 
		segundo_nombre, 
		apellido, 
		ROW_NUMBER() OVER (
			PARTITION BY primer_nombre, segundo_nombre, apellido 
			ORDER BY persona_id
		) AS nroFila
	FROM ddbba.Persona
)
DELETE FROM CTE_duplicados
WHERE nroFila > 1;
GO

EXEC ddbba.SP_insertarLog 'DUPLICADOS','ELIMINACION'
GO


-- Ej 10

DELETE ddbba.Materia

INSERT INTO ddbba.Materia (nombre) VALUES
    ('Bases de Datos Aplicadas'),
    ('Algoritmos y Estructuras de Datos'),
    ('Principios de Diseño de Sistemas'),
    ('Gestión de las Organizaciones'),
    ('Redes de Computadoras');

select * from ddbba.materia

DROP PROCEDURE IF EXISTS ddbba.SP_crearCursos;
GO

CREATE PROCEDURE ddbba.SP_crearCursos
AS
BEGIN
    DECLARE @materia_id INT;
    DECLARE @dia VARCHAR(10);
    DECLARE @turno VARCHAR(10);
    DECLARE @nro INT;
    DECLARE @i INT, @cantidad INT;

    -- Cursor para recorrer todas las materias
    DECLARE materia_cursor CURSOR FOR
    SELECT materia_id
    FROM ddbba.Materia;

    OPEN materia_cursor;
    FETCH NEXT FROM materia_cursor INTO @materia_id;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @i = 0;
        -- Generar una cantidad aleatoria de comisiones entre 1 y 5 para cada materia
        SET @cantidad = FLOOR(RAND() * 5) + 1;

        WHILE @i < @cantidad
        BEGIN
            -- Seleccionar aleatoriamente un día y un turno
            SET @dia = (SELECT TOP 1 dia FROM (VALUES ('Lunes'), ('Martes'), ('Miercoles'), ('Jueves'), ('Viernes'), ('Sabado'), ('Domingo')) AS Dias(dia) ORDER BY NEWID());
            SET @turno = (SELECT TOP 1 turno FROM (VALUES ('mañana'), ('tarde'), ('noche')) AS Turnos(turno) ORDER BY NEWID());

            -- Calcular el número de curso basado en el día y el turno
            SET @nro =
                CASE @dia
                    WHEN 'Lunes' THEN 1000
                    WHEN 'Martes' THEN 2000
                    WHEN 'Miercoles' THEN 3000
                    WHEN 'Jueves' THEN 4000
                    WHEN 'Viernes' THEN 5000
                    WHEN 'Sabado' THEN 6000
                    WHEN 'Domingo' THEN 7000
                END +
                CASE @turno
                    WHEN 'mañana' THEN 300
                    WHEN 'tarde' THEN 600
                    WHEN 'noche' THEN 900
                END;

            -- Insertar el curso en la tabla Curso
            INSERT INTO ddbba.Curso (nro, materia_id, dia, turno)
            VALUES (@nro, @materia_id, @dia, @turno);

            SET @i = @i + 1;
        END

        FETCH NEXT FROM materia_cursor INTO @materia_id;
    END;

    CLOSE materia_cursor;
    DEALLOCATE materia_cursor;

    -- Registrar la operación en el log
    EXEC ddbba.SP_insertarLog 'CURSOS', 'INSERCION';
END;
GO

DELETE ddbba.Curso

EXEC ddbba.SP_crearCursos


SELECT * FROM ddbba.Curso


SELECT * FROM ddbba.Materia


-- Ej 12


DROP VIEW IF EXISTS ddbba.V_comisiones;
GO

CREATE VIEW ddbba.V_comisiones
WITH SCHEMABINDING
AS
	SELECT 
		c.nro AS nro_comision,
		c.materia_id,
		m.nombre AS nombre_materia,
		CAST(p.apellido + ', ' + p.primer_nombre + ISNULL(' ' + p.segundo_nombre, '') AS VARCHAR(150)) AS [Apellido, Nombres]
	FROM ddbba.Curso c
	JOIN ddbba.Materia m ON m.materia_id = c.materia_id
	JOIN ddbba.Inscripcion i ON i.curso_id = c.curso_id
	JOIN ddbba.Persona p ON p.persona_id = i.persona_id
	WHERE i.rol LIKE 'Alumno'

-- a)
ALTER TABLE ddbba.Persona
ALTER COLUMN primer_nombre VARCHAR(40); 
-- ERROR: The object 'V_comisiones' is dependent on column 'primer_nombre'.

-- b)
ALTER TABLE ddbba.Persona
ADD edad INT; 
-- NO hay error.

-- c)
ALTER TABLE ddbba.Persona
ADD cuil CHAR(15) NOT NULL; 
-- ERROR: .ALTER TABLE only allows columns to be added that can contain nulls, or have a DEFAULT definition specified, or the column being added is an identity or timestamp column, or alternatively if none of the previous conditions are satisfied the table must be empty to allow addition of this column. Column 'cuil' cannot be added to non-empty table 'Persona' because it does not satisfy these conditions.

-- d)
SELECT * FROM ddbba.V_comisiones 
-- Si, es posible.

-- Ej 13
IF OBJECT_ID('ddbba.Dia','U') IS NOT NULL
	DROP TABLE ddbba.Dia;
GO
CREATE TABLE ddbba.Dia (
    dia_id INT IDENTITY(1,1) PRIMARY KEY,
    nombre CHAR(10) UNIQUE NOT NULL
);

IF OBJECT_ID('ddbba.Turno','U') IS NOT NULL
	DROP TABLE ddbba.Turno;
GO
CREATE TABLE ddbba.Turno (
    turno_id INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(10) UNIQUE NOT NULL
);

-- Insertar valores únicos desde la tabla Curso
INSERT INTO ddbba.Dia (nombre) VALUES
('Lunes'),
('Martes'),
('Miercoles'),
('Jueves'),
('Viernes'),
('Sabado'),
('Domingo');

select * from ddbba.Dia order by dia_id;


INSERT INTO ddbba.Turno (nombre) VALUES
('mañana'),
('tarde'),
('noche');

select * from ddbba.Turno order by turno_id;

--Agregar columnas dia_id y turno_id a la tabla Curso
ALTER TABLE ddbba.Curso ADD dia_id INT NULL;
ALTER TABLE ddbba.Curso ADD turno_id INT NULL;

--Actualizar las columnas dia_id y turno_id usando Dia y Turno
UPDATE c
SET dia_id = d.dia_id
FROM ddbba.Curso c
JOIN ddbba.Dia d ON c.dia = d.nombre;

UPDATE c
SET turno_id = t.turno_id
FROM ddbba.Curso c
JOIN ddbba.Turno t ON c.turno = t.nombre;

--Eliminar constraints de validación vieja y columnas dia y turno
ALTER TABLE ddbba.Curso DROP CONSTRAINT verify_dia;
ALTER TABLE ddbba.Curso DROP CONSTRAINT verify_turno;

ALTER TABLE ddbba.Curso DROP COLUMN dia;
ALTER TABLE ddbba.Curso DROP COLUMN turno;

--Modificar columnas dia_id y turno_id a NOT NULL y agregar FOREIGN KEY
ALTER TABLE ddbba.Curso ALTER COLUMN dia_id INT NOT NULL;
ALTER TABLE ddbba.Curso ALTER COLUMN turno_id INT NOT NULL;

ALTER TABLE ddbba.Curso ADD CONSTRAINT FK_Curso_Dia FOREIGN KEY (dia_id) REFERENCES ddbba.Dia(dia_id);
ALTER TABLE ddbba.Curso ADD CONSTRAINT FK_Curso_Turno FOREIGN KEY (turno_id) REFERENCES ddbba.Turno(turno_id);

--Agregar columnas anio y cuatrimestre a Curso
ALTER TABLE ddbba.Curso ADD anio INT NOT NULL DEFAULT 2025;
ALTER TABLE ddbba.Curso ADD cuatrimestre INT NOT NULL DEFAULT 1;

select * from ddbba.Curso


-- Ej 15
CREATE FUNCTION ddbba.validaCursada (@dni CHAR(9))
RETURNS INT
AS
BEGIN
    DECLARE @superpuestas INT = 0;

    WITH CursosPorAlumno AS (
        SELECT
            c.dia_id,
            c.turno_id,
            COUNT(*) AS cantidad
        FROM ddbba.Inscripcion i
        JOIN ddbba.Persona p ON i.persona_id = p.persona_id
        JOIN ddbba.Curso c ON i.curso_id = c.curso_id
        WHERE i.rol = 'Alumno' AND p.dni = @dni
        GROUP BY c.dia_id, c.turno_id
        HAVING COUNT(*) > 1
    )
    SELECT @superpuestas = COUNT(*) FROM CursosPorAlumno;

    RETURN @superpuestas;
END;


-- Ej 16
CREATE VIEW ddbba.Vista_AlumnosConSuperposicion
AS
SELECT
    p.persona_id,
    p.dni,
    p.primer_nombre,
    p.apellido,
    ddbba.validaCursada(p.dni) AS cantidad_superposiciones
FROM ddbba.Persona p
WHERE ddbba.validaCursada(p.dni) > 0;
GO

Select * from ddbba.Vista_AlumnosConSuperposicion;

-- Ej 17
CREATE PROCEDURE ddbba.SP_eliminarInscripcionesSuperpuestas
AS
BEGIN
    SET NOCOUNT ON;

    WITH InscripcionesDuplicadas AS (
        SELECT
            i.persona_id,
            i.curso_id,
            ROW_NUMBER() OVER (
                PARTITION BY i.persona_id, c.dia_id, c.turno_id
                ORDER BY i.curso_id
            ) AS rn
        FROM ddbba.Inscripcion i
        JOIN ddbba.Curso c ON i.curso_id = c.curso_id
        WHERE i.rol = 'Alumno'
    )

    DELETE i
    FROM ddbba.Inscripcion i
    JOIN InscripcionesDuplicadas d ON i.persona_id = d.persona_id AND i.curso_id = d.curso_id
    WHERE d.rn > 1;
END;
GO

--GENERAR LOTE DE PRUEBAS PARA PROBAR SP Y VIEW
-- Borrar si ya existe
DELETE FROM ddbba.Inscripcion WHERE persona_id = 999;
DELETE FROM ddbba.Persona WHERE persona_id = 999;
DELETE FROM ddbba.Curso WHERE curso_id IN (9001, 9002, 9003);

--Insertar un alumno de prueba
SET IDENTITY_INSERT ddbba.Persona ON;
INSERT INTO ddbba.Persona (persona_id, primer_nombre, apellido, dni, tel, localidad, fnac)
VALUES (999, 'Juan', 'Pérez', '123456789', '1234567890', 'Buenos Aires', '1990-01-01');
SET IDENTITY_INSERT ddbba.Persona OFF;

--Insertar un curso de prueba
SET IDENTITY_INSERT ddbba.Curso ON;
INSERT INTO ddbba.Curso (curso_id, materia_id, dia_id, turno_id, nro)
VALUES 
(9001, 1, 1, 1, 1),
(9002, 2, 1, 1, 2), 
(9003, 3, 2, 2, 3);
SET IDENTITY_INSERT ddbba.Curso OFF;


--Inscribir al alumno en cursos superpuestos
INSERT INTO ddbba.Inscripcion (persona_id, curso_id, rol)
VALUES
(999, 9001, 'Alumno'),
(999, 9002, 'Alumno'),
(999, 9003, 'Alumno');

--Verificar función
SELECT ddbba.validaCursada('123456789') AS superposiciones; -- Debería devolver 1

--Verificar la vista
SELECT * FROM ddbba.Vista_AlumnosConSuperposicion;

--Ejecutar el SP para eliminar inscripciones superpuestas
EXEC ddbba.SP_eliminarInscripcionesSuperpuestas;

--Verificar nuevamente la función y la vista
SELECT ddbba.validaCursada('123456789') AS superposiciones_despues; -- Debería devolver 0

SELECT * FROM ddbba.Vista_AlumnosConSuperposicion; -- Ya no debería mostrar al amigo Juan

SELECT * FROM ddbba.Inscripcion WHERE persona_id = 999;


--MOSTRAR CONTENIDO DE LAS TABLAS TABLAS
SELECT * FROM ddbba.Inscripcion
SELECT * FROM ddbba.Curso
SELECT * FROM ddbba.Materia
SELECT * FROM ddbba.Persona

-- Ej 18
--creación de una tabla pivot para ver las incripciones de los alumnos por turno
CREATE VIEW ddbba.Vista_InscripcionesPorTurno AS
SELECT 
    materia, 
    ISNULL([Mañana], 0) AS Mañana,
    ISNULL([Tarde], 0) AS Tarde,
    ISNULL([Noche], 0) AS Noche
FROM (
    SELECT 
        m.nombre AS materia,
        t.nombre AS turno
    FROM ddbba.Inscripcion i
    JOIN ddbba.Curso c ON i.curso_id = c.curso_id
    JOIN ddbba.Materia m ON c.materia_id = m.materia_id
    JOIN ddbba.Turno t ON c.turno_id = t.turno_id
    WHERE i.rol = 'Alumno'
) AS Fuente
PIVOT (
    COUNT(turno) FOR turno IN ([Mañana], [Tarde], [Noche])
) AS TablaPivoteada;
GO

SELECT * FROM ddbba.Vista_InscripcionesPorTurno;


--creación de una tabla pivot para ver las incripciones de los alumnos por dia
CREATE VIEW ddbba.Vista_InscripcionesPorDia AS
SELECT 
    materia,
    ISNULL([lunes], 0) AS lunes,
    ISNULL([martes], 0) AS martes,
    ISNULL([miércoles], 0) AS miércoles,
    ISNULL([jueves], 0) AS jueves,
    ISNULL([viernes], 0) AS viernes,
    ISNULL([sábado], 0) AS sábado,
    ISNULL([domingo], 0) AS domingo
FROM (
    SELECT 
        m.nombre AS materia,
        CASE c.dia_id
            WHEN 1 THEN 'lunes'
            WHEN 2 THEN 'martes'
            WHEN 3 THEN 'miércoles'
            WHEN 4 THEN 'jueves'
            WHEN 5 THEN 'viernes'
            WHEN 6 THEN 'sábado'
            WHEN 7 THEN 'domingo'
        END AS dia_semana
    FROM ddbba.Inscripcion i
    JOIN ddbba.Curso c ON i.curso_id = c.curso_id
    JOIN ddbba.Materia m ON c.materia_id = m.materia_id
    WHERE i.rol = 'Alumno'
) AS Fuente
PIVOT (
    COUNT(dia_semana) FOR dia_semana IN (
        [lunes], [martes], [miércoles], [jueves], [viernes], [sábado], [domingo]
    )
) AS TablaPivoteada;
GO

SELECT * FROM ddbba.Vista_InscripcionesPorDia;

-- Ej 19

CREATE OR ALTER VIEW ddbba.Vista_AlumnosMaterias_Cuatrimestre AS
SELECT 
    i.persona_id,
    p.primer_nombre + ' '+ ISNULL(p.segundo_nombre + ' ','') + p.apellido AS nombre_completo,
    m.nombre AS materia,
    c.anio,
    c.cuatrimestre,
    COUNT(*) OVER (PARTITION BY i.persona_id, c.anio, c.cuatrimestre) AS total_materias_cuatrimestre
FROM ddbba.Inscripcion i
JOIN ddbba.Curso c ON i.curso_id = c.curso_id
JOIN ddbba.Materia m ON c.materia_id = m.materia_id
JOIN ddbba.Persona p ON i.persona_id = p.persona_id
WHERE i.rol = 'Alumno';

SELECT * FROM ddbba.Vista_AlumnosMaterias_Cuatrimestre;

-- Ej 20

WITH AlumnosConEdad AS (
    SELECT 
        p.persona_id,
        p.fnac,
        DATEDIFF(YEAR, p.fnac, GETDATE()) AS edad,
        PERCENT_RANK() OVER (ORDER BY p.fnac DESC) AS percentil_edad
    FROM ddbba.Persona p
    JOIN ddbba.Inscripcion i ON p.persona_id = i.persona_id
    WHERE i.rol = 'Alumno'
    GROUP BY p.persona_id, p.fnac
)

SELECT *
FROM AlumnosConEdad
WHERE percentil_edad <= 0.05 OR percentil_edad >= 0.95
ORDER BY edad;