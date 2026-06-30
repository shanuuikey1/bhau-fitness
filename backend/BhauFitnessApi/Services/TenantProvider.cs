using Microsoft.AspNetCore.Http;

namespace BhauFitnessApi.Services;

public interface ITenantProvider
{
    string GetTenantId();
}

public class HttpContextTenantProvider : ITenantProvider
{
    private readonly IHttpContextAccessor _httpContextAccessor;

    public HttpContextTenantProvider(IHttpContextAccessor httpContextAccessor)
    {
        _httpContextAccessor = httpContextAccessor;
    }

    public string GetTenantId()
    {
        var context = _httpContextAccessor.HttpContext;
        if (context != null && context.Request.Headers.TryGetValue("X-Tenant-Id", out var tenantId))
        {
            return tenantId.ToString();
        }
        return "default"; // Fallback tenant
    }
}
