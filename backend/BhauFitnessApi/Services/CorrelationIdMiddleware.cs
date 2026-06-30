using System;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Serilog.Context;

namespace BhauFitnessApi.Services;

public class CorrelationIdMiddleware
{
    private readonly RequestDelegate _next;
    private const string CorrelationIdHeaderKey = "X-Correlation-ID";

    public CorrelationIdMiddleware(RequestDelegate next)
    {
        _next = next;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        // Resolve or generate Correlation ID
        if (!context.Request.Headers.TryGetValue(CorrelationIdHeaderKey, out var correlationId))
        {
            correlationId = Guid.NewGuid().ToString();
        }

        // Push Correlation ID to Serilog's LogContext so all logs for this request include it
        using (LogContext.PushProperty("CorrelationId", correlationId.ToString()))
        {
            // Add Correlation ID to response headers
            context.Response.Headers[CorrelationIdHeaderKey] = correlationId;

            await _next(context);
        }
    }
}
