namespace FondoXYZ.Domain.Entities;

public class Caracteristica
{
    public int Id { get; set; }
    public int AlojamientoId { get; set; }
    public string? TipoCocina { get; set; }
    public int NumBanos { get; set; } = 1;
    public bool BanoPrivado { get; set; }
    public bool TieneTelevIsor { get; set; }
    public bool TieneNevera { get; set; }
    public bool TieneSofaCama { get; set; }
    public bool TieneTerraza { get; set; }
    public bool TerrazaCubierta { get; set; }
    public bool TieneComedor { get; set; }
    public bool TieneSalaEstar { get; set; }
    public bool TieneParqueo { get; set; }

    public Alojamiento Alojamiento { get; set; } = null!;
}
