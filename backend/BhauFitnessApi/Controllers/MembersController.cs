using System.Security.Claims;
using BhauFitnessApi.Models.DTOs;
using BhauFitnessApi.Models.Entities;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;

namespace BhauFitnessApi.Controllers;

[ApiController]
[Route("api/members")]
[Authorize] // every endpoint here requires a valid JWT
public class MembersController : ControllerBase
{
    private readonly UserManager<ApplicationUser> _userManager;

    public MembersController(UserManager<ApplicationUser> userManager)
    {
        _userManager = userManager;
    }

    private string CurrentUserId =>
        User.FindFirstValue(ClaimTypes.NameIdentifier) ?? User.FindFirstValue("sub")!;

    [HttpGet("me")]
    public async Task<ActionResult<MemberProfileDto>> GetMe()
    {
        var user = await _userManager.FindByIdAsync(CurrentUserId);
        if (user == null) return NotFound();

        return Ok(await ToProfileDto(user));
    }

    [HttpPut("me")]
    public async Task<ActionResult<MemberProfileDto>> UpdateMe(UpdateProfileDto dto)
    {
        var user = await _userManager.FindByIdAsync(CurrentUserId);
        if (user == null) return NotFound();

        user.FullName = dto.FullName;
        user.PhoneNumber = dto.Phone;
        user.Goal = dto.Goal;

        var result = await _userManager.UpdateAsync(user);
        if (!result.Succeeded)
        {
            var errors = result.Errors.Select(e => e.Description);
            return BadRequest(new { error = string.Join(" ", errors) });
        }

        return Ok(await ToProfileDto(user));
    }

    private async Task<MemberProfileDto> ToProfileDto(ApplicationUser user)
    {
        var roles = await _userManager.GetRolesAsync(user);
        return new MemberProfileDto
        {
            Id = user.Id,
            FullName = user.FullName,
            Email = user.Email ?? string.Empty,
            Phone = user.PhoneNumber ?? string.Empty,
            Goal = user.Goal,
            MemberCode = user.MemberCode,
            Role = roles.Contains("Admin") ? "Admin" : "Member",
        };
    }
}
