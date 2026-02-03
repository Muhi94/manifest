# Backup Restore Script für Postgres
# Usage: .\restore-backup.ps1 [-BackupFile <filename>] [-ListBackups]

param(
    [string]$BackupFile,
    [switch]$ListBackups
)

$ErrorActionPreference = "Stop"

# Namespace und Pod
$namespace = "development"
$backupDaemonPod = kubectl get pods -n $namespace -l app=postgres-backup -o jsonpath="{.items[0].metadata.name}" 2>$null

if (-not $backupDaemonPod) {
    Write-Error "Backup daemon pod not found. Make sure postgres-backup-daemon is running."
    exit 1
}

# Liste verfügbare Backups
if ($ListBackups) {
    Write-Host "`nAvailable backups:" -ForegroundColor Cyan
    kubectl exec -n $namespace $backupDaemonPod -- ls -lh /backups/continuous-*.sql 2>$null | 
        Select-Object -Skip 1 | 
        ForEach-Object {
            if ($_ -match '(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(.*?)continuous-(.+)\.sql') {
                $size = $matches[5].Trim()
                $timestamp = $matches[6]
                Write-Host "  • continuous-$timestamp.sql [$size]" -ForegroundColor Green
            }
        }
    Write-Host ""
    exit 0
}

# Backup-Datei auswählen
if (-not $BackupFile) {
    Write-Host "Available backups:" -ForegroundColor Cyan
    $backups = kubectl exec -n $namespace $backupDaemonPod -- ls -t /backups/continuous-*.sql 2>$null
    $backups | ForEach-Object { Write-Host "  $_" }
    
    Write-Host "`nUsage: .\restore-backup.ps1 -BackupFile <filename>" -ForegroundColor Yellow
    Write-Host "   or: .\restore-backup.ps1 -ListBackups" -ForegroundColor Yellow
    exit 0
}

# Prüfe ob Backup existiert
$exists = kubectl exec -n $namespace $backupDaemonPod -- test -f "/backups/$BackupFile" 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Error "Backup file not found: $BackupFile"
    exit 1
}

Write-Host "`n=== Postgres Backup Restore ===" -ForegroundColor Cyan
Write-Host "Backup file: $BackupFile" -ForegroundColor Yellow
Write-Host ""

# Warnung
Write-Host "WARNING: This will overwrite all data in the database!" -ForegroundColor Red
$confirm = Read-Host "Continue? (yes/no)"
if ($confirm -ne "yes") {
    Write-Host "Restore cancelled." -ForegroundColor Yellow
    exit 0
}

Write-Host "`nRestoring backup..." -ForegroundColor Green

# DB-Credentials holen
$user = kubectl get secret db-credentials -n $namespace -o jsonpath="{.data.username}" | 
        ForEach-Object { [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($_)) }
$pass = kubectl get secret db-credentials -n $namespace -o jsonpath="{.data.password}" | 
        ForEach-Object { [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($_)) }

# Restore ausführen
kubectl exec -n $namespace $backupDaemonPod -- sh -c "PGPASSWORD='$pass' psql -h postgres-service -U $user -d studentdb < /backups/$BackupFile"

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n✓ Restore completed successfully!" -ForegroundColor Green
} else {
    Write-Host "`n✗ Restore failed!" -ForegroundColor Red
    exit 1
}
