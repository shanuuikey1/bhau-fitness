using System.Security.Claims;
using BhauFitnessApi.Data;
using BhauFitnessApi.Models.DTOs;
using BhauFitnessApi.Models.Entities;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace BhauFitnessApi.Controllers;

[ApiController]
[Route("api/bookings")]
[Authorize]
public class BookingsController : ControllerBase
{
    private readonly ApplicationDbContext _db;

    public BookingsController(ApplicationDbContext db)
    {
        _db = db;
    }

    private string CurrentUserId =>
        User.FindFirstValue(ClaimTypes.NameIdentifier) ?? User.FindFirstValue("sub")!;

    [HttpGet("me")]
    public async Task<ActionResult<List<BookingDto>>> GetMine()
    {
        var today = DateOnly.FromDateTime(DateTime.UtcNow);
        var bookings = await _db.Bookings
            .Include(b => b.ClassSession)
            .Where(b => b.UserId == CurrentUserId && b.Status == BookingStatus.Booked && b.ClassDate >= today)
            .OrderBy(b => b.ClassDate).ThenBy(b => b.ClassSession!.StartTime)
            .ToListAsync();

        return Ok(bookings.Select(ToDto).ToList());
    }

    [HttpPost]
    public async Task<ActionResult<BookingDto>> Book(CreateBookingDto dto)
    {
        var session = await _db.ClassSessions.FindAsync(dto.ClassSessionId);
        if (session == null || !session.IsActive)
            return BadRequest(new { error = "Class not found." });

        // ClassSession.DayOfWeek uses ISO convention (1=Monday..7=Sunday); DateOnly.DayOfWeek
        // uses .NET's convention (0=Sunday..6=Saturday), so map Sunday to 7 before comparing.
        var isoDayOfWeek = dto.ClassDate.DayOfWeek == DayOfWeek.Sunday ? 7 : (int)dto.ClassDate.DayOfWeek;
        if (isoDayOfWeek != session.DayOfWeek)
            return BadRequest(new { error = "That date doesn't match this class's weekly slot." });

        var alreadyBooked = await _db.Bookings.AnyAsync(b =>
            b.UserId == CurrentUserId && b.ClassSessionId == dto.ClassSessionId &&
            b.ClassDate == dto.ClassDate && b.Status == BookingStatus.Booked);
        if (alreadyBooked)
            return BadRequest(new { error = "You've already booked this class." });

        var bookedCount = await _db.Bookings.CountAsync(b =>
            b.ClassSessionId == dto.ClassSessionId && b.ClassDate == dto.ClassDate && b.Status == BookingStatus.Booked);
        if (bookedCount >= session.Capacity)
            return BadRequest(new { error = "This class is full." });

        var booking = new Booking
        {
            UserId = CurrentUserId,
            ClassSessionId = dto.ClassSessionId,
            ClassDate = dto.ClassDate,
            Status = BookingStatus.Booked,
        };
        _db.Bookings.Add(booking);
        await _db.SaveChangesAsync();

        booking.ClassSession = session;
        return Ok(ToDto(booking));
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Cancel(int id)
    {
        var booking = await _db.Bookings.FirstOrDefaultAsync(b => b.Id == id && b.UserId == CurrentUserId);
        if (booking == null) return NotFound();

        booking.Status = BookingStatus.Cancelled;
        await _db.SaveChangesAsync();
        return NoContent();
    }

    private static BookingDto ToDto(Booking b) => new()
    {
        Id = b.Id,
        ClassSessionId = b.ClassSessionId,
        ClassTitle = b.ClassSession?.Title ?? string.Empty,
        TrainerName = b.ClassSession?.TrainerName ?? string.Empty,
        StartTime = b.ClassSession?.StartTime ?? default,
        ClassDate = b.ClassDate,
        Status = b.Status.ToString(),
    };
}
