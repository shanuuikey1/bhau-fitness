using System.Security.Claims;
using BhauFitnessApi.Data;
using BhauFitnessApi.Models.DTOs;
using BhauFitnessApi.Models.Entities;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace BhauFitnessApi.Controllers;

[ApiController]
[Route("api/memberships")]
[Authorize]
public class MembershipsController : ControllerBase
{
    private readonly ApplicationDbContext _db;

    public MembershipsController(ApplicationDbContext db)
    {
        _db = db;
    }

    private string CurrentUserId =>
        User.FindFirstValue(ClaimTypes.NameIdentifier) ?? User.FindFirstValue("sub")!;

    [HttpGet("me")]
    public async Task<ActionResult<MembershipDto>> GetMine()
    {
        var membership = await _db.Memberships
            .Include(m => m.Plan)
            .Where(m => m.UserId == CurrentUserId && m.Status == MembershipStatus.Active)
            .OrderByDescending(m => m.CreatedAt)
            .FirstOrDefaultAsync();

        if (membership == null || membership.Plan == null)
            return NotFound(new { error = "No active membership." });

        var today = DateOnly.FromDateTime(DateTime.UtcNow);
        var daysRemaining = Math.Max(0, membership.EndDate.DayNumber - today.DayNumber);

        return Ok(new MembershipDto
        {
            Id = membership.Id,
            PlanName = membership.Plan.Name,
            PlanPrice = membership.Plan.Price,
            Status = membership.Status.ToString(),
            StartDate = membership.StartDate,
            EndDate = membership.EndDate,
            DaysRemaining = daysRemaining,
        });
    }

    // Self-service "join a plan" — in the foundation scope this activates immediately.
    // (The web app instead routes this through a WhatsApp lead + manual payment —
    // wire that same pattern in here later if you want parity instead of instant activation.)
    [HttpPost]
    public async Task<ActionResult<MembershipDto>> CreateMembership(CreateMembershipDto dto)
    {
        var plan = await _db.Plans.FindAsync(dto.PlanId);
        if (plan == null || !plan.IsActive)
            return BadRequest(new { error = "Plan not found or inactive." });

        // Cancel any existing active membership before starting a new one.
        var existingActive = await _db.Memberships
            .Where(m => m.UserId == CurrentUserId && m.Status == MembershipStatus.Active)
            .ToListAsync();
        foreach (var m in existingActive) m.Status = MembershipStatus.Cancelled;

        var start = DateOnly.FromDateTime(DateTime.UtcNow);
        var membership = new Membership
        {
            UserId = CurrentUserId,
            PlanId = plan.Id,
            Status = MembershipStatus.Active,
            StartDate = start,
            EndDate = start.AddDays(plan.DurationDays),
        };

        _db.Memberships.Add(membership);
        await _db.SaveChangesAsync();

        return Ok(new MembershipDto
        {
            Id = membership.Id,
            PlanName = plan.Name,
            PlanPrice = plan.Price,
            Status = membership.Status.ToString(),
            StartDate = membership.StartDate,
            EndDate = membership.EndDate,
            DaysRemaining = plan.DurationDays,
        });
    }
}
