using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using BhauFitnessApi.Data;
using BhauFitnessApi.Models.DTOs;
using BhauFitnessApi.Models.Entities;

namespace BhauFitnessApi.Controllers
{
    [Authorize(Roles = "Admin")]
    [ApiController]
    [Route("api/analytics")]
    public class AnalyticsController : ControllerBase
    {
        private readonly ApplicationDbContext _db;

        public AnalyticsController(ApplicationDbContext db)
        {
            _db = db;
        }

        [HttpGet("overview")]
        public async Task<ActionResult<AnalyticsOverviewDto>> GetOverview()
        {
            int totalMembers = await _db.Users.CountAsync();
            int activeMemberships = await _db.Memberships.CountAsync(m => m.Status == MembershipStatus.Active);

            // Revenue = money actually collected (paid payments), not the
            // nominal plan price of memberships (which includes admin-granted
            // freebies and would overstate earnings).
            decimal totalRevenue = await _db.Payments
                .Where(p => p.Status == PaymentStatus.Paid)
                .SumAsync(p => (decimal?)p.Amount) ?? 0m;

            // Monthly revenue (current month)
            var now = DateTime.UtcNow;
            var startOfMonth = new DateTime(now.Year, now.Month, 1, 0, 0, 0, DateTimeKind.Utc);
            decimal monthlyRevenue = await _db.Payments
                .Where(p => p.Status == PaymentStatus.Paid && p.CreatedAt >= startOfMonth)
                .SumAsync(p => (decimal?)p.Amount) ?? 0m;

            int newSignupsThisMonth = await _db.Users
                .CountAsync(u => u.CreatedAt.Year == now.Year && u.CreatedAt.Month == now.Month);

            // Churn rate: expired or cancelled memberships / total memberships
            int inactiveMemberships = await _db.Memberships
                .CountAsync(m => m.Status == MembershipStatus.Expired || m.Status == MembershipStatus.Cancelled);
            int totalMemberships = await _db.Memberships.CountAsync();
            double churnRate = totalMemberships > 0 
                ? Math.Round((double)inactiveMemberships / totalMemberships * 100, 1) 
                : 0.0;

            var today = DateOnly.FromDateTime(DateTime.UtcNow);
            int todayBookings = await _db.Bookings.CountAsync(b => b.ClassDate == today);
            int totalClassesBooked = await _db.Bookings.CountAsync();

            return Ok(new AnalyticsOverviewDto
            {
                TotalMembers = totalMembers,
                ActiveMemberships = activeMemberships,
                TotalRevenue = totalRevenue,
                MonthlyRevenue = monthlyRevenue,
                NewSignupsThisMonth = newSignupsThisMonth,
                ChurnRate = churnRate,
                TodayBookings = todayBookings,
                TotalClassesBooked = totalClassesBooked
            });
        }

        [HttpGet("revenue-trend")]
        public async Task<ActionResult<List<MonthlyRevenueDto>>> GetRevenueTrend()
        {
            // Actual collected payments from the last 12 months.
            var oneYearAgo = DateTime.UtcNow.AddMonths(-12);
            var payments = await _db.Payments
                .Where(p => p.Status == PaymentStatus.Paid && p.CreatedAt >= oneYearAgo)
                .ToListAsync();

            // Group in-memory for simpler LINQ translation
            var trend = payments
                .GroupBy(p => new { p.CreatedAt.Year, p.CreatedAt.Month })
                .OrderBy(g => g.Key.Year)
                .ThenBy(g => g.Key.Month)
                .Select(g => new MonthlyRevenueDto
                {
                    Month = new DateTime(g.Key.Year, g.Key.Month, 1).ToString("MMM yyyy"),
                    Revenue = g.Sum(p => p.Amount),
                    NewMembers = g.Select(p => p.UserId).Distinct().Count()
                })
                .ToList();

            return Ok(trend);
        }

        [HttpGet("popular-classes")]
        public async Task<ActionResult<List<PopularClassDto>>> GetPopularClasses()
        {
            var popular = await _db.Bookings
                .Include(b => b.ClassSession)
                .Where(b => b.ClassSession != null)
                .GroupBy(b => b.ClassSession!.Title)
                .Select(g => new PopularClassDto
                {
                    ClassName = g.Key,
                    TotalBookings = g.Count()
                })
                .OrderByDescending(c => c.TotalBookings)
                .Take(5)
                .ToListAsync();

            return Ok(popular);
        }

        [HttpGet("membership-distribution")]
        public async Task<ActionResult<List<MembershipDistributionDto>>> GetMembershipDistribution()
        {
            var activeMembers = await _db.Memberships
                .Include(m => m.Plan)
                .Where(m => m.Status == MembershipStatus.Active && m.Plan != null)
                .ToListAsync();

            int totalActive = activeMembers.Count;

            var dist = activeMembers
                .GroupBy(m => m.Plan!.Name)
                .Select(g => new MembershipDistributionDto
                {
                    PlanName = g.Key,
                    ActiveCount = g.Count(),
                    Percentage = totalActive > 0 ? Math.Round((double)g.Count() / totalActive * 100, 1) : 0.0
                })
                .ToList();

            return Ok(dist);
        }
    }
}
