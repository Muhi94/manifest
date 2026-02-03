# Manual Backup Script für Postgres
# Führt sofort ein Backup aus (ohne auf das automatische Intervall zu warten)

param(
    [string]$BackupName = "",
    [switch]$Download
)

$ErrorActionPreference = "Stop"

$namespace = "development"

Write-Host "`n=== Postgres Manual Backup ===" -ForegroundColor Cyan
Write-Host ""

# Hole DB-Credentials
Write-Host "[1/4] Getting database credentials..." -ForegroundColor Yellow
$user = kubectl get secret db-credentials -n $namespace -o jsonpath="{.data.username}" 2>$null | 
        ForEach-Object { [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($_)) }
$pass = kubectl get secret db-credentials -n $namespace -o jsonpath="{.data.password}" 2>$null | 
        ForEach-Object { [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($_)) }

if (-not $user -or -not $pass) {
    Write-Error "Failed to get DB credentials from secret 'db-credentials'"
    exit 1
}

# Prüfe ob Postgres läuft
Write-Host "[2/4] Checking Postgres status..." -ForegroundColor Yellow
$postgresReady = kubectl get pods -n $namespace postgres-0 -o jsonpath="{.status.conditions[?(@.type=='Ready')].status}" 2>$null
if ($postgresReady -ne "True") {
    Write-Error "Postgres pod is not ready!"
    exit 1
}
Write-Host "      Postgres is ready" -ForegroundColor Green

# Erstelle Backup-Namen
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
if ($BackupName) {
    $backupFile = "manual-$BackupName-$timestamp.sql"
} else {
    $backupFile = "manual-$timestamp.sql"
}

# Erstelle Backup
Write-Host "[3/4] Creating backup: $backupFile" -ForegroundColor Yellow
Write-Host "      This may take a moment..." -ForegroundColor Gray

$backupCommand = "PGPASSWORD='$pass' pg_dump -h postgres-service -U $user -d studentdb > /tmp/$backupFile && echo SUCCESS"

$result = kubectl exec -n $namespace postgres-0 -- sh -c $backupCommand 2>&1

if ($result -notmatch "SUCCESS") {
    Write-Host "[FAILED] Backup creation failed!" -ForegroundColor Red
    Write-Host $result
    exit 1
}

# Hole Backup-Größe
$backupSize = kubectl exec -n $namespace postgres-0 -- sh -c "ls -lh /tmp/$backupFile | awk '{print `$5}'" 2>$null
Write-Host "      Backup size: $backupSize" -ForegroundColor Green

# Download Backup lokal (optional)
if ($Download) {
    Write-Host "[4/4] Downloading backup locally..." -ForegroundColor Yellow
    kubectl cp ${namespace}/postgres-0:/tmp/$backupFile ./$backupFile 2>$null
    
    if (Test-Path ./$backupFile) {
        $localSize = (Get-Item ./$backupFile).Length
        Write-Host "      Downloaded to: ./$backupFile [$([math]::Round($localSize/1KB, 2)) KB]" -ForegroundColor Green
    } else {
        Write-Host "      Download failed!" -ForegroundColor Red
    }
    
    # Cleanup remote temp file
    kubectl exec -n $namespace postgres-0 -- rm /tmp/$backupFile 2>$null
} else {
    Write-Host "[4/4] Backup stored in pod at: /tmp/$backupFile" -ForegroundColor Yellow
    Write-Host "      To download: kubectl cp ${namespace}/postgres-0:/tmp/$backupFile ./$backupFile" -ForegroundColor Gray
}

Write-Host ""
Write-Host "[SUCCESS] Backup completed!" -ForegroundColor Green
Write-Host ""
Write-Host "Backup file: $backupFile" -ForegroundColor Cyan
Write-Host "Size:        $backupSize" -ForegroundColor Cyan

if (-not $Download) {
    Write-Host ""
    Write-Host "Tip: Use -Download flag to automatically download the backup locally" -ForegroundColor Yellow
    Write-Host "     .\backup-now.ps1 -Download" -ForegroundColor Gray
}

Write-Host ""
