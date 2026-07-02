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

    // NOTE: the old self-service POST /api/memberships endpoint (instant free
    // activation, no payment) was removed — memberships are granted only via
    // the verified payment flow (PaymentsController) or by an admin
    // (AdminController.GrantMembership).
}
