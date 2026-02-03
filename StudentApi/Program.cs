using Microsoft.EntityFrameworkCore;
using StudentApi.Data;
using StudentApi.Models;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.

builder.Services.AddControllers();
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Read secrets from Docker secrets location
string GetSecret(string secretName)
{
    var secretPath = Path.Combine("/run/secrets", secretName);
    if (File.Exists(secretPath))
    {
        return File.ReadAllText(secretPath).Trim();
    }
    return null;
}

var dbPassword = GetSecret("db_password") ?? "postgres"; // Fallback for local dev if not using secrets
var dbUser = GetSecret("db_user") ?? "postgres";
var dbHost = Environment.GetEnvironmentVariable("DB_HOST") ?? "db";

var connectionString = $"Host={dbHost};Database=studentdb;Username={dbUser};Password={dbPassword}";

builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseNpgsql(connectionString));

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment() || true) // Enable Swagger in production for this demo
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

// Ensure database is created (for simplicity in this demo)
using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
    
    // Simple retry logic for container startup
    int retries = 10;
    while (retries > 0)
    {
        try
        {
            db.Database.EnsureCreated();
            break;
        }
        catch (Exception ex)
        {
            retries--;
            if (retries == 0) throw;
            Console.WriteLine($"Database not ready yet, retrying... ({ex.Message})");
            Thread.Sleep(2000);
        }
    }
}

app.UseAuthorization();

app.MapControllers();

app.Run();
