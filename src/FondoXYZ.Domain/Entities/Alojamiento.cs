namespace FondoXYZ.Domain.Entities;

public class Alojamiento
{
    public int Id { get; set; }
    public int SedeId { get; set; }
    public int Numero { get; set; }
    public string Nombre { get; set; } = string.Empty;
    public string Bloque { get; set; } = "principal"; // principal | cabanas | bloque_nuevo
    public string? TipoCabana { get; set; }
    public int NumHabitaciones { get; set; } = 1;
    public int? CapacidadMaxima { get; set; }
    public int? CapacidadBloque { get; set; }
    public bool Activo { get; set; } = true;

    public Sede Sede { get; set; } = null!;
    public Caracteristica? Caracteristica { get; set; }
    public ICollection<Dormitorio> Dormitorios { get; set; } = [];
    public ICollection<Reserva> Reservas { get; set; } = [];
}
