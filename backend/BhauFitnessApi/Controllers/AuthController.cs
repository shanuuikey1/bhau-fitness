using BhauFitnessApi.Data;
using BhauFitnessApi.Models.DTOs;
using BhauFitnessApi.Models.Entities;
using BhauFitnessApi.Services;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace BhauFitnessApi.Controllers;

[ApiController]
[Route("api/auth")]
public class AuthController : ControllerBase
{
    private readonly UserManager<ApplicationUser> _userManager;
    private readonly ITokenService _tokenService;
    private readonly ApplicationDbContext _db;
    private readonly IEmailSender _emailSender;

    public AuthController(
        UserManager<ApplicationUser> userManager,
        ITokenService tokenService,
        ApplicationDbContext db,
        IEmailSender emailSender)
    {
        _userManager = userManager;
        _tokenService = tokenService;
        _db = db;
        _emailSender = emailSender;
    }

    [HttpPost("register")]
    public async Task<ActionResult<AuthResponseDto>> Register(RegisterDto dto)
    {
        var existing = await _userManager.FindByEmailAsync(dto.Email);
        if (existing != null)
            return Conflict(new { error = "An account with this email already exists." });

        // Generate a simple sequential-looking member code, e.g. BHAU-0007.
        var memberCount = await _db.Users.CountAsync();
        var memberCode = $"BHAU-{(memberCount + 1):D4}";

        var user = new ApplicationUser
        {
            UserName = dto.Email,
            Email = dto.Email,
            PhoneNumber = dto.Phone,
            FullName = dto.FullName,
            Goal = dto.Goal,
            MemberCode = memberCode,
        };

        var result = await _userManager.CreateAsync(user, dto.Password);
        if (!result.Succeeded)
        {
            var errors = result.Errors.Select(e => e.Description);
            return BadRequest(new { error = string.Join(" ", errors) });
        }

        var roles = await _userManager.GetRolesAsync(user);
        var (token, expires) = _tokenService.CreateToken(user, roles);
        return Ok(new AuthResponseDto
        {
            Token = token,
            ExpiresAtUtc = expires,
            Profile = ToProfileDto(user, roles),
        });
    }

    [HttpPost("login")]
    public async Task<ActionResult<AuthResponseDto>> Login(LoginDto dto)
    {
        var user = await _userManager.FindByEmailAsync(dto.Email);
        // Deliberately vague error on both "no such user" and "wrong password" —
        // same security reasoning Supabase uses: don't reveal which emails are registered.
        if (user == null)
            return Unauthorized(new { error = "Invalid email or password." });

        var passwordOk = await _userManager.CheckPasswordAsync(user, dto.Password);
        if (!passwordOk)
            return Unauthorized(new { error = "Invalid email or password." });

        var roles = await _userManager.GetRolesAsync(user);
        var (token, expires) = _tokenService.CreateToken(user, roles);
        return Ok(new AuthResponseDto
        {
            Token = token,
            ExpiresAtUtc = expires,
            Profile = ToProfileDto(user, roles),
        });
    }

    // Always returns 200 — never reveal whether an email is registered. If it
    // is, an email with a reset token is sent (see EmailSender's SMTP config).
    [HttpPost("forgot-password")]
    public async Task<IActionResult> ForgotPassword(ForgotPasswordDto dto)
    {
        var user = await _userManager.FindByEmailAsync(dto.Email);
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
                // Swallow send failures: never let this endpoint reveal whether an
                // email is registered (a 500 here would only fire for real users).
                // The error is already logged inside EmailSender.
            }
        }

        return Ok(new { message = "If that email is registered, a reset code has been sent." });
    }

    [HttpPost("reset-password")]
    public async Task<IActionResult> ResetPassword(ResetPasswordDto dto)
    {
        var user = await _userManager.FindByEmailAsync(dto.Email);
        // Same vague response on a missing user as on a bad token.
        if (user == null)
            return BadRequest(new { error = "Invalid or expired reset code." });

        var result = await _userManager.ResetPasswordAsync(user, dto.Token, dto.NewPassword);
        if (!result.Succeeded)
        {
            var errors = result.Errors.Select(e => e.Description);
            return BadRequest(new { error = string.Join(" ", errors) });
        }

        return Ok(new { message = "Password updated. You can now log in." });
    }

    private static MemberProfileDto ToProfileDto(ApplicationUser user, IList<string> roles) => new()
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
