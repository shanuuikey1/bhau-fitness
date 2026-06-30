using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using BhauFitnessApi.Models.DTOs;
using BhauFitnessApi.Services;

namespace BhauFitnessApi.Controllers
{
    [Authorize]
    [ApiController]
    [Route("api/ai")]
    public class AiCoachController : ControllerBase
    {
        private readonly AiCoachService _aiCoachService;

        public AiCoachController(AiCoachService aiCoachService)
        {
            _aiCoachService = aiCoachService;
        }

        [HttpPost("workout-plan")]
        public async Task<ActionResult<WorkoutPlanDto>> GetWorkoutPlan([FromBody] AiRequestDto dto)
        {
            if (string.IsNullOrEmpty(dto.Goal) || string.IsNullOrEmpty(dto.ExperienceLevel) || dto.WeightKg <= 0)
            {
                return BadRequest(new { error = "Invalid workout plan request parameters." });
            }

            var plan = await _aiCoachService.GenerateWorkoutPlanAsync(dto.Goal, dto.WeightKg, dto.ExperienceLevel);
            return Ok(plan);
        }

        [HttpPost("diet-plan")]
        public async Task<ActionResult<DietPlanDto>> GetDietPlan([FromBody] AiRequestDto dto)
        {
            if (string.IsNullOrEmpty(dto.Goal) || dto.WeightKg <= 0 || dto.HeightCm <= 0)
            {
                return BadRequest(new { error = "Invalid diet plan request parameters." });
            }

            var plan = await _aiCoachService.GenerateDietPlanAsync(dto.Goal, dto.WeightKg, dto.HeightCm);
            return Ok(plan);
        }

        [HttpGet("tip")]
        public ActionResult<MotivationalTipDto> GetTip()
        {
            var tip = _aiCoachService.GetMotivationalTip();
            return Ok(tip);
        }
    }
}
