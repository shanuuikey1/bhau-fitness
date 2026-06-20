using System.ComponentModel.DataAnnotations;

namespace BhauFitnessApi.Models.DTOs;

public class AdminOverviewDto
{
    public int TotalMembers { get; set; }
    public int ActiveMemberships { get; set; }
    public decimal MonthlyRecurringRevenue { get; set; }
    public int ActiveClasses { get; set; }
    public List<AdminMemberSummaryDto> RecentSignups { get; set; } = new();
    public List<PlanDistributionDto> PlanDistribution { get; set; } = new();
}

public class PlanDistributionDto
{
    public string PlanName { get; set; } = string.Empty;
    public int MemberCount { get; set; }
}

public class AdminMemberSummaryDto
{
    public string Id { get; set; } = string.Empty;
    public string FullName { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string MemberCode { get; set; } = string.Empty;
    public string? PlanName { get; set; }
    public string? MembershipStatus { get; set; }
    public DateTime CreatedAt { get; set; }
}

public class GrantMembershipDto
{
    [Required]
    public int PlanId { get; set; }
}

public class CreatePlanDto
{
    [Required, MaxLength(50)]
    public string Name { get; set; } = string.Empty;

    public decimal Price { get; set; }
    public int DurationDays { get; set; } = 30;
    public string? Description { get; set; }
}

public class UpdatePlanDto
{
    [Required, MaxLength(50)]
    public string Name { get; set; } = string.Empty;

    public decimal Price { get; set; }
    public int DurationDays { get; set; } = 30;
    public bool IsActive { get; set; } = true;
    public string? Description { get; set; }
}

public class CreateClassSessionDto
{
    [Range(1, 7)]
    public int DayOfWeek { get; set; }

    public TimeOnly StartTime { get; set; }

    [Required, MaxLength(80)]
    public string Title { get; set; } = string.Empty;

    [Required, MaxLength(80)]
    public string TrainerName { get; set; } = string.Empty;

    [Required, MaxLength(20)]
    public string Level { get; set; } = "All Levels";

    [Required, MaxLength(40)]
    public string Type { get; set; } = "General";

    [Range(10, 180)]
    public int DurationMin { get; set; } = 60;

    [Required, MaxLength(40)]
    public string DayLabel { get; set; } = "Weekly";

    public int Capacity { get; set; } = 20;
}
