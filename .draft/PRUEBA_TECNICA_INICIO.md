# PRUEBA TÉCNICA - SISTEMA DE RESERVAS FONDO XYZ

## 📋 OBJETIVO

Desarrollar un sistema de reservas web para sedes recreativas y apartamentos del Fondo XYZ que permita:

1. **Consultar disponibilidad** de alojamientos por fechas
2. **Calcular tarifas** según temporada, número de personas, tipo de alojamiento
3. **Crear y gestionar reservas** con pago en línea
4. **Autenticación de usuarios** con recuperación de contraseña

---

## 🎯 ALCANCE DE LA PRUEBA

### Back-End (Prioridad Alta)

#### Base de Datos SQL Server
- [ ] Diseñar modelo relacional normalizado
- [ ] Crear script de creación de tablas con constraints
- [ ] Implementar SPs requeridos (ver sección de SPs)
- [ ] Poblar con datos iniciales (seed data)

#### Procedimientos Almacenados Requeridos

**SP1: Buscar habitaciones disponibles por rango de fechas**
```sql
EXEC sp_BuscarDisponibilidad 
  @FechaInicio DATE,
  @FechaFin DATE,
  @SedeId INT = NULL  -- Opcional, NULL = todas las sedes
```
**Output**: Lista de alojamientos disponibles con información básica

**SP2: Buscar habitaciones disponibles por fechas Y número de personas**
```sql
EXEC sp_BuscarDisponibilidadPersonas
  @FechaInicio DATE,
  @FechaFin DATE,
  @NumeroPersonas INT,
  @SedeId INT = NULL
```
**Output**: Alojamientos que soporten esa cantidad de personas

**SP3: Consultar tarifas aplicables**
```sql
EXEC sp_ConsultarTarifas
  @SedeId INT,
  @TipoAlojamiento VARCHAR(50),  -- 'sede_recreativa' | 'apartamento'
  @Fecha DATE,
  @NumeroPersonas INT
```
**Output**: Tarifa base + persona adicional + temporada aplicable

**SP4: Calcular costo total de reserva**
```sql
EXEC sp_CalcularCostoReserva
  @AlojamientoId INT,
  @FechaInicio DATE,
  @FechaFin DATE,
  @NumeroPersonas INT
```
**Output**: Desglose de costos (base + adicionales + total)

**SP5 (Bonus): Crear reserva**
```sql
EXEC sp_CrearReserva
  @UsuarioId INT,
  @AlojamientoId INT,
  @FechaInicio DATE,
  @FechaFin DATE,
  @NumeroPersonas INT,
  @CostoTotal DECIMAL(10,2)
```

#### Aplicación .NET (MVC + Entity Framework)

**Arquitectura en Capas:**
```
Solution/
├── FondoXYZ.Domain/          # Entidades, interfaces
├── FondoXYZ.Data/            # EF Context, Repositories
├── FondoXYZ.Business/        # Lógica de negocio
├── FondoXYZ.Web/             # Controllers, Views
└── FondoXYZ.Tests/           # Unit tests (opcional)
```

**Funcionalidades Mínimas:**
- Registro de usuarios (CRUD)
- Login con .NET Identity
- Recuperación de contraseña vía SMTP
- Consulta de disponibilidad (consumiendo SPs)
- Creación de reservas

### Front-End (Prioridad Media)

- Formulario de registro con validaciones
- Login/Logout
- Consulta de disponibilidad con filtros
- Visualización de tarifas calculadas
- Formulario de reserva

**No se requiere diseño elaborado**, funcionalidad sobre estética.

---

## 📊 DATOS INICIALES

Los datos del Fondo XYZ están estructurados en JSON (ver archivo `extracted_data_v3.json`):

### Estructura de Datos

```javascript
{
  "sedes_recreativas": [
    {
      "nombre": "Villeta",
      "ciudad": "Villeta",
      "capacidad_total": 32,
      "alojamientos": [
        {
          "numero": 1,
          "nombre": "Habitación 1",
          "caracteristicas": {
            "dormitorios": [
              { "camas": { "doble": 1, "camarote": 1 } }
            ],
            "tipo_cocina": null,
            "equipamiento": { "televisor": true, "nevera": true },
            "espacios": { "bano": { "cantidad": 1, "privado": true } }
          }
        }
        // ... 8 habitaciones
      ]
    },
    // ... 6 sedes recreativas totales
  ],
  "apartamentos": [
    {
      "nombre": "Suramericana",
      "ciudad": "Medellín",
      "habitaciones": [ /* 5 habitaciones */ ]
    },
    {
      "nombre": "El Rodadero",
      "ciudad": "Santa Marta",
      "unidades": [ /* 3 apartamentos */ ]
    }
  ],
  "tarifas": [
    {
      "nombre": "Sede 1 Habitación Normal",
      "tipo_sede": "sede_recreativa",
      "temporada": "normal",
      "num_habitaciones": 1,
      "personas_max": 4,
      "precio_noche": 70000
    },
    // ... 14 tarifas totales
  ]
}
```

### Reglas de Negocio Clave

**Temporadas:**
- **Normal**: Fines de semana, festivos, temporadas regulares
- **Especial**: Lunes-Jueves (excepto festivos, semana escolar, alta temporada)
- **Alta/Baja**: Solo aplica para apartamentos Santa Marta

**Cálculo de Personas Adicionales:**
- Base: 1-4 personas incluidas en tarifa
- Adicionales: $16,000/noche (normal) o $11,000/noche (especial)

**Visita Día:**
- Solo sedes recreativas específicas (Villeta, El Placer, Manguruma, Gonzalo Morante, Tablones)
- $5,500 por acompañante (del 5° al 10° acompañante)

**Bloque Nuevo (El Placer/Manguruma):**
- Cabañas 5-8 (El Placer) y alojamientos nuevos 4-11 (Manguruma)
- Tarifa fija de 2 habitaciones ($90,000) independiente del número real de habitaciones

---

## 🏗️ DISEÑO DE BASE DE DATOS SUGERIDO

### Opción A: Modelo Normalizado (Recomendado)

```sql
-- Entidades principales
Sede (id, nombre, ciudad, tipo_sede, capacidad_total)
Alojamiento (id, sede_id, numero, nombre, bloque, tipo_cabana, num_habitaciones)
Dormitorio (id, alojamiento_id, numero, camas_dobles, camas_sencillas, camarotes, camas_gemelas, camas_auxiliares)
Caracteristica (id, alojamiento_id, tipo_cocina, num_banos, bano_privado, ...)

-- Tarifas
Tarifa (id, nombre, tipo_sede, temporada, num_habitaciones, personas_max, precio_noche)
TarifaSede (id, tarifa_id, sede_id) -- Relación M:N

-- Reservas
Usuario (id, nombre, email, password_hash, ...)
Reserva (id, usuario_id, alojamiento_id, fecha_inicio, fecha_fin, num_personas, costo_total, estado)
DetalleReserva (id, reserva_id, concepto, monto)

-- Disponibilidad
ReservaFecha (id, reserva_id, fecha) -- Fechas bloqueadas por reserva
```

### Opción B: Modelo Semi-Desnormalizado (Más Simple)

```sql
Alojamiento (
  id, sede_nombre, numero, nombre,
  -- Totales de camas
  total_camas_dobles, total_camas_sencillas, total_camarotes, total_gemelas, total_auxiliares,
  -- Características
  tipo_cocina, num_banos, bano_privado,
  tiene_televisor, tiene_nevera, tiene_sofa_cama,
  tiene_terraza, terraza_cubierta, tiene_comedor, tiene_sala_estar, tiene_parqueo
)

-- Resto igual
```

**Trade-off**: 
- ✅ Opción A: Mayor normalización, consultas más complejas
- ✅ Opción B: Más simple, pierde detalle de distribución de camas por dormitorio

---

## 🚀 PASOS PARA EMPEZAR

### Fase 1: Diseño de Base de Datos (2-3 horas)

1. **Crear diagrama ER** con todas las entidades y relaciones
2. **Escribir script SQL** de creación de tablas
3. **Definir constraints**: PKs, FKs, checks, defaults
4. **Crear índices** en columnas de búsqueda frecuente (fecha_inicio, fecha_fin, sede_id)

**Entregable**: `01_CREATE_TABLES.sql`

### Fase 2: Seed Data (1 hora)

1. **Convertir JSON a INSERT statements**
2. **Poblar tablas** en orden de dependencias (Sede → Alojamiento → Característica)
3. **Verificar integridad** de datos insertados

**Entregable**: `02_SEED_DATA.sql`

### Fase 3: Stored Procedures (3-4 horas)

Implementar los 4-5 SPs requeridos, en orden:

1. `sp_BuscarDisponibilidad` (más simple)
2. `sp_BuscarDisponibilidadPersonas` (añade filtro capacidad)
3. `sp_ConsultarTarifas` (lógica de temporada)
4. `sp_CalcularCostoReserva` (combina tarifas + días)
5. `sp_CrearReserva` (transacción compleja - bonus)

**Entregable**: `03_STORED_PROCEDURES.sql`

### Fase 4: Aplicación .NET (6-8 horas)

#### 4.1 Configuración Inicial
```bash
dotnet new mvc -n FondoXYZ.Web
dotnet add package Microsoft.EntityFrameworkCore.SqlServer
dotnet add package Microsoft.AspNetCore.Identity.EntityFrameworkCore
```

#### 4.2 Modelo de Dominio
```csharp
// Domain/Entities/Alojamiento.cs
public class Alojamiento 
{
    public int Id { get; set; }
    public string Nombre { get; set; }
    public int SedeId { get; set; }
    public virtual Sede Sede { get; set; }
    // ... propiedades según tu modelo
}
```

#### 4.3 DbContext con EF
```csharp
public class FondoXYZContext : IdentityDbContext<Usuario>
{
    public DbSet<Sede> Sedes { get; set; }
    public DbSet<Alojamiento> Alojamientos { get; set; }
    public DbSet<Reserva> Reservas { get; set; }
    // ...
}
```

#### 4.4 Llamar SPs desde EF
```csharp
// Repository
public async Task<List<AlojamientoDisponible>> BuscarDisponibilidad(DateTime inicio, DateTime fin)
{
    return await _context.Set<AlojamientoDisponible>()
        .FromSqlRaw("EXEC sp_BuscarDisponibilidad @FechaInicio, @FechaFin", 
            new SqlParameter("@FechaInicio", inicio),
            new SqlParameter("@FechaFin", fin))
        .ToListAsync();
}
```

#### 4.5 Controllers Mínimos
- `AccountController`: Register, Login, ForgotPassword
- `ReservasController`: Index, Consultar, Create
- `HomeController`: Landing page

**Entregable**: Solución completa `.sln` + código fuente

### Fase 5: SMTP Recovery (1 hora)

```csharp
// appsettings.json
"EmailSettings": {
  "SmtpServer": "smtp.gmail.com",
  "SmtpPort": 587,
  "Username": "your-email@gmail.com",
  "Password": "app-password",
  "FromEmail": "noreply@fondoxyz.com"
}

// Services/EmailService.cs
public async Task SendPasswordResetEmail(string email, string resetToken) { ... }
```

---

## ✅ CHECKLIST DE ENTREGABLES

### Base de Datos
- [ ] Script SQL de creación de tablas
- [ ] Script SQL de seed data
- [ ] Script SQL de stored procedures
- [ ] Backup .bak de base de datos poblada

### Aplicación Web
- [ ] Código fuente completo (.sln)
- [ ] README con instrucciones de instalación
- [ ] Connection string configurable
- [ ] Migraciones de EF (si aplica)

### Funcionalidades Implementadas
- [ ] Registro de usuarios funcional
- [ ] Login/Logout con Identity
- [ ] Envío de email de recuperación
- [ ] Consulta de disponibilidad (llamando SP)
- [ ] Visualización de tarifas calculadas
- [ ] Creación de reserva
- [ ] Consulta de reservas existentes

---

## 🎓 CRITERIOS DE EVALUACIÓN

**Back-End (60%)**
- Diseño de BD normalizado y eficiente (15%)
- SPs correctos y optimizados (25%)
- Arquitectura en capas bien definida (10%)
- Uso apropiado de EF (10%)

**Funcionalidad (30%)**
- Autenticación completa (10%)
- Cálculo de tarifas correcto (10%)
- Flujo de reserva funcional (10%)

**Código Limpio (10%)**
- Nombres descriptivos
- Separación de responsabilidades
- Manejo de errores

---

## 📚 RECURSOS

- **Documento original**: `context.md`
- **Datos estructurados**: `extracted_data_v3.json`
- **Referencia visual**: Diagrama en imagen adjunta
- **URL de referencia**: https://reservaenlinea.fodun.com.co/

---

## ⏱️ TIEMPO ESTIMADO

- **Mínimo viable**: 12-16 horas
- **Con extras (tests, UI mejorada)**: 20-24 horas

**Prioriza**: Backend → SPs → Funcionalidad básica → Front-End

---

## 🚨 TIPS IMPORTANTES

1. **No sobrediseñes**: La prueba pide funcionalidad, no arquitectura enterprise
2. **SPs primero**: Son el corazón de la lógica de negocio
3. **Seed data realista**: Usa el JSON provisto, no inventes datos
4. **Testing manual**: Prepara casos de prueba claros
5. **Documenta decisiones**: Si tomaste un atajo, explica por qué

**¿Dudas sobre el modelo de datos o reglas de negocio?** Pregunta antes de empezar a codear.
