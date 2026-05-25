using FondoXYZ.Domain.Interfaces;
using MailKit.Net.Smtp;
using MailKit.Security;
using Microsoft.Extensions.Configuration;
using MimeKit;

namespace FondoXYZ.Business.Services;

public class EmailService : IEmailService
{
    private readonly IConfiguration _config;

    public EmailService(IConfiguration config) => _config = config;

    public async Task SendPasswordResetEmailAsync(string toEmail, string userName, string resetLink)
    {
        var subject = "Recuperación de contraseña — Fondo XYZ";
        var body = $"""
            <h2>Recuperación de contraseña</h2>
            <p>Hola {userName},</p>
            <p>Recibimos una solicitud para restablecer tu contraseña.</p>
            <p><a href="{resetLink}" style="background:#1a73e8;color:#fff;padding:10px 20px;text-decoration:none;border-radius:4px;">Restablecer contraseña</a></p>
            <p>Si no solicitaste este cambio, ignora este mensaje.</p>
            <p>Este enlace expira en 24 horas.</p>
            """;

        await SendAsync(toEmail, subject, body);
    }

    public async Task SendReservaConfirmacionAsync(string toEmail, string userName,
        int reservaId, string alojamiento, DateOnly inicio, DateOnly fin, decimal total)
    {
        var noches = fin.DayNumber - inicio.DayNumber;
        var subject = $"Confirmación reserva #{reservaId} — Fondo XYZ";
        var body = $"""
            <h2>Reserva confirmada ✔</h2>
            <p>Hola {userName},</p>
            <table>
              <tr><td><strong>Reserva #</strong></td><td>{reservaId}</td></tr>
              <tr><td><strong>Alojamiento</strong></td><td>{alojamiento}</td></tr>
              <tr><td><strong>Llegada</strong></td><td>{inicio:dd/MM/yyyy}</td></tr>
              <tr><td><strong>Salida</strong></td><td>{fin:dd/MM/yyyy}</td></tr>
              <tr><td><strong>Noches</strong></td><td>{noches}</td></tr>
              <tr><td><strong>Total</strong></td><td>${total:N0}</td></tr>
            </table>
            <p>Gracias por reservar con Fondo XYZ.</p>
            """;

        await SendAsync(toEmail, subject, body);
    }

    private async Task SendAsync(string toEmail, string subject, string htmlBody)
    {
        var settings = _config.GetSection("EmailSettings");
        var fromEmail = settings["FromEmail"] ?? throw new InvalidOperationException("EmailSettings:FromEmail not configured.");
        var smtpServer = settings["SmtpServer"] ?? throw new InvalidOperationException("EmailSettings:SmtpServer not configured.");
        var username   = settings["Username"]   ?? throw new InvalidOperationException("EmailSettings:Username not configured.");
        var password   = settings["Password"]   ?? throw new InvalidOperationException("EmailSettings:Password not configured.");

        var message = new MimeMessage();
        message.From.Add(MailboxAddress.Parse(fromEmail));
        message.To.Add(MailboxAddress.Parse(toEmail));
        message.Subject = subject;
        message.Body = new TextPart("html") { Text = htmlBody };

        using var client = new SmtpClient();
        await client.ConnectAsync(smtpServer, int.Parse(settings["SmtpPort"]!), SecureSocketOptions.StartTls);
        await client.AuthenticateAsync(username, password);
        await client.SendAsync(message);
        await client.DisconnectAsync(true);
    }
}
