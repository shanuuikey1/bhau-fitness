using System.Security.Claims;
using BhauFitnessApi.Models.DTOs;
using BhauFitnessApi.Models.Entities;
using BhauFitnessApi.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.RateLimiting;
using Microsoft.EntityFrameworkCore;

namespace BhauFitnessApi.Controllers;

[ApiController]
[Route("api/auth")]
[EnableRateLimiting("strict")]
public class AuthController : ControllerBase
{
    private readonly IUserService _userService;
    private readonly UserManager<ApplicationUser> _userManager;
    private readonly ITokenService _tokenService;
    private readonly IEmailSender _emailSender;

    public AuthController(
        IUserService userService,
        UserManager<ApplicationUser> userManager,
        ITokenService tokenService,
        IEmailSender emailSender)
    {
        _userService = userService;
        _userManager = userManager;
        _tokenService = tokenService;
        _emailSender = emailSender;
    }

    [HttpPost("register")]
    public async Task<ActionResult<AuthResponseDto>> Register(RegisterDto dto)
    {
        var existing = await _userService.GetUserByEmailAsync(dto.Email);
        if (existing != null)
            return Conflict(new { error = "An account with this email already exists." });

        var result = await _userService.RegisterUserAsync(dto);
        if (!result.Succeeded)
        {
            var errors = result.Errors.Select(e => e.Description);
            return BadRequest(new { error = string.Join(" ", errors) });
        }

        var user = await _userService.GetUserByEmailAsync(dto.Email);
        var roles = await _userManager.GetRolesAsync(user!);
        var (token, expires) = _tokenService.CreateToken(user!, roles);
        return Ok(new AuthResponseDto
        {
            Token = token,
            ExpiresAtUtc = expires,
            Profile = ToProfileDto(user!, roles),
        });
    }

    [HttpPost("login")]
    public async Task<ActionResult<AuthResponseDto>> Login(LoginDto dto)
    {
        var user = await _userService.GetUserByEmailAsync(dto.Email);
        if (user == null)
        {
            user = await _userManager.Users.FirstOrDefaultAsync(u => u.PhoneNumber == dto.Email);
        }
        
        if (user == null)
            return Unauthorized(new { error = "Invalid email/mobile number or password." });

        if (await _userManager.IsLockedOutAsync(user))
            return Unauthorized(new { error = "Too many failed attempts. Try again in a few minutes." });

        var passwordOk = await _userManager.CheckPasswordAsync(user, dto.Password);
        if (!passwordOk)
        {
            await _userManager.AccessFailedAsync(user); // counts towards lockout
            return Unauthorized(new { error = "Invalid email or password." });
        }
        await _userManager.ResetAccessFailedCountAsync(user);

        var roles = await _userManager.GetRolesAsync(user);
        var (token, expires) = _tokenService.CreateToken(user, roles);
        return Ok(new AuthResponseDto
        {
            Token = token,
            ExpiresAtUtc = expires,
            Profile = ToProfileDto(user, roles),
        });
    }

    [HttpPost("forgot-password")]
    public async Task<IActionResult> ForgotPassword(ForgotPasswordDto dto)
    {
        var user = await _userService.GetUserByEmailAsync(dto.Email);
        if (user != null)
        {
            try
            {
                var token = await _userManager.GeneratePasswordResetTokenAsync(user);
                var body =
                    $"<p>Hi {user.FullName},</p>" +
                    "<p>Use the code below in the BHAU FITNESS app to reset your password. " +
                    "It expires shortly, so use it soon.</p>" +
                    $"<p style=\"font-family:monospace;background:#f4f4f4;padding:12px;word-break:break-all\">{token}</p>" +
                    "<p>If you didn't request this, you can safely ignore this email.</p>";
                await _emailSender.SendAsync(user.Email!, "Reset your BHAU FITNESS password", body);
            }
            catch
            {
                // Silence SMTP errors in dev
            }
        }
        return Ok();
    }

    [HttpPost("reset-password")]
    public async Task<IActionResult> ResetPassword(ResetPasswordDto dto)
    {
        var user = await _userService.GetUserByEmailAsync(dto.Email);
        if (user == null)
            return BadRequest(new { error = "Invalid email or expired token." });

        var result = await _userManager.ResetPasswordAsync(user, dto.Token, dto.NewPassword);
        if (!result.Succeeded)
        {
            var errors = result.Errors.Select(e => e.Description);
            return BadRequest(new { error = string.Join(" ", errors) });
        }
        return Ok();
    }

    [Authorize]
    [HttpGet("profile")]
    public async Task<ActionResult<MemberProfileDto>> GetProfile()
    {
        var userId = User.FindFirstValue(ClaimTypes.NameIdentifier) ?? User.FindFirstValue("sub");
        var user = await _userService.GetUserByIdAsync(userId!);
        if (user == null) return NotFound();

        var roles = await _userManager.GetRolesAsync(user);
        return Ok(ToProfileDto(user, roles));
    }

    private static MemberProfileDto ToProfileDto(ApplicationUser user, IList<string> roles) => new()
    {
        Id = user.Id,
        Email = user.Email!,
        FullName = user.FullName,
        Phone = user.PhoneNumber ?? string.Empty,
        Goal = user.Goal,
        MemberCode = user.MemberCode,
        Role = roles.Contains("Admin") ? "Admin" : "Member"
    };
}
