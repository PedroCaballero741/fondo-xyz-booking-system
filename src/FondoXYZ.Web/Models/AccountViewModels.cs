using System.ComponentModel.DataAnnotations;

namespace FondoXYZ.Web.Models;

public class LoginViewModel
{
    [Required, EmailAddress, Display(Name = "Correo electrónico")]
    public string Email { get; set; } = string.Empty;

    [Required, DataType(DataType.Password), Display(Name = "Contraseña")]
    public string Password { get; set; } = string.Empty;

    [Display(Name = "Recordarme")]
    public bool RememberMe { get; set; }
}

public class RegisterViewModel
{
    [Required, Display(Name = "Nombre completo")]
    public string Nombre { get; set; } = string.Empty;

    [Required, EmailAddress, Display(Name = "Correo electrónico")]
    public string Email { get; set; } = string.Empty;

    [Required, DataType(DataType.Password), Display(Name = "Contraseña"),
     MinLength(6, ErrorMessage = "Mínimo 6 caracteres.")]
    public string Password { get; set; } = string.Empty;

    [Required, DataType(DataType.Password), Display(Name = "Confirmar contraseña"),
     Compare(nameof(Password), ErrorMessage = "Las contraseñas no coinciden.")]
    public string ConfirmPassword { get; set; } = string.Empty;
}

public class ForgotPasswordViewModel
{
    [Required, EmailAddress, Display(Name = "Correo electrónico")]
    public string Email { get; set; } = string.Empty;
}

public class ResetPasswordViewModel
{
    [Required]
    public string Token { get; set; } = string.Empty;

    [Required, EmailAddress]
    public string Email { get; set; } = string.Empty;

    [Required, DataType(DataType.Password), MinLength(6)]
    public string Password { get; set; } = string.Empty;

    [DataType(DataType.Password),
     Compare(nameof(Password), ErrorMessage = "Las contraseñas no coinciden.")]
    public string ConfirmPassword { get; set; } = string.Empty;
}
