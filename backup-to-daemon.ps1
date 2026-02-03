# Upload Manual Backup to Backup Daemon
# Verschiebt ein manuelles Backup in das Continuous Backup System

param(
    [Parameter(Mandatory=$false)]
    [string]$LocalFile
)

$ErrorActionPreference = "Stop"

$namespace = "development"

Write-Host "`n=== Upload Backup to Daemon ===" -ForegroundColor Cyan
Write-Host ""

# Finde Backup Daemon Pod
$backupDaemonPod = kubectl get pods -n $namespace -l app=postgres-backup -o jsonpath="{.items[0].metadata.name}" 2>$null

if (-not $backupDaemonPod) {
    Write-Error "Backup daemon pod not found!"
    exit 1
}

# Wenn keine Datei angegeben, erstelle neues Backup
if (-not $LocalFile) {
    Write-Host "No local file specified. Creating new backup..." -ForegroundColor Yellow
    Write-Host ""
    
    # Hole DB-Credentials
    $user = kubectl get secret db-credentials -n $namespace -o jsonpath="{.data.username}" 2>$null | 
            ForEach-Object { [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($_)) }
    $pass = kubectl get secret db-credentials -n $namespace -o jsonpath="{.data.password}" 2>$null | 
            ForEach-Object { [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($_)) }
    
    if (-not $user -or -not $pass) {
        Write-Error "Failed to get DB credentials"
        exit 1
    }
    
    # Erstelle Backup direkt im Daemon
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $backupFile = "manual-$timestamp.sql"
    
    Write-Host "Creating backup: $backupFile" -ForegroundColor Yellow
    
    $backupCommand = "PGPASSWORD='$pass' pg_dump -h postgres-service -U $user -d studentdb > /backups/$backupFile && echo SUCCESS"
    $result = kubectl exec -n $namespace $backupDaemonPod -- sh -c $backupCommand 2>&1
    
    if ($result -notmatch "SUCCESS") {
        Write-Host "[FAILED] Backup creation failed!" -ForegroundColor Red
        Write-Host $result
        exit 1
    }
    
    $backupSize = kubectl exec -n $namespace $backupDaemonPod -- sh -c "ls -lh /backups/$backupFile | awk '{print `$5}'" 2>$null
    
    Write-Host ""
    Write-Host "[SUCCESS] Backup created in daemon storage!" -ForegroundColor Green
    Write-Host "File: $backupFile [$backupSize]" -ForegroundColor Cyan
    
} else {
    # Upload lokale Datei
    if (-not (Test-Path $LocalFile)) {
        Write-Error "Local file not found: $LocalFile"
        exit 1
    }
    
    $fileName = Split-Path $LocalFile -Leaf
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $targetFile = "uploaded-$timestamp-$fileName"
    
    Write-Host "Uploading: $LocalFile" -ForegroundColor Yellow
    Write-Host "Target:    $targetFile" -ForegroundColor Yellow
    Write-Host ""
    
    kubectl cp $LocalFile ${namespace}/${backupDaemonPod}:/backups/$targetFile 2>$null
    
    if ($LASTEXITCODE -eq 0) {
        $backupSize = kubectl exec -n $namespace $backupDaemonPod -- sh -c "ls -lh /backups/$targetFile | awk '{print `$5}'" 2>$null
        
        Write-Host "[SUCCESS] Backup uploaded to daemon storage!" -ForegroundColor Green
        Write-Host "File: $targetFile [$backupSize]" -ForegroundColor Cyan
    } else {
        Write-Host "[FAILED] Upload failed!" -ForegroundColor Red
        exit 1
    }
}

# Liste alle Backups
Write-Host ""
Write-Host "All backups in daemon storage:" -ForegroundColor Cyan
kubectl exec -n $namespace $backupDaemonPod -- sh -c 'ls -lh /backups/*.sql' 2>$null | ForEach-Object {
    Write-Host "  $_" -ForegroundColor Gray
}

Write-Host ""
