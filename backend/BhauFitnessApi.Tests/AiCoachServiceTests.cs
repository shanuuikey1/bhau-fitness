using Xunit;
using BhauFitnessApi.Services;
using BhauFitnessApi.Models.DTOs;
using System.Net.Http;
using System.Threading.Tasks;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging.Abstractions;

namespace BhauFitnessApi.Tests
{
    public class AiCoachServiceTests
    {
        private readonly AiCoachService _service;

        public AiCoachServiceTests()
        {
            var httpClient = new HttpClient();
            var configuration = new ConfigurationBuilder().Build();
            var logger = NullLogger<AiCoachService>.Instance;

            _service = new AiCoachService(httpClient, configuration, logger);
        }

        [Theory]
        [InlineData("WeightLoss", "Beginner")]
        [InlineData("MuscleGain", "Intermediate")]
        [InlineData("Endurance", "Advanced")]
        [InlineData("Flexibility", "Beginner")]
        public async Task GenerateWorkoutPlan_ReturnsValidSevenDayPlan(string goal, string level)
        {
            // Act
            var plan = await _service.GenerateWorkoutPlanAsync(goal, 75.0, level);

            // Assert
            Assert.NotNull(plan);
            Assert.Equal(goal, plan.Goal);
            Assert.Equal("7 Days", plan.Duration);
            Assert.Equal(7, plan.Days.Count);

            foreach (var day in plan.Days)
            {
                Assert.NotEmpty(day.DayName);
                Assert.NotEmpty(day.Focus);
                Assert.NotEmpty(day.Exercises);

                foreach (var ex in day.Exercises)
                {
                    Assert.NotEmpty(ex.Name);
                    Assert.True(ex.Sets > 0);
                    Assert.True(ex.Reps > 0);
                    Assert.True(ex.RestSeconds >= 0);
                }
            }
        }

        [Theory]
        [InlineData("WeightLoss", 80.0, 180.0)]
        [InlineData("MuscleGain", 65.0, 170.0)]
        [InlineData("Endurance", 70.0, 175.0)]
        public async Task GenerateDietPlan_CalculatesValidMacrosAndMeals(string goal, double weight, double height)
        {
            // Act
            var diet = await _service.GenerateDietPlanAsync(goal, weight, height);

            // Assert
            Assert.NotNull(diet);
            Assert.Equal(goal, diet.Goal);
            Assert.True(diet.DailyCalories > 1000);
            Assert.True(diet.DailyProteinG > 30);
            Assert.True(diet.DailyCarbsG > 50);
            Assert.True(diet.DailyFatG > 20);
            Assert.Equal(5, diet.Meals.Count); // 5 meals: Breakfast, Snack 1, Lunch, Snack 2, Dinner

            foreach (var meal in diet.Meals)
            {
                Assert.NotEmpty(meal.MealType);
                Assert.NotEmpty(meal.Name);
                Assert.NotEmpty(meal.Description);
                Assert.True(meal.Calories > 0);
                Assert.True(meal.ProteinG >= 0);
                Assert.True(meal.CarbsG >= 0);
                Assert.True(meal.FatG >= 0);
            }
        }

        [Fact]
        public void GetMotivationalTip_ReturnsNonEmptyTipAndCategory()
        {
            // Act
            var tip = _service.GetMotivationalTip();

            // Assert
            Assert.NotNull(tip);
            Assert.NotEmpty(tip.Tip);
            Assert.NotEmpty(tip.Category);
        }
    }
}
