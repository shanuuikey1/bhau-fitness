using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace BhauFitnessApi.Models.Entities;

public enum MembershipStatus
{
    Active,
    Expired,
    Cancelled
}

public class Membership : IMultitenant
{
    public int Id { get; set; }
    public string TenantId { get; set; } = "default";

    [Required]
    public string UserId { get; set; } = string.Empty;
    [ForeignKey(nameof(UserId))]
    public ApplicationUser? User { get; set; }

    [Required]
    public int PlanId { get; set; }
    [ForeignKey(nameof(PlanId))]
    public Plan? Plan { get; set; }

    public MembershipStatus Status { get; set; } = MembershipStatus.Active;

    public DateOnly StartDate { get; set; }
    public DateOnly EndDate { get; set; }

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}
