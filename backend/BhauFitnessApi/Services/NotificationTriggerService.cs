using System;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using BhauFitnessApi.Data;
using BhauFitnessApi.Models.Entities;

namespace BhauFitnessApi.Services
{
    public class NotificationTriggerService : BackgroundService
    {
        private readonly IServiceScopeFactory _scopeFactory;
        private readonly ILogger<NotificationTriggerService> _logger;
        private readonly TimeSpan _period = TimeSpan.FromHours(1);

        public NotificationTriggerService(IServiceScopeFactory scopeFactory, ILogger<NotificationTriggerService> logger)
        {
            _scopeFactory = scopeFactory;
            _logger = logger;
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            _logger.LogInformation("Notification Trigger Service is starting.");

            while (!stoppingToken.IsCancellationRequested)
            {
                try
                {
                    await CheckAndTriggerNotificationsAsync();
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Error occurred executing notification trigger checks.");
                }

                await Task.Delay(_period, stoppingToken);
            }

            _logger.LogInformation("Notification Trigger Service is stopping.");
        }

        private async Task CheckAndTriggerNotificationsAsync()
        {
            using var scope = _scopeFactory.CreateScope();
            var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();

            var today = DateOnly.FromDateTime(DateTime.UtcNow);
            var threeDaysFromNow = today.AddDays(3);
            var tomorrow = today.AddDays(1);

            // 1. Check for memberships expiring in 3 days
            var expiringMemberships = await db.Memberships
                .Include(m => m.Plan)
                .Where(m => m.Status == MembershipStatus.Active && m.EndDate == threeDaysFromNow)
                .ToListAsync();

            foreach (var m in expiringMemberships)
            {
                // Prevent duplicate notifications
                bool alreadyNotified = await db.Notifications
                    .AnyAsync(n => n.UserId == m.UserId && n.Type == "MembershipExpiry" && n.CreatedAt >= DateTime.UtcNow.AddDays(-5));

                if (!alreadyNotified)
                {
                    var n = new Notification
                    {
                        UserId = m.UserId,
                        Title = "Membership Expiring Soon!",
                        Body = $"Your {m.Plan?.Name} plan will expire in 3 days on {m.EndDate:dd MMM yyyy}. Renew now to stay active!",
                        Type = "MembershipExpiry",
                        IsRead = false,
                        CreatedAt = DateTime.UtcNow
                    };
                    db.Notifications.Add(n);
                    _logger.LogInformation($"Queued membership expiry notification for user {m.UserId}");
                }
            }

            // 2. Check for classes booked for tomorrow
            var tomorrowBookings = await db.Bookings
                .Include(b => b.ClassSession)
                .Where(b => b.Status == BookingStatus.Booked && b.ClassDate == tomorrow)
                .ToListAsync();

            foreach (var b in tomorrowBookings)
            {
                if (b.ClassSession == null) continue;

                // Prevent duplicate notifications
                string bookingKey = $"ClassReminder:{b.Id}";
                bool alreadyNotified = await db.Notifications
                    .AnyAsync(n => n.UserId == b.UserId && n.Type == "ClassReminder" && n.Body.Contains(b.ClassSession.Title) && n.CreatedAt >= DateTime.UtcNow.AddDays(-2));

                if (!alreadyNotified)
                {
                    var n = new Notification
                    {
                        UserId = b.UserId,
                        Title = "Upcoming Class Reminder",
                        Body = $"Reminder: You are booked for '{b.ClassSession.Title}' tomorrow ({tomorrow:dd MMM}) at {b.ClassSession.StartTime}. See you there!",
                        Type = "ClassReminder",
                        IsRead = false,
                        CreatedAt = DateTime.UtcNow
                    };
                    db.Notifications.Add(n);
                    _logger.LogInformation($"Queued class booking reminder for user {b.UserId}");
                }
            }

            await db.SaveChangesAsync();
        }
    }
}
