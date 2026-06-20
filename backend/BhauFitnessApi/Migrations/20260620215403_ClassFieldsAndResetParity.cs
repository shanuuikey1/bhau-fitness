using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace BhauFitnessApi.Migrations
{
    /// <inheritdoc />
    public partial class ClassFieldsAndResetParity : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "DayLabel",
                table: "ClassSessions",
                type: "nvarchar(40)",
                maxLength: 40,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<int>(
                name: "DurationMin",
                table: "ClassSessions",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<string>(
                name: "Type",
                table: "ClassSessions",
                type: "nvarchar(40)",
                maxLength: 40,
                nullable: false,
                defaultValue: "");

            migrationBuilder.UpdateData(
                table: "ClassSessions",
                keyColumn: "Id",
                keyValue: 1,
                columns: new[] { "DayLabel", "DurationMin", "Type" },
                values: new object[] { "Mon", 45, "Cardio" });

            migrationBuilder.UpdateData(
                table: "ClassSessions",
                keyColumn: "Id",
                keyValue: 2,
                columns: new[] { "DayLabel", "DurationMin", "Type" },
                values: new object[] { "Mon", 60, "Strength" });

            migrationBuilder.UpdateData(
                table: "ClassSessions",
                keyColumn: "Id",
                keyValue: 3,
                columns: new[] { "DayLabel", "DurationMin", "Type" },
                values: new object[] { "Tue", 60, "Yoga" });

            migrationBuilder.UpdateData(
                table: "ClassSessions",
                keyColumn: "Id",
                keyValue: 4,
                columns: new[] { "DayLabel", "DurationMin", "Type" },
                values: new object[] { "Wed", 45, "Cardio" });

            migrationBuilder.UpdateData(
                table: "ClassSessions",
                keyColumn: "Id",
                keyValue: 5,
                columns: new[] { "DayLabel", "DurationMin", "Type" },
                values: new object[] { "Thu", 60, "Functional" });

            migrationBuilder.UpdateData(
                table: "ClassSessions",
                keyColumn: "Id",
                keyValue: 6,
                columns: new[] { "DayLabel", "DurationMin", "Type" },
                values: new object[] { "Fri", 60, "Yoga" });

            migrationBuilder.UpdateData(
                table: "ClassSessions",
                keyColumn: "Id",
                keyValue: 7,
                columns: new[] { "DayLabel", "DurationMin", "Type" },
                values: new object[] { "Sat", 75, "Strength" });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "DayLabel",
                table: "ClassSessions");

            migrationBuilder.DropColumn(
                name: "DurationMin",
                table: "ClassSessions");

            migrationBuilder.DropColumn(
                name: "Type",
                table: "ClassSessions");
        }
    }
}
