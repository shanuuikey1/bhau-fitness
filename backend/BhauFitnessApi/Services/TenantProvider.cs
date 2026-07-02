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
        if (context == null)
        {
            return "default"; // background services / seeding
        }

        // Authenticated requests: the tenant comes from the signed JWT, never
        // from a client-editable header.
        var tokenTenant = context.User?.FindFirst("tenant")?.Value;
        if (!string.IsNullOrEmpty(tokenTenant))
        {
            return tokenTenant;
        }

        // Anonymous requests (login, register, public plan/class lists) may
        // select a tenant via header.
        if (context.Request.Headers.TryGetValue("X-Tenant-Id", out var tenantId)
            && !string.IsNullOrWhiteSpace(tenantId))
        {
            return tenantId.ToString();
        }
        return "default"; // Fallback tenant
    }
}
