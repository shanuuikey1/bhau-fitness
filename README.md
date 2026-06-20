# BHAU FITNESS — Flutter + ASP.NET Core + MSSQL

A from-scratch foundation: **auth + core membership CRUD**, in a genuinely different stack
from the live Supabase/Vercel web app — built for a freelance portfolio.

```
backend/BhauFitnessApi/      ASP.NET Core 8 Web API + EF Core + SQL Server
frontend/bhau_fitness_flutter/   Flutter app (Provider state management)
```

## ⚠️ Read this first

Everything in this folder was written carefully but **never compiled or run** — my
sandbox can't reach the .NET or Flutter SDK download servers, so unlike the web app
earlier (where I validated every change with `node --check`), this code hasn't been
through that safety net. The architecture and logic are sound and I cross-checked every
field name between the C# DTOs and Dart models mechanically (zero mismatches), but treat
the first build as a real "let's see what comes up" — likely a missing NuGet package
version or a small typo, not a structural problem. Tell me the exact error and I'll fix it
fast.

## What's included (and what isn't)

**Included:** register, login (JWT), view/edit profile, list plans, join a plan, view
current membership status.

**Not included yet** (this was scoped as a foundation, not full feature parity with the
web app): admin panel, AI coach, WhatsApp lead notifications, BMI calculator, workout
planner, engagement suite (badges/streaks/leaderboard), password reset emails. Ask for
any of these next and I'll build them on this same foundation.

---

## Prerequisites

Install these if you don't already have them:

1. **.NET 10 SDK** — https://dotnet.microsoft.com/download/dotnet/10.0 (verify with `dotnet --version` first — you may already have it)
2. **SQL Server** — Express or Developer edition (free):
   https://www.microsoft.com/sql-server/sql-server-downloads
   (Already have SQL Server installed some other way? Skip this — just adjust the
   connection string below to match.)
3. **Flutter SDK** — https://flutter.dev (the official install guide includes Android
   Studio setup, which you'll also want for an emulator)
4. An editor — VS Code with the Flutter + C# extensions, or Visual Studio for the backend
   and Android Studio for the Flutter side. Either works.

Verify installs:
```bash
dotnet --version      # should print 8.x.x
flutter doctor         # checks your whole Flutter setup, fix anything it flags red
```

---

## 1. Backend setup

```bash
cd backend/BhauFitnessApi
dotnet restore
```

**Check the database connection** — open `appsettings.Development.json` and confirm the
`Server=` value matches your actual SQL Server instance name:
- Default SQL Server Express install → `Server=localhost\SQLEXPRESS;...` (already set)
- Using LocalDB instead → change to `Server=(localdb)\mssqllocaldb;Database=BhauFitnessDb;Trusted_Connection=True;`
- Using SQL Server auth (username/password) instead of Windows auth → change to
  `Server=localhost;Database=BhauFitnessDb;User Id=sa;Password=yourpassword;TrustServerCertificate=True;`

**Create the database schema:**
```bash
dotnet tool install --global dotnet-ef   # one-time, skip if you already have it
dotnet ef migrations add InitialCreate
```
This generates a `Migrations/` folder based on the entity models — that's expected and
correct, EF Core migrations are meant to be generated locally, not hand-written.

**Run it:**
```bash
dotnet run
```
The first run also auto-applies the migration to create your database (see the
`Database.Migrate()` call in `Program.cs` — Development-only convenience). Note the
**port** it prints in the terminal (commonly `http://localhost:5000` or similar, but
.NET sometimes assigns a different one — check the actual output).

**Test it's alive:** open `http://localhost:<port>/swagger` in a browser — you should see
the full API with a green "Authorize" button (paste a JWT there to test protected
endpoints directly from Swagger, no Flutter needed for a quick check).

---

## 2. Frontend setup

```bash
cd frontend/bhau_fitness_flutter
flutter pub get
```

**Critical step — fix the API URL.** Open `lib/services/api_service.dart` and find:
```dart
static const String baseUrl = 'http://10.0.2.2:5000/api';
```
`10.0.2.2` is a special address that only works from the **Android emulator** (it's the
emulator's alias for your computer's `localhost`). Change it based on what you're
actually running on:

| Running on | Use |
|---|---|
| Android emulator | `http://10.0.2.2:<port>/api` (already set — just fix the port) |
| iOS simulator | `http://localhost:<port>/api` |
| Chrome (`flutter run -d chrome`) | `http://localhost:<port>/api` |
| Physical phone | `http://<your-computer's-LAN-IP>:<port>/api` (phone and computer must be on the same Wi-Fi; find your IP with `ipconfig` on Windows) |

Match `<port>` to whatever the backend printed in step 1.

**Run it:**
```bash
flutter run
```
Pick a device/emulator when prompted if you have more than one available.

---

## 3. Test the full loop

1. Register a new account in the app (pick a goal, fill the form).
2. You should land on the home screen — "No active membership yet" + a plan list.
3. Tap **Join** on a plan → the membership card should appear with status, dates, days
   remaining.
4. In SQL Server Management Studio (or Azure Data Studio), check the `BhauFitnessDb`
   database → `AspNetUsers` and `Memberships` tables → your test data should be there.
5. Log out, log back in with the same credentials → should return straight to the
   dashboard with your membership intact.

---

## If something breaks

Most likely culprits, roughly in order of probability:
1. **Connection string mismatch** — SQL Server instance name doesn't match what's in
   `appsettings.Development.json`. Error will mention "cannot open database" or "server
   not found."
2. **Wrong API URL in Flutter** — usually shows as "Could not reach the server" on
   login/register. Double check the table above matches your actual run target.
3. **Migrations not applied** — if you skipped `dotnet ef migrations add InitialCreate`,
   the API will throw on first request. Run that command, then `dotnet run` again.
4. **NuGet package version conflicts** — if `dotnet restore` complains, tell me the exact
   error; package versions sometimes need a small bump.

Paste me the exact error text (terminal output, not a paraphrase) and I'll pinpoint the
fix immediately — that's far faster than guessing.
