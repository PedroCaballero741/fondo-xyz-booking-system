namespace FondoXYZ.Domain.Entities;

public class DetalleReserva
{
    public int Id { get; set; }
    public int ReservaId { get; set; }
    public string Concepto { get; set; } = string.Empty;
    public decimal Monto { get; set; }

    public Reserva Reserva { get; set; } = null!;
}
