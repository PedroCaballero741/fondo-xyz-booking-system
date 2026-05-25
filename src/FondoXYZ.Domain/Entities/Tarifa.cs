namespace FondoXYZ.Domain.Entities;

public class Tarifa
{
    public int Id { get; set; }
    public string Nombre { get; set; } = string.Empty;
    public string? Sede { get; set; }
    public string TipoSede { get; set; } = string.Empty;
    public string? Temporada { get; set; }
    public int? NumHabitaciones { get; set; }
    public int? PersonasMax { get; set; }
    public decimal PrecioNoche { get; set; }
}
