# Persistent Volume Claims (PVCs) - Daten-Schutz

## Übersicht

Die PVCs für Postgres sind **persistent** konfiguriert und werden **NICHT automatisch gelöscht**, selbst wenn:
- Die ArgoCD Application gelöscht wird
- Der Namespace gelöscht wird (siehe unten)
- Pods neu gestartet werden

Dies schützt deine Datenbank-Daten vor versehentlichem Verlust.

## Persistente PVCs

### 1. `postgres-data-postgres-0`
- **Zweck:** Postgres Hauptdatenbank
- **Größe:** 10Gi
- **Annotation:** `argocd.argoproj.io/sync-options: Prune=false`

### 2. `postgres-backup-pvc`
- **Zweck:** Backup-Speicher (automatische & manuelle Backups)
- **Größe:** 5Gi
- **Annotation:** `argocd.argoproj.io/sync-options: Prune=false`

## ArgoCD Verhalten

### ✅ **Was ArgoCD NICHT löscht:**
- PVCs mit `Prune=false` Annotation
- Die Daten im PersistentVolume

### ❌ **Was ArgoCD löscht:**
- Pods
- Services
- Deployments/StatefulSets
- ConfigMaps
- Secrets

### ⚠️ **Wichtig: Namespace-Löschung**

Wenn du den **Namespace manuell löschst** (nicht über ArgoCD), werden die PVCs **trotzdem gelöscht**!

```powershell
# ⚠️ LÖSCHT ALLES (inkl. PVCs):
kubectl delete namespace development
```

**Grund:** Kubernetes löscht alle Ressourcen in einem Namespace, unabhängig von Annotations.

## Wie du PVCs wirklich schützt

### Option 1: PVCs in separatem Namespace (Production-Empfehlung)

```yaml
# PVCs in "storage" Namespace
apiVersion: v1
kind: Namespace
metadata:
  name: storage
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: postgres-data
  namespace: storage  # ← Separater Namespace
```

Dann in StatefulSet:
```yaml
volumes:
- name: postgres-data
  persistentVolumeClaim:
    claimName: postgres-data
    namespace: storage  # Cross-Namespace PVC
```

### Option 2: Finalizer entfernen (kurzfristig)

```powershell
# Entferne Finalizer vor Namespace-Löschung
kubectl patch pvc postgres-data-postgres-0 -n development -p '{"metadata":{"finalizers":[]}}'
kubectl patch pvc postgres-backup-pvc -n development -p '{"metadata":{"finalizers":[]}}'

# Namespace kann jetzt nicht gelöscht werden (PVCs hängen)
```

### Option 3: PV Reclaim Policy auf Retain (BESTE für deine Setup)

Die PVs behalten, auch wenn PVCs gelöscht werden:

```powershell
# Finde PV Namen
kubectl get pvc postgres-data-postgres-0 -n development -o jsonpath='{.spec.volumeName}'

# Setze Retain Policy
kubectl patch pv <PV_NAME> -p '{"spec":{"persistentVolumeReclaimPolicy":"Retain"}}'
```

**Vorteil:** Auch nach Namespace-Löschung bleiben die PVs erhalten und können neu gebunden werden.

## Aktuelle Konfiguration

Mit den Änderungen in `persistent-volumes.yaml`:

```yaml
annotations:
  argocd.argoproj.io/sync-options: Prune=false
```

**Was das bedeutet:**
- ✅ ArgoCD löscht PVCs nicht bei Application-Delete
- ✅ PVCs bleiben bei Pod-Restarts
- ❌ Namespace-Löschung löscht PVCs trotzdem

## Manuelle PVC-Löschung

Falls du die PVCs wirklich löschen willst:

```powershell
# Prüfe was gelöscht wird
kubectl get pvc -n development

# Lösche spezifisches PVC
kubectl delete pvc postgres-data-postgres-0 -n development

# ODER alle auf einmal
kubectl delete pvc -n development --all
```

## Backup vor kritischen Operationen

**Immer vorher Backup machen:**

```powershell
# Vor Namespace/Application-Löschung
.\backup-now.ps1 -BackupName "before-delete" -Download

# Oder in Daemon
.\backup-to-daemon.ps1
```

## PV Recovery nach versehentlicher Löschung

Wenn PVCs gelöscht wurden, aber PVs noch existieren (bei `Retain` Policy):

```powershell
# 1. Finde verfügbare PVs
kubectl get pv | Select-String "Released|Available"

# 2. Lösche claimRef im PV
kubectl patch pv <PV_NAME> -p '{"spec":{"claimRef":null}}'

# 3. Erstelle neue PVC mit gleichem Namen
kubectl apply -f k8s/postgres/persistent-volumes.yaml

# 4. PV wird automatisch neu gebunden
```

## Empfehlung für Production

Für Production-Umgebungen:
1. ✅ Separater "storage" Namespace für PVCs
2. ✅ `persistentVolumeReclaimPolicy: Retain`
3. ✅ Regelmäßige Backups auf externes Storage (S3, Azure Blob)
4. ✅ Snapshot-fähiger StorageClass
5. ✅ Disaster Recovery Tests
