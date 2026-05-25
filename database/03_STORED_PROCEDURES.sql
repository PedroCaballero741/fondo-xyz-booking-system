-- =============================================
-- FONDO XYZ - FASE 3: STORED PROCEDURES
-- Ejecutar DESPUÉS de 01_CREATE_TABLES.sql
-- y 02_SEED_DATA.sql
-- =============================================

USE FondoXYZ;
GO

-- =============================================
-- SP1: sp_BuscarDisponibilidad
-- Retorna alojamientos sin reserva que solape
-- el rango [FechaInicio, FechaFin)
-- @SedeId = NULL → todas las sedes
-- =============================================
CREATE OR ALTER PROCEDURE sp_BuscarDisponibilidad
    @FechaInicio    DATE,
    @FechaFin       DATE,
    @SedeId         INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @FechaFin <= @FechaInicio
    BEGIN
        RAISERROR('FechaFin debe ser posterior a FechaInicio.', 16, 1);
        RETURN;
    END

    SELECT
        a.Id                AS AlojamientoId,
        a.Nombre            AS Alojamiento,
        s.Id                AS SedeId,
        s.Nombre            AS Sede,
        s.Ciudad,
        s.TipoSede,
        a.Bloque,
        a.NumHabitaciones,
        a.CapacidadMaxima,
        a.CapacidadBloque
    FROM Alojamiento a
    INNER JOIN Sede s ON s.Id = a.SedeId
    WHERE a.Activo = 1
      AND s.Activo = 1
      AND (@SedeId IS NULL OR s.Id = @SedeId)
      AND NOT EXISTS (
            SELECT 1
            FROM Reserva r
            WHERE r.AlojamientoId = a.Id
              AND r.Estado <> 'cancelada'
              AND r.FechaInicio < @FechaFin
              AND r.FechaFin   > @FechaInicio
          )
    ORDER BY s.Nombre, a.Numero;
END
GO

-- =============================================
-- SP2: sp_BuscarDisponibilidadPersonas
-- Igual que SP1 + filtra por CapacidadMaxima
-- =============================================
CREATE OR ALTER PROCEDURE sp_BuscarDisponibilidadPersonas
    @FechaInicio    DATE,
    @FechaFin       DATE,
    @NumeroPersonas INT,
    @SedeId         INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @FechaFin <= @FechaInicio
    BEGIN
        RAISERROR('FechaFin debe ser posterior a FechaInicio.', 16, 1);
        RETURN;
    END

    IF @NumeroPersonas < 1
    BEGIN
        RAISERROR('NumeroPersonas debe ser >= 1.', 16, 1);
        RETURN;
    END

    SELECT
        a.Id                AS AlojamientoId,
        a.Nombre            AS Alojamiento,
        s.Id                AS SedeId,
        s.Nombre            AS Sede,
        s.Ciudad,
        s.TipoSede,
        a.Bloque,
        a.NumHabitaciones,
        a.CapacidadMaxima,
        a.CapacidadBloque
    FROM Alojamiento a
    INNER JOIN Sede s ON s.Id = a.SedeId
    WHERE a.Activo = 1
      AND s.Activo = 1
      AND (@SedeId IS NULL OR s.Id = @SedeId)
      AND a.CapacidadMaxima >= @NumeroPersonas
      AND NOT EXISTS (
            SELECT 1
            FROM Reserva r
            WHERE r.AlojamientoId = a.Id
              AND r.Estado <> 'cancelada'
              AND r.FechaInicio < @FechaFin
              AND r.FechaFin   > @FechaInicio
          )
    ORDER BY s.Nombre, a.Numero;
END
GO

-- =============================================
-- SP3: sp_ConsultarTarifas
-- Retorna tarifa base + adicionales aplicables
-- para un alojamiento en una fecha concreta.
--
-- Lógica de temporada:
--   El Rodadero  → alta/baja según TemporadaAlta
--   Sede recreativa:
--     fn_EsTarifaEspecial = 1 → especial
--     else                    → normal
--   Suramericana → sin temporada (precio por personas)
-- =============================================
CREATE OR ALTER PROCEDURE sp_ConsultarTarifas
    @AlojamientoId  INT,
    @Fecha          DATE,
    @NumeroPersonas INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Datos del alojamiento
    DECLARE @SedeNombre     NVARCHAR(100);
    DECLARE @TipoSede       NVARCHAR(20);
    DECLARE @Bloque         NVARCHAR(20);
    DECLARE @NumHabitaciones INT;
    DECLARE @CapacidadMax   INT;

    SELECT
        @SedeNombre      = s.Nombre,
        @TipoSede        = s.TipoSede,
        @Bloque          = a.Bloque,
        @NumHabitaciones = a.NumHabitaciones,
        @CapacidadMax    = a.CapacidadMaxima
    FROM Alojamiento a
    INNER JOIN Sede s ON s.Id = a.SedeId
    WHERE a.Id = @AlojamientoId;

    IF @SedeNombre IS NULL
    BEGIN
        RAISERROR('AlojamientoId no encontrado.', 16, 1);
        RETURN;
    END

    -- Temporada aplicable
    DECLARE @Temporada NVARCHAR(10);

    IF @TipoSede = 'apartamento' AND @SedeNombre = 'El Rodadero'
    BEGIN
        SET @Temporada = CASE
            WHEN dbo.fn_EsAltaTemporadaRodadero(@Fecha) = 1 THEN 'alta'
            ELSE 'baja'
        END
    END
    ELSE IF @TipoSede = 'sede_recreativa'
    BEGIN
        SET @Temporada = CASE
            WHEN dbo.fn_EsTarifaEspecial(@Fecha, NULL) = 1 THEN 'especial'
            ELSE 'normal'
        END
    END
    -- Suramericana: temporada NULL (precio varía por número de personas)

    -- Habitaciones efectivas para tarifa
    -- Bloque 'cabanas' o 'bloque_nuevo' siempre factura como 2 habitaciones
    DECLARE @HabEfectivas INT = CASE
        WHEN @Bloque IN ('cabanas', 'bloque_nuevo') THEN 2
        ELSE @NumHabitaciones
    END

    -- Resultado: tarifa base
    SELECT
        t.Id            AS TarifaId,
        t.Nombre        AS Tarifa,
        @Temporada      AS Temporada,
        t.PersonasMax,
        t.NumHabitaciones,
        t.PrecioNoche   AS PrecioBaseNoche,
        CASE
            WHEN @TipoSede = 'sede_recreativa'
             AND @NumeroPersonas > 4
            THEN (@NumeroPersonas - 4) * (
                    SELECT PrecioNoche FROM Tarifa
                    WHERE TipoSede = 'sede_recreativa'
                      AND Nombre LIKE 'Persona Adicional%'
                      AND (Temporada = @Temporada OR (@Temporada IS NULL AND Temporada = 'normal'))
                 )
            ELSE 0
        END             AS CostoPersonasAdicionales,
        t.PrecioNoche
        + CASE
            WHEN @TipoSede = 'sede_recreativa'
             AND @NumeroPersonas > 4
            THEN (@NumeroPersonas - 4) * (
                    SELECT PrecioNoche FROM Tarifa
                    WHERE TipoSede = 'sede_recreativa'
                      AND Nombre LIKE 'Persona Adicional%'
                      AND (Temporada = @Temporada OR (@Temporada IS NULL AND Temporada = 'normal'))
                 )
            ELSE 0
          END           AS TotalNoche,
        @Fecha          AS Fecha,
        DATENAME(WEEKDAY, @Fecha) AS DiaSemana
    FROM Tarifa t
    WHERE t.TipoSede = @TipoSede
      AND (t.Temporada = @Temporada OR t.Temporada IS NULL AND @Temporada IS NULL)
      AND (
            -- Sede recreativa: buscar por número de habitaciones efectivas
            (@TipoSede = 'sede_recreativa'
             AND (t.NumHabitaciones = @HabEfectivas OR t.NumHabitaciones IS NULL AND t.PersonasMax IS NULL))
            OR
            -- El Rodadero: buscar por capacidad máxima del apartamento
            (@SedeNombre = 'El Rodadero'
             AND t.Sede = 'ElRodadero'
             AND t.PersonasMax = @CapacidadMax)
            OR
            -- Suramericana: buscar por número de personas
            (@SedeNombre = 'Suramericana'
             AND t.Sede = 'Suramericana'
             AND t.PersonasMax >= @NumeroPersonas)
          )
    ORDER BY t.PrecioNoche;
END
GO

-- =============================================
-- SP4: sp_CalcularCostoReserva
-- Calcula el desglose noche a noche para
-- la reserva, retorna el total y el detalle.
-- =============================================
CREATE OR ALTER PROCEDURE sp_CalcularCostoReserva
    @AlojamientoId  INT,
    @FechaInicio    DATE,
    @FechaFin       DATE,
    @NumeroPersonas INT
AS
BEGIN
    SET NOCOUNT ON;

    IF @FechaFin <= @FechaInicio
    BEGIN
        RAISERROR('FechaFin debe ser posterior a FechaInicio.', 16, 1);
        RETURN;
    END

    -- Datos del alojamiento y sede
    DECLARE @SedeNombre      NVARCHAR(100);
    DECLARE @TipoSede        NVARCHAR(20);
    DECLARE @Bloque          NVARCHAR(20);
    DECLARE @NumHabitaciones INT;
    DECLARE @CapacidadMax    INT;

    SELECT
        @SedeNombre      = s.Nombre,
        @TipoSede        = s.TipoSede,
        @Bloque          = a.Bloque,
        @NumHabitaciones = a.NumHabitaciones,
        @CapacidadMax    = a.CapacidadMaxima
    FROM Alojamiento a
    INNER JOIN Sede s ON s.Id = a.SedeId
    WHERE a.Id = @AlojamientoId;

    IF @SedeNombre IS NULL
    BEGIN
        RAISERROR('AlojamientoId no encontrado.', 16, 1);
        RETURN;
    END

    -- Habitaciones efectivas (bloque_nuevo/cabanas → siempre 2)
    DECLARE @HabEfectivas INT = CASE
        WHEN @Bloque IN ('cabanas', 'bloque_nuevo') THEN 2
        ELSE @NumHabitaciones
    END

    -- Tabla temporal: detalle noche a noche
    DECLARE @Detalle TABLE (
        Fecha           DATE,
        DiaSemana       NVARCHAR(15),
        Temporada       NVARCHAR(10),
        PrecioBase      DECIMAL(10,2),
        CostoAdicional  DECIMAL(10,2),
        TotalNoche      DECIMAL(10,2)
    );

    -- Generar secuencia de noches con CTE de números
    WITH Nums AS (
        SELECT TOP (DATEDIFF(DAY, @FechaInicio, @FechaFin))
               ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS N
        FROM sys.all_objects a CROSS JOIN sys.all_objects b
    ),
    Noches AS (
        SELECT DATEADD(DAY, N, @FechaInicio) AS Fecha
        FROM Nums
    )
    INSERT INTO @Detalle (Fecha, DiaSemana, Temporada, PrecioBase, CostoAdicional, TotalNoche)
    SELECT
        n.Fecha,
        DATENAME(WEEKDAY, n.Fecha),

        -- Temporada por noche
        CASE
            WHEN @TipoSede = 'apartamento' AND @SedeNombre = 'El Rodadero'
                THEN CASE WHEN dbo.fn_EsAltaTemporadaRodadero(n.Fecha) = 1 THEN 'alta' ELSE 'baja' END
            WHEN @TipoSede = 'sede_recreativa'
                THEN CASE WHEN dbo.fn_EsTarifaEspecial(n.Fecha, NULL) = 1 THEN 'especial' ELSE 'normal' END
            ELSE NULL
        END,

        -- Precio base de la noche
        CASE
            -- Sede recreativa
            WHEN @TipoSede = 'sede_recreativa' THEN
                ISNULL((
                    SELECT TOP 1 PrecioNoche FROM Tarifa
                    WHERE TipoSede = 'sede_recreativa'
                      AND NumHabitaciones = @HabEfectivas
                      AND Temporada = CASE
                            WHEN dbo.fn_EsTarifaEspecial(n.Fecha, NULL) = 1 THEN 'especial'
                            ELSE 'normal' END
                ), 0)

            -- El Rodadero: por capacidad del apartamento y temporada
            WHEN @SedeNombre = 'El Rodadero' THEN
                ISNULL((
                    SELECT TOP 1 PrecioNoche FROM Tarifa
                    WHERE Sede = 'ElRodadero'
                      AND PersonasMax = @CapacidadMax
                      AND Temporada = CASE
                            WHEN dbo.fn_EsAltaTemporadaRodadero(n.Fecha) = 1 THEN 'alta'
                            ELSE 'baja' END
                ), 0)

            -- Suramericana: por número de personas (1 o 2)
            WHEN @SedeNombre = 'Suramericana' THEN
                ISNULL((
                    SELECT TOP 1 PrecioNoche FROM Tarifa
                    WHERE Sede = 'Suramericana'
                      AND PersonasMax >= @NumeroPersonas
                    ORDER BY PersonasMax ASC
                ), 0)

            ELSE 0
        END,

        -- Personas adicionales (solo sede recreativa, >4 personas)
        CASE
            WHEN @TipoSede = 'sede_recreativa' AND @NumeroPersonas > 4 THEN
                (@NumeroPersonas - 4) * ISNULL((
                    SELECT TOP 1 PrecioNoche FROM Tarifa
                    WHERE TipoSede = 'sede_recreativa'
                      AND NumHabitaciones IS NULL
                      AND PersonasMax IS NULL
                      AND Temporada = CASE
                            WHEN dbo.fn_EsTarifaEspecial(n.Fecha, NULL) = 1 THEN 'especial'
                            ELSE 'normal' END
                ), 0)
            ELSE 0
        END,

        -- Total noche (calculado abajo en UPDATE)
        0
    FROM Noches n;

    -- Calcular total de cada noche
    UPDATE @Detalle
    SET TotalNoche = PrecioBase + CostoAdicional;

    -- Resultado 1: detalle por noche
    SELECT
        Fecha,
        DiaSemana,
        Temporada,
        PrecioBase,
        CostoAdicional      AS PersonasAdicionales,
        TotalNoche
    FROM @Detalle
    ORDER BY Fecha;

    -- Resultado 2: resumen total
    SELECT
        @AlojamientoId      AS AlojamientoId,
        @FechaInicio        AS FechaInicio,
        @FechaFin           AS FechaFin,
        DATEDIFF(DAY, @FechaInicio, @FechaFin) AS NumNoches,
        @NumeroPersonas     AS NumPersonas,
        SUM(PrecioBase)     AS TotalBase,
        SUM(CostoAdicional) AS TotalAdicionales,
        SUM(TotalNoche)     AS CostoTotal
    FROM @Detalle;
END
GO

-- =============================================
-- SP5: sp_CrearReserva (Bonus)
-- Verifica disponibilidad, crea la reserva
-- y su detalle en una sola transacción.
-- =============================================
CREATE OR ALTER PROCEDURE sp_CrearReserva
    @UsuarioId      NVARCHAR(450),
    @AlojamientoId  INT,
    @FechaInicio    DATE,
    @FechaFin       DATE,
    @NumeroPersonas INT,
    @CostoTotal     DECIMAL(10,2),
    @Notas          NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Validaciones básicas
    IF @FechaFin <= @FechaInicio
    BEGIN
        RAISERROR('FechaFin debe ser posterior a FechaInicio.', 16, 1);
        RETURN;
    END

    IF @NumeroPersonas < 1
    BEGIN
        RAISERROR('NumeroPersonas debe ser >= 1.', 16, 1);
        RETURN;
    END

    BEGIN TRANSACTION;

    BEGIN TRY
        -- Verificar disponibilidad con bloqueo pesimista
        IF EXISTS (
            SELECT 1
            FROM Reserva WITH (UPDLOCK, HOLDLOCK)
            WHERE AlojamientoId = @AlojamientoId
              AND Estado <> 'cancelada'
              AND FechaInicio < @FechaFin
              AND FechaFin   > @FechaInicio
        )
        BEGIN
            ROLLBACK TRANSACTION;
            RAISERROR('El alojamiento no está disponible para las fechas seleccionadas.', 16, 1);
            RETURN;
        END

        -- Verificar que el alojamiento existe y está activo
        IF NOT EXISTS (SELECT 1 FROM Alojamiento WHERE Id = @AlojamientoId AND Activo = 1)
        BEGIN
            ROLLBACK TRANSACTION;
            RAISERROR('Alojamiento no encontrado o inactivo.', 16, 1);
            RETURN;
        END

        -- Crear la reserva
        INSERT INTO Reserva (UsuarioId, AlojamientoId, FechaInicio, FechaFin,
                             NumPersonas, CostoTotal, Estado, Notas)
        VALUES (@UsuarioId, @AlojamientoId, @FechaInicio, @FechaFin,
                @NumeroPersonas, @CostoTotal, 'confirmada', @Notas);

        DECLARE @ReservaId INT = SCOPE_IDENTITY();

        -- Insertar detalle de la reserva noche a noche
        DECLARE @SedeNombre      NVARCHAR(100);
        DECLARE @TipoSede        NVARCHAR(20);
        DECLARE @Bloque          NVARCHAR(20);
        DECLARE @NumHabitaciones INT;
        DECLARE @CapacidadMax    INT;

        SELECT
            @SedeNombre      = s.Nombre,
            @TipoSede        = s.TipoSede,
            @Bloque          = a.Bloque,
            @NumHabitaciones = a.NumHabitaciones,
            @CapacidadMax    = a.CapacidadMaxima
        FROM Alojamiento a
        INNER JOIN Sede s ON s.Id = a.SedeId
        WHERE a.Id = @AlojamientoId;

        DECLARE @HabEfectivas INT = CASE
            WHEN @Bloque IN ('cabanas', 'bloque_nuevo') THEN 2
            ELSE @NumHabitaciones
        END

        -- Detalle resumido: 2 conceptos (base + adicionales si aplica)
        DECLARE @TotalBase      DECIMAL(10,2) = 0;
        DECLARE @TotalAdicional DECIMAL(10,2) = 0;

        -- Calcular sumando noche a noche con CTE (subqueries en CTE, SUM afuera)
        WITH Nums AS (
            SELECT TOP (DATEDIFF(DAY, @FechaInicio, @FechaFin))
                   ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS N
            FROM sys.all_objects a CROSS JOIN sys.all_objects b
        ),
        Noches AS (SELECT DATEADD(DAY, N, @FechaInicio) AS Fecha FROM Nums),
        NocheCostos AS (
            SELECT
                CASE
                    WHEN @TipoSede = 'sede_recreativa' THEN
                        ISNULL((SELECT TOP 1 PrecioNoche FROM Tarifa
                                WHERE TipoSede='sede_recreativa' AND NumHabitaciones=@HabEfectivas
                                  AND Temporada=CASE WHEN dbo.fn_EsTarifaEspecial(n.Fecha,NULL)=1 THEN 'especial' ELSE 'normal' END), 0)
                    WHEN @SedeNombre='El Rodadero' THEN
                        ISNULL((SELECT TOP 1 PrecioNoche FROM Tarifa
                                WHERE Sede='ElRodadero' AND PersonasMax=@CapacidadMax
                                  AND Temporada=CASE WHEN dbo.fn_EsAltaTemporadaRodadero(n.Fecha)=1 THEN 'alta' ELSE 'baja' END), 0)
                    WHEN @SedeNombre='Suramericana' THEN
                        ISNULL((SELECT TOP 1 PrecioNoche FROM Tarifa
                                WHERE Sede='Suramericana' AND PersonasMax>=@NumeroPersonas ORDER BY PersonasMax ASC), 0)
                    ELSE 0
                END AS CostoBase,
                CASE
                    WHEN @TipoSede='sede_recreativa' AND @NumeroPersonas>4 THEN
                        (@NumeroPersonas-4) * ISNULL((SELECT TOP 1 PrecioNoche FROM Tarifa
                            WHERE TipoSede='sede_recreativa' AND NumHabitaciones IS NULL AND PersonasMax IS NULL
                              AND Temporada=CASE WHEN dbo.fn_EsTarifaEspecial(n.Fecha,NULL)=1 THEN 'especial' ELSE 'normal' END), 0)
                    ELSE 0
                END AS CostoAdicional
            FROM Noches n
        )
        SELECT
            @TotalBase      = SUM(CostoBase),
            @TotalAdicional = SUM(CostoAdicional)
        FROM NocheCostos;

        INSERT INTO DetalleReserva (ReservaId, Concepto, Monto) VALUES
            (@ReservaId, 'Alojamiento (' + CAST(DATEDIFF(DAY,@FechaInicio,@FechaFin) AS NVARCHAR) + ' noches)', @TotalBase);

        IF @TotalAdicional > 0
            INSERT INTO DetalleReserva (ReservaId, Concepto, Monto)
            VALUES (@ReservaId,
                    'Personas adicionales (' + CAST(@NumeroPersonas-4 AS NVARCHAR) + ' adicionales)',
                    @TotalAdicional);

        COMMIT TRANSACTION;

        -- Retornar la reserva creada
        SELECT
            r.Id            AS ReservaId,
            r.UsuarioId,
            r.AlojamientoId,
            a.Nombre        AS Alojamiento,
            s.Nombre        AS Sede,
            r.FechaInicio,
            r.FechaFin,
            DATEDIFF(DAY, r.FechaInicio, r.FechaFin) AS NumNoches,
            r.NumPersonas,
            r.CostoTotal,
            r.Estado,
            r.FechaCreacion
        FROM Reserva r
        INNER JOIN Alojamiento a ON a.Id = r.AlojamientoId
        INNER JOIN Sede s        ON s.Id = a.SedeId
        WHERE r.Id = @ReservaId;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

PRINT '✔ Fase 3 completada: 5 stored procedures creados.';
PRINT '';
PRINT 'SPs disponibles:';
PRINT '  EXEC sp_BuscarDisponibilidad       @FechaInicio, @FechaFin [, @SedeId]';
PRINT '  EXEC sp_BuscarDisponibilidadPersonas @FechaInicio, @FechaFin, @NumeroPersonas [, @SedeId]';
PRINT '  EXEC sp_ConsultarTarifas           @AlojamientoId, @Fecha, @NumeroPersonas';
PRINT '  EXEC sp_CalcularCostoReserva       @AlojamientoId, @FechaInicio, @FechaFin, @NumeroPersonas';
PRINT '  EXEC sp_CrearReserva               @UsuarioId, @AlojamientoId, @FechaInicio, @FechaFin, @NumeroPersonas, @CostoTotal [, @Notas]';
GO
