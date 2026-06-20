using BhauFitnessApi.Data;
using BhauFitnessApi.Models.DTOs;
using BhauFitnessApi.Models.Entities;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace BhauFitnessApi.Controllers;

[ApiController]
[Route("api/classes")]
public class ClassesController : ControllerBase
{
    private readonly ApplicationDbContext _db;

    public ClassesController(ApplicationDbContext db)
    {
        _db = db;
    }

    // Public — visitors can see the weekly schedule before logging in, same as the web app.
    // Optional ?date=yyyy-MM-dd gives BookedCount for that specific occurrence; without it,
    // BookedCount is always 0 (just the weekly template).
    [HttpGet]
    public async Task<ActionResult<List<ClassSessionDto>>> GetClasses([FromQuery] DateOnly? date)
    {
        var sessions = await _db.ClassSessions
            .Where(c => c.IsActive)
            .OrderBy(c => c.DayOfWeek).ThenBy(c => c.StartTime)
            .ToListAsync();

        var bookedCounts = date == null
            ? new Dictionary<int, int>()
            : await _db.Bookings
                .Where(b => b.ClassDate == date && b.Status == BookingStatus.Booked)
                .GroupBy(b => b.ClassSessionId)
                .ToDictionaryAsync(g => g.Key, g => g.Count());

        return Ok(sessions.Select(c => new ClassSessionDto
        {
            Id = c.Id,
            DayOfWeek = c.DayOfWeek,
            StartTime = c.StartTime,
            Title = c.Title,
            TrainerName = c.TrainerName,
            Level = c.Level,
            Type = c.Type,
            DurationMin = c.DurationMin,
            DayLabel = c.DayLabel,
            Capacity = c.Capacity,
            BookedCount = bookedCounts.GetValueOrDefault(c.Id, 0),
        }).ToList());
    }

    [HttpPost]
    [Authorize(Roles = "Admin")]
    public async Task<ActionResult<ClassSessionDto>> CreateClass(CreateClassSessionDto dto)
    {
        var session = new ClassSession
        {
            DayOfWeek = dto.DayOfWeek,
            StartTime = dto.StartTime,
            Title = dto.Title,
            TrainerName = dto.TrainerName,
            Level = dto.Level,
            Type = dto.Type,
            DurationMin = dto.DurationMin,
            DayLabel = dto.DayLabel,
            Capacity = dto.Capacity,
            IsActive = true,
        };
        _db.ClassSessions.Add(session);
        await _db.SaveChangesAsync();

        return Ok(new ClassSessionDto
        {
            Id = session.Id,
            DayOfWeek = session.DayOfWeek,
            StartTime = session.StartTime,
            Title = session.Title,
            TrainerName = session.TrainerName,
            Level = session.Level,
            Type = session.Type,
            DurationMin = session.DurationMin,
            DayLabel = session.DayLabel,
            Capacity = session.Capacity,
            BookedCount = 0,
        });
    }

    [HttpDelete("{id:int}")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> DeactivateClass(int id)
    {
        var session = await _db.ClassSessions.FindAsync(id);
        if (session == null) return NotFound();

        session.IsActive = false;
        await _db.SaveChangesAsync();
        return NoContent();
    }
}
