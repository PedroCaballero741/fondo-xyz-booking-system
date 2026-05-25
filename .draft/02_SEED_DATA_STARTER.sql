-- =============================================
-- FONDO XYZ - SEED DATA SCRIPT
-- Generado desde extracted_data_v3.json
-- =============================================

USE FondoXYZ;
GO

-- =============================================
-- 1. SEDES RECREATIVAS
-- =============================================

INSERT INTO Sede (Nombre, NombreOficial, Ciudad, TipoSede, CapacidadTotal)
VALUES 
  ('Villeta', 'Villeta', 'Villeta', 'sede_recreativa', 32),
  ('El Placer', 'El Placer – Fusagasugá', 'Fusagasugá', 'sede_recreativa', 34),
  ('Gonzalo Morante', 'Gonzalo Morante - Chinchiná', 'Chinchiná', 'sede_recreativa', 30),
  ('Tablones', 'Tablones – Palmira', 'Palmira', 'sede_recreativa', 24),
  ('Manguruma', 'Manguruma – Santa fe de Antioquia', 'Santa fe de Antioquia', 'sede_recreativa', 46),
  ('Federman', 'Federman - Bogotá', 'Bogotá', 'sede_recreativa', NULL);

-- =============================================
-- 2. APARTAMENTOS
-- =============================================

INSERT INTO Sede (Nombre, NombreOficial, Ciudad, TipoSede, CapacidadTotal)
VALUES 
  ('Suramericana', 'Suramericana, Medellín', 'Medellín', 'apartamento', NULL),
  ('El Rodadero', 'El Rodadero, Santa Marta', 'Santa Marta', 'apartamento', 20);

-- =============================================
-- 3. ALOJAMIENTOS - VILLETA (8 habitaciones idénticas)
-- =============================================

DECLARE @SedeVilleta INT = (SELECT Id FROM Sede WHERE Nombre = 'Villeta');

INSERT INTO Alojamiento (SedeId, Numero, Nombre, Bloque, TipoCabana, NumHabitaciones)
VALUES 
  (@SedeVilleta, 1, 'Habitación 1', 'principal', NULL, 1),
  (@SedeVilleta, 2, 'Habitación 2', 'principal', NULL, 1),
  (@SedeVilleta, 3, 'Habitación 3', 'principal', NULL, 1),
  (@SedeVilleta, 4, 'Habitación 4', 'principal', NULL, 1),
  (@SedeVilleta, 5, 'Habitación 5', 'principal', NULL, 1),
  (@SedeVilleta, 6, 'Habitación 6', 'principal', NULL, 1),
  (@SedeVilleta, 7, 'Habitación 7', 'principal', NULL, 1),
  (@SedeVilleta, 8, 'Habitación 8', 'principal', NULL, 1);

-- Características de Villeta (todas iguales)
DECLARE @AlojamientoId INT;

DECLARE villeta_cursor CURSOR FOR 
  SELECT Id FROM Alojamiento WHERE SedeId = @SedeVilleta;

OPEN villeta_cursor;
FETCH NEXT FROM villeta_cursor INTO @AlojamientoId;

WHILE @@FETCH_STATUS = 0
BEGIN
  -- Características
  INSERT INTO Caracteristica (AlojamientoId, TipoCocina, NumBanos, BanoPrivado, Tienetelevisor, TieneNevera, TieneSofaCama,
                              TieneTerraza, TerrazaCubierta, TieneComedor, TieneSalaEstar, TieneParqueo)
  VALUES (@AlojamientoId, NULL, 1, 1, 1, 1, 0, 1, 1, 0, 0, 0);

  -- Dormitorio
  INSERT INTO Dormitorio (AlojamientoId, Numero, CamasDobles, CamasSencillas, Camarotes, CamasGemelas, CamasAuxiliares)
  VALUES (@AlojamientoId, 1, 1, 0, 1, 0, 0);

  FETCH NEXT FROM villeta_cursor INTO @AlojamientoId;
END

CLOSE villeta_cursor;
DEALLOCATE villeta_cursor;

-- =============================================
-- 4. ALOJAMIENTOS - EL PLACER (8 alojamientos variados)
-- =============================================

DECLARE @SedeElPlacer INT = (SELECT Id FROM Sede WHERE Nombre = 'El Placer');

-- Alojamiento 1
INSERT INTO Alojamiento (SedeId, Numero, Nombre, Bloque, TipoCabana, NumHabitaciones, CapacidadBloque)
VALUES (@SedeElPlacer, 1, 'Alojamiento 1', 'principal', NULL, 2, 18);
SET @AlojamientoId = SCOPE_IDENTITY();

INSERT INTO Caracteristica (AlojamientoId, TipoCocina, NumBanos, BanoPrivado, TieneTelevISor, TieneNevera, TieneSofaCama, TieneTerraza, TerrazaCubierta, TieneComedor, TieneSalaEstar, TieneParqueo)
VALUES (@AlojamientoId, NULL, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0);

INSERT INTO Dormitorio (AlojamientoId, Numero, CamasDobles, CamasSencillas, Camarotes, CamasGemelas, CamasAuxiliares)
VALUES 
  (@AlojamientoId, 1, 1, 1, 0, 0, 0),
  (@AlojamientoId, 2, 0, 1, 0, 0, 0);

-- Alojamiento 2
INSERT INTO Alojamiento (SedeId, Numero, Nombre, Bloque, TipoCabana, NumHabitaciones, CapacidadBloque)
VALUES (@SedeElPlacer, 2, 'Alojamiento 2', 'principal', NULL, 2, 18);
SET @AlojamientoId = SCOPE_IDENTITY();

INSERT INTO Caracteristica (AlojamientoId, TipoCocina, NumBanos, BanoPrivado, TieneTelevISor, TieneNevera, TieneSofaCama, TieneTerraza, TerrazaCubierta, TieneComedor, TieneSalaEstar, TieneParqueo)
VALUES (@AlojamientoId, NULL, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0);

INSERT INTO Dormitorio (AlojamientoId, Numero, CamasDobles, CamasSencillas, Camarotes, CamasGemelas, CamasAuxiliares)
VALUES 
  (@AlojamientoId, 1, 1, 0, 0, 0, 0),
  (@AlojamientoId, 2, 0, 4, 0, 0, 0);

-- Alojamiento 3
INSERT INTO Alojamiento (SedeId, Numero, Nombre, Bloque, TipoCabana, NumHabitaciones, CapacidadBloque)
VALUES (@SedeElPlacer, 3, 'Alojamiento 3', 'principal', NULL, 1, 18);
SET @AlojamientoId = SCOPE_IDENTITY();

INSERT INTO Caracteristica (AlojamientoId, TipoCocina, NumBanos, BanoPrivado, TieneTelevISor, TieneNevera, TieneSofaCama, TieneTerraza, TerrazaCubierta, TieneComedor, TieneSalaEstar, TieneParqueo)
VALUES (@AlojamientoId, NULL, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0);

INSERT INTO Dormitorio (AlojamientoId, Numero, CamasDobles, CamasSencillas, Camarotes, CamasGemelas, CamasAuxiliares)
VALUES (@AlojamientoId, 1, 1, 2, 0, 0, 0);

-- Alojamiento 4
INSERT INTO Alojamiento (SedeId, Numero, Nombre, Bloque, TipoCabana, NumHabitaciones, CapacidadBloque)
VALUES (@SedeElPlacer, 4, 'Alojamiento 4', 'principal', NULL, 2, 18);
SET @AlojamientoId = SCOPE_IDENTITY();

INSERT INTO Caracteristica (AlojamientoId, TipoCocina, NumBanos, BanoPrivado, TieneTelevISor, TieneNevera, TieneSofaCama, TieneTerraza, TerrazaCubierta, TieneComedor, TieneSalaEstar, TieneParqueo)
VALUES (@AlojamientoId, NULL, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0);

INSERT INTO Dormitorio (AlojamientoId, Numero, CamasDobles, CamasSencillas, Camarotes, CamasGemelas, CamasAuxiliares)
VALUES 
  (@AlojamientoId, 1, 1, 1, 0, 0, 0),
  (@AlojamientoId, 2, 0, 1, 0, 0, 0);

-- Cabañas 5-8 (bloque de cabañas)
DECLARE @i INT = 5;
WHILE @i <= 8
BEGIN
  INSERT INTO Alojamiento (SedeId, Numero, Nombre, Bloque, TipoCabana, NumHabitaciones, CapacidadBloque)
  VALUES (@SedeElPlacer, @i, 'Cabaña ' + CAST(@i AS VARCHAR), 'cabanas', 'estandar', 1, 16);
  SET @AlojamientoId = SCOPE_IDENTITY();

  INSERT INTO Caracteristica (AlojamientoId, TipoCocina, NumBanos, BanoPrivado, TieneTelevISor, TieneNevera, TieneSofaCama, TieneTerraza, TerrazaCubierta, TieneComedor, TieneSalaEstar, TieneParqueo)
  VALUES (@AlojamientoId, 'cocineta', 1, 0, 1, 1, 1, 1, 0, 1, 1, 0);

  INSERT INTO Dormitorio (AlojamientoId, Numero, CamasDobles, CamasSencillas, Camarotes, CamasGemelas, CamasAuxiliares)
  VALUES (@AlojamientoId, 1, 1, 1, 0, 0, 0);

  SET @i = @i + 1;
END

-- =============================================
-- 5. TARIFAS
-- =============================================

INSERT INTO Tarifa (Nombre, Sede, TipoSede, Temporada, NumHabitaciones, PersonasMax, PrecioNoche)
VALUES 
  -- Medellín
  ('Habitación Medellín 1 persona', 'Suramericana', 'apartamento', NULL, 1, 1, 63000),
  ('Habitación Medellín 2 personas', 'Suramericana', 'apartamento', NULL, 1, 2, 75000),
  
  -- Santa Marta
  ('Apto 301-401 Baja Temporada', 'El Rodadero', 'apartamento', 'baja', NULL, 6, 89000),
  ('Apto 202 Baja Temporada', 'El Rodadero', 'apartamento', 'baja', NULL, 8, 103000),
  ('Apto 301-401 Alta Temporada', 'El Rodadero', 'apartamento', 'alta', NULL, 6, 124000),
  ('Apto 202 Alta Temporada', 'El Rodadero', 'apartamento', 'alta', NULL, 8, 143000),
  
  -- Sedes Recreativas - Normal
  ('Sede 1 Habitación Normal', NULL, 'sede_recreativa', 'normal', 1, 4, 70000),
  ('Sede 2 Habitaciones Normal', NULL, 'sede_recreativa', 'normal', 2, 4, 90000),
  
  -- Sedes Recreativas - Especial
  ('Sede 1 Habitación Especial', NULL, 'sede_recreativa', 'especial', 1, 4, 27000),
  ('Sede 2 Habitaciones Especial', NULL, 'sede_recreativa', 'especial', 2, 4, 37000),
  
  -- Adicionales
  ('Persona Adicional Normal', NULL, 'sede_recreativa', 'normal', NULL, NULL, 16000),
  ('Persona Adicional Especial', NULL, 'sede_recreativa', 'especial', NULL, NULL, 11000),
  ('Visita Día Acompañante', NULL, 'sede_recreativa', NULL, NULL, NULL, 5500),
  ('Servicio de Lavandería', 'El Rodadero', 'apartamento', NULL, NULL, NULL, 18000);

-- =============================================
-- 6. USUARIOS DE PRUEBA
-- =============================================

-- Nota: Los passwords deben ser hasheados por Identity en la aplicación
-- Estos son solo placeholders

INSERT INTO Usuario (Nombre, Apellido, Email, Telefono, FechaRegistro)
VALUES 
  ('Juan', 'Pérez', 'juan.perez@test.com', '3001234567', GETDATE()),
  ('María', 'González', 'maria.gonzalez@test.com', '3109876543', GETDATE()),
  ('Carlos', 'Rodríguez', 'carlos.rodriguez@test.com', '3201112233', GETDATE());

PRINT 'Seed data insertado exitosamente';
PRINT 'Total Sedes: ' + CAST((SELECT COUNT(*) FROM Sede) AS VARCHAR);
PRINT 'Total Alojamientos: ' + CAST((SELECT COUNT(*) FROM Alojamiento) AS VARCHAR);
PRINT 'Total Tarifas: ' + CAST((SELECT COUNT(*) FROM Tarifa) AS VARCHAR);
PRINT 'Total Usuarios: ' + CAST((SELECT COUNT(*) FROM Usuario) AS VARCHAR);

GO

-- =============================================
-- NOTA: Este script solo incluye ejemplos
-- Completar con el resto de sedes del JSON:
-- - Gonzalo Morante (6 alojamientos)
-- - Tablones (4 alojamientos)
-- - Manguruma (11 alojamientos)
-- - Federman (metadata, sin alojamientos)
-- - Apartamentos Medellín (5 habitaciones)
-- - Apartamentos Santa Marta (3 unidades)
-- =============================================
