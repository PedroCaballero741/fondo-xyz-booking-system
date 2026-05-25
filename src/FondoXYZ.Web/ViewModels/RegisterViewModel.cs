using System.ComponentModel.DataAnnotations;

namespace FondoXYZ.Web.ViewModels;

public class RegisterViewModel
{
    [Required(ErrorMessage = "Ingrese su número de documento")]
    public string NumeroDocumento { get; set; } = "";

    [Required(ErrorMessage = "Ingrese su nombre completo")]
    public string NombreCompleto { get; set; } = "";

    public DateOnly? FechaNacimiento { get; set; }

    [Required(ErrorMessage = "Ingrese su celular")]
    public string Celular { get; set; } = "";

    [Required(ErrorMessage = "Ingrese su correo electrónico")]
    [EmailAddress(ErrorMessage = "Correo electrónico inválido")]
    public string Email { get; set; } = "";

    public string? Departamento { get; set; }
    public string? Municipio { get; set; }
    public string? Barrio { get; set; }
    public string? DireccionResidencia { get; set; }
    public string? TelefonoResidencia { get; set; }
    public string? PreguntaSecreta { get; set; }
    public string? RespuestaSecreta { get; set; }
    public bool AutorizaEnvioCorreo { get; set; }
    public bool AutorizaEnvioCelular { get; set; }

    [Required(ErrorMessage = "Ingrese su clave de 4 dígitos")]
    [StringLength(4, MinimumLength = 4, ErrorMessage = "La clave debe tener exactamente 4 dígitos")]
    public string Clave { get; set; } = "";

    [Required(ErrorMessage = "Confirme su clave")]
    [Compare(nameof(Clave), ErrorMessage = "Las claves no coinciden")]
    public string ConfirmarClave { get; set; } = "";
}
