using FondoXYZ.Data.Context;
using FondoXYZ.Domain.Entities;
using FondoXYZ.Domain.Interfaces;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;

namespace FondoXYZ.Data.Repositories;

public class AlojamientoRepository : IAlojamientoRepository
{
    private readonly FondoXYZContext _ctx;

    public AlojamientoRepository(FondoXYZContext ctx) => _ctx = ctx;

    public async Task<IEnumerable<AlojamientoDisponibleDto>> BuscarDisponibilidadAsync(DateOnly inicio, DateOnly fin, int? sedeId)
    {
        var p = BuildParams(inicio, fin, sedeId: sedeId);
        var sql = sedeId.HasValue
            ? "EXEC sp_BuscarDisponibilidad @FechaInicio, @FechaFin, @SedeId"
            : "EXEC sp_BuscarDisponibilidad @FechaInicio, @FechaFin";

        var rows = await _ctx.AlojamientosDisponibles.FromSqlRaw(sql, p).ToListAsync();
        return rows.Select(Map);
    }

    public async Task<IEnumerable<AlojamientoDisponibleDto>> BuscarDisponibilidadPersonasAsync(DateOnly inicio, DateOnly fin, int numPersonas, int? sedeId)
    {
        var p = BuildParams(inicio, fin, numPersonas, sedeId);
        var sql = sedeId.HasValue
            ? "EXEC sp_BuscarDisponibilidadPersonas @FechaInicio, @FechaFin, @NumeroPersonas, @SedeId"
            : "EXEC sp_BuscarDisponibilidadPersonas @FechaInicio, @FechaFin, @NumeroPersonas";

        var rows = await _ctx.AlojamientosDisponibles.FromSqlRaw(sql, p).ToListAsync();
        return rows.Select(Map);
    }

    public async Task<IEnumerable<TarifaDto>> ConsultarTarifasAsync(int alojamientoId, DateOnly fecha, int numPersonas)
    {
        var rows = await _ctx.TarifasResult.FromSqlRaw(
            "EXEC sp_ConsultarTarifas @AlojamientoId, @Fecha, @NumeroPersonas",
            new SqlParameter("@AlojamientoId", alojamientoId),
            new SqlParameter("@Fecha", fecha.ToDateTime(TimeOnly.MinValue)),
            new SqlParameter("@NumeroPersonas", numPersonas)
        ).ToListAsync();

        return rows.Select(r => new TarifaDto(r.TarifaId, r.Tarifa, r.Temporada, r.PersonasMax,
            r.NumHabitaciones, r.PrecioBaseNoche, r.CostoPersonasAdicionales, r.TotalNoche,
            r.Fecha, r.DiaSemana));
    }

    public async Task<CostoReservaDto> CalcularCostoAsync(int alojamientoId, DateOnly inicio, DateOnly fin, int numPersonas)
    {
        var p = new[]
        {
            new SqlParameter("@AlojamientoId", alojamientoId),
            new SqlParameter("@FechaInicio", inicio.ToDateTime(TimeOnly.MinValue)),
            new SqlParameter("@FechaFin", fin.ToDateTime(TimeOnly.MinValue)),
            new SqlParameter("@NumeroPersonas", numPersonas)
        };

        var detalle = await _ctx.CostosDetalle
            .FromSqlRaw("EXEC sp_CalcularCostoReserva @AlojamientoId, @FechaInicio, @FechaFin, @NumeroPersonas", p)
            .ToListAsync();

        // EF solo agarra el primer result set del SP, el resumen lo calculamos a mano
        var resumen = new CostoResumenResult
        {
            AlojamientoId  = alojamientoId,
            FechaInicio    = inicio,
            FechaFin       = fin,
            NumNoches      = detalle.Count,
            NumPersonas    = numPersonas,
            TotalBase      = detalle.Sum(d => d.PrecioBase),
            TotalAdicionales = detalle.Sum(d => d.PersonasAdicionales),
            CostoTotal     = detalle.Sum(d => d.TotalNoche)
        };

        return new CostoReservaDto(
            resumen.AlojamientoId, resumen.FechaInicio, resumen.FechaFin,
            resumen.NumNoches, resumen.NumPersonas,
            resumen.TotalBase, resumen.TotalAdicionales, resumen.CostoTotal,
            detalle.Select(d => new DetalleNocheDto(d.Fecha, d.DiaSemana, d.Temporada,
                d.PrecioBase, d.PersonasAdicionales, d.TotalNoche))
        );
    }

    public async Task<IEnumerable<Sede>> ObtenerSedesAsync() =>
        await _ctx.Sedes.Where(s => s.Activo).OrderBy(s => s.Nombre).ToListAsync();

    public async Task<Alojamiento?> ObtenerPorIdAsync(int id) =>
        await _ctx.Alojamientos
            .Include(a => a.Sede)
            .Include(a => a.Caracteristica)
            .Include(a => a.Dormitorios)
            .FirstOrDefaultAsync(a => a.Id == id && a.Activo);

    private static AlojamientoDisponibleDto Map(AlojamientoDisponibleResult r) =>
        new(r.AlojamientoId, r.Alojamiento, r.SedeId, r.Sede, r.Ciudad,
            r.TipoSede, r.Bloque, r.NumHabitaciones, r.CapacidadMaxima, r.CapacidadBloque);

    private static SqlParameter[] BuildParams(DateOnly inicio, DateOnly fin,
        int? numPersonas = null, int? sedeId = null)
    {
        var list = new List<SqlParameter>
        {
            new("@FechaInicio", inicio.ToDateTime(TimeOnly.MinValue)),
            new("@FechaFin",    fin.ToDateTime(TimeOnly.MinValue))
        };
        if (numPersonas.HasValue) list.Add(new("@NumeroPersonas", numPersonas.Value));
        if (sedeId.HasValue)      list.Add(new("@SedeId", sedeId.Value));
        return [.. list];
    }
}
