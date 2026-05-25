using FondoXYZ.Domain.Interfaces;
using FondoXYZ.Domain.Models;
using FondoXYZ.Web.ViewModels;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;

namespace FondoXYZ.Web.Controllers;

public class AccountController : Controller
{
    private readonly UserManager<ApplicationUser> _users;
    private readonly SignInManager<ApplicationUser> _signIn;
    private readonly IEmailService _email;

    public AccountController(UserManager<ApplicationUser> users,
        SignInManager<ApplicationUser> signIn, IEmailService email)
    {
        _users = users;
        _signIn = signIn;
        _email = email;
    }

    [HttpGet]
    public IActionResult Login(string? returnUrl = null)
    {
        ViewData["ActiveTab"] = "login";
        ViewBag.ReturnUrl = returnUrl;
        return View();
    }

    [HttpPost, ValidateAntiForgeryToken]
    public async Task<IActionResult> Login(LoginViewModel model, string? returnUrl = null)
    {
        ViewData["ActiveTab"] = "login";
        ViewBag.ReturnUrl = returnUrl;

        if (!ModelState.IsValid) return View(model);

        // el username en Identity es el numero de documento
        var result = await _signIn.PasswordSignInAsync(
            model.NumeroDocumento, model.Clave, isPersistent: false, lockoutOnFailure: false);

        if (result.Succeeded)
            return LocalRedirect(returnUrl ?? Url.Action("Index", "Sedes")!);

        ModelState.AddModelError(string.Empty, "Documento o clave incorrectos. Verifique sus datos.");
        return View(model);
    }

    [HttpGet]
    public IActionResult Register()
    {
        ViewData["ActiveTab"] = "login";
        return View();
    }

    [HttpPost, ValidateAntiForgeryToken]
    public async Task<IActionResult> Register(RegisterViewModel model)
    {
        ViewData["ActiveTab"] = "login";

        if (!ModelState.IsValid) return View(model);

        var user = new ApplicationUser
        {
            UserName = model.NumeroDocumento,
            Email = model.Email,
            NumeroDocumento = model.NumeroDocumento,
            NombreCompleto = model.NombreCompleto,
            FechaNacimiento = model.FechaNacimiento,
            Celular = model.Celular,
            Departamento = model.Departamento,
            Municipio = model.Municipio,
            Barrio = model.Barrio,
            DireccionResidencia = model.DireccionResidencia,
            TelefonoResidencia = model.TelefonoResidencia,
            PreguntaSecreta = model.PreguntaSecreta,
            RespuestaSecreta = model.RespuestaSecreta,
            AutorizaEnvioCorreo = model.AutorizaEnvioCorreo,
            AutorizaEnvioCelular = model.AutorizaEnvioCelular
        };

        var result = await _users.CreateAsync(user, model.Clave);

        if (result.Succeeded)
        {
            await _signIn.SignInAsync(user, isPersistent: false);
            return RedirectToAction("Index", "Sedes");
        }

        foreach (var e in result.Errors)
            ModelState.AddModelError(string.Empty, e.Description);

        return View(model);
    }

    [HttpPost, ValidateAntiForgeryToken, Authorize]
    public async Task<IActionResult> Logout()
    {
        await _signIn.SignOutAsync();
        return RedirectToAction("Index", "Sedes");
    }

    [HttpGet, Authorize]
    public async Task<IActionResult> Actualizar()
    {
        ViewData["ActiveTab"] = "actualizar";
        var user = await _users.GetUserAsync(User);
        if (user is null) return Challenge();

        var vm = new ActualizarViewModel
        {
            NombreCompleto = user.NombreCompleto,
            FechaNacimiento = user.FechaNacimiento,
            Celular = user.Celular ?? "",
            Email = user.Email ?? "",
            Departamento = user.Departamento,
            Municipio = user.Municipio,
            Barrio = user.Barrio,
            DireccionResidencia = user.DireccionResidencia,
            TelefonoResidencia = user.TelefonoResidencia,
            PreguntaSecreta = user.PreguntaSecreta,
            RespuestaSecreta = user.RespuestaSecreta,
            AutorizaEnvioCorreo = user.AutorizaEnvioCorreo,
            AutorizaEnvioCelular = user.AutorizaEnvioCelular
        };

        return View(vm);
    }

    [HttpPost, ValidateAntiForgeryToken, Authorize]
    public async Task<IActionResult> Actualizar(ActualizarViewModel model)
    {
        ViewData["ActiveTab"] = "actualizar";

        if (!ModelState.IsValid) return View(model);

        var user = await _users.GetUserAsync(User);
        if (user is null) return Challenge();

        user.NombreCompleto = model.NombreCompleto;
        user.FechaNacimiento = model.FechaNacimiento;
        user.Celular = model.Celular;
        user.Email = model.Email;
        user.Departamento = model.Departamento;
        user.Municipio = model.Municipio;
        user.Barrio = model.Barrio;
        user.DireccionResidencia = model.DireccionResidencia;
        user.TelefonoResidencia = model.TelefonoResidencia;
        user.PreguntaSecreta = model.PreguntaSecreta;
        user.RespuestaSecreta = model.RespuestaSecreta;
        user.AutorizaEnvioCorreo = model.AutorizaEnvioCorreo;
        user.AutorizaEnvioCelular = model.AutorizaEnvioCelular;

        var updateResult = await _users.UpdateAsync(user);

        if (!updateResult.Succeeded)
        {
            foreach (var e in updateResult.Errors)
                ModelState.AddModelError(string.Empty, e.Description);
            return View(model);
        }

        // si mando clave nueva la cambiamos, si no la dejamos igual
        if (!string.IsNullOrWhiteSpace(model.NuevaClave))
        {
            var token = await _users.GeneratePasswordResetTokenAsync(user);
            var pinResult = await _users.ResetPasswordAsync(user, token, model.NuevaClave);
            if (!pinResult.Succeeded)
            {
                foreach (var e in pinResult.Errors)
                    ModelState.AddModelError(string.Empty, e.Description);
                return View(model);
            }
        }

        TempData["Success"] = "Sus datos han sido actualizados correctamente.";
        return RedirectToAction(nameof(Actualizar));
    }
}
