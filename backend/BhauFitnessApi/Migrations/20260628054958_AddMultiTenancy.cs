using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace BhauFitnessApi.Migrations
{
    /// <inheritdoc />
    public partial class AddMultiTenancy : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "TenantId",
                table: "WorkoutLogs",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "TenantId",
                table: "WaterLogs",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "TenantId",
                table: "Plans",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "TenantId",
                table: "Payments",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "TenantId",
                table: "Notifications",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "TenantId",
                table: "Memberships",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "TenantId",
                table: "ClassSessions",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "TenantId",
                table: "Bookings",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "TenantId",
                table: "AspNetUsers",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "");

            migrationBuilder.UpdateData(
                table: "ClassSessions",
                keyColumn: "Id",
                keyValue: 1,
                column: "TenantId",
                value: "default");

            migrationBuilder.UpdateData(
                table: "ClassSessions",
                keyColumn: "Id",
                keyValue: 2,
                column: "TenantId",
                value: "default");

            migrationBuilder.UpdateData(
                table: "ClassSessions",
                keyColumn: "Id",
                keyValue: 3,
                column: "TenantId",
                value: "default");

            migrationBuilder.UpdateData(
                table: "ClassSessions",
                keyColumn: "Id",
                keyValue: 4,
                column: "TenantId",
                value: "default");

            migrationBuilder.UpdateData(
                table: "ClassSessions",
                keyColumn: "Id",
                keyValue: 5,
                column: "TenantId",
                value: "default");

            migrationBuilder.UpdateData(
                table: "ClassSessions",
                keyColumn: "Id",
                keyValue: 6,
                column: "TenantId",
                value: "default");

            migrationBuilder.UpdateData(
                table: "ClassSessions",
                keyColumn: "Id",
                keyValue: 7,
                column: "TenantId",
                value: "default");

            migrationBuilder.UpdateData(
                table: "Plans",
                keyColumn: "Id",
                keyValue: 1,
                column: "TenantId",
                value: "default");

            migrationBuilder.UpdateData(
                table: "Plans",
                keyColumn: "Id",
                keyValue: 2,
                column: "TenantId",
                value: "default");

            migrationBuilder.UpdateData(
                table: "Plans",
                keyColumn: "Id",
                keyValue: 3,
                column: "TenantId",
                value: "default");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "TenantId",
                table: "WorkoutLogs");

            migrationBuilder.DropColumn(
                name: "TenantId",
                table: "WaterLogs");

            migrationBuilder.DropColumn(
                name: "TenantId",
                table: "Plans");

            migrationBuilder.DropColumn(
                name: "TenantId",
                table: "Payments");

            migrationBuilder.DropColumn(
                name: "TenantId",
                table: "Notifications");

            migrationBuilder.DropColumn(
                name: "TenantId",
                table: "Memberships");

            migrationBuilder.DropColumn(
                name: "TenantId",
                table: "ClassSessions");

            migrationBuilder.DropColumn(
                name: "TenantId",
                table: "Bookings");

            migrationBuilder.DropColumn(
                name: "TenantId",
                table: "AspNetUsers");
        }
    }
}
