using FondoXYZ.Business.Services;
using FondoXYZ.Data.Context;
using FondoXYZ.Data.Repositories;
using FondoXYZ.Domain.Interfaces;
using FondoXYZ.Domain.Models;
using FondoXYZ.Web.Services;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Identity.UI.Services;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddDbContext<FondoXYZContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));

// clave de 4 digitos numericos en vez de password normal
builder.Services.AddDefaultIdentity<ApplicationUser>(options =>
{
    options.Password.RequiredLength         = 4;
    options.Password.RequireDigit           = true;
    options.Password.RequireNonAlphanumeric = false;
    options.Password.RequireUppercase       = false;
    options.Password.RequireLowercase       = false;
    options.Password.RequiredUniqueChars    = 1;
    options.SignIn.RequireConfirmedAccount  = false;
})
.AddEntityFrameworkStores<FondoXYZContext>();

var emailProvider = builder.Configuration["EmailSettings:Provider"] ?? "Smtp";
if (emailProvider == "Console")
    builder.Services.AddScoped<IEmailService, ConsoleEmailService>();
else
    builder.Services.AddScoped<IEmailService, EmailService>();

builder.Services.AddScoped<IEmailSender<ApplicationUser>, IdentityEmailSender>();
builder.Services.AddScoped<IEmailSender, IdentityEmailSender>();

builder.Services.AddScoped<IAlojamientoRepository, AlojamientoRepository>();
builder.Services.AddScoped<IReservaRepository, ReservaRepository>();

builder.Services.AddControllersWithViews();
builder.Services.AddRazorPages();

var app = builder.Build();

if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Home/Error");
    app.UseHsts();
}

app.UseHttpsRedirection();
app.UseRouting();
app.UseAuthentication();
app.UseAuthorization();
app.MapStaticAssets();
app.MapRazorPages();

app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Home}/{action=Index}/{id?}")
    .WithStaticAssets();

app.Run();
