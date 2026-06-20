using BhauFitnessApi.Models.Entities;

namespace BhauFitnessApi.Services;

public interface ITokenService
{
    (string token, DateTime expiresAtUtc) CreateToken(ApplicationUser user, IEnumerable<string> roles);
}
