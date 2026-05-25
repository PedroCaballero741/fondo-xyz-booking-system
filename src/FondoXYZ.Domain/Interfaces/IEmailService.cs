namespace FondoXYZ.Domain.Interfaces;

public interface IEmailService
{
    Task SendPasswordResetEmailAsync(string toEmail, string userName, string resetLink);
    Task SendReservaConfirmacionAsync(string toEmail, string userName, int reservaId, string alojamiento, DateOnly inicio, DateOnly fin, decimal total);
}
