# Multi-stage build for the BHAU FITNESS API (ASP.NET Core, .NET 10).
# Render builds this image and runs it; the app binds to $PORT (set by Render)
# via the logic in Program.cs.

FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

# Restore first (cached layer) then copy the rest and publish.
COPY *.csproj ./
RUN dotnet restore
COPY . ./
RUN dotnet publish -c Release -o /app /p:UseAppHost=false

FROM mcr.microsoft.com/dotnet/aspnet:10.0
WORKDIR /app
COPY --from=build /app ./

# Production config (connection string, DB_PROVIDER, JWT, SMTP) is supplied as
# environment variables by the host — never baked into the image.
ENV ASPNETCORE_ENVIRONMENT=Production
EXPOSE 8080

ENTRYPOINT ["dotnet", "BhauFitnessApi.dll"]
