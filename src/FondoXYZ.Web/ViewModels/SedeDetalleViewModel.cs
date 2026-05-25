using FondoXYZ.Domain.Entities;
using FondoXYZ.Domain.Interfaces;

namespace FondoXYZ.Web.ViewModels;

public class SedeDetalleViewModel
{
    public Sede Sede { get; set; } = null!;
    public IEnumerable<Alojamiento> Alojamientos { get; set; } = [];
    public IEnumerable<Tarifa> Tarifas { get; set; } = [];

    public DateOnly FechaInicio { get; set; } = DateOnly.FromDateTime(DateTime.Today.AddDays(1));
    public DateOnly FechaFin { get; set; } = DateOnly.FromDateTime(DateTime.Today.AddDays(3));
    public int NumPersonas { get; set; } = 1;

    public IEnumerable<AlojamientoDisponibleDto> Disponibles { get; set; } = [];
    public bool BuscadoDisponibilidad { get; set; }

    public CostoReservaDto? Costo { get; set; }
    public int? AlojamientoSeleccionadoId { get; set; }
}
