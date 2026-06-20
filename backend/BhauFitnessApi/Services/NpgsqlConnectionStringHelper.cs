namespace BhauFitnessApi.Services;

/// Neon, Render, Heroku, etc. expose PostgreSQL credentials as a single
/// `postgres://user:pass@host:port/db?sslmode=require` URL. Npgsql expects a
/// key-value connection string instead, so convert when given a URL. A string
/// that already looks like a key-value connection string is passed through.
public static class NpgsqlConnectionStringHelper
{
    public static string Normalize(string raw)
    {
        raw = raw.Trim();
        if (!raw.StartsWith("postgres://", StringComparison.OrdinalIgnoreCase)
            && !raw.StartsWith("postgresql://", StringComparison.OrdinalIgnoreCase))
        {
            return raw; // already a key-value connection string
        }

        var uri = new Uri(raw);
        var userInfo = uri.UserInfo.Split(':', 2);
        var username = Uri.UnescapeDataString(userInfo[0]);
        var password = userInfo.Length > 1 ? Uri.UnescapeDataString(userInfo[1]) : string.Empty;
        var database = uri.AbsolutePath.TrimStart('/');
        var port = uri.Port > 0 ? uri.Port : 5432;

        // Most hosted Postgres (Neon especially) require SSL.
        var sslmode = "Require";
        var query = uri.Query.TrimStart('?');
        foreach (var pair in query.Split('&', StringSplitOptions.RemoveEmptyEntries))
        {
            var kv = pair.Split('=', 2);
            if (kv.Length == 2 && kv[0].Equals("sslmode", StringComparison.OrdinalIgnoreCase))
            {
                sslmode = kv[1];
            }
        }

        return $"Host={uri.Host};Port={port};Database={database};Username={username};" +
               $"Password={password};SSL Mode={sslmode};Trust Server Certificate=true";
    }
}
