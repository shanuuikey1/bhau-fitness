using System.Text;
using BhauFitnessApi.Data;
using BhauFitnessApi.Models.Entities;
using BhauFitnessApi.Services;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;

var builder = WebApplication.CreateBuilder(args);

// Render (and most PaaS hosts) inject the port to listen on via $PORT. Bind to it
// so the container is reachable; locally this env var is absent and Kestrel uses
// its normal defaults from launchSettings/appsettings.
var port = Environment.GetEnvironmentVariable("PORT");
if (!string.IsNullOrWhiteSpace(port))
{
    builder.WebHost.UseUrls($"http://0.0.0.0:{port}");
}

// ── Database ──────────────────────────────────────────────────────────────
// Provider is chosen by config so the same codebase runs on PostgreSQL (free
// hosting now) or SQL Server (local dev + Azure later) with no code changes —
// set DB_PROVIDER=Postgres on the host, or leave it for SQL Server by default.
var dbProvider = (Environment.GetEnvironmentVariable("DB_PROVIDER")
    ?? builder.Configuration["Database:Provider"]
    ?? "SqlServer").Trim();
var usePostgres = dbProvider.Equals("Postgres", StringComparison.OrdinalIgnoreCase)
    || dbProvider.Equals("PostgreSQL", StringComparison.OrdinalIgnoreCase);

builder.Services.AddDbContext<ApplicationDbContext>(options =>
{
    if (usePostgres)
    {
        // Neon/Render hand out a postgres:// URL; Npgsql wants a key-value string.
        var rawUrl = Environment.GetEnvironmentVariable("DATABASE_URL")
            ?? builder.Configuration.GetConnectionString("DefaultConnection")
            ?? throw new InvalidOperationException("No PostgreSQL connection string (set DATABASE_URL).");
        options.UseNpgsql(NpgsqlConnectionStringHelper.Normalize(rawUrl));
    }
    else
    {
        var connectionString = builder.Configuration.GetConnectionString("DefaultConnection")
            ?? throw new InvalidOperationException("ConnectionStrings:DefaultConnection is missing.");
        options.UseSqlServer(connectionString);
    }
});

// ── Identity (password hashing, user store, etc.) ──────────────────────────
builder.Services.AddIdentity<ApplicationUser, IdentityRole>(options =>
{
    // Reasonable defaults for a real app — relax if you want easier testing.
    options.Password.RequiredLength = 6;
    options.Password.RequireNonAlphanumeric = false;
    options.Password.RequireUppercase = false;
    options.User.RequireUniqueEmail = true;
})
.AddEntityFrameworkStores<ApplicationDbContext>()
.AddDefaultTokenProviders();

// ── JWT settings + auth ─────────────────────────────────────────────────────
builder.Services.Configure<JwtSettings>(builder.Configuration.GetSection("Jwt"));
var jwt = builder.Configuration.GetSection("Jwt").Get<JwtSettings>()
    ?? throw new InvalidOperationException("Jwt section is missing in appsettings.json");

builder.Services.AddAuthentication(options =>
{
    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
})
.AddJwtBearer(options =>
{
    // Without this, ASP.NET Core's legacy claim-mapping can silently rewrite short
    // claim names like "sub" into long XML claim-type URIs, depending on version —
    // disabling it keeps claims exactly as issued, so claim lookups are predictable.
    options.MapInboundClaims = false;
    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuer = true,
        ValidateAudience = true,
        ValidateLifetime = true,
        ValidateIssuerSigningKey = true,
        ValidIssuer = jwt.Issuer,
        ValidAudience = jwt.Audience,
        IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwt.Key)),
        ClockSkew = TimeSpan.FromMinutes(2),
        NameClaimType = "sub", // so User.Identity.Name / FindFirstValue("sub") work consistently
    };
});

builder.Services.AddAuthorization();
builder.Services.AddScoped<ITokenService, TokenService>();
builder.Services.AddScoped<IEmailSender, EmailSender>();

// ── CORS — Flutter (mobile/emulator/web) needs to call this from a different origin ──
// ALLOWED_ORIGINS is a comma-separated list of allowed web origins (set on the host,
// e.g. Render). Mobile/emulator builds don't send an Origin header so they're unaffected
// either way. With no value set, falls back to allow-any (local dev convenience).
var allowedOrigins = (Environment.GetEnvironmentVariable("ALLOWED_ORIGINS") ?? "")
    .Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries);

builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowFlutterClient", policy =>
    {
        if (allowedOrigins.Length > 0)
        {
            policy.WithOrigins(allowedOrigins).AllowAnyMethod().AllowAnyHeader();
        }
        else
        {
            policy.AllowAnyOrigin().AllowAnyMethod().AllowAnyHeader();
        }
    });
});

// ── Controllers + Swagger (with JWT "Authorize" button for easy testing) ───
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo { Title = "BHAU FITNESS API", Version = "v1" });
    c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Description = "Paste just the JWT token (no 'Bearer ' prefix needed here — Swagger adds it).",
        Name = "Authorization",
        In = ParameterLocation.Header,
        Type = SecuritySchemeType.ApiKey,
        Scheme = "Bearer",
    });
    c.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference { Type = ReferenceType.SecurityScheme, Id = "Bearer" }
            },
            Array.Empty<string>()
        }
    });
});

var app = builder.Build();

// ── Create/upgrade the schema + seed the Admin role on startup ─────────────
// Runs in every environment so a freshly-provisioned cloud DB is usable on first
// boot. SQL Server uses EF migrations (kept for the Azure/Path B future);
// PostgreSQL uses EnsureCreated (builds schema + HasData seed straight from the
// model, so no Postgres-specific migration files are needed).
{
    using var scope = app.Services.CreateScope();
    var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
    if (usePostgres)
    {
        await db.Database.EnsureCreatedAsync();
    }
    else
    {
        await db.Database.MigrateAsync();
    }

    var roleManager = scope.ServiceProvider.GetRequiredService<RoleManager<IdentityRole>>();
    if (!await roleManager.RoleExistsAsync("Admin"))
    {
        await roleManager.CreateAsync(new IdentityRole("Admin"));
    }
}

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI(); // browse to /swagger to explore and test the API
}

// Locally we redirect to HTTPS; on Render/containers TLS is terminated at the
// edge and forcing redirects here causes loops, so only do it in Development.
if (app.Environment.IsDevelopment())
{
    app.UseHttpsRedirection();
}
app.UseCors("AllowFlutterClient");
app.UseAuthentication();
app.UseAuthorization();

app.MapGet("/api/health", () => new { status = "ok", timestamp = DateTime.UtcNow })
    .WithName("Health")
    .WithOpenApi()
    .AllowAnonymous();

app.MapControllers();

app.Run();
