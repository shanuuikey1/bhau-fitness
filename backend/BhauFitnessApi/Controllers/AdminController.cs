using BhauFitnessApi.Data;
using BhauFitnessApi.Models.DTOs;
using BhauFitnessApi.Models.Entities;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace BhauFitnessApi.Controllers;

[ApiController]
[Route("api/admin")]
[Authorize(Roles = "Admin")]
public class AdminController : ControllerBase
{
    private readonly ApplicationDbContext _db;
    private readonly UserManager<ApplicationUser> _userManager;

    public AdminController(ApplicationDbContext db, UserManager<ApplicationUser> userManager)
    {
        _db = db;
        _userManager = userManager;
    }

    [HttpGet("overview")]
    public async Task<ActionResult<AdminOverviewDto>> GetOverview()
    {
        var totalMembers = await _db.Users.CountAsync();

        var activeMemberships = await _db.Memberships
            .Include(m => m.Plan)
            .Where(m => m.Status == MembershipStatus.Active)
            .ToListAsync();

        var planDistribution = activeMemberships
            .GroupBy(m => m.Plan!.Name)
            .Select(g => new PlanDistributionDto { PlanName = g.Key, MemberCount = g.Count() })
            .ToList();

        var recentSignups = await _db.Users
            .OrderByDescending(u => u.CreatedAt)
            .Take(5)
            .Select(u => new AdminMemberSummaryDto
            {
                Id = u.Id,
                FullName = u.FullName,
                Email = u.Email ?? string.Empty,
                MemberCode = u.MemberCode,
                CreatedAt = u.CreatedAt,
            })
            .ToListAsync();

        var activeClasses = await _db.ClassSessions.CountAsync(c => c.IsActive);

        return Ok(new AdminOverviewDto
        {
            TotalMembers = totalMembers,
            ActiveMemberships = activeMemberships.Count,
            MonthlyRecurringRevenue = activeMemberships.Sum(m => m.Plan!.Price),
            ActiveClasses = activeClasses,
            RecentSignups = recentSignups,
            PlanDistribution = planDistribution,
        });
    }

    [HttpGet("members")]
    public async Task<ActionResult<List<AdminMemberSummaryDto>>> GetMembers([FromQuery] string? search)
    {
        var query = _db.Users.AsQueryable();
        if (!string.IsNullOrWhiteSpace(search))
        {
            // ToLower keeps the search case-insensitive on Postgres too (SQL
            // Server's default collation already is; Postgres' is not).
            var term = search.ToLower();
            query = query.Where(u =>
                u.FullName.ToLower().Contains(term)
                || u.Email!.ToLower().Contains(term)
                || u.MemberCode.ToLower().Contains(term));
        }

        var users = await query.OrderByDescending(u => u.CreatedAt).ToListAsync();
        var userIds = users.Select(u => u.Id).ToList();

        var activeMemberships = await _db.Memberships
            .Include(m => m.Plan)
            .Where(m => userIds.Contains(m.UserId) && m.Status == MembershipStatus.Active)
            .ToListAsync();
        var membershipByUser = activeMemberships.ToDictionary(m => m.UserId);

        return Ok(users.Select(u =>
        {
            membershipByUser.TryGetValue(u.Id, out var membership);
            return new AdminMemberSummaryDto
            {
                Id = u.Id,
                FullName = u.FullName,
                Email = u.Email ?? string.Empty,
                MemberCode = u.MemberCode,
                PlanName = membership?.Plan?.Name,
                MembershipStatus = membership?.Status.ToString(),
                CreatedAt = u.CreatedAt,
            };
        }).ToList());
    }

    // Promotes an existing member to Admin. Bootstrapping the very first admin
    // still needs a one-time manual step (see README) since this endpoint
    // itself requires an existing admin to call it.
    [HttpPost("members/{id}/promote")]
    public async Task<IActionResult> PromoteToAdmin(string id)
    {
        var user = await _userManager.FindByIdAsync(id);
        if (user == null) return NotFound();

        if (!await _userManager.IsInRoleAsync(user, "Admin"))
        {
            await _userManager.AddToRoleAsync(user, "Admin");
        }

        return NoContent();
    }

    // Admin assigns a plan directly to a member (skips self-service signup).
    // Cancels any existing active membership first, same as self-service join.
    [HttpPost("members/{id}/grant")]
    public async Task<IActionResult> GrantMembership(string id, GrantMembershipDto dto)
    {
        var user = await _userManager.FindByIdAsync(id);
        if (user == null) return NotFound();

        var plan = await _db.Plans.FindAsync(dto.PlanId);
        if (plan == null || !plan.IsActive)
            return BadRequest(new { error = "Plan not found or inactive." });

        var existingActive = await _db.Memberships
            .Where(m => m.UserId == id && m.Status == MembershipStatus.Active)
            .ToListAsync();
        foreach (var m in existingActive) m.Status = MembershipStatus.Cancelled;

        var start = DateOnly.FromDateTime(DateTime.UtcNow);
        _db.Memberships.Add(new Membership
        {
            UserId = id,
            PlanId = plan.Id,
            Status = MembershipStatus.Active,
            StartDate = start,
            EndDate = start.AddDays(plan.DurationDays),
        });
        await _db.SaveChangesAsync();
        return NoContent();
    }

    // Cancels a member's active membership(s) — used by the admin "deactivate"
    // action. Doesn't delete the account or its history.
    [HttpPost("members/{id}/deactivate")]
    public async Task<IActionResult> DeactivateMember(string id)
    {
        var user = await _userManager.FindByIdAsync(id);
        if (user == null) return NotFound();

        var active = await _db.Memberships
            .Where(m => m.UserId == id && m.Status == MembershipStatus.Active)
            .ToListAsync();
        foreach (var m in active) m.Status = MembershipStatus.Cancelled;
        await _db.SaveChangesAsync();
        return NoContent();
    }
}
