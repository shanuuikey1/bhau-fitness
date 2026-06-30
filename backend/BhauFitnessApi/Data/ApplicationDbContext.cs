using BhauFitnessApi.Models.Entities;
using BhauFitnessApi.Services;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;

namespace BhauFitnessApi.Data;

/// <summary>
/// IdentityDbContext gives us all the Identity tables (AspNetUsers, AspNetRoles, etc.)
/// for free, already wired to ApplicationUser. We add our own DbSets on top.
/// </summary>
public class ApplicationDbContext : IdentityDbContext<ApplicationUser>
{
    private readonly ITenantProvider _tenantProvider;

    public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options, ITenantProvider tenantProvider)
        : base(options)
    {
        _tenantProvider = tenantProvider;
    }

    public DbSet<Plan> Plans { get; set; } = null!;
    public DbSet<Membership> Memberships { get; set; } = null!;
    public DbSet<ClassSession> ClassSessions { get; set; } = null!;
    public DbSet<Booking> Bookings { get; set; } = null!;
    public DbSet<WorkoutLog> WorkoutLogs { get; set; } = null!;
    public DbSet<WaterLog> WaterLogs { get; set; } = null!;
    public DbSet<Payment> Payments { get; set; } = null!;
    public DbSet<Notification> Notifications { get; set; } = null!;

    public override int SaveChanges()
    {
        SetTenantId();
        return base.SaveChanges();
    }

    public override Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
    {
        SetTenantId();
        return base.SaveChangesAsync(cancellationToken);
    }

    private void SetTenantId()
    {
        var tenantId = _tenantProvider.GetTenantId();
        var entries = ChangeTracker.Entries<IMultitenant>()
            .Where(e => e.State == EntityState.Added);

        foreach (var entry in entries)
        {
            if (string.IsNullOrEmpty(entry.Entity.TenantId) || entry.Entity.TenantId == "default")
            {
                entry.Entity.TenantId = tenantId;
            }
        }
    }

    protected override void OnModelCreating(ModelBuilder builder)
    {
        base.OnModelCreating(builder); // IMPORTANT: must call base first for Identity tables to configure correctly

        // Apply Global Query Filters for Multi-Tenancy
        builder.Entity<Plan>().HasQueryFilter(e => e.TenantId == _tenantProvider.GetTenantId());
        builder.Entity<ClassSession>().HasQueryFilter(e => e.TenantId == _tenantProvider.GetTenantId());
        builder.Entity<Booking>().HasQueryFilter(e => e.TenantId == _tenantProvider.GetTenantId());
        builder.Entity<Membership>().HasQueryFilter(e => e.TenantId == _tenantProvider.GetTenantId());
        builder.Entity<Payment>().HasQueryFilter(e => e.TenantId == _tenantProvider.GetTenantId());
        builder.Entity<Notification>().HasQueryFilter(e => e.TenantId == _tenantProvider.GetTenantId());
        builder.Entity<WaterLog>().HasQueryFilter(e => e.TenantId == _tenantProvider.GetTenantId());
        builder.Entity<WorkoutLog>().HasQueryFilter(e => e.TenantId == _tenantProvider.GetTenantId());
        builder.Entity<ApplicationUser>().HasQueryFilter(e => e.TenantId == _tenantProvider.GetTenantId());

        builder.Entity<Membership>()
            .HasOne(m => m.User)
            .WithMany(u => u.Memberships)
            .HasForeignKey(m => m.UserId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.Entity<Membership>()
            .HasOne(m => m.Plan)
            .WithMany(p => p.Memberships)
            .HasForeignKey(m => m.PlanId)
            .OnDelete(DeleteBehavior.Restrict); // don't let a plan delete wipe membership history

        builder.Entity<Booking>()
            .HasOne(b => b.User)
            .WithMany()
            .HasForeignKey(b => b.UserId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.Entity<Booking>()
            .HasOne(b => b.ClassSession)
            .WithMany(c => c.Bookings)
            .HasForeignKey(b => b.ClassSessionId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.Entity<WorkoutLog>()
            .HasOne(w => w.User)
            .WithMany()
            .HasForeignKey(w => w.UserId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.Entity<WaterLog>()
            .HasOne(w => w.User)
            .WithMany()
            .HasForeignKey(w => w.UserId)
            .OnDelete(DeleteBehavior.Cascade);

        // One water log row per member per day.
        builder.Entity<WaterLog>()
            .HasIndex(w => new { w.UserId, w.LogDate })
            .IsUnique();

        // Seed the three standard plans so the API has real data on first run.
        builder.Entity<Plan>().HasData(
            new Plan { Id = 1, Name = "Basic", Price = 1499m, DurationDays = 30, IsActive = true, Description = "Gym floor access, standard hours.", TenantId = "default" },
            new Plan { Id = 2, Name = "Premium", Price = 2999m, DurationDays = 30, IsActive = true, Description = "All classes + personal training discount.", TenantId = "default" },
            new Plan { Id = 3, Name = "Elite", Price = 4999m, DurationDays = 30, IsActive = true, Description = "24/7 access, all classes, monthly PT session.", TenantId = "default" }
        );

        // Seed a demo weekly schedule mirroring the HTML site's schedule preview.
        builder.Entity<ClassSession>().HasData(
            new ClassSession { Id = 1, DayOfWeek = 1, StartTime = new TimeOnly(6, 0), Title = "HIIT", TrainerName = "Coach Aman", Level = "Intermediate", Type = "Cardio", DurationMin = 45, DayLabel = "Mon", Capacity = 20, IsActive = true, TenantId = "default" },
            new ClassSession { Id = 2, DayOfWeek = 1, StartTime = new TimeOnly(18, 0), Title = "Strength Training", TrainerName = "Coach Vikram", Level = "All Levels", Type = "Strength", DurationMin = 60, DayLabel = "Mon", Capacity = 16, IsActive = true, TenantId = "default" },
            new ClassSession { Id = 3, DayOfWeek = 2, StartTime = new TimeOnly(7, 0), Title = "Yoga & Mobility", TrainerName = "Coach Priya", Level = "All Levels", Type = "Yoga", DurationMin = 60, DayLabel = "Tue", Capacity = 18, IsActive = true, TenantId = "default" },
            new ClassSession { Id = 4, DayOfWeek = 3, StartTime = new TimeOnly(6, 0), Title = "HIIT", TrainerName = "Coach Aman", Level = "Intermediate", Type = "Cardio", DurationMin = 45, DayLabel = "Wed", Capacity = 20, IsActive = true, TenantId = "default" },
            new ClassSession { Id = 5, DayOfWeek = 4, StartTime = new TimeOnly(18, 0), Title = "Functional Athlete", TrainerName = "Coach Vikram", Level = "Advanced", Type = "Functional", DurationMin = 60, DayLabel = "Thu", Capacity = 14, IsActive = true, TenantId = "default" },
            new ClassSession { Id = 6, DayOfWeek = 5, StartTime = new TimeOnly(7, 0), Title = "Yoga & Mobility", TrainerName = "Coach Priya", Level = "All Levels", Type = "Yoga", DurationMin = 60, DayLabel = "Fri", Capacity = 18, IsActive = true, TenantId = "default" },
            new ClassSession { Id = 7, DayOfWeek = 6, StartTime = new TimeOnly(9, 0), Title = "Body Transformation", TrainerName = "Coach Sneha", Level = "All Levels", Type = "Strength", DurationMin = 75, DayLabel = "Sat", Capacity = 20, IsActive = true, TenantId = "default" }
        );
    }
}
