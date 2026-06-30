using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace BhauFitnessApi.Models.Entities
{
    public enum PaymentStatus
    {
        Created,
        Paid,
        Failed
    }

    public class Payment : IMultitenant
    {
        [Key]
        public int Id { get; set; }
        public string TenantId { get; set; } = "default";

        [Required]
        public string UserId { get; set; } = string.Empty;

        [ForeignKey("UserId")]
        public ApplicationUser? User { get; set; }

        [Required]
        public int PlanId { get; set; }

        [ForeignKey("PlanId")]
        public Plan? Plan { get; set; }

        [Required]
        public string RazorpayOrderId { get; set; } = string.Empty;

        public string? RazorpayPaymentId { get; set; }
        public string? RazorpaySignature { get; set; }

        [Column(TypeName = "decimal(18,2)")]
        public decimal Amount { get; set; }

        [Required]
        public string Currency { get; set; } = "INR";

        public PaymentStatus Status { get; set; } = PaymentStatus.Created;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }
}
