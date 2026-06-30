using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Xunit;
using BhauFitnessApi.Controllers;
using BhauFitnessApi.Models.DTOs;
using BhauFitnessApi.Models.Entities;
using BhauFitnessApi.Tests.Helpers;

namespace BhauFitnessApi.Tests
{
    public class PlansControllerTests
    {
        [Fact]
        public async Task GetPlans_ReturnsOnlyActivePlansSortedByPrice()
        {
            // Arrange
            using var db = TestDbContextFactory.Create();
            db.Plans.AddRange(new List<Plan>
            {
                new() { Id = 1, Name = "Premium Plan", Price = 2000, DurationDays = 30, IsActive = true, Description = "Desc 1" },
                new() { Id = 2, Name = "Basic Plan", Price = 1000, DurationDays = 30, IsActive = true, Description = "Desc 2" },
                new() { Id = 3, Name = "Old Plan", Price = 500, DurationDays = 30, IsActive = false, Description = "Desc 3" }
            });
            await db.SaveChangesAsync();

            var controller = new PlansController(db);

            // Act
            var result = await controller.GetPlans();

            // Assert
            var actionResult = Assert.IsType<ActionResult<List<PlanDto>>>(result);
            var okResult = Assert.IsType<OkObjectResult>(actionResult.Result);
            var plansList = Assert.IsType<List<PlanDto>>(okResult.Value);

            Assert.Equal(2, plansList.Count);
            Assert.Equal("Basic Plan", plansList[0].Name); // Sorted by price ascending
            Assert.Equal("Premium Plan", plansList[1].Name);
        }
    }
}
