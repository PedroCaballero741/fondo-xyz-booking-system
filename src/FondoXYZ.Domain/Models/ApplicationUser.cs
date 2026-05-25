using Microsoft.AspNetCore.Identity;
namespace FondoXYZ.Domain.Models;
public class ApplicationUser : IdentityUser
{
    public string NumeroDocumento { get; set; } = "";
    public string NombreCompleto { get; set; } = "";
    public DateOnly? FechaNacimiento { get; set; }
    public string? Celular { get; set; }
    public string? Departamento { get; set; }
    public string? Municipio { get; set; }
    public string? Barrio { get; set; }
    public string? DireccionResidencia { get; set; }
    public string? TelefonoResidencia { get; set; }
    public string? PreguntaSecreta { get; set; }
    public string? RespuestaSecreta { get; set; }
    public bool AutorizaEnvioCorreo { get; set; }
    public bool AutorizaEnvioCelular { get; set; }
}
