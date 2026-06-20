using BhauFitnessApi.Data;
using BhauFitnessApi.Models.DTOs;
using BhauFitnessApi.Models.Entities;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace BhauFitnessApi.Controllers;

[ApiController]
[Route("api/plans")]
public class PlansController : ControllerBase
{
    private readonly ApplicationDbContext _db;

    public PlansController(ApplicationDbContext db)
    {
        _db = db;
    }

    // Public — visitors should see pricing before logging in, same as the web app.
    [HttpGet]
    public async Task<ActionResult<List<PlanDto>>> GetPlans()
    {
        var plans = await _db.Plans
            .Where(p => p.IsActive)
            .OrderBy(p => p.Price)
            .Select(p => new PlanDto
            {
                Id = p.Id,
                Name = p.Name,
                Price = p.Price,
                DurationDays = p.DurationDays,
                Description = p.Description,
            })
            .ToListAsync();

        return Ok(plans);
    }

    [HttpPost]
    [Authorize(Roles = "Admin")]
    public async Task<ActionResult<PlanDto>> CreatePlan(CreatePlanDto dto)
    {
        var plan = new Plan
        {
            Name = dto.Name,
            Price = dto.Price,
            DurationDays = dto.DurationDays,
            Description = dto.Description,
            IsActive = true,
        };
        _db.Plans.Add(plan);
        await _db.SaveChangesAsync();

        return Ok(new PlanDto { Id = plan.Id, Name = plan.Name, Price = plan.Price, DurationDays = plan.DurationDays, Description = plan.Description });
    }

    [HttpPut("{id:int}")]
    [Authorize(Roles = "Admin")]
    public async Task<ActionResult<PlanDto>> UpdatePlan(int id, UpdatePlanDto dto)
    {
        var plan = await _db.Plans.FindAsync(id);
        if (plan == null) return NotFound();

        plan.Name = dto.Name;
        plan.Price = dto.Price;
        plan.DurationDays = dto.DurationDays;
        plan.IsActive = dto.IsActive;
        plan.Description = dto.Description;
        await _db.SaveChangesAsync();

        return Ok(new PlanDto { Id = plan.Id, Name = plan.Name, Price = plan.Price, DurationDays = plan.DurationDays, Description = plan.Description });
    }
}
