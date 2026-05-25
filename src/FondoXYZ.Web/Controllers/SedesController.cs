using FondoXYZ.Data.Context;
using FondoXYZ.Domain.Interfaces;
using FondoXYZ.Web.ViewModels;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace FondoXYZ.Web.Controllers;

public class SedesController : Controller
{
    private readonly FondoXYZContext _db;
    private readonly IAlojamientoRepository _alojRepo;

    public SedesController(FondoXYZContext db, IAlojamientoRepository alojRepo)
    {
        _db = db;
        _alojRepo = alojRepo;
    }

    public async Task<IActionResult> Index()
    {
        ViewData["ActiveTab"] = "sedes";
        var sedes = await _db.Sedes.Where(s => s.Activo).OrderBy(s => s.Nombre).ToListAsync();
        return View(sedes);
    }

    public async Task<IActionResult> Detalle(int id, DateOnly? fechaInicio, DateOnly? fechaFin, int numPersonas = 1)
    {
        ViewData["ActiveTab"] = "sedes";
        var sede = await _db.Sedes.FindAsync(id);
        if (sede == null) return NotFound();

        var alojamientos = await _db.Alojamientos
            .Where(a => a.SedeId == id && a.Activo)
            .Include(a => a.Dormitorios)
            .Include(a => a.Caracteristica)
            .ToListAsync();

        var vm = new SedeDetalleViewModel
        {
            Sede = sede,
            Alojamientos = alojamientos,
            NumPersonas = numPersonas
        };

        if (fechaInicio.HasValue && fechaFin.HasValue)
        {
            vm.FechaInicio = fechaInicio.Value;
            vm.FechaFin = fechaFin.Value;
            vm.NumPersonas = numPersonas;

            var disponibles = await _alojRepo.BuscarDisponibilidadPersonasAsync(
                fechaInicio.Value, fechaFin.Value, numPersonas, id);
            vm.Disponibles = disponibles;
            vm.BuscadoDisponibilidad = true;
        }

        return View(vm);
    }

    [HttpPost, ValidateAntiForgeryToken]
    public async Task<IActionResult> Detalle(int id, SedeDetalleViewModel form)
    {
        ViewData["ActiveTab"] = "sedes";
        var sede = await _db.Sedes.FindAsync(id);
        if (sede == null) return NotFound();

        form.Sede = sede;
        form.Alojamientos = await _db.Alojamientos
            .Where(a => a.SedeId == id && a.Activo)
            .Include(a => a.Dormitorios)
            .Include(a => a.Caracteristica)
            .ToListAsync();

        if (form.FechaFin <= form.FechaInicio)
        {
            ModelState.AddModelError("FechaFin", "La fecha de salida debe ser posterior a la de entrada.");
            return View(form);
        }

        var disponibles = await _alojRepo.BuscarDisponibilidadPersonasAsync(
            form.FechaInicio, form.FechaFin, form.NumPersonas, id);
        form.Disponibles = disponibles;
        form.BuscadoDisponibilidad = true;

        return View(form);
    }

    [Authorize]
    [HttpGet]
    public async Task<IActionResult> CalcularCosto(int alojamientoId, DateOnly fechaInicio, DateOnly fechaFin, int numPersonas)
    {
        try
        {
            var costo = await _alojRepo.CalcularCostoAsync(alojamientoId, fechaInicio, fechaFin, numPersonas);
            return Json(new { ok = true, data = costo });
        }
        catch (Exception ex)
        {
            return Json(new { ok = false, error = ex.Message });
        }
    }
}
