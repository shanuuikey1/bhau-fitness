using System.Threading.Tasks;
using BhauFitnessApi.Models.DTOs;
using BhauFitnessApi.Models.Entities;
using Microsoft.AspNetCore.Identity;

namespace BhauFitnessApi.Services;

public interface IUserService
{
    Task<ApplicationUser?> GetUserByIdAsync(string userId);
    Task<ApplicationUser?> GetUserByEmailAsync(string email);
    Task<IdentityResult> RegisterUserAsync(RegisterDto dto);
    Task<string> GenerateUniqueMemberCodeAsync();
}
