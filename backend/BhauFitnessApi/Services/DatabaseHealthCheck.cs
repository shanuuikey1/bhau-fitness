using Microsoft.Extensions.Diagnostics.HealthChecks;
using BhauFitnessApi.Data;

namespace BhauFitnessApi.Services;

public class DatabaseHealthCheck : IHealthCheck
{
    private readonly IServiceProvider _serviceProvider;

    public DatabaseHealthCheck(IServiceProvider serviceProvider)
    {
        _serviceProvider = serviceProvider;
    }

    public async Task<HealthCheckResult> CheckHealthAsync(HealthCheckContext context, CancellationToken cancellationToken = default)
    {
        try
        {
            using var scope = _serviceProvider.CreateScope();
            var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
            var canConnect = await db.Database.CanConnectAsync(cancellationToken);
            return canConnect 
                ? HealthCheckResult.Healthy("Database is online and reachable.") 
                : HealthCheckResult.Unhealthy("Database is offline or unreachable.");
        }
        catch (Exception ex)
        {
            return HealthCheckResult.Unhealthy("Database connection threw an exception.", ex);
        }
    }
}
