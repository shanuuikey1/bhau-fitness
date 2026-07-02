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

            // This service runs with no HttpContext, so the tenant provider
            // resolves to "default" and the global query filters would hide
            // every other gym's data. IgnoreQueryFilters + explicit TenantId
            // on created rows keeps notifications working for all tenants.

            // 1. Memberships entering their final 3 days. A window (not an
            // exact date match) so a day of downtime doesn't skip anyone.
            var expiringMemberships = await db.Memberships
                .IgnoreQueryFilters()
                .Include(m => m.Plan)
                .Where(m => m.Status == MembershipStatus.Active
                    && m.EndDate > today && m.EndDate <= threeDaysFromNow)
                .ToListAsync();

            foreach (var m in expiringMemberships)
            {
                // Prevent duplicate notifications
                bool alreadyNotified = await db.Notifications
                    .IgnoreQueryFilters()
                    .AnyAsync(n => n.UserId == m.UserId && n.Type == "MembershipExpiry" && n.CreatedAt >= DateTime.UtcNow.AddDays(-5));

                if (!alreadyNotified)
                {
                    var n = new Notification
                    {
                        UserId = m.UserId,
                        Title = "Membership Expiring Soon!",
                        Body = $"Your {m.Plan?.Name} plan will expire on {m.EndDate:dd MMM yyyy}. Renew now to stay active!",
                        Type = "MembershipExpiry",
                        IsRead = false,
                        CreatedAt = DateTime.UtcNow,
                        TenantId = m.TenantId
                    };
                    db.Notifications.Add(n);
                    _logger.LogInformation("Queued membership expiry notification for user {UserId}", m.UserId);
                }
            }

            // 2. Check for classes booked for tomorrow
            var tomorrowBookings = await db.Bookings
                .IgnoreQueryFilters()
                .Include(b => b.ClassSession)
                .Where(b => b.Status == BookingStatus.Booked && b.ClassDate == tomorrow)
                .ToListAsync();

            foreach (var b in tomorrowBookings)
            {
                if (b.ClassSession == null) continue;

                // Dedup on a stable per-booking marker embedded in the body.
                string bookingMarker = $"[booking #{b.Id}]";
                bool alreadyNotified = await db.Notifications
                    .IgnoreQueryFilters()
                    .AnyAsync(n => n.UserId == b.UserId && n.Type == "ClassReminder" && n.Body.Contains(bookingMarker));

                if (!alreadyNotified)
                {
                    var n = new Notification
                    {
                        UserId = b.UserId,
                        Title = "Upcoming Class Reminder",
                        Body = $"Reminder: You are booked for '{b.ClassSession.Title}' tomorrow ({tomorrow:dd MMM}) at {b.ClassSession.StartTime:HH\\:mm}. See you there! {bookingMarker}",
                        Type = "ClassReminder",
                        IsRead = false,
                        CreatedAt = DateTime.UtcNow,
                        TenantId = b.TenantId
                    };
                    db.Notifications.Add(n);
                    _logger.LogInformation("Queued class booking reminder for user {UserId}", b.UserId);
                }
            }

            await db.SaveChangesAsync();
        }
    }
}
