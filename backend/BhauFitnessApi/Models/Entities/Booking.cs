using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace BhauFitnessApi.Models.Entities;

public enum BookingStatus
{
    Booked,
    Cancelled
}

public class Booking
{
    public int Id { get; set; }

    [Required]
    public string UserId { get; set; } = string.Empty;
    [ForeignKey(nameof(UserId))]
    public ApplicationUser? User { get; set; }

    [Required]
    public int ClassSessionId { get; set; }
    [ForeignKey(nameof(ClassSessionId))]
    public ClassSession? ClassSession { get; set; }

    // The specific calendar date this booking is for (a class session repeats
    // weekly, but each booking is for one occurrence of it).
    public DateOnly ClassDate { get; set; }

    public BookingStatus Status { get; set; } = BookingStatus.Booked;

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}
