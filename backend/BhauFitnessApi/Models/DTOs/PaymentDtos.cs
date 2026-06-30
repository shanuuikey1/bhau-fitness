using System;

namespace BhauFitnessApi.Models.DTOs
{
    public class CreateOrderDto
    {
        public int PlanId { get; set; }
    }

    public class CreateOrderResponseDto
    {
        public string OrderId { get; set; } = string.Empty;
        public decimal Amount { get; set; }
        public string Currency { get; set; } = "INR";
        public string Key { get; set; } = string.Empty;
    }

    public class VerifyPaymentDto
    {
        public string RazorpayOrderId { get; set; } = string.Empty;
        public string RazorpayPaymentId { get; set; } = string.Empty;
        public string RazorpaySignature { get; set; } = string.Empty;
    }

    public class PaymentHistoryDto
    {
        public int Id { get; set; }
        public string PlanName { get; set; } = string.Empty;
        public decimal Amount { get; set; }
        public string Status { get; set; } = string.Empty;
        public DateTime PaymentDate { get; set; }
    }
}
