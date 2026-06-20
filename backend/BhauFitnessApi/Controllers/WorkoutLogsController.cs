using System.Security.Claims;
using BhauFitnessApi.Data;
using BhauFitnessApi.Models.DTOs;
using BhauFitnessApi.Models.Entities;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace BhauFitnessApi.Controllers;

[ApiController]
[Route("api/workoutlogs")]
[Authorize]
public class WorkoutLogsController : ControllerBase
{
    private readonly ApplicationDbContext _db;

    public WorkoutLogsController(ApplicationDbContext db)
    {
        _db = db;
    }

    private string CurrentUserId =>
        User.FindFirstValue(ClaimTypes.NameIdentifier) ?? User.FindFirstValue("sub")!;

    // Most recent 50 entries — enough for the dashboard's workout log list and progress charts.
    [HttpGet]
    public async Task<ActionResult<List<WorkoutLogDto>>> GetMine()
    {
        var logs = await _db.WorkoutLogs
            .Where(w => w.UserId == CurrentUserId)
            .OrderByDescending(w => w.LoggedDate).ThenByDescending(w => w.Id)
            .Take(50)
            .ToListAsync();

        return Ok(logs.Select(ToDto).ToList());
    }

    [HttpPost]
    public async Task<ActionResult<WorkoutLogDto>> Create(CreateWorkoutLogDto dto)
    {
        var log = new WorkoutLog
        {
            UserId = CurrentUserId,
            Exercise = dto.Exercise,
            Sets = dto.Sets,
            Reps = dto.Reps,
            WeightKg = dto.WeightKg,
            LoggedDate = DateOnly.FromDateTime(DateTime.UtcNow),
        };
        _db.WorkoutLogs.Add(log);
        await _db.SaveChangesAsync();
        return Ok(ToDto(log));
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id)
    {
        var log = await _db.WorkoutLogs.FirstOrDefaultAsync(w => w.Id == id && w.UserId == CurrentUserId);
        if (log == null) return NotFound();

        _db.WorkoutLogs.Remove(log);
        await _db.SaveChangesAsync();
        return NoContent();
    }

    private static WorkoutLogDto ToDto(WorkoutLog w) => new()
    {
        Id = w.Id,
        Exercise = w.Exercise,
        Sets = w.Sets,
        Reps = w.Reps,
        WeightKg = w.WeightKg,
        LoggedDate = w.LoggedDate,
    };
}
