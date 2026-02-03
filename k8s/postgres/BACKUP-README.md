# Postgres Continuous Backup System

## Übersicht

Das automatische Backup-System erstellt alle **30 Minuten** ein vollständiges Backup der Postgres-Datenbank und behält die letzten **10 Backups**.

## Komponenten

### 1. Backup Daemon (`postgres-backup-daemon`)
- Läuft als Deployment mit 1 Replica
- Erstellt automatisch Backups alle 30 Minuten
- Löscht alte Backups (behält nur die letzten 10)
- Speichert Backups im PVC `postgres-backup-pvc`

### 2. Backup Storage (`postgres-backup-pvc`)
- PersistentVolumeClaim mit 5GB Speicher
- Hostpath StorageClass (Docker Desktop)
- Speichert Backup-Dateien im Format: `continuous-YYYYMMDD-HHMMSS.sql`

### 3. Backup Script (`postgres-backup-script`)
- ConfigMap mit dem Backup-Logic
- Verwendet `pg_dump` für konsistente Backups
- Logging mit Timestamps

## Verwendung

### Backup-Status überprüfen

```powershell
# Backup Daemon Status
kubectl get pods -n development -l app=postgres-backup

# Backup Daemon Logs
kubectl logs -n development -l app=postgres-backup --tail=50 -f

# Verfügbare Backups auflisten
.\restore-backup.ps1 -ListBackups
```

### Backup manuell auslösen

Warte einfach auf das nächste automatische Backup (max. 30 Min) oder starte den Pod neu für ein sofortiges Backup:

```powershell
kubectl rollout restart deployment postgres-backup-daemon -n development
```

### Backup wiederherstellen

1. **Liste verfügbare Backups:**
   ```powershell
   .\restore-backup.ps1 -ListBackups
   ```

2. **Restore ein bestimmtes Backup:**
   ```powershell
   .\restore-backup.ps1 -BackupFile continuous-20260203-120000.sql
   ```

3. **Neuestes Backup wiederherstellen:**
   ```powershell
   # Automatisch das neueste auswählen
   $latest = kubectl exec -n development $(kubectl get pods -n development -l app=postgres-backup -o jsonpath="{.items[0].metadata.name}") -- ls -t /backups/continuous-*.sql | Select-Object -First 1
   .\restore-backup.ps1 -BackupFile $latest
   ```

## Backup-Retention

- **Intervall:** 30 Minuten
- **Anzahl:** Letzte 10 Backups
- **Alter:** Max. 5 Stunden (10 × 30 Min)

Falls du das ändern möchtest, passe das ConfigMap-Script an:
- **Intervall:** Ändere `sleep 1800` (Sekunden)
- **Anzahl:** Ändere `tail -n +11` (z.B. `tail -n +21` für 20 Backups)

## Troubleshooting

### Backup Daemon läuft nicht
```powershell
kubectl get pods -n development -l app=postgres-backup
kubectl describe pod -n development -l app=postgres-backup
```

### Backups werden nicht erstellt
```powershell
# Prüfe die Logs
kubectl logs -n development -l app=postgres-backup --tail=100

# Prüfe DB-Credentials
kubectl get secret db-credentials -n development -o yaml
```

### Kein Speicherplatz mehr
```powershell
# Prüfe PVC-Nutzung
kubectl exec -n development $(kubectl get pods -n development -l app=postgres-backup -o jsonpath="{.items[0].metadata.name}") -- df -h /backups

# Alte Backups manuell löschen
kubectl exec -n development $(kubectl get pods -n development -l app=postgres-backup -o jsonpath="{.items[0].metadata.name}") -- rm /backups/continuous-2026*.sql
```

## Backup-Dateien direkt kopieren

Falls du Backups lokal speichern möchtest:

```powershell
# Backup vom Pod herunterladen
$pod = kubectl get pods -n development -l app=postgres-backup -o jsonpath="{.items[0].metadata.name}"
kubectl cp development/${pod}:/backups/continuous-20260203-120000.sql ./local-backup.sql

# Backup zum Pod hochladen
kubectl cp ./local-backup.sql development/${pod}:/backups/external-backup.sql
```

## Sicherheitshinweise

⚠️ **Wichtig für Production:**
1. Backups sollten zusätzlich auf **externes Storage** (S3, Azure Blob, etc.) kopiert werden
2. Verwende **verschlüsselte Backups** für sensible Daten
3. Teste regelmäßig **Restore-Prozeduren**
4. Implementiere **Backup-Monitoring** und Alerts

## Monitoring

Überwache das Backup-System mit:

```powershell
# Letztes Backup-Datum
kubectl exec -n development $(kubectl get pods -n development -l app=postgres-backup -o jsonpath="{.items[0].metadata.name}") -- ls -lt /backups/continuous-*.sql | head -n 2

# Backup-Größen
kubectl exec -n development $(kubectl get pods -n development -l app=postgres-backup -o jsonpath="{.items[0].metadata.name}") -- du -h /backups/continuous-*.sql
```

Für Production solltest du Prometheus/Grafana Alerts einrichten, die warnen wenn:
- Kein Backup in den letzten 45 Minuten erstellt wurde
- Der PVC-Speicher > 80% voll ist
- Backup-Daemon-Pod nicht läuft
