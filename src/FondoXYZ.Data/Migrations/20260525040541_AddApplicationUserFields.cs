using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace FondoXYZ.Data.Migrations
{
    /// <inheritdoc />
    public partial class AddApplicationUserFields : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<bool>(
                name: "AutorizaEnvioCelular",
                table: "AspNetUsers",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<bool>(
                name: "AutorizaEnvioCorreo",
                table: "AspNetUsers",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<string>(
                name: "Barrio",
                table: "AspNetUsers",
                type: "nvarchar(max)",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "Celular",
                table: "AspNetUsers",
                type: "nvarchar(max)",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "Departamento",
                table: "AspNetUsers",
                type: "nvarchar(max)",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "DireccionResidencia",
                table: "AspNetUsers",
                type: "nvarchar(max)",
                nullable: true);

            migrationBuilder.AddColumn<DateOnly>(
                name: "FechaNacimiento",
                table: "AspNetUsers",
                type: "date",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "Municipio",
                table: "AspNetUsers",
                type: "nvarchar(max)",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "NombreCompleto",
                table: "AspNetUsers",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "NumeroDocumento",
                table: "AspNetUsers",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "PreguntaSecreta",
                table: "AspNetUsers",
                type: "nvarchar(max)",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "RespuestaSecreta",
                table: "AspNetUsers",
                type: "nvarchar(max)",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "TelefonoResidencia",
                table: "AspNetUsers",
                type: "nvarchar(max)",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "AutorizaEnvioCelular",
                table: "AspNetUsers");

            migrationBuilder.DropColumn(
                name: "AutorizaEnvioCorreo",
                table: "AspNetUsers");

            migrationBuilder.DropColumn(
                name: "Barrio",
                table: "AspNetUsers");

            migrationBuilder.DropColumn(
                name: "Celular",
                table: "AspNetUsers");

            migrationBuilder.DropColumn(
                name: "Departamento",
                table: "AspNetUsers");

            migrationBuilder.DropColumn(
                name: "DireccionResidencia",
                table: "AspNetUsers");

            migrationBuilder.DropColumn(
                name: "FechaNacimiento",
                table: "AspNetUsers");

            migrationBuilder.DropColumn(
                name: "Municipio",
                table: "AspNetUsers");

            migrationBuilder.DropColumn(
                name: "NombreCompleto",
                table: "AspNetUsers");

            migrationBuilder.DropColumn(
                name: "NumeroDocumento",
                table: "AspNetUsers");

            migrationBuilder.DropColumn(
                name: "PreguntaSecreta",
                table: "AspNetUsers");

            migrationBuilder.DropColumn(
                name: "RespuestaSecreta",
                table: "AspNetUsers");

            migrationBuilder.DropColumn(
                name: "TelefonoResidencia",
                table: "AspNetUsers");
        }
    }
}
