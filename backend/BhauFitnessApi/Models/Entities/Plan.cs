using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace BhauFitnessApi.Models.Entities;

public class Plan
{
    public int Id { get; set; }

    [Required, MaxLength(50)]
    public string Name { get; set; } = string.Empty; // "Basic", "Premium", "Elite"

    [Column(TypeName = "decimal(10,2)")]
    public decimal Price { get; set; } // monthly price in INR

    public int DurationDays { get; set; } = 30;

    public bool IsActive { get; set; } = true;

    [MaxLength(500)]
    public string? Description { get; set; }

    public ICollection<Membership> Memberships { get; set; } = new List<Membership>();
}
