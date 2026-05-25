-- =============================================
-- FONDO XYZ - FASE 2: DATOS INICIALES (SEED)
-- Fuente: extracted_data_v3.json + requerimentos.md
-- + analisistemporadaaltaysemanaescolar.md
-- + ColombianHolidaysCalendar (rmunate, GitHub)
-- Ejecutar DESPUÉS de 01_CREATE_TABLES.sql
-- =============================================

USE FondoXYZ;
GO

SET NOCOUNT ON;
GO

-- =============================================
-- 1. SEDES RECREATIVAS
-- =============================================
INSERT INTO Sede (Nombre, NombreOficial, Ciudad, TipoSede, CapacidadTotal) VALUES
    ('Villeta',          'Villeta',                           'Villeta',               'sede_recreativa', 32),
    ('El Placer',        'El Placer - Fusagasuga',            'Fusagasuga',            'sede_recreativa', 34),
    ('Gonzalo Morante',  'Gonzalo Morante - Chinchina',       'Chinchina',             'sede_recreativa', 30),
    ('Tablones',         'Tablones - Palmira',                'Palmira',               'sede_recreativa', 24),
    ('Manguruma',        'Manguruma - Santa fe de Antioquia', 'Santa fe de Antioquia', 'sede_recreativa', 46),
    ('Federman',         'Federman - Bogota',                 'Bogota',                'sede_recreativa', NULL);

INSERT INTO Sede (Nombre, NombreOficial, Ciudad, TipoSede, CapacidadTotal) VALUES
    ('Suramericana', 'Suramericana, Medellin', 'Medellin',    'apartamento', NULL),
    ('El Rodadero',  'El Rodadero, Santa Marta', 'Santa Marta', 'apartamento', 20);
GO

-- =============================================
-- 3. ALOJAMIENTOS — VILLETA (8 habitaciones)
-- =============================================
DECLARE @SedeId INT;
DECLARE @AlojId INT;
DECLARE @i      INT;

SELECT @SedeId = Id FROM Sede WHERE Nombre = 'Villeta';
SET @i = 1;

WHILE @i <= 8
BEGIN
    INSERT INTO Alojamiento (SedeId, Numero, Nombre, Bloque, NumHabitaciones, CapacidadMaxima)
    VALUES (@SedeId, @i, 'Habitacion ' + CAST(@i AS NVARCHAR(3)), 'principal', 1, 4);

    SET @AlojId = SCOPE_IDENTITY();

    INSERT INTO Dormitorio (AlojamientoId, Numero, CamasDobles, Camarotes)
    VALUES (@AlojId, 1, 1, 1);

    INSERT INTO Caracteristica (AlojamientoId, NumBanos, BanoPrivado, TieneTelevIsor, TieneNevera, TieneTerraza, TerrazaCubierta)
    VALUES (@AlojId, 1, 1, 1, 1, 1, 1);

    SET @i += 1;
END
GO

-- =============================================
-- 4. ALOJAMIENTOS — EL PLACER (8 alojamientos)
-- =============================================
DECLARE @SedeId INT;
DECLARE @AlojId INT;
DECLARE @cab    INT;

SELECT @SedeId = Id FROM Sede WHERE Nombre = 'El Placer';

-- Alojamiento 1: 2 dorms, cap=4
INSERT INTO Alojamiento (SedeId, Numero, Nombre, Bloque, NumHabitaciones, CapacidadMaxima, CapacidadBloque)
VALUES (@SedeId, 1, 'Alojamiento 1', 'principal', 2, 4, 18);
SET @AlojId = SCOPE_IDENTITY();
INSERT INTO Dormitorio (AlojamientoId, Numero, CamasDobles, CamasSencillas) VALUES (@AlojId, 1, 1, 1);
INSERT INTO Dormitorio (AlojamientoId, Numero, CamasSencillas)              VALUES (@AlojId, 2, 1);
INSERT INTO Caracteristica (AlojamientoId, NumBanos, TieneTelevIsor)        VALUES (@AlojId, 1, 1);

-- Alojamiento 2: 2 dorms, cap=6
INSERT INTO Alojamiento (SedeId, Numero, Nombre, Bloque, NumHabitaciones, CapacidadMaxima, CapacidadBloque)
VALUES (@SedeId, 2, 'Alojamiento 2', 'principal', 2, 6, 18);
SET @AlojId = SCOPE_IDENTITY();
INSERT INTO Dormitorio (AlojamientoId, Numero, CamasDobles)      VALUES (@AlojId, 1, 1);
INSERT INTO Dormitorio (AlojamientoId, Numero, CamasSencillas)   VALUES (@AlojId, 2, 4);
INSERT INTO Caracteristica (AlojamientoId, NumBanos, TieneTelevIsor) VALUES (@AlojId, 1, 1);

-- Alojamiento 3: 1 dorm, cap=4
INSERT INTO Alojamiento (SedeId, Numero, Nombre, Bloque, NumHabitaciones, CapacidadMaxima, CapacidadBloque)
VALUES (@SedeId, 3, 'Alojamiento 3', 'principal', 1, 4, 18);
SET @AlojId = SCOPE_IDENTITY();
INSERT INTO Dormitorio (AlojamientoId, Numero, CamasDobles, CamasSencillas) VALUES (@AlojId, 1, 1, 2);
INSERT INTO Caracteristica (AlojamientoId, NumBanos, TieneTelevIsor)        VALUES (@AlojId, 1, 1);

-- Alojamiento 4: 2 dorms, cap=4
INSERT INTO Alojamiento (SedeId, Numero, Nombre, Bloque, NumHabitaciones, CapacidadMaxima, CapacidadBloque)
VALUES (@SedeId, 4, 'Alojamiento 4', 'principal', 2, 4, 18);
SET @AlojId = SCOPE_IDENTITY();
INSERT INTO Dormitorio (AlojamientoId, Numero, CamasDobles, CamasSencillas) VALUES (@AlojId, 1, 1, 1);
INSERT INTO Dormitorio (AlojamientoId, Numero, CamasSencillas)              VALUES (@AlojId, 2, 1);
INSERT INTO Caracteristica (AlojamientoId, NumBanos, TieneTelevIsor)        VALUES (@AlojId, 1, 1);

-- Cabanas 5-8: bloque cabanas -> tarifa 2 hab, cap=4
SET @cab = 5;
WHILE @cab <= 8
BEGIN
    INSERT INTO Alojamiento (SedeId, Numero, Nombre, Bloque, TipoCabana, NumHabitaciones, CapacidadMaxima, CapacidadBloque)
    VALUES (@SedeId, @cab, 'Cabana ' + CAST(@cab AS NVARCHAR(2)), 'cabanas', 'estandar', 1, 4, 16);
    SET @AlojId = SCOPE_IDENTITY();
    INSERT INTO Dormitorio (AlojamientoId, Numero, CamasDobles, CamasSencillas) VALUES (@AlojId, 1, 1, 1);
    INSERT INTO Caracteristica (AlojamientoId, TipoCocina, NumBanos, TieneTelevIsor, TieneNevera, TieneSofaCama, TieneTerraza, TieneComedor, TieneSalaEstar)
    VALUES (@AlojId, 'cocineta', 1, 1, 1, 1, 1, 1, 1);
    SET @cab += 1;
END
GO

-- =============================================
-- 5. ALOJAMIENTOS — GONZALO MORANTE (6 alojamientos)
-- =============================================
DECLARE @SedeId INT;
DECLARE @AlojId INT;

SELECT @SedeId = Id FROM Sede WHERE Nombre = 'Gonzalo Morante';

INSERT INTO Alojamiento (SedeId, Numero, Nombre, Bloque, NumHabitaciones, CapacidadMaxima)
VALUES (@SedeId, 1, 'Alojamiento 1', 'principal', 2, 7);
SET @AlojId = SCOPE_IDENTITY();
INSERT INTO Dormitorio (AlojamientoId, Numero, CamasSencillas, CamasAuxiliares) VALUES (@AlojId, 1, 2, 2);
INSERT INTO Dormitorio (AlojamientoId, Numero, CamasDobles, CamasSencillas)     VALUES (@AlojId, 2, 1, 1);
INSERT INTO Caracteristica (AlojamientoId, TipoCocina, NumBanos, TieneTelevIsor) VALUES (@AlojId, 'cocineta', 1, 1);

INSERT INTO Alojamiento (SedeId, Numero, Nombre, Bloque, NumHabitaciones, CapacidadMaxima)
VALUES (@SedeId, 2, 'Alojamiento 2', 'principal', 2, 7);
SET @AlojId = SCOPE_IDENTITY();
INSERT INTO Dormitorio (AlojamientoId, Numero, CamasDobles, CamasAuxiliares)    VALUES (@AlojId, 1, 1, 1);
INSERT INTO Dormitorio (AlojamientoId, Numero, CamasSencillas, CamasAuxiliares) VALUES (@AlojId, 2, 2, 2);
INSERT INTO Caracteristica (AlojamientoId, TipoCocina, NumBanos, TieneTelevIsor) VALUES (@AlojId, 'cocineta', 1, 1);

INSERT INTO Alojamiento (SedeId, Numero, Nombre, Bloque, TipoCabana, NumHabitaciones, CapacidadMaxima)
VALUES (@SedeId, 3, 'Alojamiento 3 (Cabana Tipo A)', 'cabanas', 'A', 2, 6);
SET @AlojId = SCOPE_IDENTITY();
INSERT INTO Dormitorio (AlojamientoId, Numero, CamasDobles)                     VALUES (@AlojId, 1, 1);
INSERT INTO Dormitorio (AlojamientoId, Numero, CamasSencillas, CamasAuxiliares) VALUES (@AlojId, 2, 2, 2);
INSERT INTO Caracteristica (AlojamientoId, TipoCocina, NumBanos, TieneTelevIsor, TieneComedor)
VALUES (@AlojId, 'cocineta', 2, 1, 1);

INSERT INTO Alojamiento (SedeId, Numero, Nombre, Bloque, NumHabitaciones, CapacidadMaxima)
VALUES (@SedeId, 4, 'Alojamiento 4', 'principal', 1, 3);
SET @AlojId = SCOPE_IDENTITY();
INSERT INTO Dormitorio (AlojamientoId, Numero, CamasDobles, CamasSencillas) VALUES (@AlojId, 1, 1, 1);
INSERT INTO Caracteristica (AlojamientoId, TipoCocina, NumBanos, TieneTelevIsor) VALUES (@AlojId, 'cocineta', 1, 1);

INSERT INTO Alojamiento (SedeId, Numero, Nombre, Bloque, TipoCabana, NumHabitaciones, CapacidadMaxima)
VALUES (@SedeId, 5, 'Alojamiento 5 (Cabana Tipo B)', 'cabanas', 'B', 1, 4);
SET @AlojId = SCOPE_IDENTITY();
INSERT INTO Dormitorio (AlojamientoId, Numero, CamasDobles, CamasSencillas) VALUES (@AlojId, 1, 1, 1);
INSERT INTO Caracteristica (AlojamientoId, TipoCocina, NumBanos, TieneTelevIsor, TieneSofaCama, TieneSalaEstar)
VALUES (@AlojId, 'cocineta', 1, 1, 1, 1);

INSERT INTO Alojamiento (SedeId, Numero, Nombre, Bloque, TipoCabana, NumHabitaciones, CapacidadMaxima)
VALUES (@SedeId, 6, 'Alojamiento 6 (Cabana Tipo B)', 'cabanas', 'B', 1, 4);
SET @AlojId = SCOPE_IDENTITY();
INSERT INTO Dormitorio (AlojamientoId, Numero, CamasDobles, CamasSencillas) VALUES (@AlojId, 1, 1, 1);
INSERT INTO Caracteristica (AlojamientoId, TipoCocina, NumBanos, TieneTelevIsor, TieneSofaCama, TieneSalaEstar)
VALUES (@AlojId, 'cocineta', 1, 1, 1, 1);
GO

-- =============================================
-- 6. ALOJAMIENTOS — TABLONES (4 alojamientos)
-- =============================================
DECLARE @SedeId INT;
DECLARE @AlojId INT;

SELECT @SedeId = Id FROM Sede WHERE Nombre = 'Tablones';

INSERT INTO Alojamiento (SedeId, Numero, Nombre, Bloque, NumHabitaciones, CapacidadMaxima)
VALUES (@SedeId, 1, 'Alojamiento 1', 'principal', 1, 4);
SET @AlojId = SCOPE_IDENTITY();
INSERT INTO Dormitorio (AlojamientoId, Numero, CamasDobles, Camarotes) VALUES (@AlojId, 1, 1, 1);
INSERT INTO Caracteristica (AlojamientoId, TipoCocina, NumBanos, TieneTelevIsor, TieneNevera, TieneComedor)
VALUES (@AlojId, 'cocineta', 1, 1, 1, 1);

INSERT INTO Alojamiento (SedeId, Numero, Nombre, Bloque, NumHabitaciones, CapacidadMaxima)
VALUES (@SedeId, 2, 'Alojamiento 2', 'principal', 1, 4);
SET @AlojId = SCOPE_IDENTITY();
INSERT INTO Dormitorio (AlojamientoId, Numero, CamasDobles, Camarotes) VALUES (@AlojId, 1, 1, 1);
INSERT INTO Caracteristica (AlojamientoId, TipoCocina, NumBanos, TieneTelevIsor, TieneNevera, TieneComedor)
VALUES (@AlojId, 'cocineta', 1, 1, 1, 1);

INSERT INTO Alojamiento (SedeId, Numero, Nombre, Bloque, NumHabitaciones, CapacidadMaxima)
VALUES (@SedeId, 3, 'Alojamiento 3', 'principal', 2, 8);
SET @AlojId = SCOPE_IDENTITY();
INSERT INTO Dormitorio (AlojamientoId, Numero, CamasDobles, Camarotes) VALUES (@AlojId, 1, 1, 1);
INSERT INTO Dormitorio (AlojamientoId, Numero, Camarotes)              VALUES (@AlojId, 2, 2);
INSERT INTO Caracteristica (AlojamientoId, TipoCocina, NumBanos, TieneTelevIsor, TieneSalaEstar)
VALUES (@AlojId, 'cocineta', 1, 1, 1);

INSERT INTO Alojamiento (SedeId, Numero, Nombre, Bloque, NumHabitaciones, CapacidadMaxima)
VALUES (@SedeId, 4, 'Alojamiento 4', 'principal', 2, 8);
SET @AlojId = SCOPE_IDENTITY();
INSERT INTO Dormitorio (AlojamientoId, Numero, CamasDobles, Camarotes) VALUES (@AlojId, 1, 1, 1);
INSERT INTO Dormitorio (AlojamientoId, Numero, Camarotes)              VALUES (@AlojId, 2, 2);
INSERT INTO Caracteristica (AlojamientoId, TipoCocina, NumBanos, TieneTelevIsor, TieneSalaEstar)
VALUES (@AlojId, 'cocineta', 1, 1, 1);
GO

-- =============================================
-- 7. ALOJAMIENTOS — MANGURUMA (11 alojamientos)
-- =============================================
DECLARE @SedeId INT;
DECLARE @AlojId INT;
DECLARE @nuevo  INT;

SELECT @SedeId = Id FROM Sede WHERE Nombre = 'Manguruma';

INSERT INTO Alojamiento (SedeId, Numero, Nombre, Bloque, NumHabitaciones, CapacidadMaxima, CapacidadBloque)
VALUES (@SedeId, 1, 'Alojamiento 1', 'principal', 1, 4, 14);
SET @AlojId = SCOPE_IDENTITY();
INSERT INTO Dormitorio (AlojamientoId, Numero, CamasDobles, Camarotes) VALUES (@AlojId, 1, 1, 1);
INSERT INTO Caracteristica (AlojamientoId, NumBanos, TieneTelevIsor, TieneTerraza) VALUES (@AlojId, 1, 1, 1);

INSERT INTO Alojamiento (SedeId, Numero, Nombre, Bloque, NumHabitaciones, CapacidadMaxima, CapacidadBloque)
VALUES (@SedeId, 2, 'Alojamiento 2', 'principal', 1, 5, 14);
SET @AlojId = SCOPE_IDENTITY();
INSERT INTO Dormitorio (AlojamientoId, Numero, CamasDobles, Camarotes) VALUES (@AlojId, 1, 1, 1);
INSERT INTO Caracteristica (AlojamientoId, NumBanos, TieneTelevIsor, TieneSofaCama, TieneTerraza) VALUES (@AlojId, 1, 1, 1, 1);

INSERT INTO Alojamiento (SedeId, Numero, Nombre, Bloque, NumHabitaciones, CapacidadMaxima, CapacidadBloque)
VALUES (@SedeId, 3, 'Alojamiento 3', 'principal', 1, 5, 14);
SET @AlojId = SCOPE_IDENTITY();
INSERT INTO Dormitorio (AlojamientoId, Numero, CamasDobles, Camarotes) VALUES (@AlojId, 1, 1, 1);
INSERT INTO Caracteristica (AlojamientoId, NumBanos, TieneTelevIsor, TieneSofaCama, TieneTerraza) VALUES (@AlojId, 1, 1, 1, 1);

-- Alojamientos Nuevos 4-11: bloque_nuevo -> tarifa 2 hab
SET @nuevo = 4;
WHILE @nuevo <= 11
BEGIN
    INSERT INTO Alojamiento (SedeId, Numero, Nombre, Bloque, NumHabitaciones, CapacidadMaxima, CapacidadBloque)
    VALUES (@SedeId, @nuevo, 'Alojamiento Nuevo ' + CAST(@nuevo AS NVARCHAR(2)), 'bloque_nuevo', 1, 4, 32);
    SET @AlojId = SCOPE_IDENTITY();
    INSERT INTO Dormitorio (AlojamientoId, Numero, CamasGemelas, Camarotes) VALUES (@AlojId, 1, 2, 1);
    INSERT INTO Caracteristica (AlojamientoId, TipoCocina, NumBanos, TieneTelevIsor, TieneNevera, TieneTerraza, TieneComedor)
    VALUES (@AlojId, 'cocina', 1, 1, 1, 1, 1);
    SET @nuevo += 1;
END
GO

-- =============================================
-- 8. APARTAMENTOS — SURAMERICANA (5 habitaciones)
-- =============================================
DECLARE @SedeId INT;
DECLARE @AlojId INT;

SELECT @SedeId = Id FROM Sede WHERE Nombre = 'Suramericana';

INSERT INTO Alojamiento (SedeId, Numero, Nombre, Bloque, NumHabitaciones, CapacidadMaxima)
VALUES (@SedeId, 1, 'Habitacion 1', 'principal', 1, 2);
SET @AlojId = SCOPE_IDENTITY();
INSERT INTO Dormitorio (AlojamientoId, Numero, CamasSencillas) VALUES (@AlojId, 1, 2);
INSERT INTO Caracteristica (AlojamientoId, NumBanos, BanoPrivado) VALUES (@AlojId, 1, 1);

INSERT INTO Alojamiento (SedeId, Numero, Nombre, Bloque, NumHabitaciones, CapacidadMaxima)
VALUES (@SedeId, 2, 'Habitacion 2', 'principal', 1, 2);
SET @AlojId = SCOPE_IDENTITY();
INSERT INTO Dormitorio (AlojamientoId, Numero, CamasSencillas) VALUES (@AlojId, 1, 2);
INSERT INTO Caracteristica (AlojamientoId, NumBanos, BanoPrivado) VALUES (@AlojId, 0, 0);

INSERT INTO Alojamiento (SedeId, Numero, Nombre, Bloque, NumHabitaciones, CapacidadMaxima)
VALUES (@SedeId, 3, 'Habitacion 3', 'principal', 1, 2);
SET @AlojId = SCOPE_IDENTITY();
INSERT INTO Dormitorio (AlojamientoId, Numero, CamasSencillas) VALUES (@AlojId, 1, 2);
INSERT INTO Caracteristica (AlojamientoId, NumBanos, BanoPrivado) VALUES (@AlojId, 0, 0);

INSERT INTO Alojamiento (SedeId, Numero, Nombre, Bloque, NumHabitaciones, CapacidadMaxima)
VALUES (@SedeId, 4, 'Habitacion 4', 'principal', 1, 2);
SET @AlojId = SCOPE_IDENTITY();
INSERT INTO Dormitorio (AlojamientoId, Numero, CamasSencillas) VALUES (@AlojId, 1, 2);
INSERT INTO Caracteristica (AlojamientoId, NumBanos, BanoPrivado) VALUES (@AlojId, 0, 0);

INSERT INTO Alojamiento (SedeId, Numero, Nombre, Bloque, NumHabitaciones, CapacidadMaxima)
VALUES (@SedeId, 5, 'Habitacion 5', 'principal', 1, 1);
SET @AlojId = SCOPE_IDENTITY();
INSERT INTO Dormitorio (AlojamientoId, Numero, CamasSencillas) VALUES (@AlojId, 1, 1);
INSERT INTO Caracteristica (AlojamientoId, NumBanos, BanoPrivado) VALUES (@AlojId, 1, 1);
GO

-- =============================================
-- 9. APARTAMENTOS — EL RODADERO (3 unidades)
-- =============================================
DECLARE @SedeId INT;
DECLARE @AlojId INT;

SELECT @SedeId = Id FROM Sede WHERE Nombre = 'El Rodadero';

INSERT INTO Alojamiento (SedeId, Numero, Nombre, Bloque, NumHabitaciones, CapacidadMaxima)
VALUES (@SedeId, 202, 'Apartamento 202', 'principal', 3, 8);
SET @AlojId = SCOPE_IDENTITY();
INSERT INTO Caracteristica (AlojamientoId, TipoCocina, NumBanos, TieneComedor, TieneSalaEstar, TieneParqueo)
VALUES (@AlojId, 'cocina', 2, 1, 1, 1);

INSERT INTO Alojamiento (SedeId, Numero, Nombre, Bloque, NumHabitaciones, CapacidadMaxima)
VALUES (@SedeId, 301, 'Apartamento 301', 'principal', 2, 6);
SET @AlojId = SCOPE_IDENTITY();
INSERT INTO Caracteristica (AlojamientoId, TipoCocina, NumBanos, TieneComedor, TieneSalaEstar, TieneParqueo)
VALUES (@AlojId, 'cocina', 1, 1, 1, 1);

INSERT INTO Alojamiento (SedeId, Numero, Nombre, Bloque, NumHabitaciones, CapacidadMaxima)
VALUES (@SedeId, 401, 'Apartamento 401', 'principal', 2, 6);
SET @AlojId = SCOPE_IDENTITY();
INSERT INTO Caracteristica (AlojamientoId, TipoCocina, NumBanos, TieneComedor, TieneSalaEstar, TieneParqueo)
VALUES (@AlojId, 'cocina', 1, 1, 1, 1);
GO

-- =============================================
-- 10. TARIFAS
-- =============================================
INSERT INTO Tarifa (Nombre, Sede, TipoSede, Temporada, NumHabitaciones, PersonasMax, PrecioNoche) VALUES
    ('Habitacion Medellin 1 persona',  'Suramericana', 'apartamento',    NULL,      1, 1, 63000),
    ('Habitacion Medellin 2 personas', 'Suramericana', 'apartamento',    NULL,      1, 2, 75000),
    ('Apto 301-401 Baja Temporada',    'ElRodadero',   'apartamento',    'baja',    NULL, 6, 89000),
    ('Apto 202 Baja Temporada',        'ElRodadero',   'apartamento',    'baja',    NULL, 8, 103000),
    ('Apto 301-401 Alta Temporada',    'ElRodadero',   'apartamento',    'alta',    NULL, 6, 124000),
    ('Apto 202 Alta Temporada',        'ElRodadero',   'apartamento',    'alta',    NULL, 8, 143000),
    ('Sede 1 Habitacion Normal',       NULL,           'sede_recreativa', 'normal',  1, 4, 70000),
    ('Sede 2 Habitaciones Normal',     NULL,           'sede_recreativa', 'normal',  2, 4, 90000),
    ('Sede 1 Habitacion Especial',     NULL,           'sede_recreativa', 'especial', 1, 4, 27000),
    ('Sede 2 Habitaciones Especial',   NULL,           'sede_recreativa', 'especial', 2, 4, 37000),
    ('Persona Adicional Normal',       NULL,           'sede_recreativa', 'normal',  NULL, NULL, 16000),
    ('Persona Adicional Especial',     NULL,           'sede_recreativa', 'especial', NULL, NULL, 11000),
    ('Visita Dia Acompanante',         NULL,           'sede_recreativa', NULL,      NULL, NULL, 5500),
    ('Servicio de Lavanderia',         'ElRodadero',   'apartamento',    NULL,      NULL, NULL, 18000);
GO

-- =============================================
-- 11. FESTIVOS 2025-2026
-- =============================================
INSERT INTO Festivos (Fecha, Descripcion, Anio) VALUES
    ('2025-01-01', 'Ano Nuevo',                     2025),
    ('2025-01-06', 'Reyes Magos',                   2025),
    ('2025-03-03', 'Lunes de Carnaval',             2025),
    ('2025-03-04', 'Martes de Carnaval',            2025),
    ('2025-03-24', 'San Jose',                      2025),
    ('2025-04-17', 'Jueves Santo',                  2025),
    ('2025-04-18', 'Viernes Santo',                 2025),
    ('2025-05-01', 'Dia del Trabajo',               2025),
    ('2025-06-02', 'Ascension del Senor',           2025),
    ('2025-06-23', 'Corpus Christi',                2025),
    ('2025-06-30', 'San Pedro y San Pablo',         2025),
    ('2025-08-07', 'Batalla de Boyaca',             2025),
    ('2025-08-18', 'Asuncion de la Virgen',         2025),
    ('2025-10-13', 'Dia de la Raza',                2025),
    ('2025-11-03', 'Todos los Santos',              2025),
    ('2025-11-17', 'Independencia de Cartagena',    2025),
    ('2025-12-08', 'Inmaculada Concepcion',         2025),
    ('2025-12-25', 'Navidad',                       2025),
    ('2026-01-01', 'Ano Nuevo',                     2026),
    ('2026-01-12', 'Reyes Magos',                   2026),
    ('2026-02-16', 'Lunes de Carnaval',             2026),
    ('2026-02-17', 'Martes de Carnaval',            2026),
    ('2026-03-23', 'San Jose',                      2026),
    ('2026-04-02', 'Jueves Santo',                  2026),
    ('2026-04-03', 'Viernes Santo',                 2026),
    ('2026-05-01', 'Dia del Trabajo',               2026),
    ('2026-05-18', 'Ascension del Senor',           2026),
    ('2026-06-08', 'Corpus Christi',                2026),
    ('2026-06-15', 'Sagrado Corazon de Jesus',      2026),
    ('2026-06-29', 'San Pedro y San Pablo',         2026),
    ('2026-07-20', 'Dia de la Independencia',       2026),
    ('2026-08-07', 'Batalla de Boyaca',             2026),
    ('2026-08-17', 'Asuncion de la Virgen',         2026),
    ('2026-10-12', 'Dia de la Raza',                2026),
    ('2026-11-02', 'Todos los Santos',              2026),
    ('2026-11-16', 'Independencia de Cartagena',    2026),
    ('2026-12-08', 'Inmaculada Concepcion',         2026),
    ('2026-12-25', 'Navidad',                       2026);
GO

-- =============================================
-- 12. TEMPORADA ALTA / RECESOS ESCOLARES
-- =============================================
INSERT INTO TemporadaAlta (Nombre, FechaInicio, FechaFin, Tipo, AplicaRecurso, Anio, Notas) VALUES
    ('Semana Santa',              '2025-04-13', '2025-04-20', 'RecEscolar',    NULL,         2025, 'Receso escolar MEN. Festivos: 17 y 18 abr.'),
    ('Vacaciones Mitad de Anio',  '2025-06-20', '2025-07-20', 'RecEscolar',    NULL,         2025, 'MEN Bogota: 23-jun al 11-jul.'),
    ('Receso Octubre',            '2025-10-06', '2025-10-13', 'RecEscolar',    NULL,         2025, 'Decreto 1373/2007. Puente 12 oct.'),
    ('Vacaciones Fin de Anio',    '2025-12-05', '2026-01-13', 'RecEscolar',    NULL,         2025, 'Cierre escolar 5-dic-2025.'),
    ('Alta Temporada Dic-Ene',    '2025-12-01', '2026-01-15', 'AltaTemporada', 'ElRodadero', 2025, 'Temporada alta El Rodadero Cotelco Magdalena.'),
    ('Carnaval de Barranquilla',  '2025-03-01', '2025-03-04', 'Festivo',       NULL,         2025, 'Lunes 3-mar y Martes 4-mar festivos.'),
    ('Semana Santa',              '2026-03-29', '2026-04-05', 'RecEscolar',    NULL,         2026, 'Festivos: 2 y 3 abr.'),
    ('Vacaciones Mitad de Anio',  '2026-06-22', '2026-07-20', 'RecEscolar',    NULL,         2026, 'MEN Bogota: 22-jun al 6-jul.'),
    ('Receso Octubre',            '2026-10-05', '2026-10-12', 'RecEscolar',    NULL,         2026, 'Decreto 1373/2007. Puente 12 oct.'),
    ('Vacaciones Fin de Anio',    '2026-11-30', '2027-01-11', 'RecEscolar',    NULL,         2026, 'Cierre escolar 29-nov-2026.'),
    ('Alta Temporada Dic-Ene',    '2026-12-01', '2027-01-15', 'AltaTemporada', 'ElRodadero', 2026, 'Temporada alta El Rodadero.'),
    ('Carnaval de Barranquilla',  '2026-02-14', '2026-02-17', 'Festivo',       NULL,         2026, 'Lunes 16-feb y Martes 17-feb festivos.');
GO

-- Verificacion
DECLARE @nSede INT, @nAloj INT, @nDorm INT, @nCar INT, @nTar INT, @nFest INT, @nTemp INT;
SELECT @nSede = COUNT(*) FROM Sede;
SELECT @nAloj = COUNT(*) FROM Alojamiento;
SELECT @nDorm = COUNT(*) FROM Dormitorio;
SELECT @nCar  = COUNT(*) FROM Caracteristica;
SELECT @nTar  = COUNT(*) FROM Tarifa;
SELECT @nFest = COUNT(*) FROM Festivos;
SELECT @nTemp = COUNT(*) FROM TemporadaAlta;
PRINT '--- Verificacion Seed Data ---';
PRINT 'Sedes:         ' + CAST(@nSede AS VARCHAR);
PRINT 'Alojamientos:  ' + CAST(@nAloj AS VARCHAR);
PRINT 'Dormitorios:   ' + CAST(@nDorm AS VARCHAR);
PRINT 'Caracterist.:  ' + CAST(@nCar  AS VARCHAR);
PRINT 'Tarifas:       ' + CAST(@nTar  AS VARCHAR);
PRINT 'Festivos:      ' + CAST(@nFest AS VARCHAR);
PRINT 'Temporadas:    ' + CAST(@nTemp AS VARCHAR);
PRINT 'Fase 2 completada.';
GO
