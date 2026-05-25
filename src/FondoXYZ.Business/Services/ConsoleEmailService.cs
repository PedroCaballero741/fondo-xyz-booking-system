using FondoXYZ.Domain.Interfaces;
using Microsoft.Extensions.Logging;

namespace FondoXYZ.Business.Services;

// solo para dev, en vez de mandar el correo lo imprime en consola
// para activarlo: EmailSettings:Provider = "Console" en appsettings.Development.json
public class ConsoleEmailService : IEmailService
{
    private readonly ILogger<ConsoleEmailService> _logger;

    public ConsoleEmailService(ILogger<ConsoleEmailService> logger) => _logger = logger;

    public Task SendPasswordResetEmailAsync(string toEmail, string userName, string resetLink)
    {
        _logger.LogInformation(
            "[DEV EMAIL] Recuperación de contraseña → {To}\nUsuario: {User}\nEnlace: {Link}",
            toEmail, userName, resetLink);
        return Task.CompletedTask;
    }

    public Task SendReservaConfirmacionAsync(string toEmail, string userName,
        int reservaId, string alojamiento, DateOnly inicio, DateOnly fin, decimal total)
    {
        _logger.LogInformation(
            "[DEV EMAIL] Confirmación reserva #{Id} → {To}\nAlojamiento: {Aloj}\n{Ini} → {Fin}\nTotal: ${Total:N0}",
            reservaId, toEmail, alojamiento, inicio, fin, total);
        return Task.CompletedTask;
    }
}
