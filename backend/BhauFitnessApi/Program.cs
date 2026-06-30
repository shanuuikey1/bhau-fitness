using System.Text;
using System.Threading.RateLimiting;
using BhauFitnessApi.Data;
using BhauFitnessApi.Models.Entities;
using BhauFitnessApi.Services;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.RateLimiting;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using Serilog;

// ── Serilog Setup ────────────────────────────────────────────────────────────
Log.Logger = new LoggerConfiguration()
    .WriteTo.Console()
    .WriteTo.File("Logs/bhau_fitness_log.txt", rollingInterval: RollingInterval.Day)
    .CreateLogger();

try
{
    Log.Information("Starting BHAU FITNESS API host...");

    var builder = WebApplication.CreateBuilder(args);

    builder.Host.UseSerilog();

    // Render (and most PaaS hosts) inject the port to listen on via $PORT.
    var port = Environment.GetEnvironmentVariable("PORT");
    if (!string.IsNullOrWhiteSpace(port))
    {
        builder.WebHost.UseUrls($"http://0.0.0.0:{port}");
    }

    // ── Database ──────────────────────────────────────────────────────────────
    var dbProvider = (Environment.GetEnvironmentVariable("DB_PROVIDER")
        ?? builder.Configuration["Database:Provider"]
        ?? "SqlServer").Trim();
    var usePostgres = dbProvider.Equals("Postgres", StringComparison.OrdinalIgnoreCase)
        || dbProvider.Equals("PostgreSQL", StringComparison.OrdinalIgnoreCase);

    builder.Services.AddDbContext<ApplicationDbContext>(options =>
    {
        if (usePostgres)
        {
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

    // ── Identity ──────────────────────────────────────────────────────────────
    builder.Services.AddIdentity<ApplicationUser, IdentityRole>(options =>
    {
        options.Password.RequiredLength = 6;
        options.Password.RequireNonAlphanumeric = false;
        options.Password.RequireUppercase = false;
        options.User.RequireUniqueEmail = true;
    })
    .AddEntityFrameworkStores<ApplicationDbContext>()
    .AddDefaultTokenProviders();

    // ── JWT Settings ──────────────────────────────────────────────────────────
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
            NameClaimType = "sub",
        };
    });

    builder.Services.AddAuthorization();

    // ── Services Registration ──────────────────────────────────────────────────
    builder.Services.AddHttpContextAccessor();
    builder.Services.AddScoped<ITenantProvider, HttpContextTenantProvider>();
    builder.Services.AddScoped<ITokenService, TokenService>();
    builder.Services.AddScoped<IEmailSender, EmailSender>();
    builder.Services.AddScoped<IUserService, UserService>();
    builder.Services.AddScoped<IMembershipService, MembershipService>();
    builder.Services.AddScoped<IClassService, ClassService>();
    builder.Services.AddHttpClient<AiCoachService>();
    builder.Services.AddScoped<RazorpayService>();
    builder.Services.AddHostedService<NotificationTriggerService>();

    // ── Health Checks ─────────────────────────────────────────────────────────
    builder.Services.AddHealthChecks()
        .AddCheck<DatabaseHealthCheck>("Database");

    // ── Rate Limiting ─────────────────────────────────────────────────────────
    builder.Services.AddRateLimiter(options =>
    {
        options.RejectionStatusCode = StatusCodes.Status429TooManyRequests;
        options.AddFixedWindowLimiter("strict", opt =>
        {
            opt.PermitLimit = 10;
            opt.Window = TimeSpan.FromMinutes(1);
            opt.QueueProcessingOrder = QueueProcessingOrder.OldestFirst;
            opt.QueueLimit = 2;
        });
    });

    // ── CORS ──────────────────────────────────────────────────────────────────
    var allowedOrigins = (Environment.GetEnvironmentVariable("ALLOWED_ORIGINS") ?? "")
        .Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries);

    builder.Services.AddCors(options =>
    {
        options.AddPolicy("AllowFlutterClient", policy =>
        {
            if (allowedOrigins.Length > 0)
            {
                policy.WithOrigins(allowedOrigins).AllowAnyMethod().AllowAnyHeader().AllowCredentials();
            }
            else
            {
                policy.AllowAnyOrigin().AllowAnyMethod().AllowAnyHeader();
            }
        });
    });

    // ── Controllers & Swagger ─────────────────────────────────────────────────
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

    // ── Database Migrations & Seeding ─────────────────────────────────────────
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

        // Clean up any legacy truncated class type names in the database
        var sessions = await db.ClassSessions.ToListAsync();
        bool updated = false;
        foreach (var s in sessions)
        {
            if (s.Type == "Cardi") { s.Type = "Cardio"; updated = true; }
            else if (s.Type == "Strengt") { s.Type = "Strength"; updated = true; }
            else if (s.Type == "Functiona") { s.Type = "Functional"; updated = true; }
        }
        if (updated)
        {
            await db.SaveChangesAsync();
        }

        var roleManager = scope.ServiceProvider.GetRequiredService<RoleManager<IdentityRole>>();
        if (!await roleManager.RoleExistsAsync("Admin"))
        {
            await roleManager.CreateAsync(new IdentityRole("Admin"));
        }

        var userManager = scope.ServiceProvider.GetRequiredService<UserManager<ApplicationUser>>();
        var adminEmail = "admin@bhau.com";
        var adminExists = await db.Users.IgnoreQueryFilters().AnyAsync(u => u.Email == adminEmail);
        if (!adminExists)
        {
            var adminUser = new ApplicationUser
            {
                UserName = adminEmail,
                Email = adminEmail,
                FullName = "Bhau Admin",
                EmailConfirmed = true,
                CreatedAt = DateTime.UtcNow,
                TenantId = "default"
            };
            var result = await userManager.CreateAsync(adminUser, "AdminPassword123");
            if (result.Succeeded)
            {
                await userManager.AddToRoleAsync(adminUser, "Admin");
            }
        }
    }

    if (app.Environment.IsDevelopment())
    {
        app.UseSwagger();
        app.UseSwaggerUI();
    }

    if (app.Environment.IsDevelopment())
    {
        app.UseHttpsRedirection();
    }

    app.UseMiddleware<CorrelationIdMiddleware>();
    app.UseSerilogRequestLogging(); // Log HTTP requests

    app.UseCors("AllowFlutterClient");
    app.UseRateLimiter();

    app.UseAuthentication();
    app.UseAuthorization();

    // Map Health Checks endpoint
    app.MapHealthChecks("/api/health");

    app.MapControllers();

    app.Run();
}
catch (Exception ex)
{
    Log.Fatal(ex, "Host terminated unexpectedly!");
}
finally
{
    Log.CloseAndFlush();
}
