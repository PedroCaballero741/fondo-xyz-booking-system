namespace FondoXYZ.Domain.Entities;

public class Dormitorio
{
    public int Id { get; set; }
    public int AlojamientoId { get; set; }
    public int Numero { get; set; }
    public int CamasDobles { get; set; }
    public int CamasSencillas { get; set; }
    public int Camarotes { get; set; }
    public int CamasGemelas { get; set; }
    public int CamasAuxiliares { get; set; }

    public Alojamiento Alojamiento { get; set; } = null!;
}
