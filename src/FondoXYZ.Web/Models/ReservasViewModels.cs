using System.ComponentModel.DataAnnotations;
using FondoXYZ.Domain.Entities;
using FondoXYZ.Domain.Interfaces;

namespace FondoXYZ.Web.Models;

public class ConsultaDisponibilidadViewModel
{
    [Required, DataType(DataType.Date), Display(Name = "Fecha llegada")]
    public DateOnly FechaInicio { get; set; } = DateOnly.FromDateTime(DateTime.Today.AddDays(1));

    [Required, DataType(DataType.Date), Display(Name = "Fecha salida")]
    public DateOnly FechaFin { get; set; } = DateOnly.FromDateTime(DateTime.Today.AddDays(3));

    [Range(1, 50), Display(Name = "Número de personas")]
    public int? NumeroPersonas { get; set; }

    [Display(Name = "Sede")]
    public int? SedeId { get; set; }

    public IEnumerable<Sede> Sedes { get; set; } = [];
    public IEnumerable<AlojamientoDisponibleDto> Resultados { get; set; } = [];
    public bool Buscado { get; set; }
}

public class TarifasViewModel
{
    public int AlojamientoId { get; set; }
    public string NombreAlojamiento { get; set; } = string.Empty;
    public string NombreSede { get; set; } = string.Empty;
    public DateOnly FechaInicio { get; set; }
    public DateOnly FechaFin { get; set; }
    public int NumPersonas { get; set; }
    public CostoReservaDto? Costo { get; set; }
}

public class CrearReservaViewModel
{
    [Required]
    public int AlojamientoId { get; set; }

    [Required, DataType(DataType.Date)]
    public DateOnly FechaInicio { get; set; }

    [Required, DataType(DataType.Date)]
    public DateOnly FechaFin { get; set; }

    [Required, Range(1, 50, ErrorMessage = "Ingrese entre 1 y 50 personas.")]
    public int NumPersonas { get; set; }

    [Required]
    public decimal CostoTotal { get; set; }

    public string? Notas { get; set; }

    // solo para mostrar en la vista, no se guarda
    public string NombreAlojamiento { get; set; } = string.Empty;
    public string NombreSede { get; set; } = string.Empty;
}
