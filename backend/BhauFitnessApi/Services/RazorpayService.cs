using System;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;

namespace BhauFitnessApi.Services
{
    public class RazorpayService
    {
        private readonly IConfiguration _config;
        private readonly HttpClient _httpClient;
        private readonly ILogger<RazorpayService> _logger;

        public RazorpayService(HttpClient httpClient, IConfiguration config, ILogger<RazorpayService> logger)
        {
            _config = config;
            _httpClient = httpClient;
            _logger = logger;
        }

        private string KeyId => _config["Razorpay:KeyId"] ?? "rzp_test_placeholder";
        private string KeySecret => _config["Razorpay:KeySecret"] ?? "placeholder_secret";

        /// Sandbox mode: no real Razorpay keys configured. Orders are mocked and
        /// mock signatures verify, so the demo checkout works end-to-end. The
        /// moment real keys are set, every mock path is disabled.
        public bool IsSandboxMode => KeyId.Contains("placeholder") || KeySecret.Contains("placeholder");

        public async Task<string> CreateOrderAsync(decimal amount, string currency, string receipt)
        {
            if (IsSandboxMode)
            {
                return $"order_mock_{Guid.NewGuid().ToString().Substring(0, 12)}";
            }

            var request = new HttpRequestMessage(HttpMethod.Post, "https://api.razorpay.com/v1/orders");

            // Razorpay expects amount in paise (Rupees * 100)
            int amountInPaise = (int)(amount * 100);

            var payload = new
            {
                amount = amountInPaise,
                currency = currency,
                receipt = receipt
            };

            request.Content = new StringContent(JsonSerializer.Serialize(payload), Encoding.UTF8, "application/json");

            // Basic Auth
            var authBytes = Encoding.ASCII.GetBytes($"{KeyId}:{KeySecret}");
            request.Headers.Authorization = new AuthenticationHeaderValue("Basic", Convert.ToBase64String(authBytes));

            // With real keys there is deliberately NO mock fallback: a failed
            // Razorpay call must surface as an error, never as a fake order
            // that would later auto-verify into a free membership.
            var response = await _httpClient.SendAsync(request);
            if (!response.IsSuccessStatusCode)
            {
                _logger.LogError("Razorpay order creation failed with status {Status}.", response.StatusCode);
                throw new InvalidOperationException("Payment gateway is unavailable. Please try again later.");
            }

            var responseBody = await response.Content.ReadAsStringAsync();
            using var doc = JsonDocument.Parse(responseBody);
            if (doc.RootElement.TryGetProperty("id", out var idProp) && idProp.GetString() is string orderId)
            {
                return orderId;
            }

            throw new InvalidOperationException("Payment gateway returned an unexpected response.");
        }

        public bool VerifySignature(string orderId, string paymentId, string signature)
        {
            // Mock orders only verify while in sandbox mode. With real keys a
            // mock order id can't exist legitimately, so it always fails.
            if (orderId.StartsWith("order_mock_"))
            {
                return IsSandboxMode;
            }

            try
            {
                string payload = $"{orderId}|{paymentId}";
                var keyBytes = Encoding.UTF8.GetBytes(KeySecret);
                var payloadBytes = Encoding.UTF8.GetBytes(payload);

                using var hmac = new HMACSHA256(keyBytes);
                var hashBytes = hmac.ComputeHash(payloadBytes);

                var expected = Encoding.UTF8.GetBytes(Convert.ToHexString(hashBytes).ToLowerInvariant());
                var provided = Encoding.UTF8.GetBytes(signature.ToLowerInvariant());
                return CryptographicOperations.FixedTimeEquals(expected, provided);
            }
            catch
            {
                return false;
            }
        }
    }
}
