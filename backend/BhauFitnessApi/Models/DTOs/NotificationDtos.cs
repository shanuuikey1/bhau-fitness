using System;

namespace BhauFitnessApi.Models.DTOs
{
    public class NotificationDto
    {
        public int Id { get; set; }
        public string Title { get; set; } = string.Empty;
        public string Body { get; set; } = string.Empty;
        public string Type { get; set; } = string.Empty;
        public bool IsRead { get; set; }
        public DateTime CreatedAt { get; set; }
    }

    public class SendNotificationDto
    {
        public string? UserId { get; set; } // Null for global/broadcast notifications
        public string Title { get; set; } = string.Empty;
        public string Body { get; set; } = string.Empty;
        public string Type { get; set; } = "System";
    }

    public class UnreadCountDto
    {
        public int Count { get; set; }
    }
}
