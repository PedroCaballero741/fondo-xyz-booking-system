using FondoXYZ.Domain.Entities;

namespace FondoXYZ.Domain.Interfaces;

public interface IAlojamientoRepository
{
    Task<IEnumerable<AlojamientoDisponibleDto>> BuscarDisponibilidadAsync(DateOnly inicio, DateOnly fin, int? sedeId);
    Task<IEnumerable<AlojamientoDisponibleDto>> BuscarDisponibilidadPersonasAsync(DateOnly inicio, DateOnly fin, int numPersonas, int? sedeId);
    Task<IEnumerable<TarifaDto>> ConsultarTarifasAsync(int alojamientoId, DateOnly fecha, int numPersonas);
    Task<CostoReservaDto> CalcularCostoAsync(int alojamientoId, DateOnly inicio, DateOnly fin, int numPersonas);
    Task<IEnumerable<Sede>> ObtenerSedesAsync();
    Task<Alojamiento?> ObtenerPorIdAsync(int id);
}

public record AlojamientoDisponibleDto(
    int AlojamientoId,
    string Alojamiento,
    int SedeId,
    string Sede,
    string Ciudad,
    string TipoSede,
    string Bloque,
    int NumHabitaciones,
    int? CapacidadMaxima,
    int? CapacidadBloque
);

public record TarifaDto(
    int TarifaId,
    string Tarifa,
    string? Temporada,
    int? PersonasMax,
    int? NumHabitaciones,
    decimal PrecioBaseNoche,
    decimal CostoPersonasAdicionales,
    decimal TotalNoche,
    DateOnly Fecha,
    string DiaSemana
);

public record CostoReservaDto(
    int AlojamientoId,
    DateOnly FechaInicio,
    DateOnly FechaFin,
    int NumNoches,
    int NumPersonas,
    decimal TotalBase,
    decimal TotalAdicionales,
    decimal CostoTotal,
    IEnumerable<DetalleNocheDto> Detalle
);

public record DetalleNocheDto(
    DateOnly Fecha,
    string DiaSemana,
    string? Temporada,
    decimal PrecioBase,
    decimal PersonasAdicionales,
    decimal TotalNoche
);
