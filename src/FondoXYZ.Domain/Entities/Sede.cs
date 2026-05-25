namespace FondoXYZ.Domain.Entities;

public class Sede
{
    public int Id { get; set; }
    public string Nombre { get; set; } = string.Empty;
    public string NombreOficial { get; set; } = string.Empty;
    public string Ciudad { get; set; } = string.Empty;
    public string TipoSede { get; set; } = string.Empty; // sede_recreativa | apartamento
    public int? CapacidadTotal { get; set; }
    public bool Activo { get; set; } = true;

    public ICollection<Alojamiento> Alojamientos { get; set; } = [];
}
