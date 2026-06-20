using Microsoft.AspNetCore.Identity;

namespace BhauFitnessApi.Models.Entities;

/// <summary>
/// Extends ASP.NET Core Identity's IdentityUser with the profile fields
/// BHAU FITNESS needs. Identity already gives us: Id, Email, PasswordHash,
/// PhoneNumber, EmailConfirmed, etc. — we only add what's missing.
/// </summary>
public class ApplicationUser : IdentityUser
{
    public string FullName { get; set; } = string.Empty;

    // e.g. "lose", "muscle", "fit", "strength" — matches the goal-picker in the web app
    public string Goal { get; set; } = "fit";

    // Human-friendly code shown on the membership pass, e.g. "BHAU-0007"
    public string MemberCode { get; set; } = string.Empty;

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    // Navigation: a member can have a history of memberships over time
    // (renewals, plan changes), but only one should be Active at a time.
    public ICollection<Membership> Memberships { get; set; } = new List<Membership>();
}
