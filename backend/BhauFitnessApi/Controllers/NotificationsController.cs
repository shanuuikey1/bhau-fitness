using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using BhauFitnessApi.Data;
using BhauFitnessApi.Models.DTOs;
using BhauFitnessApi.Models.Entities;

namespace BhauFitnessApi.Controllers
{
    [Authorize]
    [ApiController]
    [Route("api/notifications")]
    public class NotificationsController : ControllerBase
    {
        private readonly ApplicationDbContext _db;

        public NotificationsController(ApplicationDbContext db)
        {
            _db = db;
        }

        private string CurrentUserId => User.FindFirstValue(ClaimTypes.NameIdentifier) ?? string.Empty;

        [HttpGet]
        public async Task<ActionResult<List<NotificationDto>>> GetNotifications()
        {
            var list = await _db.Notifications
                .Where(n => n.UserId == CurrentUserId)
                .OrderByDescending(n => n.CreatedAt)
                .Take(50)
                .Select(n => new NotificationDto
                {
                    Id = n.Id,
                    Title = n.Title,
                    Body = n.Body,
                    Type = n.Type,
                    IsRead = n.IsRead,
                    CreatedAt = n.CreatedAt
                })
                .ToListAsync();

            return Ok(list);
        }

        [HttpGet("unread-count")]
        public async Task<ActionResult<UnreadCountDto>> GetUnreadCount()
        {
            int count = await _db.Notifications
                .CountAsync(n => n.UserId == CurrentUserId && !n.IsRead);

            return Ok(new UnreadCountDto { Count = count });
        }

        [HttpPut("{id}/read")]
        public async Task<IActionResult> MarkAsRead(int id)
        {
            var n = await _db.Notifications
                .FirstOrDefaultAsync(x => x.Id == id && x.UserId == CurrentUserId);

            if (n == null) return NotFound();

            n.IsRead = true;
            await _db.SaveChangesAsync();
            return NoContent();
        }

        [HttpPut("read-all")]
        public async Task<IActionResult> MarkAllAsRead()
        {
            var unread = await _db.Notifications
                .Where(n => n.UserId == CurrentUserId && !n.IsRead)
                .ToListAsync();

            foreach (var n in unread)
            {
                n.IsRead = true;
            }

            await _db.SaveChangesAsync();
            return NoContent();
        }

        [Authorize(Roles = "Admin")]
        [HttpPost("send")]
        public async Task<IActionResult> SendNotification([FromBody] SendNotificationDto dto)
        {
            if (string.IsNullOrEmpty(dto.Title) || string.IsNullOrEmpty(dto.Body))
            {
                return BadRequest(new { error = "Title and body are required." });
            }

            if (!string.IsNullOrEmpty(dto.UserId))
            {
                // Send to single user
                var user = await _db.Users.FindAsync(dto.UserId);
                if (user == null) return NotFound(new { error = "Target user not found." });

                var n = new Notification
                {
                    UserId = dto.UserId,
                    Title = dto.Title,
                    Body = dto.Body,
                    Type = dto.Type,
                    IsRead = false,
                    CreatedAt = DateTime.UtcNow
                };
                _db.Notifications.Add(n);
            }
            else
            {
                // Broadcast to all users
                var userIds = await _db.Users.Select(u => u.Id).ToListAsync();
                foreach (var userId in userIds)
                {
                    var n = new Notification
                    {
                        UserId = userId,
                        Title = dto.Title,
                        Body = dto.Body,
                        Type = dto.Type,
                        IsRead = false,
                        CreatedAt = DateTime.UtcNow
                    };
                    _db.Notifications.Add(n);
                }
            }

            await _db.SaveChangesAsync();
            return Ok(new { message = "Notification sent successfully." });
        }
    }
}
