using System.ComponentModel.DataAnnotations;

namespace BhauFitnessApi.Models.Entities;

/// <summary>
/// A recurring class slot on the weekly schedule (mirrors the HTML site's
/// schedule preview/booking — e.g. "Mon 6:00 AM — HIIT — Coach Aman").
/// </summary>
public class ClassSession
{
    public int Id { get; set; }

    // 1 (Monday) .. 7 (Sunday) — kept simple since classes repeat weekly.
    public int DayOfWeek { get; set; }

    public TimeOnly StartTime { get; set; }

    [Required, MaxLength(80)]
    public string Title { get; set; } = string.Empty; // "HIIT", "Yoga & Mobility", ...

    [Required, MaxLength(80)]
    public string TrainerName { get; set; } = string.Empty;

    [Required, MaxLength(20)]
    public string Level { get; set; } = "All Levels";

    // Class category, e.g. "Strength", "Cardio", "Yoga" (HTML's `type`).
    [Required, MaxLength(40)]
    public string Type { get; set; } = "General";

    public int DurationMin { get; set; } = 60;

    // Human-readable frequency label shown on the schedule ("Daily", "Mon", ...).
    [Required, MaxLength(40)]
    public string DayLabel { get; set; } = "Weekly";

    public int Capacity { get; set; } = 20;

    public bool IsActive { get; set; } = true;

    public ICollection<Booking> Bookings { get; set; } = new List<Booking>();
}
