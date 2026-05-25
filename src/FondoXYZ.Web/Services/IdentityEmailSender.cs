using FondoXYZ.Domain.Interfaces;
using FondoXYZ.Domain.Models;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Identity.UI.Services;

namespace FondoXYZ.Web.Services;

// Identity exige esta interfaz para enviar correos internamente (confirmacion, reset, etc)
// la enganchamos a nuestro IEmailService para no tener dos sistemas de email
public class IdentityEmailSender : IEmailSender<ApplicationUser>, IEmailSender
{
    private readonly IEmailService _emailService;

    public IdentityEmailSender(IEmailService emailService) => _emailService = emailService;

    public Task SendConfirmationLinkAsync(ApplicationUser user, string email, string confirmationLink) =>
        _emailService.SendPasswordResetEmailAsync(email, user.NombreCompleto.Length > 0 ? user.NombreCompleto : email, confirmationLink);

    public Task SendPasswordResetLinkAsync(ApplicationUser user, string email, string resetLink) =>
        _emailService.SendPasswordResetEmailAsync(email, user.NombreCompleto.Length > 0 ? user.NombreCompleto : email, resetLink);

    public Task SendPasswordResetCodeAsync(ApplicationUser user, string email, string resetCode) =>
        _emailService.SendPasswordResetEmailAsync(email, user.NombreCompleto.Length > 0 ? user.NombreCompleto : email, resetCode);

    // interfaz legacy de Identity, igual la necesitamos
    public Task SendEmailAsync(string email, string subject, string htmlMessage) =>
        _emailService.SendPasswordResetEmailAsync(email, email, htmlMessage);
}
