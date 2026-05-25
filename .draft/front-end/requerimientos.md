 Sistema de Reservas FODUN — Implementación en .NET

Necesito que implementes el **Sistema de Reservas de Sedes Recreativas y Apartamentos del FODUN** (Fondo de Docentes de la Universidad Nacional de Colombia) usando **ASP.NET Core MVC + Entity Framework Core + SQL Server**.

Tengo un prototipo HTML/CSS/React de referencia visual con el diseño exacto que necesito replicar. **Copia los estilos del CSS al proyecto Razor.** Los archivos están en `/ruta/a/proyecto/`:
- `FODUN Sistema de Reservas.html`
- `styles.css` ← copia directo a `wwwroot/css/site.css`
- `screens.jsx` (referencia de estructura de cada pantalla)
- `app.jsx` (flujo de navegación)

## Stack
- **ASP.NET Core 8 MVC** (Controllers + Views Razor)
- **Entity Framework Core** + **SQL Server** (o SQLite para desarrollo)
- **ASP.NET Core Identity** customizado para usar clave numérica de 4 dígitos
- **Bootstrap 5** mínimo (la mayoría del estilo viene del CSS de referencia)
- **jQuery** solo donde sea necesario (calendarios, modales)

## Modelo de Datos (Entity Framework)

```csharp
public class Usuario {
    public int Id { get; set; }
    public string NumeroDocumento { get; set; }  // único
    public string NombreCompleto { get; set; }
    public DateTime FechaNacimiento { get; set; }
    public string Celular { get; set; }
    public string Email { get; set; }
    public string Departamento { get; set; }
    public string Municipio { get; set; }
    public string Barrio { get; set; }
    public string DireccionResidencia { get; set; }
    public string TelefonoResidencia { get; set; }
    public string PreguntaSecreta { get; set; }
    public string RespuestaSecreta { get; set; }  // hash
    public string ClaveHash { get; set; }         // hash de 4 dígitos
    public bool AutorizaEnvioCorreo { get; set; }
    public bool AutorizaEnvioCelular { get; set; }
}

public class Sede {
    public int Id { get; set; }
    public string Nombre { get; set; }
    public string Descripcion { get; set; }
    public string DescripcionLarga { get; set; }
    public TipoSede Tipo { get; set; }            // enum: Recreativa, Apartamento
    public string Ubicacion { get; set; }
    public string ImagenPrincipal { get; set; }
    public List<SedeImagen> Galeria { get; set; }
    public string RutaLlegadaPdfPath { get; set; }
    public List<Habitacion> Habitaciones { get; set; }
}

public class Habitacion {
    public int Id { get; set; }
    public int SedeId { get; set; }
    public Sede Sede { get; set; }
    public int Numero { get; set; }
    public int Capacidad { get; set; }
    public decimal TarifaOrdinaria { get; set; }
    public decimal TarifaEspecial { get; set; }
    public List<HabitacionAmenidad> Amenidades { get; set; }
}

public class Reserva {
    public int Id { get; set; }
    public int UsuarioId { get; set; }
    public Usuario Usuario { get; set; }
    public int SedeId { get; set; }
    public Sede Sede { get; set; }
    public List<ReservaHabitacion> Habitaciones { get; set; }
    public DateTime FechaReserva { get; set; }
    public DateTime FechaLlegada { get; set; }
    public DateTime FechaSalida { get; set; }
    public int Noches { get; set; }
    public int Personas { get; set; }
    public bool ServicioLavanderia { get; set; }
    public decimal ValorTotal { get; set; }
    public string ComprobantePagoPath { get; set; }  // archivo subido
    public EstadoReserva Estado { get; set; }
}

public class DiaEspecial {
    public int Id { get; set; }
    public DateTime Fecha { get; set; }
    public string Descripcion { get; set; }   // feriado, temporada alta, etc
}
```

## Pantallas a implementar (7)

### 1. `GET /Cuenta/Ingreso` — Login
- Form: `NumeroDocumento` + `Clave` (4 dígitos)
- **Teclado dinámico**: 10 botones (0-9) en orden aleatorio generado en cada GET. La clave se construye haciendo click en los botones, no escribiendo.
- Botón "Limpiar" reinicia el campo clave.
- Link "¿Olvidó su clave?" → recuperación por pregunta secreta.
- Banner "¿Usuario Nuevo? REGÍSTRESE AQUÍ" → redirige a `/Cuenta/Registro`.
- Selector de "Contraste" (3 niveles, opcional/decorativo).

### 2. `GET /Cuenta/Registro` — Registro Nuevo Usuario
Formulario en 2 columnas con los campos del modelo `Usuario`. Validaciones:
- Todos los campos con `*` rojo son obligatorios.
- Clave debe tener exactamente 4 dígitos numéricos.
- Confirmar Clave debe coincidir.
- Email válido.
- Documento único en BD.
Botones: Enviar / Cancelar.

### 3. `GET /Sedes` — Listado público
- Tabla con foto, Nombre, Descripción, Tipo, Ubicación, botón "Seleccionar".
- Si el usuario NO está autenticado, "Seleccionar" lo redirige a login con returnUrl.

### 4. `GET /Sedes/Detalle/{id}` — Detalle + Selección Fechas
**Sub-tabs**: "Sedes Recreativas y Apartamentos" / "Seleccione sus Fechas" (activa).

Layout 2 columnas:
- **Izquierda**: form "Mis Fechas" (Fecha Llegada, Fecha Salida, Noches auto-calc, Personas, checkbox Servicio de Lavandería) + bloque "Total Reserva" (Habitaciones, Días Ordinarios, Días Especiales, Lavandería, Valor Total en grande rojo) + botón **Reservar** rojo.
- **Derecha**: galería de imágenes (1 principal + 4 thumbnails) + descripción larga con scroll + "Descargar ruta de llegada" (PDF).

Abajo: tabla **"Habitaciones / Alojamientos"** con columnas:
| Detalles | Habitación | Capacidad | Tarifa Ordinario | Tarifa Especial | Disponibilidad | Ver Calendario | Reservar |

- Click ícono 🔍 → abre modal "Detalle Habitación" con amenidades.
- Click ícono 📅 → abre calendario con días bloqueados.
- Checkbox "Reservar" solo si está disponible.

**Cálculo del total** (server-side al hacer click en Reservar):
```
totalOrdinario = SUM(habs.TarifaOrdinaria * diasOrdinarios)
totalEspecial  = SUM(habs.TarifaEspecial * diasEspeciales)
lavanderia     = checkbox ? (TARIFA_LAVANDERIA * numHabs * noches) : 0
valorTotal     = totalOrdinario + totalEspecial + lavanderia
```
Los "días especiales" se determinan consultando la tabla `DiaEspecial` para fechas dentro del rango.

### 5. Modal Detalle Habitación
Pop-up con: descripción + amenidades (cama doble, camarote, baño, nevera, TV, terraza) + datos de tarifa.

### 6. Modal Confirmación de Reserva
Antes de persistir, muestra resumen idéntico al de "Total Reserva" + botones **Confirmar / Cancelar**.
Al confirmar: insertar `Reserva` en BD + redirigir a `/MisReservas`.

### 7. `GET /MisReservas` — Listado del usuario logueado
Tabla con: Ampliar 🔍, Lugar, Fecha Reserva, Fecha Llegada, Fecha Salida, Personas, Habitaciones, Valor Total, Comprobante de Pago.
- Si `ComprobantePagoPath == null` → botón **Enviar** (abre form de upload).
- Si ya subido → ícono de documento (link al archivo).

### 8. (Bonus) `GET /Cuenta/Actualizar` — Actualizar Datos
Mismo form que Registro pero pre-llenado, sin permitir cambiar NumeroDocumento.

## Estilo Visual

Toma los estilos de `styles.css` del prototipo. Variables clave:
```css
--fodun-red: #A8202F;
--fodun-red-button: #B71C2A;
--fodun-gray-1: #F5F5F5;
--fodun-section-bg: #E8E8E8;
```
- **Header** rojo con gradiente radial + logo "X" en círculo blanco + banner blanco "SISTEMA DE RESERVAS / Sedes Recreativas y Apartamentos".
- **Nav** gris claro con tabs (activo blanco con borde rojo arriba).
- **Sub-tabs** estilo carpeta (activo rojo, inactivo gris).
- **Tablas** con header gris, filas zebra, hover rosado.
- **Botones primarios** rojos con gradiente, sombra y text-shadow.
- **Footer** rojo: "FODUN - Fondo de Docentes Universidad Nacional - Derechos Reservados © 2014 - Desarrollado por MarketingItSolutions S.A.S".
- Tipografía: **Open Sans** (Google Fonts), 13px base.

## Estructura del proyecto sugerida
```
FodunReservas/
├── Controllers/
│   ├── CuentaController.cs        (Login, Registro, Logout, Actualizar)
│   ├── SedesController.cs         (List, Detalle)
│   ├── ReservasController.cs      (Crear, Confirmar, Mis)
│   └── HomeController.cs
├── Models/
│   ├── Usuario.cs, Sede.cs, Habitacion.cs, Reserva.cs, DiaEspecial.cs
│   └── ViewModels/ (LoginVM, RegistroVM, ReservaVM, etc)
├── Data/
│   └── FodunDbContext.cs
├── Services/
│   ├── IKeypadService.cs          (genera orden aleatorio + valida)
│   ├── IReservaCalculator.cs      (lógica de tarifas)
│   └── IFileStorage.cs            (subida comprobantes)
├── Views/
│   ├── Shared/_Layout.cshtml      (header + nav + footer)
│   ├── Cuenta/{Ingreso, Registro, Actualizar}.cshtml
│   ├── Sedes/{Index, Detalle}.cshtml
│   └── Reservas/{MisReservas, _Confirmar.cshtml}
├── wwwroot/
│   ├── css/site.css               (← copiar styles.css aquí)
│   ├── js/teclado.js              (lógica del teclado dinámico)
│   └── images/sedes/
└── Program.cs
```

## Requisitos no funcionales
1. **Seguridad**: clave hasheada con BCrypt, antiforgery tokens, validación server-side estricta.
2. **Disponibilidad**: al consultar habitaciones para un rango de fechas, excluir las que tengan `Reserva` con rango solapado.
3. **Sesión**: cookie auth con timeout de 30 min.
4. **Mensajes de error** claros y en español.
5. **Seed data**: las 4 sedes de muestra (Villeta, El Placer, Suramericana, Reina 1) con sus habitaciones.

## Entregables
1. Proyecto compilable con `dotnet run`.
2. Migración EF Core inicial + seed.
3. README con instrucciones para levantar el proyecto y credenciales de prueba.
4. Los Views deben verse **pixel-similar** al prototipo de referencia.

Empieza por: (1) crear el proyecto y modelos, (2) DbContext + migración + seed, (3) Layout compartido con header/nav/footer copiando estilos, (4) Login con teclado dinámico, (5) resto de pantallas. Después de cada paso muéstrame qué hiciste antes de continuar.
