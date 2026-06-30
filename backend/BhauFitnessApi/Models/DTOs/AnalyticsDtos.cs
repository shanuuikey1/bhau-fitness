using System;
using System.Collections.Generic;

namespace BhauFitnessApi.Models.DTOs
{
    public class AnalyticsOverviewDto
    {
        public int TotalMembers { get; set; }
        public int ActiveMemberships { get; set; }
        public decimal TotalRevenue { get; set; }
        public decimal MonthlyRevenue { get; set; }
        public int NewSignupsThisMonth { get; set; }
        public double ChurnRate { get; set; }
        public int TodayBookings { get; set; }
        public int TotalClassesBooked { get; set; }
    }

    public class MonthlyRevenueDto
    {
        public string Month { get; set; } = string.Empty; // e.g. "Jan 2026"
        public decimal Revenue { get; set; }
        public int NewMembers { get; set; }
    }

    public class PopularClassDto
    {
        public string ClassName { get; set; } = string.Empty;
        public int TotalBookings { get; set; }
    }

    public class MembershipDistributionDto
    {
        public string PlanName { get; set; } = string.Empty;
        public int ActiveCount { get; set; }
        public double Percentage { get; set; }
    }
}
