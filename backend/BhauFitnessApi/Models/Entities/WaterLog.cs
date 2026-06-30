using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace BhauFitnessApi.Models.Entities;

/// <summary>One day's hydration count for a member (mirrors the HTML's 8-glass tracker).</summary>
public class WaterLog : IMultitenant
{
    public int Id { get; set; }
    public string TenantId { get; set; } = "default";

    [Required]
    public string UserId { get; set; } = string.Empty;
    [ForeignKey(nameof(UserId))]
    public ApplicationUser? User { get; set; }

    public DateOnly LogDate { get; set; }

    public int GlassCount { get; set; }
}
