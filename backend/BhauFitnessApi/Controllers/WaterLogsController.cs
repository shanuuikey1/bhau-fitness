using System.Security.Claims;
using BhauFitnessApi.Data;
using BhauFitnessApi.Models.DTOs;
using BhauFitnessApi.Models.Entities;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace BhauFitnessApi.Controllers;

[ApiController]
[Route("api/waterlogs")]
[Authorize]
public class WaterLogsController : ControllerBase
{
    private readonly ApplicationDbContext _db;

    public WaterLogsController(ApplicationDbContext db)
    {
        _db = db;
    }

    private string CurrentUserId =>
        User.FindFirstValue(ClaimTypes.NameIdentifier) ?? User.FindFirstValue("sub")!;

    [HttpGet("today")]
    public async Task<ActionResult<WaterLogDto>> GetToday()
    {
        var today = DateOnly.FromDateTime(DateTime.UtcNow);
        var log = await _db.WaterLogs.FirstOrDefaultAsync(w => w.UserId == CurrentUserId && w.LogDate == today);

        return Ok(new WaterLogDto { LogDate = today, GlassCount = log?.GlassCount ?? 0 });
    }

    // Upserts today's glass count — the Flutter water tracker calls this on every tap.
    [HttpPut("today")]
    public async Task<ActionResult<WaterLogDto>> SetToday(SetWaterLogDto dto)
    {
        var today = DateOnly.FromDateTime(DateTime.UtcNow);
        var log = await _db.WaterLogs.FirstOrDefaultAsync(w => w.UserId == CurrentUserId && w.LogDate == today);

        if (log == null)
        {
            log = new WaterLog { UserId = CurrentUserId, LogDate = today, GlassCount = dto.GlassCount };
            _db.WaterLogs.Add(log);
        }
        else
        {
            log.GlassCount = dto.GlassCount;
        }

        await _db.SaveChangesAsync();
        return Ok(new WaterLogDto { LogDate = today, GlassCount = log.GlassCount });
    }
}
