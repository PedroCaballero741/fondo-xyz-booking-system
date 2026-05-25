using FondoXYZ.Domain.Entities;
using FondoXYZ.Domain.Models;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;

namespace FondoXYZ.Data.Context;

public class FondoXYZContext : IdentityDbContext<ApplicationUser>
{
    public FondoXYZContext(DbContextOptions<FondoXYZContext> options) : base(options) { }

    public DbSet<Sede> Sedes => Set<Sede>();
    public DbSet<Alojamiento> Alojamientos => Set<Alojamiento>();
    public DbSet<Dormitorio> Dormitorios => Set<Dormitorio>();
    public DbSet<Caracteristica> Caracteristicas => Set<Caracteristica>();
    public DbSet<Tarifa> Tarifas => Set<Tarifa>();
    public DbSet<Reserva> Reservas => Set<Reserva>();
    public DbSet<DetalleReserva> DetallesReserva => Set<DetalleReserva>();

    public DbSet<AlojamientoDisponibleResult> AlojamientosDisponibles => Set<AlojamientoDisponibleResult>();
    public DbSet<TarifaResult> TarifasResult => Set<TarifaResult>();
    public DbSet<CostoDetalleResult> CostosDetalle => Set<CostoDetalleResult>();
    public DbSet<CostoResumenResult> CostosResumen => Set<CostoResumenResult>();

    protected override void OnModelCreating(ModelBuilder builder)
    {
        base.OnModelCreating(builder);

        builder.Entity<Sede>(e => {
            e.ToTable("Sede");
            e.Property(x => x.TipoSede).HasMaxLength(20);
        });

        builder.Entity<Alojamiento>(e => {
            e.ToTable("Alojamiento");
            e.HasOne(x => x.Sede).WithMany(s => s.Alojamientos).HasForeignKey(x => x.SedeId);
            e.HasOne(x => x.Caracteristica).WithOne(c => c.Alojamiento).HasForeignKey<Caracteristica>(c => c.AlojamientoId);
            e.HasMany(x => x.Dormitorios).WithOne(d => d.Alojamiento).HasForeignKey(d => d.AlojamientoId);
        });

        builder.Entity<Dormitorio>(e => e.ToTable("Dormitorio"));
        builder.Entity<Caracteristica>(e => e.ToTable("Caracteristica"));
        builder.Entity<Tarifa>(e => e.ToTable("Tarifa"));

        builder.Entity<Reserva>(e => {
            e.ToTable("Reserva");
            e.HasOne(x => x.Alojamiento).WithMany(a => a.Reservas).HasForeignKey(x => x.AlojamientoId);
            e.HasMany(x => x.Detalles).WithOne(d => d.Reserva).HasForeignKey(d => d.ReservaId);
            e.Property(x => x.FechaInicio).HasColumnType("date");
            e.Property(x => x.FechaFin).HasColumnType("date");
        });

        builder.Entity<DetalleReserva>(e => e.ToTable("DetalleReserva"));

        // sin tabla propia, solo se usan para mapear resultados de SPs
        builder.Entity<AlojamientoDisponibleResult>().HasNoKey().ToView(null);
        builder.Entity<TarifaResult>().HasNoKey().ToView(null);
        builder.Entity<CostoDetalleResult>().HasNoKey().ToView(null);
        builder.Entity<CostoResumenResult>().HasNoKey().ToView(null);
    }
}

public class AlojamientoDisponibleResult
{
    public int AlojamientoId { get; set; }
    public string Alojamiento { get; set; } = string.Empty;
    public int SedeId { get; set; }
    public string Sede { get; set; } = string.Empty;
    public string Ciudad { get; set; } = string.Empty;
    public string TipoSede { get; set; } = string.Empty;
    public string Bloque { get; set; } = string.Empty;
    public int NumHabitaciones { get; set; }
    public int? CapacidadMaxima { get; set; }
    public int? CapacidadBloque { get; set; }
}

public class TarifaResult
{
    public int TarifaId { get; set; }
    public string Tarifa { get; set; } = string.Empty;
    public string? Temporada { get; set; }
    public int? PersonasMax { get; set; }
    public int? NumHabitaciones { get; set; }
    public decimal PrecioBaseNoche { get; set; }
    public decimal CostoPersonasAdicionales { get; set; }
    public decimal TotalNoche { get; set; }
    public DateOnly Fecha { get; set; }
    public string DiaSemana { get; set; } = string.Empty;
}

public class CostoDetalleResult
{
    public DateOnly Fecha { get; set; }
    public string DiaSemana { get; set; } = string.Empty;
    public string? Temporada { get; set; }
    public decimal PrecioBase { get; set; }
    public decimal PersonasAdicionales { get; set; }
    public decimal TotalNoche { get; set; }
}

public class CostoResumenResult
{
    public int AlojamientoId { get; set; }
    public DateOnly FechaInicio { get; set; }
    public DateOnly FechaFin { get; set; }
    public int NumNoches { get; set; }
    public int NumPersonas { get; set; }
    public decimal TotalBase { get; set; }
    public decimal TotalAdicionales { get; set; }
    public decimal CostoTotal { get; set; }
}
