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
        private readonly Microsoft.Extensions.Configuration.IConfiguration _config;

        public PaymentsController(IMembershipService membershipService, Microsoft.Extensions.Configuration.IConfiguration config)
        {
            _membershipService = membershipService;
            _config = config;
        }

        private string CurrentUserId => User.FindFirstValue(ClaimTypes.NameIdentifier) ?? User.FindFirstValue("sub")!;

        [HttpPost("create-order")]
        public async Task<ActionResult<CreateOrderResponseDto>> CreateOrder([FromBody] CreateOrderDto dto)
        {
            try
            {
                var payment = await _membershipService.CreateOrderAsync(CurrentUserId, dto.PlanId);

                return Ok(new CreateOrderResponseDto
                {
                    OrderId = payment.RazorpayOrderId,
                    Amount = payment.Amount,
                    Currency = payment.Currency,
                    Key = _config["Razorpay:KeyId"] ?? "rzp_test_placeholder"
                });
            }
            catch (ArgumentException ex)
            {
                return BadRequest(new { error = ex.Message });
            }
            catch (InvalidOperationException ex)
            {
                // Real gateway unreachable — surface as service unavailable.
                return StatusCode(StatusCodes.Status503ServiceUnavailable, new { error = ex.Message });
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
