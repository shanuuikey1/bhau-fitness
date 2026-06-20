using System.ComponentModel.DataAnnotations;

namespace BhauFitnessApi.Models.DTOs;

public class MemberProfileDto
{
    public string Id { get; set; } = string.Empty;
    public string FullName { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string Phone { get; set; } = string.Empty;
    public string Goal { get; set; } = string.Empty;
    public string MemberCode { get; set; } = string.Empty;
    public string Role { get; set; } = "Member";
}

public class UpdateProfileDto
{
    [Required, MaxLength(120)]
    public string FullName { get; set; } = string.Empty;

    [Required, Phone]
    public string Phone { get; set; } = string.Empty;

    public string Goal { get; set; } = "fit";
}

public class PlanDto
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public decimal Price { get; set; }
    public int DurationDays { get; set; }
    public string? Description { get; set; }
}

public class MembershipDto
{
    public int Id { get; set; }
    public string PlanName { get; set; } = string.Empty;
    public decimal PlanPrice { get; set; }
    public string Status { get; set; } = string.Empty;
    public DateOnly StartDate { get; set; }
    public DateOnly EndDate { get; set; }
    public int DaysRemaining { get; set; }
}

public class CreateMembershipDto
{
    [Required]
    public int PlanId { get; set; }
}
