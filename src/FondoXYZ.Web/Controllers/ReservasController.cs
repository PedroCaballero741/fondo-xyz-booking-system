using FondoXYZ.Domain.Interfaces;
using FondoXYZ.Domain.Models;
using FondoXYZ.Web.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;

namespace FondoXYZ.Web.Controllers;

[Authorize]
public class ReservasController : Controller
{
    private readonly IAlojamientoRepository _alojamientos;
    private readonly IReservaRepository _reservas;
    private readonly IEmailService _email;
    private readonly UserManager<ApplicationUser> _users;

    public ReservasController(IAlojamientoRepository alojamientos,
        IReservaRepository reservas, IEmailService email,
        UserManager<ApplicationUser> users)
    {
        _alojamientos = alojamientos;
        _reservas = reservas;
        _email = email;
        _users = users;
    }

    public async Task<IActionResult> Index()
    {
        ViewData["ActiveTab"] = "reservas";
        var userId = _users.GetUserId(User)!;
        var lista = await _reservas.ObtenerPorUsuarioAsync(userId);
        return View(lista);
    }

    [AllowAnonymous]
    [HttpGet]
    public async Task<IActionResult> Consultar()
    {
        var vm = new ConsultaDisponibilidadViewModel
        {
            Sedes = await _alojamientos.ObtenerSedesAsync()
        };
        return View(vm);
    }

    [AllowAnonymous]
    [HttpPost, ValidateAntiForgeryToken]
    public async Task<IActionResult> Consultar(ConsultaDisponibilidadViewModel model)
    {
        model.Sedes = await _alojamientos.ObtenerSedesAsync();

        if (!ModelState.IsValid) return View(model);

        if (model.FechaFin <= model.FechaInicio)
        {
            ModelState.AddModelError(nameof(model.FechaFin), "La fecha de salida debe ser posterior a la de llegada.");
            return View(model);
        }

        model.Resultados = model.NumeroPersonas.HasValue
            ? await _alojamientos.BuscarDisponibilidadPersonasAsync(
                model.FechaInicio, model.FechaFin, model.NumeroPersonas.Value, model.SedeId)
            : await _alojamientos.BuscarDisponibilidadAsync(
                model.FechaInicio, model.FechaFin, model.SedeId);

        model.Buscado = true;
        return View(model);
    }

    [HttpGet]
    public async Task<IActionResult> Tarifas(int alojamientoId, DateOnly fechaInicio,
        DateOnly fechaFin, int numPersonas)
    {
        var aloj = await _alojamientos.ObtenerPorIdAsync(alojamientoId);
        if (aloj is null) return NotFound();

        var costo = await _alojamientos.CalcularCostoAsync(alojamientoId, fechaInicio, fechaFin, numPersonas);

        var vm = new TarifasViewModel
        {
            AlojamientoId     = alojamientoId,
            NombreAlojamiento = aloj.Nombre,
            NombreSede        = aloj.Sede.NombreOficial,
            FechaInicio       = fechaInicio,
            FechaFin          = fechaFin,
            NumPersonas       = numPersonas,
            Costo             = costo
        };

        return View(vm);
    }

    [HttpGet]
    public async Task<IActionResult> Create(int alojamientoId, DateOnly fechaInicio,
        DateOnly fechaFin, int numPersonas, decimal costoTotal)
    {
        var aloj = await _alojamientos.ObtenerPorIdAsync(alojamientoId);
        if (aloj is null) return NotFound();

        var vm = new CrearReservaViewModel
        {
            AlojamientoId     = alojamientoId,
            FechaInicio       = fechaInicio,
            FechaFin          = fechaFin,
            NumPersonas       = numPersonas,
            CostoTotal        = costoTotal,
            NombreAlojamiento = aloj.Nombre,
            NombreSede        = aloj.Sede.NombreOficial
        };

        return View(vm);
    }

    [HttpPost, ValidateAntiForgeryToken]
    public async Task<IActionResult> Create(CrearReservaViewModel model)
    {
        if (!ModelState.IsValid) return View(model);

        var user = await _users.GetUserAsync(User);
        if (user is null) return Challenge();

        try
        {
            var reserva = await _reservas.CrearAsync(
                user.Id, model.AlojamientoId, model.FechaInicio,
                model.FechaFin, model.NumPersonas, model.CostoTotal, model.Notas);

            await _email.SendReservaConfirmacionAsync(
                user.Email!, user.NombreCompleto.Length > 0 ? user.NombreCompleto : user.Email!,
                reserva.Id, model.NombreAlojamiento,
                model.FechaInicio, model.FechaFin, model.CostoTotal);

            TempData["Success"] = $"Reserva #{reserva.Id} confirmada exitosamente.";
            return RedirectToAction(nameof(Index));
        }
        catch (Exception ex)
        {
            ModelState.AddModelError(string.Empty, ex.Message);
            return View(model);
        }
    }

    [HttpPost, ValidateAntiForgeryToken]
    public async Task<IActionResult> Cancelar(int id)
    {
        var userId = _users.GetUserId(User)!;
        var ok = await _reservas.CancelarAsync(id, userId);

        TempData[ok ? "Success" : "Error"] = ok
            ? "Reserva cancelada."
            : "No se pudo cancelar la reserva.";

        return RedirectToAction(nameof(Index));
    }

    [HttpPost, ValidateAntiForgeryToken]
    public async Task<IActionResult> SubirComprobante(int id, IFormFile archivo)
    {
        var userId = _users.GetUserId(User)!;
        var reserva = await _reservas.ObtenerPorIdAsync(id);

        if (reserva is null || reserva.UsuarioId != userId)
            return NotFound();

        if (archivo is null || archivo.Length == 0)
        {
            TempData["Error"] = "Seleccione un archivo válido.";
            return RedirectToAction(nameof(Index));
        }

        var uploadsDir = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "uploads", "comprobantes");
        Directory.CreateDirectory(uploadsDir);

        var ext = Path.GetExtension(archivo.FileName);
        var fileName = $"reserva_{id}_{DateTime.UtcNow:yyyyMMddHHmmss}{ext}";
        var filePath = Path.Combine(uploadsDir, fileName);

        using (var stream = new FileStream(filePath, FileMode.Create))
            await archivo.CopyToAsync(stream);

        TempData["Success"] = "Comprobante de pago subido correctamente.";
        return RedirectToAction(nameof(Index));
    }
}
