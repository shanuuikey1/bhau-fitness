using System;
using Microsoft.EntityFrameworkCore;
using BhauFitnessApi.Data;
using BhauFitnessApi.Services;

namespace BhauFitnessApi.Tests.Helpers
{
    public class TestTenantProvider : ITenantProvider
    {
        public string GetTenantId() => "default";
    }

    public static class TestDbContextFactory
    {
        public static ApplicationDbContext Create()
        {
            var options = new DbContextOptionsBuilder<ApplicationDbContext>()
                .UseInMemoryDatabase(databaseName: Guid.NewGuid().ToString())
                .Options;

            return new ApplicationDbContext(options, new TestTenantProvider());
        }
    }
}
