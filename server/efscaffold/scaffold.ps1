# Ensure the script stops if a command fails
$ErrorActionPreference = "Stop"

# 1. Load and parse the .env file safely
if (Test-Path .env) {
    Get-Content .env | ForEach-Object {
        # Ignore comments (#) and empty lines
        if ($_ -match '^[^#]*=') {
            $k, $v = $_.Split('=', 2)
            # Clean up spaces around keys and values
            $k = $k.Trim()
            $v = $v.Trim().Trim('"').Trim("'") 
            
            [System.Environment]::SetEnvironmentVariable($k, $v, "Process")
        }
    }
    Write-Host "✅ Environment variables loaded from .env" -ForegroundColor Green
} else {
    Write-Warning ".env file not found! Attempting to run anyway..."
}

# 2. Ensure dotnet-ef tool is installed
Write-Host "Checking dotnet-ef tool..." -ForegroundColor Cyan
dotnet tool install -g dotnet-ef 2>$null

# 3. Run the EF Core Scaffold command
Write-Host "Running DB Context Scaffold..." -ForegroundColor Cyan

dotnet ef dbcontext scaffold $env:CONN_STR Npgsql.EntityFrameworkCore.PostgreSQL `
    --output-dir ./Entities `
    --context-dir . `
    --context MyDbContext `
    --no-onconfiguring `
    --namespace efscaffold.Entities `
    --context-namespace Infrastructure.Postgres.Scaffolding `
    --schema todosystem `
    --force

Write-Host "🚀 Scaffolding complete!" -ForegroundColor Green