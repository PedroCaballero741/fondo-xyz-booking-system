namespace FondoXYZ.Domain.Entities;

public class Reserva
{
    public int Id { get; set; }
    public string UsuarioId { get; set; } = string.Empty;
    public int AlojamientoId { get; set; }
    public DateOnly FechaInicio { get; set; }
    public DateOnly FechaFin { get; set; }
    public int NumPersonas { get; set; }
    public decimal CostoTotal { get; set; }
    public string Estado { get; set; } = "pendiente"; // pendiente | confirmada | cancelada
    public DateTime FechaCreacion { get; set; } = DateTime.UtcNow;
    public string? Notas { get; set; }

    public Alojamiento Alojamiento { get; set; } = null!;
    public ICollection<DetalleReserva> Detalles { get; set; } = [];
}
