# FODUN — Sistema de Reservas

Sistema de reservas de sedes recreativas y apartamentos para el Fondo de Docentes de la Universidad Nacional de Colombia (FODUN). Prueba técnica mayo 2026.

---

## Stack

- **ASP.NET Core 10 MVC** — arquitectura en 4 capas (Domain / Data / Business / Web)
- **SQL Server 2022** — via Docker
- **Entity Framework Core 10** — migrations + acceso a datos
- **ASP.NET Core Identity** — autenticación con clave numérica de 4 dígitos
- **MailKit** — envío de correos por SMTP (Gmail)

---

## Requisitos

- [.NET 10 SDK](https://dotnet.microsoft.com/download)
- [Docker](https://www.docker.com/)

---

## Levantar el proyecto

### 1. Iniciar SQL Server en Docker

```bash
docker run -e "ACCEPT_EULA=Y" -e "SA_PASSWORD=FondoXYZ@2025" \
  -p 1433:1433 --name fondoxyz-sqlserver \
  -d mcr.microsoft.com/mssql/server:2022-latest
```

Si ya lo creaste antes, solo arrancarlo:

```bash
docker start fondoxyz-sqlserver
```

### 2. Ejecutar los scripts SQL (solo la primera vez)

```bash
docker exec -i fondoxyz-sqlserver /opt/mssql-tools18/bin/sqlcmd \
  -S localhost -U sa -P "FondoXYZ@2025" -No \
  < database/01_CREATE_TABLES.sql

docker exec -i fondoxyz-sqlserver /opt/mssql-tools18/bin/sqlcmd \
  -S localhost -U sa -P "FondoXYZ@2025" -No \
  < database/02_SEED_DATA.sql

docker exec -i fondoxyz-sqlserver /opt/mssql-tools18/bin/sqlcmd \
  -S localhost -U sa -P "FondoXYZ@2025" -No \
  < database/03_STORED_PROCEDURES.sql
```

Esto crea las tablas, carga los datos iniciales (8 sedes, 45 alojamientos, tarifas, festivos colombianos 2025-2026) y registra los 5 stored procedures.

### 3. Correr la aplicación

```bash
dotnet run --project src/FondoXYZ.Web
```

La app queda en **http://localhost:5159**

---

## Primer uso

No hay usuarios precargados. Para registrarse:

1. Ir a **Ingreso y Registro** → **REGISTRESE AQUI**
2. Llenar el formulario — la clave es de **4 digitos numericos**
3. El numero de documento es el usuario para ingresar

---

## Configurar correo (opcional)

En desarrollo los correos se imprimen en la terminal. Para activar SMTP real, editar `src/FondoXYZ.Web/appsettings.json`:

```json
"EmailSettings": {
  "Provider": "Smtp",
  "SmtpServer": "smtp.gmail.com",
  "SmtpPort": "587",
  "Username": "tu-correo@gmail.com",
  "Password": "tu-app-password-de-google",
  "FromEmail": "noreply@fodun.com"
}
```

Para Gmail necesitas un **App Password** — no es la clave normal de la cuenta. Se genera en configuracion de seguridad de Google.

---

## Estructura del proyecto

```
fondo-xyz-booking-system/
├── database/
│   ├── 01_CREATE_TABLES.sql       tablas, funciones y vista
│   ├── 02_SEED_DATA.sql           datos iniciales (sedes, tarifas, festivos)
│   └── 03_STORED_PROCEDURES.sql   5 SPs de disponibilidad, tarifas y reservas
│
└── src/
    ├── FondoXYZ.Domain/           entidades, interfaces, DTOs
    ├── FondoXYZ.Data/             DbContext, repositorios, migrations
    ├── FondoXYZ.Business/         servicios de negocio (email)
    └── FondoXYZ.Web/              controllers, views, assets
```

---

## Pantallas

| Ruta | Acceso | Descripcion |
|---|---|---|
| `/Sedes` | publico | listado de sedes y apartamentos |
| `/Sedes/Detalle/{id}` | autenticado | detalle + busqueda de disponibilidad |
| `/Account/Login` | publico | ingreso con teclado dinamico |
| `/Account/Register` | publico | registro de nuevo usuario |
| `/Account/Actualizar` | autenticado | actualizar datos personales |
| `/Reservas` | autenticado | mis reservas + subir comprobante de pago |
| `/Reservas/Consultar` | publico | busqueda libre de disponibilidad |

---

## Logica de tarifas

- **Tarifa especial**: lunes a jueves, excluyendo festivos y recesos escolares colombianos
- **Tarifa normal**: viernes a domingo, festivos y temporada alta
- **El Rodadero**: maneja alta/baja temporada segun fechas especificas (Cotelco Magdalena)
- **Bloque nuevo**: cabanas 5-8 de El Placer y nuevos 4-11 de Manguruma siempre se cobran como 2 habitaciones
- El calculo noche por noche lo hace el SP `sp_CalcularCostoReserva`
