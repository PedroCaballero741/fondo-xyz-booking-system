-- =============================================================
--  TemporadaAlta — Fondo XYZ
--  Lógica: los rangos aquí almacenados corresponden a períodos
--  donde NO aplica "tarifa especial" (L-J), sino tarifa normal
--  o alta según el recurso. Incluye recesos escolares MEN + 
--  alta temporada El Rodadero.
-- =============================================================

CREATE TABLE TemporadaAlta (
    Id              INT IDENTITY(1,1) PRIMARY KEY,
    Nombre          NVARCHAR(100)   NOT NULL,
    FechaInicio     DATE            NOT NULL,
    FechaFin        DATE            NOT NULL,        -- inclusive
    Tipo            NVARCHAR(50)    NOT NULL,        -- 'RecEscolar' | 'AltaTemporada' | 'Festivo'
    AplicaRecurso   NVARCHAR(100)   NULL,            -- NULL = todos; 'ElRodadero' = solo aptos SM
    Anio            SMALLINT        NOT NULL,
    Notas           NVARCHAR(255)   NULL
);
GO

-- ============================================================
--  AÑO 2025
-- ============================================================
INSERT INTO TemporadaAlta (Nombre, FechaInicio, FechaFin, Tipo, AplicaRecurso, Anio, Notas) VALUES

-- Semana Santa 2025
-- Festivos nacionales: Jue 17-abr y Vie 18-abr
-- Receso escolar oficial: Lun 14-abr al Dom 20-abr
('Semana Santa',            '2025-04-13', '2025-04-20', 'RecEscolar',   NULL,          2025,
 'Domingo Ramos al Domingo Pascua. Festivos: 17 y 18 abr. Receso escolar oficial 14-18 abr (MEN/SED Bogotá).'),

-- Vacaciones mitad de año 2025
-- Atlántico: 23-jun al 13-jul. Se usa rango conservador.
('Vacaciones Mitad de Año', '2025-06-20', '2025-07-20', 'RecEscolar',   NULL,          2025,
 'MEN Bogotá: 23-jun al 11-jul. Atlántico retorno 14-jul. Extendido a 20-jul por impacto turístico.'),

-- Semana de receso estudiantil octubre 2025
-- Semana 6-10 oct + puente 11-13 oct (Día de la Raza 12-oct es festivo)
('Receso Estudiantil Octubre', '2025-10-06', '2025-10-13', 'RecEscolar', NULL,          2025,
 'Decreto 1373/2007: semana previa al 12-oct (Día de la Raza). Puente: 11-13 oct.'),

-- Vacaciones fin de año 2025
-- Colegios: desde 5-dic. Festivos clave: 8-dic (Inmaculada), 25-dic (Navidad), 1-ene
('Vacaciones Fin de Año',   '2025-12-05', '2026-01-13', 'RecEscolar',   NULL,          2025,
 'Cierre escolar 5-dic-2025. Retorno escolar según SED: 13-ene-2026 aprox.'),

-- Alta temporada El Rodadero — Temporada pico dic-ene
-- Cotelco: pico máximo última semana dic y primeros días enero
('Alta Temporada Dec-Ene',  '2025-12-01', '2026-01-15', 'AltaTemporada','ElRodadero',  2025,
 'Temporada alta El Rodadero según Cotelco Magdalena. Pico máximo 20-dic al 6-ene.'),

-- Carnaval de Barranquilla 2025 (fondo en BAQ, aplica demanda local)
-- Festivos: Lunes de Carnaval 3-mar y Martes de Carnaval 4-mar-2025
('Carnaval de Barranquilla', '2025-03-01', '2025-03-04', 'Festivo',     NULL,          2025,
 'Lunes 3-mar y Martes 4-mar son festivos nacionales. Aplica puente desde viernes 28-feb.');

-- ============================================================
--  AÑO 2026
-- ============================================================
INSERT INTO TemporadaAlta (Nombre, FechaInicio, FechaFin, Tipo, AplicaRecurso, Anio, Notas) VALUES

-- Semana Santa 2026
-- Festivos nacionales: Jue 2-abr y Vie 3-abr
-- Receso escolar: 30-mar al 5-abr (Res. 2433/2025 SED Bogotá)
('Semana Santa',            '2026-03-29', '2026-04-05', 'RecEscolar',   NULL,          2026,
 'Domingo Ramos 29-mar al Domingo Pascua 5-abr. Festivos: 2 y 3 abr. Receso escolar oficial.'),

-- Vacaciones mitad de año 2026
-- MEN/Bogotá: 22-jun al 6-jul. Atlántico: 22-jun al 12-jul.
('Vacaciones Mitad de Año', '2026-06-22', '2026-07-20', 'RecEscolar',   NULL,          2026,
 'MEN Bogotá (Res. 2433): 22-jun al 6-jul. Atlántico hasta 12-jul. Extendido a 20-jul por impacto turístico.'),

-- Semana de receso estudiantil octubre 2026
-- Semana 5-11 oct + festivo 12-oct (Día de la Raza, lunes)
('Receso Estudiantil Octubre', '2026-10-05', '2026-10-12', 'RecEscolar', NULL,          2026,
 'Decreto 1373/2007. Puente: 10-12 oct (12 oct = Día de la Raza cae lunes).'),

-- Vacaciones fin de año 2026
-- Cierre escolar 29-nov-2026. Retorno escolar enero 2027.
('Vacaciones Fin de Año',   '2026-11-30', '2027-01-11', 'RecEscolar',   NULL,          2026,
 'Cierre escolar Res. 2433: 29-nov-2026. Retorno estimado 11-ene-2027.'),

-- Alta temporada El Rodadero — Temporada pico dic-ene
('Alta Temporada Dec-Ene',  '2026-12-01', '2027-01-15', 'AltaTemporada','ElRodadero',  2026,
 'Temporada alta El Rodadero según Cotelco Magdalena.'),

-- Carnaval de Barranquilla 2026
-- Festivos: Lunes 16-feb y Martes 17-feb de 2026
('Carnaval de Barranquilla', '2026-02-14', '2026-02-17', 'Festivo',     NULL,          2026,
 'Lunes 16-feb y Martes 17-feb son festivos. Puente desde viernes 13-feb.');
GO

-- ============================================================
--  Vista de utilidad: ¿una fecha dada es temporada alta?
-- ============================================================
CREATE OR ALTER VIEW vw_TemporadasActivas AS
SELECT
    Id, Nombre, FechaInicio, FechaFin, Tipo, AplicaRecurso, Anio, Notas,
    DATEDIFF(DAY, FechaInicio, FechaFin) + 1 AS DiasTotal
FROM TemporadaAlta
WHERE FechaFin >= CAST(GETDATE() AS DATE)
GO

-- ============================================================
--  Función: verificar si @Fecha es alta temporada
--  @Recurso: NULL para regla global, 'ElRodadero' para aptos SM
-- ============================================================
CREATE OR ALTER FUNCTION fn_EsTemporadaAlta (
    @Fecha    DATE,
    @Recurso  NVARCHAR(100) = NULL
)
RETURNS BIT
AS
BEGIN
    DECLARE @EsAlta BIT = 0;

    IF EXISTS (
        SELECT 1
        FROM TemporadaAlta
        WHERE @Fecha BETWEEN FechaInicio AND FechaFin
          AND (AplicaRecurso IS NULL OR AplicaRecurso = @Recurso)
    )
        SET @EsAlta = 1;

    RETURN @EsAlta;
END
GO

-- ============================================================
--  Uso: calcular tarifa para una reserva
-- ============================================================
-- SELECT
--   @Fecha                          AS Fecha,
--   DATENAME(WEEKDAY, @Fecha)       AS DiaSemana,
--   dbo.fn_EsTemporadaAlta(@Fecha, @Recurso) AS EsAltaTemporada,
--   CASE
--     WHEN dbo.fn_EsTemporadaAlta(@Fecha, @Recurso) = 1 THEN 'TarifaNormal'
--     WHEN DATEPART(WEEKDAY, @Fecha) IN (2,3,4,5)       THEN 'TarifaEspecial'  -- L-J
--     ELSE                                                   'TarifaNormal'
--   END AS TarifaAplicable
