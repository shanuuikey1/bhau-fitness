using System;
using System.Net.Http;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace BhauFitnessApi.Controllers;

[ApiController]
[Route("api/aicoach")]
[Authorize]
public class AiCoachController : ControllerBase
{
    private static readonly HttpClient _httpClient = new();
    private readonly Microsoft.Extensions.Configuration.IConfiguration _configuration;

    public AiCoachController(Microsoft.Extensions.Configuration.IConfiguration configuration)
    {
        _configuration = configuration;
    }

    [HttpPost("chat")]
    public async Task<IActionResult> Chat([FromBody] ChatRequestDto request)
    {
        var apiKey = Environment.GetEnvironmentVariable("GEMINI_API_KEY") ?? _configuration["Gemini:ApiKey"];
        
        string systemInstruction = "You are BHAU AI Coach, a premium, encouraging, and expert fitness and nutrition coach. " +
                                  "You give highly personalized, concise, and scientifically accurate fitness advice. " +
                                  $"The user's fitness goal is: {request.Goal}. " +
                                  (request.Tdee.HasValue ? $"Their calculated daily TDEE (maintenance calories) is {request.Tdee} kcal/day. " : "") +
                                  "Provide highly practical, actionable steps. Keep responses under 4 sentences unless asked for a full routine. " +
                                  "Always address the user with high energy and respect. Do not use generic placeholders.";

        if (!string.IsNullOrEmpty(apiKey))
        {
            try
            {
                var url = $"https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key={apiKey}";
                
                var payload = new
                {
                    contents = new[]
                    {
                        new
                        {
                            parts = new[]
                            {
                                new { text = $"{systemInstruction}\n\nUser Question: {request.Message}" }
                            }
                        }
                    }
                };

                var content = new StringContent(JsonSerializer.Serialize(payload), Encoding.UTF8, "application/json");
                var response = await _httpClient.PostAsync(url, content);
                
                if (response.IsSuccessStatusCode)
                {
                    var responseBody = await response.Content.ReadAsStringAsync();
                    using var doc = JsonDocument.Parse(responseBody);
                    var text = doc.RootElement
                        .GetProperty("candidates")[0]
                        .GetProperty("content")
                        .GetProperty("parts")[0]
                        .GetProperty("text")
                        .GetString();

                    if (!string.IsNullOrEmpty(text))
                    {
                        return Ok(new { response = text.Trim() });
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Gemini API error: {ex.Message}");
            }
        }

        // Smart Local Fallback Responder
        string localResponse = GenerateLocalResponse(request.Message, request.Goal, request.Tdee);
        return Ok(new { response = localResponse });
    }

    private string GenerateLocalResponse(string message, string goal, int? tdee)
    {
        string q = message.ToLowerInvariant();
        string tdeeNote = tdee.HasValue ? $" Based on your calculated TDEE of {tdee} kcal, you should aim for a daily intake of {tdee - 400} kcal for sustainable fat loss." : "";
        if (goal == "muscle" && tdee.HasValue)
        {
            tdeeNote = $" Based on your calculated TDEE of {tdee} kcal, you should aim for a surplus at around {tdee + 300} kcal to maximize muscle growth.";
        }

        if (q.Contains("nutrition") || q.Contains("diet") || q.Contains("eat") || q.Contains("protein") || q.Contains("meal"))
        {
            return $"For your goal ({goal}), prioritize eating ~1.8–2.2g of protein per kg of body weight. Focus on lean sources like chicken, paneer, lentils, and eggs.{tdeeNote} Keep your hydration high (3-4L/day).";
        }
        if (q.Contains("workout") || q.Contains("exercise") || q.Contains("train") || q.Contains("home"))
        {
            return $"To reach your goal ({goal}), base your training on compound movements (Squats, Bench Press, Deadlifts, Overhead Press) 3-4 times a week. For a quick home routine: do 4 rounds of 15 bodyweight squats, 12 push-ups, 20 mountain climbers, and a 45s plank.";
        }
        if (q.Contains("recover") || q.Contains("sore") || q.Contains("rest") || q.Contains("sleep"))
        {
            return "Muscle growth and fat loss happen during recovery. Ensure you get 7-9 hours of deep sleep every night. Keep active recovery (like light walking) on your rest days, and stretch sore muscles for 10 minutes post-workout.";
        }
        
        return $"As your BHAU Coach, my advice for your '{goal}' goal is consistency over intensity. Show up, log your workouts, hit your protein target, and trust the process. What specific workout or meal plan can I help you customize today?";
    }
}

public class ChatRequestDto
{
    public string Message { get; set; } = string.Empty;
    public string Goal { get; set; } = string.Empty;
    public int? Tdee { get; set; }
}
