using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BhauFitnessApi.Data;
using BhauFitnessApi.Models.Entities;
using Microsoft.EntityFrameworkCore;

namespace BhauFitnessApi.Services;

public class ClassService : IClassService
{
    private readonly ApplicationDbContext _db;

    public ClassService(ApplicationDbContext db)
    {
        _db = db;
    }

    public async Task<IEnumerable<ClassSession>> GetWeeklyScheduleAsync()
    {
        return await _db.ClassSessions
            .Where(c => c.IsActive)
            .OrderBy(c => c.DayOfWeek).ThenBy(c => c.StartTime)
            .ToListAsync();
    }

    public async Task<Booking> BookClassAsync(string userId, int classSessionId, DateOnly classDate)
    {
        var session = await _db.ClassSessions.FindAsync(classSessionId);
        if (session == null || !session.IsActive)
        {
            throw new KeyNotFoundException("Class not found.");
        }

        if (classDate < DateOnly.FromDateTime(DateTime.UtcNow))
        {
            throw new ArgumentException("That class date has already passed.");
        }

        var isoDayOfWeek = classDate.DayOfWeek == DayOfWeek.Sunday ? 7 : (int)classDate.DayOfWeek;
        if (isoDayOfWeek != session.DayOfWeek)
        {
            throw new ArgumentException("That date doesn't match this class's weekly slot.");
        }

        var alreadyBooked = await _db.Bookings.AnyAsync(b =>
            b.UserId == userId && b.ClassSessionId == classSessionId &&
            b.ClassDate == classDate && b.Status == BookingStatus.Booked);
        if (alreadyBooked)
        {
            throw new InvalidOperationException("You've already booked this class.");
        }

        var bookedCount = await _db.Bookings.CountAsync(b =>
            b.ClassSessionId == classSessionId && b.ClassDate == classDate && b.Status == BookingStatus.Booked);
        if (bookedCount >= session.Capacity)
        {
            throw new InvalidOperationException("This class is full.");
        }

        var booking = new Booking
        {
            UserId = userId,
            ClassSessionId = classSessionId,
            ClassDate = classDate,
            Status = BookingStatus.Booked,
        };

        _db.Bookings.Add(booking);
        await _db.SaveChangesAsync();

        booking.ClassSession = session;
        return booking;
    }

    public async Task<bool> CancelBookingAsync(string userId, int bookingId)
    {
        var booking = await _db.Bookings.FirstOrDefaultAsync(b => b.Id == bookingId && b.UserId == userId);
        if (booking == null)
        {
            return false;
        }

        booking.Status = BookingStatus.Cancelled;
        await _db.SaveChangesAsync();
        return true;
    }

    public async Task<IEnumerable<Booking>> GetUpcomingBookingsAsync(string userId)
    {
        var today = DateOnly.FromDateTime(DateTime.UtcNow);
        return await _db.Bookings
            .Include(b => b.ClassSession)
            .Where(b => b.UserId == userId && b.Status == BookingStatus.Booked && b.ClassDate >= today)
            .OrderBy(b => b.ClassDate).ThenBy(b => b.ClassSession!.StartTime)
            .ToListAsync();
    }
}
