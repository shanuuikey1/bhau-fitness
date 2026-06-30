using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using BhauFitnessApi.Models.Entities;

namespace BhauFitnessApi.Services;

public interface IClassService
{
    Task<IEnumerable<ClassSession>> GetWeeklyScheduleAsync();
    Task<Booking> BookClassAsync(string userId, int classSessionId, DateOnly classDate);
    Task<bool> CancelBookingAsync(string userId, int bookingId);
    Task<IEnumerable<Booking>> GetUpcomingBookingsAsync(string userId);
}
