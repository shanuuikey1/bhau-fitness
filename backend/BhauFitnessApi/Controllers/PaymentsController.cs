using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.RateLimiting;
using BhauFitnessApi.Models.DTOs;
using BhauFitnessApi.Services;

namespace BhauFitnessApi.Controllers
{
    [Authorize]
    [ApiController]
    [Route("api/payments")]
    [EnableRateLimiting("strict")]
    public class PaymentsController : ControllerBase
    {
        private readonly IMembershipService _membershipService;

        public PaymentsController(IMembershipService membershipService)
        {
            _membershipService = membershipService;
        }

        private string CurrentUserId => User.FindFirstValue(ClaimTypes.NameIdentifier) ?? User.FindFirstValue("sub")!;

        [HttpPost("create-order")]
        public async Task<ActionResult<CreateOrderResponseDto>> CreateOrder([FromBody] CreateOrderDto dto)
        {
            try
            {
                var payment = await _membershipService.CreateOrderAsync(CurrentUserId, dto.PlanId);
                
                // Key is resolved here based on context
                string keyId = "rzp_test_placeholder"; 

                return Ok(new CreateOrderResponseDto
                {
                    OrderId = payment.RazorpayOrderId,
                    Amount = payment.Amount,
                    Currency = payment.Currency,
                    Key = keyId
                });
            }
            catch (ArgumentException ex)
            {
                return BadRequest(new { error = ex.Message });
            }
        }

        [HttpPost("verify")]
        public async Task<IActionResult> VerifyPayment([FromBody] VerifyPaymentDto dto)
        {
            try
            {
                bool isSuccess = await _membershipService.VerifyPaymentAsync(CurrentUserId, dto);
                if (!isSuccess)
                {
                    return BadRequest(new { error = "Invalid payment signature." });
                }

                return Ok(new { message = "Payment verified and membership activated." });
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { error = ex.Message });
            }
        }

        [HttpGet("history")]
        public async Task<ActionResult<List<PaymentHistoryDto>>> GetPaymentHistory()
        {
            var history = await _membershipService.GetPaymentHistoryAsync(CurrentUserId);
            
            var dtoList = history.Select(p => new PaymentHistoryDto
            {
                Id = p.Id,
                PlanName = p.Plan != null ? p.Plan.Name : "Unknown Plan",
                Amount = p.Amount,
                Status = p.Status.ToString(),
                PaymentDate = p.CreatedAt
            }).ToList();

            return Ok(dtoList);
        }
    }
}
