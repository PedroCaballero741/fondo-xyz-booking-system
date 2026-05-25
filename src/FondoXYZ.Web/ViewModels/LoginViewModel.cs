using System.ComponentModel.DataAnnotations;

namespace FondoXYZ.Web.ViewModels;

public class LoginViewModel
{
    [Required(ErrorMessage = "Ingrese su número de documento")]
    public string NumeroDocumento { get; set; } = "";

    [Required(ErrorMessage = "Ingrese su clave")]
    [StringLength(4, MinimumLength = 4, ErrorMessage = "La clave debe tener 4 dígitos")]
    public string Clave { get; set; } = "";
}
