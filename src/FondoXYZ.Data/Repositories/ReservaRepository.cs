using FondoXYZ.Data.Context;
using FondoXYZ.Domain.Entities;
using FondoXYZ.Domain.Interfaces;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;

namespace FondoXYZ.Data.Repositories;

public class ReservaRepository : IReservaRepository
{
    private readonly FondoXYZContext _ctx;

    public ReservaRepository(FondoXYZContext ctx) => _ctx = ctx;

    public async Task<Reserva> CrearAsync(string usuarioId, int alojamientoId,
        DateOnly inicio, DateOnly fin, int numPersonas, decimal costoTotal, string? notas)
    {
        var p = new[]
        {
            new SqlParameter("@UsuarioId",      usuarioId),
            new SqlParameter("@AlojamientoId",  alojamientoId),
            new SqlParameter("@FechaInicio",    inicio.ToDateTime(TimeOnly.MinValue)),
            new SqlParameter("@FechaFin",       fin.ToDateTime(TimeOnly.MinValue)),
            new SqlParameter("@NumeroPersonas", numPersonas),
            new SqlParameter("@CostoTotal",     costoTotal),
            new SqlParameter("@Notas",          (object?)notas ?? DBNull.Value)
        };

        // SP retorna la reserva creada como result set
        var result = await _ctx.Reservas.FromSqlRaw(
            "EXEC sp_CrearReserva @UsuarioId, @AlojamientoId, @FechaInicio, @FechaFin, @NumeroPersonas, @CostoTotal, @Notas",
            p
        ).ToListAsync();

        return result.First();
    }

    public async Task<IEnumerable<Reserva>> ObtenerPorUsuarioAsync(string usuarioId) =>
        await _ctx.Reservas
            .Include(r => r.Alojamiento).ThenInclude(a => a.Sede)
            .Include(r => r.Detalles)
            .Where(r => r.UsuarioId == usuarioId)
            .OrderByDescending(r => r.FechaCreacion)
            .ToListAsync();

    public async Task<Reserva?> ObtenerPorIdAsync(int id) =>
        await _ctx.Reservas
            .Include(r => r.Alojamiento).ThenInclude(a => a.Sede)
            .Include(r => r.Detalles)
            .FirstOrDefaultAsync(r => r.Id == id);

    public async Task<bool> CancelarAsync(int id, string usuarioId)
    {
        var reserva = await _ctx.Reservas
            .FirstOrDefaultAsync(r => r.Id == id && r.UsuarioId == usuarioId && r.Estado != "cancelada");

        if (reserva is null) return false;

        reserva.Estado = "cancelada";
        await _ctx.SaveChangesAsync();
        return true;
    }
}
