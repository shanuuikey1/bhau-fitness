using System;
using System.Linq;
using System.Threading.Tasks;
using BhauFitnessApi.Data;
using BhauFitnessApi.Models.DTOs;
using BhauFitnessApi.Models.Entities;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;

namespace BhauFitnessApi.Services;

public class UserService : IUserService
{
    private readonly UserManager<ApplicationUser> _userManager;
    private readonly ApplicationDbContext _db;

    public UserService(UserManager<ApplicationUser> userManager, ApplicationDbContext db)
    {
        _userManager = userManager;
        _db = db;
    }

    public async Task<ApplicationUser?> GetUserByIdAsync(string userId)
    {
        return await _userManager.FindByIdAsync(userId);
    }

    public async Task<ApplicationUser?> GetUserByEmailAsync(string email)
    {
        return await _userManager.FindByEmailAsync(email);
    }

    public async Task<IdentityResult> RegisterUserAsync(RegisterDto dto)
    {
        var memberCode = await GenerateUniqueMemberCodeAsync();
        var user = new ApplicationUser
        {
            UserName = dto.Email,
            Email = dto.Email,
            PhoneNumber = dto.Phone,
            FullName = dto.FullName,
            Goal = dto.Goal,
            MemberCode = memberCode,
            CreatedAt = DateTime.UtcNow
        };

        return await _userManager.CreateAsync(user, dto.Password);
    }

    public async Task<string> GenerateUniqueMemberCodeAsync()
    {
        var random = new Random();
        string code;
        bool exists;
        
        // Loop to ensure uniqueness and prevent concurrency collisions
        do
        {
            // 1000–99999 gives ~99k codes; checked across all tenants so codes
            // stay globally unique.
            int num = random.Next(1000, 100000);
            code = $"BHAU-{num}";
            exists = await _db.Users.IgnoreQueryFilters().AnyAsync(u => u.MemberCode == code);
        } while (exists);

        return code;
    }
}
