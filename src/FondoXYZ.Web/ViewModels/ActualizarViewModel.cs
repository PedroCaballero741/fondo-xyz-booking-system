using System.ComponentModel.DataAnnotations;

namespace FondoXYZ.Web.ViewModels;

public class ActualizarViewModel
{
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

    // dejar vacio si no quiere cambiar la clave
    [StringLength(4, MinimumLength = 4, ErrorMessage = "La clave debe tener exactamente 4 dígitos")]
    public string? NuevaClave { get; set; }

    [Compare(nameof(NuevaClave), ErrorMessage = "Las claves no coinciden")]
    public string? ConfirmarNuevaClave { get; set; }
}
