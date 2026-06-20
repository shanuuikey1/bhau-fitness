using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace BhauFitnessApi.Models.Entities;

/// <summary>One logged exercise set, mirrors the HTML member portal's workout log.</summary>
public class WorkoutLog
{
    public int Id { get; set; }

    [Required]
    public string UserId { get; set; } = string.Empty;
    [ForeignKey(nameof(UserId))]
    public ApplicationUser? User { get; set; }

    [Required, MaxLength(120)]
    public string Exercise { get; set; } = string.Empty;

    public int Sets { get; set; }
    public int Reps { get; set; }

    [Column(TypeName = "decimal(6,2)")]
    public decimal WeightKg { get; set; }

    public DateOnly LoggedDate { get; set; }

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}
