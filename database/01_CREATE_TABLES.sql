-- =============================================
-- FONDO XYZ - FASE 1: CREACIÓN DE TABLAS
-- Motor: SQL Server 2019+
-- Orden de creación respeta dependencias FK
-- =============================================

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'FondoXYZ')
    CREATE DATABASE FondoXYZ;
GO

USE FondoXYZ;
GO

-- =============================================
-- 1. SEDE
-- =============================================
CREATE TABLE Sede (
    Id              INT             IDENTITY(1,1)   PRIMARY KEY,
    Nombre          NVARCHAR(100)   NOT NULL,
    NombreOficial   NVARCHAR(150)   NOT NULL,
    Ciudad          NVARCHAR(100)   NOT NULL,
    TipoSede        NVARCHAR(20)    NOT NULL
                    CONSTRAINT CK_Sede_TipoSede CHECK (TipoSede IN ('sede_recreativa', 'apartamento')),
    CapacidadTotal  INT             NULL,
    Activo          BIT             NOT NULL DEFAULT 1
);
GO

-- =============================================
-- 2. ALOJAMIENTO
-- =============================================
CREATE TABLE Alojamiento (
    Id              INT             IDENTITY(1,1)   PRIMARY KEY,
    SedeId          INT             NOT NULL
                    CONSTRAINT FK_Alojamiento_Sede REFERENCES Sede(Id),
    Numero          INT             NOT NULL,
    Nombre          NVARCHAR(100)   NOT NULL,
    -- 'principal' | 'cabanas' | 'bloque_nuevo'
    -- El Placer cabañas 5-8 y Manguruma nuevos 4-11 siempre usan tarifa 2-hab
    Bloque          NVARCHAR(20)    NOT NULL DEFAULT 'principal'
                    CONSTRAINT CK_Alojamiento_Bloque CHECK (Bloque IN ('principal','cabanas','bloque_nuevo')),
    TipoCabana      NVARCHAR(10)    NULL,           -- 'A' | 'B' | 'estandar' | NULL
    NumHabitaciones INT             NOT NULL DEFAULT 1,
    CapacidadMaxima INT             NULL,           -- personas máx: se calcula desde Dormitorio + sofa_cama
    CapacidadBloque INT             NULL,           -- capacidad total del bloque al que pertenece
    Activo          BIT             NOT NULL DEFAULT 1,
    CONSTRAINT UQ_Alojamiento_SedeNumero UNIQUE (SedeId, Numero)
);
GO

CREATE INDEX IX_Alojamiento_SedeId ON Alojamiento(SedeId);
GO

-- =============================================
-- 3. DORMITORIO
-- =============================================
CREATE TABLE Dormitorio (
    Id              INT             IDENTITY(1,1)   PRIMARY KEY,
    AlojamientoId   INT             NOT NULL
                    CONSTRAINT FK_Dormitorio_Alojamiento REFERENCES Alojamiento(Id),
    Numero          INT             NOT NULL,
    CamasDobles     INT             NOT NULL DEFAULT 0,  -- 2 personas c/u
    CamasSencillas  INT             NOT NULL DEFAULT 0,  -- 1 persona c/u
    Camarotes       INT             NOT NULL DEFAULT 0,  -- 2 personas c/u (litera)
    CamasGemelas    INT             NOT NULL DEFAULT 0,  -- 1 persona c/u (twin)
    CamasAuxiliares INT             NOT NULL DEFAULT 0,  -- 1 persona c/u (extra)
    CONSTRAINT UQ_Dormitorio_AlojamientoNumero UNIQUE (AlojamientoId, Numero)
);
GO

-- =============================================
-- 4. CARACTERISTICA
-- =============================================
CREATE TABLE Caracteristica (
    Id              INT             IDENTITY(1,1)   PRIMARY KEY,
    AlojamientoId   INT             NOT NULL
                    CONSTRAINT FK_Caracteristica_Alojamiento REFERENCES Alojamiento(Id),
    TipoCocina      NVARCHAR(10)    NULL
                    CONSTRAINT CK_Caracteristica_Cocina CHECK (TipoCocina IS NULL OR TipoCocina IN ('cocina','cocineta')),
    NumBanos        INT             NOT NULL DEFAULT 1,
    BanoPrivado     BIT             NOT NULL DEFAULT 0,
    TieneTelevIsor  BIT             NOT NULL DEFAULT 0,
    TieneNevera     BIT             NOT NULL DEFAULT 0,
    TieneSofaCama   BIT             NOT NULL DEFAULT 0,
    TieneTerraza    BIT             NOT NULL DEFAULT 0,
    TerrazaCubierta BIT             NOT NULL DEFAULT 0,
    TieneComedor    BIT             NOT NULL DEFAULT 0,
    TieneSalaEstar  BIT             NOT NULL DEFAULT 0,
    TieneParqueo    BIT             NOT NULL DEFAULT 0,
    CONSTRAINT UQ_Caracteristica_Alojamiento UNIQUE (AlojamientoId)
);
GO

-- =============================================
-- 5. TARIFA
-- =============================================
CREATE TABLE Tarifa (
    Id              INT             IDENTITY(1,1)   PRIMARY KEY,
    Nombre          NVARCHAR(100)   NOT NULL,
    -- NULL = aplica a todas las sedes del tipo
    Sede            NVARCHAR(100)   NULL,
    TipoSede        NVARCHAR(20)    NOT NULL
                    CONSTRAINT CK_Tarifa_TipoSede CHECK (TipoSede IN ('sede_recreativa','apartamento')),
    -- NULL = aplica independiente de temporada (ej. lavandería, visita día)
    Temporada       NVARCHAR(10)    NULL
                    CONSTRAINT CK_Tarifa_Temporada CHECK (Temporada IS NULL OR Temporada IN ('normal','especial','alta','baja')),
    NumHabitaciones INT             NULL,
    PersonasMax     INT             NULL,
    PrecioNoche     DECIMAL(10,2)   NOT NULL
);
GO

-- =============================================
-- 6. FESTIVOS
-- =============================================
CREATE TABLE Festivos (
    Id              INT             IDENTITY(1,1)   PRIMARY KEY,
    Fecha           DATE            NOT NULL,
    Descripcion     NVARCHAR(150)   NOT NULL,
    Anio            SMALLINT        NOT NULL,
    CONSTRAINT UQ_Festivos_Fecha UNIQUE (Fecha)
);
GO

CREATE INDEX IX_Festivos_Fecha ON Festivos(Fecha);
GO

-- =============================================
-- 7. TEMPORADA ALTA / RECESO ESCOLAR
-- Períodos que bloquean la "tarifa especial"
-- =============================================
CREATE TABLE TemporadaAlta (
    Id              INT             IDENTITY(1,1)   PRIMARY KEY,
    Nombre          NVARCHAR(100)   NOT NULL,
    FechaInicio     DATE            NOT NULL,
    FechaFin        DATE            NOT NULL,       -- inclusive
    -- 'RecEscolar' = receso escolar MEN (bloquea tarifa especial en sedes recreativas)
    -- 'AltaTemporada' = temporada alta (aplica tarifa alta en El Rodadero)
    -- 'Festivo' = festivo de varios días (Carnaval)
    Tipo            NVARCHAR(20)    NOT NULL
                    CONSTRAINT CK_TemporadaAlta_Tipo CHECK (Tipo IN ('RecEscolar','AltaTemporada','Festivo')),
    -- NULL = bloquea tarifa especial en todos los recursos
    -- 'ElRodadero' = aplica solo a apartamentos Santa Marta
    AplicaRecurso   NVARCHAR(100)   NULL,
    Anio            SMALLINT        NOT NULL,
    Notas           NVARCHAR(255)   NULL,
    CONSTRAINT CK_TemporadaAlta_Fechas CHECK (FechaFin >= FechaInicio)
);
GO

CREATE INDEX IX_TemporadaAlta_Fechas ON TemporadaAlta(FechaInicio, FechaFin);
GO

-- =============================================
-- 8. RESERVA
-- UsuarioId referencia AspNetUsers.Id (string),
-- FK gestionada por EF Identity en la app.
-- =============================================
CREATE TABLE Reserva (
    Id              INT             IDENTITY(1,1)   PRIMARY KEY,
    UsuarioId       NVARCHAR(450)   NOT NULL,
    AlojamientoId   INT             NOT NULL
                    CONSTRAINT FK_Reserva_Alojamiento REFERENCES Alojamiento(Id),
    FechaInicio     DATE            NOT NULL,
    FechaFin        DATE            NOT NULL,
    NumPersonas     INT             NOT NULL
                    CONSTRAINT CK_Reserva_Personas CHECK (NumPersonas >= 1),
    CostoTotal      DECIMAL(10,2)   NOT NULL,
    Estado          NVARCHAR(15)    NOT NULL DEFAULT 'pendiente'
                    CONSTRAINT CK_Reserva_Estado CHECK (Estado IN ('pendiente','confirmada','cancelada')),
    FechaCreacion   DATETIME2       NOT NULL DEFAULT GETDATE(),
    Notas           NVARCHAR(500)   NULL,
    CONSTRAINT CK_Reserva_Fechas CHECK (FechaFin > FechaInicio)
);
GO

CREATE INDEX IX_Reserva_AlojamientoFechas ON Reserva(AlojamientoId, FechaInicio, FechaFin);
CREATE INDEX IX_Reserva_UsuarioId         ON Reserva(UsuarioId);
GO

-- =============================================
-- 9. DETALLE RESERVA
-- =============================================
CREATE TABLE DetalleReserva (
    Id              INT             IDENTITY(1,1)   PRIMARY KEY,
    ReservaId       INT             NOT NULL
                    CONSTRAINT FK_DetalleReserva_Reserva REFERENCES Reserva(Id),
    Concepto        NVARCHAR(150)   NOT NULL,
    Monto           DECIMAL(10,2)   NOT NULL
);
GO

-- =============================================
-- FUNCIÓN: ¿Es tarifa especial?
-- Retorna 1 si la fecha es Lun-Jue, no es festivo
-- y no cae en receso escolar/alta temporada global
-- =============================================
CREATE OR ALTER FUNCTION dbo.fn_EsTarifaEspecial (
    @Fecha      DATE,
    @Recurso    NVARCHAR(100) = NULL
)
RETURNS BIT
AS
BEGIN
    -- Solo aplica a sedes recreativas (no a El Rodadero)
    IF @Recurso = 'ElRodadero'
        RETURN 0;

    -- Debe ser Lunes a Jueves
    IF DATENAME(WEEKDAY, @Fecha) NOT IN ('Monday','Tuesday','Wednesday','Thursday')
        RETURN 0;

    -- No debe ser festivo
    IF EXISTS (SELECT 1 FROM Festivos WHERE Fecha = @Fecha)
        RETURN 0;

    -- No debe caer en receso escolar o período de alta demanda global
    IF EXISTS (
        SELECT 1 FROM TemporadaAlta
        WHERE @Fecha BETWEEN FechaInicio AND FechaFin
          AND (AplicaRecurso IS NULL OR AplicaRecurso = @Recurso)
    )
        RETURN 0;

    RETURN 1;
END
GO

-- =============================================
-- FUNCIÓN: ¿Es alta temporada El Rodadero?
-- =============================================
CREATE OR ALTER FUNCTION dbo.fn_EsAltaTemporadaRodadero (
    @Fecha DATE
)
RETURNS BIT
AS
BEGIN
    IF EXISTS (
        SELECT 1 FROM TemporadaAlta
        WHERE @Fecha BETWEEN FechaInicio AND FechaFin
          AND Tipo = 'AltaTemporada'
          AND AplicaRecurso = 'ElRodadero'
    )
        RETURN 1;
    RETURN 0;
END
GO

-- =============================================
-- VISTA: temporadas vigentes (hoy en adelante)
-- =============================================
CREATE OR ALTER VIEW vw_TemporadasActivas AS
SELECT
    Id, Nombre, FechaInicio, FechaFin, Tipo, AplicaRecurso, Anio, Notas,
    DATEDIFF(DAY, FechaInicio, FechaFin) + 1 AS DiasTotal
FROM TemporadaAlta
WHERE FechaFin >= CAST(GETDATE() AS DATE);
GO

PRINT '✔ Fase 1 completada: tablas, índices, funciones y vista creados.';
GO
