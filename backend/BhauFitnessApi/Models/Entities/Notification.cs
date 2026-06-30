using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace BhauFitnessApi.Models.Entities
{
    public class Notification : IMultitenant
    {
        [Key]
        public int Id { get; set; }
        public string TenantId { get; set; } = "default";

        [Required]
        public string UserId { get; set; } = string.Empty;

        [ForeignKey("UserId")]
        public ApplicationUser? User { get; set; }

        [Required]
        public string Title { get; set; } = string.Empty;

        [Required]
        public string Body { get; set; } = string.Empty;

        [Required]
        public string Type { get; set; } = "System"; // MembershipExpiry, ClassReminder, WorkoutReminder, System

        public bool IsRead { get; set; } = false;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }
}
