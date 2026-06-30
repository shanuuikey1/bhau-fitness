using System.Collections.Generic;
using System.Threading.Tasks;
using BhauFitnessApi.Models.DTOs;
using BhauFitnessApi.Models.Entities;

namespace BhauFitnessApi.Services;

public interface IMembershipService
{
    Task<Membership?> GetActiveMembershipAsync(string userId);
    Task<IEnumerable<Payment>> GetPaymentHistoryAsync(string userId);
    Task<Payment> CreateOrderAsync(string userId, int planId);
    Task<bool> VerifyPaymentAsync(string userId, VerifyPaymentDto dto);
}
