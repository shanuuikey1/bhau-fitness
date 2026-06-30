using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;
using System.Threading.Tasks;
using BhauFitnessApi.Models.DTOs;
using BhauFitnessApi.Models.Entities;
using BhauFitnessApi.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace BhauFitnessApi.Controllers;

[ApiController]
[Route("api/bookings")]
[Authorize]
public class BookingsController : ControllerBase
{
    private readonly IClassService _classService;

    public BookingsController(IClassService classService)
    {
        _classService = classService;
    }

    private string CurrentUserId =>
        User.FindFirstValue(ClaimTypes.NameIdentifier) ?? User.FindFirstValue("sub")!;

    [HttpGet("me")]
    public async Task<ActionResult<List<BookingDto>>> GetMine()
    {
        var bookings = await _classService.GetUpcomingBookingsAsync(CurrentUserId);
        return Ok(bookings.Select(ToDto).ToList());
    }

    [HttpPost]
    public async Task<ActionResult<BookingDto>> Book(CreateBookingDto dto)
    {
        try
        {
            var booking = await _classService.BookClassAsync(CurrentUserId, dto.ClassSessionId, dto.ClassDate);
            return Ok(ToDto(booking));
        }
        catch (KeyNotFoundException ex)
        {
            return BadRequest(new { error = ex.Message });
        }
        catch (ArgumentException ex)
        {
            return BadRequest(new { error = ex.Message });
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { error = ex.Message });
        }
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Cancel(int id)
    {
        bool didCancel = await _classService.CancelBookingAsync(CurrentUserId, id);
        if (!didCancel)
        {
            return NotFound();
        }
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
