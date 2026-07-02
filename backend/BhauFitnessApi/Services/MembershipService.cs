using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BhauFitnessApi.Data;
using BhauFitnessApi.Models.DTOs;
using BhauFitnessApi.Models.Entities;
using Microsoft.EntityFrameworkCore;

namespace BhauFitnessApi.Services;

public class MembershipService : IMembershipService
{
    private readonly ApplicationDbContext _db;
    private readonly RazorpayService _razorpayService;

    public MembershipService(ApplicationDbContext db, RazorpayService razorpayService)
    {
        _db = db;
        _razorpayService = razorpayService;
    }

    public async Task<Membership?> GetActiveMembershipAsync(string userId)
    {
        return await _db.Memberships
            .Include(m => m.Plan)
            .FirstOrDefaultAsync(m => m.UserId == userId && m.Status == MembershipStatus.Active);
    }

    public async Task<IEnumerable<Payment>> GetPaymentHistoryAsync(string userId)
    {
        return await _db.Payments
            .Include(p => p.Plan)
            .Where(p => p.UserId == userId)
            .OrderByDescending(p => p.CreatedAt)
            .ToListAsync();
    }

    public async Task<Payment> CreateOrderAsync(string userId, int planId)
    {
        var plan = await _db.Plans.FindAsync(planId);
        if (plan == null || !plan.IsActive)
        {
            throw new ArgumentException("Plan not found or inactive.");
        }

        string orderId = await _razorpayService.CreateOrderAsync(plan.Price, "INR", $"receipt_plan_{plan.Id}");

        var payment = new Payment
        {
            UserId = userId,
            PlanId = plan.Id,
            RazorpayOrderId = orderId,
            Amount = plan.Price,
            Currency = "INR",
            Status = PaymentStatus.Created,
            CreatedAt = DateTime.UtcNow
        };

        _db.Payments.Add(payment);
        await _db.SaveChangesAsync();

        return payment;
    }

    public async Task<bool> VerifyPaymentAsync(string userId, VerifyPaymentDto dto)
    {
        var payment = await _db.Payments
            .FirstOrDefaultAsync(p => p.RazorpayOrderId == dto.RazorpayOrderId);

        if (payment == null || payment.UserId != userId)
        {
            throw new KeyNotFoundException("Payment order record not found.");
        }

        // Idempotency guard: a settled order can't be re-verified to mint
        // another membership (replay protection).
        if (payment.Status == PaymentStatus.Paid)
        {
            return true;
        }

        bool isValid = _razorpayService.VerifySignature(dto.RazorpayOrderId, dto.RazorpayPaymentId, dto.RazorpaySignature);
        if (!isValid)
        {
            payment.Status = PaymentStatus.Failed;
            await _db.SaveChangesAsync();
            return false;
        }

        payment.RazorpayPaymentId = dto.RazorpayPaymentId;
        payment.RazorpaySignature = dto.RazorpaySignature;
        payment.Status = PaymentStatus.Paid;

        // Grant the membership!
        var plan = await _db.Plans.FindAsync(payment.PlanId);
        if (plan != null)
        {
            // Cancel any existing active memberships
            var existingActive = await _db.Memberships
                .Where(m => m.UserId == payment.UserId && m.Status == MembershipStatus.Active)
                .ToListAsync();
            foreach (var m in existingActive)
            {
                m.Status = MembershipStatus.Cancelled;
            }

            var start = DateOnly.FromDateTime(DateTime.UtcNow);
            var membership = new Membership
            {
                UserId = payment.UserId,
                PlanId = plan.Id,
                Status = MembershipStatus.Active,
                StartDate = start,
                EndDate = start.AddDays(plan.DurationDays),
            };

            _db.Memberships.Add(membership);
        }

        await _db.SaveChangesAsync();
        return true;
    }
}
