using FondoXYZ.Domain.Entities;

namespace FondoXYZ.Domain.Interfaces;

public interface IReservaRepository
{
    Task<Reserva> CrearAsync(string usuarioId, int alojamientoId, DateOnly inicio, DateOnly fin, int numPersonas, decimal costoTotal, string? notas);
    Task<IEnumerable<Reserva>> ObtenerPorUsuarioAsync(string usuarioId);
    Task<Reserva?> ObtenerPorIdAsync(int id);
    Task<bool> CancelarAsync(int id, string usuarioId);
}
