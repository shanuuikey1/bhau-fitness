using System.ComponentModel.DataAnnotations;

namespace BhauFitnessApi.Models.DTOs;

public class ClassSessionDto
{
    public int Id { get; set; }
    public int DayOfWeek { get; set; }
    public TimeOnly StartTime { get; set; }
    public string Title { get; set; } = string.Empty;
    public string TrainerName { get; set; } = string.Empty;
    public string Level { get; set; } = string.Empty;
    public string Type { get; set; } = string.Empty;
    public int DurationMin { get; set; }
    public string DayLabel { get; set; } = string.Empty;
    public int Capacity { get; set; }
    public int BookedCount { get; set; }
}

public class CreateBookingDto
{
    [Required]
    public int ClassSessionId { get; set; }

    [Required]
    public DateOnly ClassDate { get; set; }
}

public class BookingDto
{
    public int Id { get; set; }
    public int ClassSessionId { get; set; }
    public string ClassTitle { get; set; } = string.Empty;
    public string TrainerName { get; set; } = string.Empty;
    public TimeOnly StartTime { get; set; }
    public DateOnly ClassDate { get; set; }
    public string Status { get; set; } = string.Empty;
}

public class CreateWorkoutLogDto
{
    [Required, MaxLength(120)]
    public string Exercise { get; set; } = string.Empty;

    [Range(1, 50)]
    public int Sets { get; set; }

    [Range(1, 200)]
    public int Reps { get; set; }

    [Range(0, 999)]
    public decimal WeightKg { get; set; }
}

public class WorkoutLogDto
{
    public int Id { get; set; }
    public string Exercise { get; set; } = string.Empty;
    public int Sets { get; set; }
    public int Reps { get; set; }
    public decimal WeightKg { get; set; }
    public DateOnly LoggedDate { get; set; }
}

public class WaterLogDto
{
    public DateOnly LogDate { get; set; }
    public int GlassCount { get; set; }
}

public class SetWaterLogDto
{
    [Range(0, 20)]
    public int GlassCount { get; set; }
}
