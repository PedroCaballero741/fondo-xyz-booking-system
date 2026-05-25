namespace FondoXYZ.Web.ViewModels;

public class SedeViewModel
{
    public int Id { get; set; }
    public string Nombre { get; set; } = "";
    public string Ciudad { get; set; } = "";
    public string TipoSede { get; set; } = "";
    public int NumAlojamientos { get; set; }
    public string? Descripcion { get; set; }
}
