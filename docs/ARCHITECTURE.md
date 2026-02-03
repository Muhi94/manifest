# 🏗️ Architektur-Übersicht - Wie alles zusammenhängt

## 📐 System-Architektur

```
┌─────────────────────────────────────────────────────────────────────────┐
│                          DEIN ENTWICKLUNGS-PC                            │
│                                                                           │
│  ┌─────────────────┐          ┌─────────────────┐                       │
│  │   VS Code /     │          │   Browser       │                       │
│  │   IDE           │          │                 │                       │
│  │                 │          │  localhost/     │                       │
│  │  Code ändern    │          │  swagger        │                       │
│  └────────┬────────┘          └────────┬────────┘                       │
│           │                            │                                 │
│           │ git push                   │ HTTP Request                    │
│           │                            │                                 │
│           ▼                            ▼                                 │
│  ┌──────────────────────────────────────────────────────┐               │
│  │                  DOCKER DESKTOP                       │               │
│  │                                                       │               │
│  │  ┌──────────────────────────────────────────────┐   │               │
│  │  │          KUBERNETES CLUSTER                   │   │               │
│  │  │                                               │   │               │
│  │  │  ┌────────────────────────────────────────┐  │   │               │
│  │  │  │         INGRESS CONTROLLER              │  │   │               │
│  │  │  │  (NGINX)                                │  │   │               │
│  │  │  │  Port 80 → Service Routing              │  │   │               │
│  │  │  └────────────┬───────────────────────────┘  │   │               │
│  │  │               │                               │   │               │
│  │  │  ┌────────────▼───────────────────────────┐  │   │               │
│  │  │  │  NAMESPACE: development                 │  │   │               │
│  │  │  │                                         │  │   │               │
│  │  │  │  ┌──────────────────────────────────┐  │  │   │               │
│  │  │  │  │   Ingress: manifest-app-ingress  │  │  │   │               │
│  │  │  │  │   Host: localhost                │  │  │   │               │
│  │  │  │  └────────────┬─────────────────────┘  │  │   │               │
│  │  │  │               │                         │  │   │               │
│  │  │  │  ┌────────────▼─────────────────────┐  │  │   │               │
│  │  │  │  │   Service: manifest-app-service  │  │  │   │               │
│  │  │  │  │   ClusterIP: 10.96.x.x:80        │  │  │   │               │
│  │  │  │  └────────────┬─────────────────────┘  │  │   │               │
│  │  │  │               │                         │  │   │               │
│  │  │  │       ┌───────┴────────┐                │  │   │               │
│  │  │  │       ▼                ▼                │  │   │               │
│  │  │  │  ┌──────────┐    ┌──────────┐          │  │   │               │
│  │  │  │  │  Pod 1   │    │  Pod 2   │          │  │   │               │
│  │  │  │  │ (Replica)│    │ (Replica)│          │  │   │               │
│  │  │  │  │          │    │          │          │  │   │               │
│  │  │  │  │ manifest │    │ manifest │          │  │   │               │
│  │  │  │  │  -app    │    │  -app    │          │  │   │               │
│  │  │  │  │ :latest  │    │ :latest  │          │  │   │               │
│  │  │  │  │          │    │          │          │  │   │               │
│  │  │  │  │ Port 8080│    │ Port 8080│          │  │   │               │
│  │  │  │  └────┬─────┘    └────┬─────┘          │  │   │               │
│  │  │  │       │               │                 │  │   │               │
│  │  │  │       └───────┬───────┘                 │  │   │               │
│  │  │  │               │ Verbindet zu            │  │   │               │
│  │  │  │               ▼                         │  │   │               │
│  │  │  │  ┌────────────────────────────────┐    │  │   │               │
│  │  │  │  │ Service: postgres-service      │    │  │   │               │
│  │  │  │  │ ClusterIP: 10.96.x.x:5432      │    │  │   │               │
│  │  │  │  └────────────┬───────────────────┘    │  │   │               │
│  │  │  │               │                         │  │   │               │
│  │  │  │               ▼                         │  │   │               │
│  │  │  │  ┌────────────────────────────────┐    │  │   │               │
│  │  │  │  │   StatefulSet: postgres        │    │  │   │               │
│  │  │  │  │   Pod: postgres-0              │    │  │   │               │
│  │  │  │  │   Image: postgres:15-alpine    │    │  │   │               │
│  │  │  │  │   Port: 5432                   │    │  │   │               │
│  │  │  │  └────────────┬───────────────────┘    │  │   │               │
│  │  │  │               │ Nutzt                   │  │   │               │
│  │  │  │               ▼                         │  │   │               │
│  │  │  │  ┌────────────────────────────────┐    │  │   │               │
│  │  │  │  │ PVC: postgres-data-postgres-0  │    │  │   │               │
│  │  │  │  │ Size: 10Gi                     │    │  │   │               │
│  │  │  │  │ StorageClass: hostpath         │    │  │   │               │
│  │  │  │  │ ReclaimPolicy: Retain          │    │  │   │               │
│  │  │  │  └────────────┬───────────────────┘    │  │   │               │
│  │  │  │               │ Gebunden an             │  │   │               │
│  │  │  │               ▼                         │  │   │               │
│  │  │  │  ┌────────────────────────────────┐    │  │   │               │
│  │  │  │  │ PV: pvc-xxxx-xxxx-xxxx         │    │  │   │               │
│  │  │  │  │ Pfad: /var/lib/k8s-pvs/...     │    │  │   │               │
│  │  │  │  └────────────────────────────────┘    │  │   │               │
│  │  │  │                                         │  │   │               │
│  │  │  │  ┌────────────────────────────────┐    │  │   │               │
│  │  │  │  │ Deployment: postgres-backup    │    │  │   │               │
│  │  │  │  │ Daemon                         │    │  │   │               │
│  │  │  │  │ Backup alle 30 Min             │    │  │   │               │
│  │  │  │  └────────────┬───────────────────┘    │  │   │               │
│  │  │  │               │ Schreibt zu             │  │   │               │
│  │  │  │               ▼                         │  │   │               │
│  │  │  │  ┌────────────────────────────────┐    │  │   │               │
│  │  │  │  │ PVC: postgres-backup-pvc       │    │  │   │               │
│  │  │  │  │ Size: 5Gi                      │    │  │   │               │
│  │  │  │  │ Letzte 10 Backups              │    │  │   │               │
│  │  │  │  └────────────────────────────────┘    │  │   │               │
│  │  │  │                                         │  │   │               │
│  │  │  └─────────────────────────────────────────┘  │   │               │
│  │  │                                               │   │               │
│  │  │  ┌────────────────────────────────────────┐  │   │               │
│  │  │  │         NAMESPACE: argocd               │  │   │               │
│  │  │  │                                         │  │   │               │
│  │  │  │  ┌──────────────────────────────────┐  │  │   │               │
│  │  │  │  │  ArgoCD Application Controller   │  │  │   │               │
│  │  │  │  │  - Überwacht Git-Repo            │  │  │   │               │
│  │  │  │  │  - Synct alle 3 Min              │  │  │   │               │
│  │  │  │  │  - Auto-Heal bei Drift           │  │  │   │               │
│  │  │  │  └──────────────────────────────────┘  │  │   │               │
│  │  │  │               │                         │  │   │               │
│  │  │  │               │ Liest aus               │  │   │               │
│  │  │  │               ▼                         │  │   │               │
│  │  │  └───────────────┼─────────────────────────┘  │   │               │
│  │  │                  │                            │   │               │
│  │  └──────────────────┼────────────────────────────┘   │               │
│  │                     │                                │               │
│  └─────────────────────┼────────────────────────────────┘               │
│                        │                                                │
└────────────────────────┼────────────────────────────────────────────────┘
                         │
                         │ Git Pull
                         ▼
              ┌─────────────────────────┐
              │  GitHub Repository      │
              │  github.com/Muhi94/     │
              │  manifest               │
              │                         │
              │  Branch: cursor         │
              │  Path: k8s/             │
              └─────────────────────────┘
```

---

## 🔄 Datenfluss: HTTP-Request → Datenbank

### **Szenario: Benutzer ruft `GET /api/student` auf**

```
1. Browser
   ↓
   GET http://localhost/api/student
   ↓
2. Docker Desktop Port Binding
   ↓
   localhost:80 → Kubernetes Cluster
   ↓
3. Ingress Controller (NGINX)
   ↓
   Host: localhost → Route zu manifest-app-ingress
   ↓
4. Ingress: manifest-app-ingress
   ↓
   Path: /api → Backend: manifest-app-service:80
   ↓
5. Service: manifest-app-service
   ↓
   ClusterIP:80 → Load Balance zwischen Pods
   ↓
6. Pod: manifest-app-xxx (einer von 2)
   ↓
   Port 8080 → ASP.NET Core App
   ↓
7. App liest Umgebungsvariablen
   ↓
   DB_HOST = postgres-service (aus ConfigMap)
   DB_NAME = studentdb (aus ConfigMap)
   DB_USER = app_user (aus Secret)
   DB_PASSWORD = Super... (aus Secret)
   ↓
8. App verbindet zu Postgres
   ↓
   postgres-service:5432
   ↓
9. Service: postgres-service
   ↓
   Route zu StatefulSet Pod
   ↓
10. Pod: postgres-0
    ↓
    Postgres-Datenbank
    ↓
    Liest von PVC: postgres-data-postgres-0
    ↓
11. Daten zurück zur App
    ↓
12. App serialisiert zu JSON
    ↓
13. Response zurück zum Browser
    ↓
14. Browser zeigt JSON:
    [{"id": 1, "name": "Max", "age": 25}]
```

**Durchlaufzeit:** ~50-200ms

---

## 🔐 Secrets & ConfigMaps Flow

```
┌─────────────────────────────────────────────────────────┐
│  Git Repository (k8s/Student-api/ConfigMap.yaml)        │
│                                                          │
│  apiVersion: v1                                          │
│  kind: ConfigMap                                         │
│  data:                                                   │
│    database-host: "postgres-service"                     │
│    database-name: "studentdb"                            │
└────────────────────┬────────────────────────────────────┘
                     │
                     │ ArgoCD synct
                     ▼
        ┌────────────────────────────┐
        │  ConfigMap: app-config     │
        │  in Namespace: development │
        └────────────┬───────────────┘
                     │
                     │ Wird gelesen als Env-Var
                     ▼
           ┌─────────────────────┐
           │  Pod: manifest-app  │
           │                     │
           │  env:               │
           │  - DB_HOST=         │
           │    postgres-service │
           │  - DB_NAME=         │
           │    studentdb        │
           └─────────────────────┘
```

```
┌─────────────────────────────────────────────────────────┐
│  Lokal: secrets/db_password.txt                          │
│  Inhalt: SuperSecurePassword123!                         │
└────────────────────┬────────────────────────────────────┘
                     │
                     │ kubectl create secret
                     ▼
        ┌────────────────────────────┐
        │  Secret: db-credentials    │
        │  in Namespace: development │
        │                            │
        │  data:                     │
        │    username: YXBwX3VzZXI=  │  (Base64 encoded)
        │    password: U3VwZXI...=   │  (Base64 encoded)
        └────────────┬───────────────┘
                     │
                     │ Zwei Wege:
                     │
        ┌────────────┴─────────────────┐
        │                              │
        ▼                              ▼
┌───────────────┐            ┌────────────────────┐
│ Env Variable  │            │ Volume Mount       │
│               │            │                    │
│ POSTGRES_     │            │ /etc/app-secrets/  │
│ PASSWORD=     │            │   db_password      │
│ SuperSecure.. │            │   db_user          │
└───────────────┘            └────────────────────┘
```

---

## 🏗️ Image Build & Deployment Pipeline

```
┌──────────────────────────────────────────────────────────────┐
│                     DEVELOPMENT WORKFLOW                      │
└──────────────────────────────────────────────────────────────┘

1. Code ändern (StudentApi/Program.cs)
   │
   ▼
2. .\pipeline.ps1
   │
   ├─► docker build -t localhost:30002/studenten/manifest-app:latest
   │   │
   │   └─► Dockerfile:
   │       FROM mcr.microsoft.com/dotnet/sdk:8.0
   │       WORKDIR /app
   │       COPY . .
   │       RUN dotnet publish -c Release -o out
   │       ENTRYPOINT ["dotnet", "StudentApi.dll"]
   │
   ├─► docker tag ...app:latest ...app:v1-20260203-1234
   │
   └─► docker push localhost:30002/studenten/manifest-app:latest
       └─► docker push localhost:30002/studenten/manifest-app:v1-...
           │
           ▼
       ┌────────────────────────────────┐
       │  Harbor Registry               │
       │  localhost:30002               │
       │                                │
       │  Project: studenten            │
       │    Repository: manifest-app    │
       │      Tags:                     │
       │        - latest                │
       │        - v1-20260203-1234      │
       └────────────┬───────────────────┘
                    │
                    │ Kubernetes pullt Image
                    ▼
         ┌──────────────────────────┐
         │  Pod: manifest-app-xxx   │
         │                          │
         │  imagePullSecrets:       │
         │  - harbor-regcred        │
         │                          │
         │  image: localhost:30002/ │
         │    studenten/            │
         │    manifest-app:latest   │
         │                          │
         │  imagePullPolicy: Always │
         └──────────────────────────┘

3. kubectl rollout restart deployment/manifest-app -n development
   │
   ├─► Beendet alte Pods (nach RollingUpdate-Strategie)
   ├─► Startet neue Pods mit neuem Image
   └─► Zero-Downtime (maxUnavailable: 0)
       │
       ▼
   ┌────────────────────────────┐
   │ 2 neue Pods laufen         │
   │ mit neuem Code             │
   └────────────────────────────┘
```

---

## 🔄 GitOps Workflow mit ArgoCD

```
┌────────────────────────────────────────────────────────────────┐
│                        GITOPS WORKFLOW                          │
└────────────────────────────────────────────────────────────────┘

1. Änderung in YAML (z.B. Replicas erhöhen)
   │
   │  k8s/Student-api/Deployment.yaml:
   │    spec:
   │      replicas: 3  # War: 2
   │
   ▼
2. Git Commit & Push
   │
   │  git add k8s/Student-api/Deployment.yaml
   │  git commit -m "Scale to 3 replicas"
   │  git push origin cursor
   │
   ▼
3. GitHub Repository
   │  Branch: cursor
   │  Commit: abc123...
   │
   ▼
4. ArgoCD Application Controller (Poll alle 3 Min)
   │
   ├─► Vergleicht Git (Desired State) mit Cluster (Actual State)
   │   │
   │   │  Desired:  replicas: 3
   │   │  Actual:   replicas: 2
   │   │  → OutOfSync!
   │   │
   │   ▼
   ├─► Auto-Sync aktiviert? → JA
   │   │
   │   ▼
   └─► kubectl apply -f (alle geänderten Ressourcen)
       │
       ▼
5. Kubernetes Reconciliation Loop
   │
   ├─► Deployment Controller sieht: Soll: 3, Ist: 2
   ├─► Erstellt 1 neuen ReplicaSet
   └─► Startet 1 neuen Pod
       │
       ▼
6. Cluster Status = Git Status
   │
   │  manifest-app-xxx-1  ✓ Running
   │  manifest-app-xxx-2  ✓ Running
   │  manifest-app-xxx-3  ✓ Running  (NEU!)
   │
   ▼
7. ArgoCD UI zeigt:
   │  Status: Synced ✓
   │  Health: Healthy ✓
   └──────────────────────────────────────────────────────────────┘
```

**Self-Heal Beispiel:**

```
Jemand ändert manuell:
  kubectl scale deployment/manifest-app --replicas=5 -n development

Nach 3 Minuten:
  ArgoCD sieht: Git sagt 3, Cluster hat 5 → Drift erkannt!
  → Auto-Heal: kubectl apply (setzt zurück auf 3)

Ergebnis: Git bleibt Single Source of Truth!
```

---

## 💾 Backup & Recovery Architektur

```
┌────────────────────────────────────────────────────────────────┐
│                    BACKUP SYSTEM                                │
└────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│  Postgres StatefulSet (postgres-0)                          │
│  - Datenbank: studentdb                                     │
│  - User: app_user                                           │
│  - Data: /var/lib/postgresql/data                           │
└────────────┬────────────────────────────────────────────────┘
             │
             │ Schreibt/Liest
             ▼
    ┌────────────────────────┐
    │ PVC:                   │
    │ postgres-data-         │
    │ postgres-0             │
    │ 10Gi                   │
    │ ReclaimPolicy: Retain  │
    └────────────────────────┘
             ▲
             │ Liest (pg_dump)
             │
    ┌────────┴────────────────────────────────────────────┐
    │  Backup Daemon (Deployment)                         │
    │  - Image: postgres:15-alpine                        │
    │  - Script: backup.sh                                │
    │  - Intervall: 30 Minuten                            │
    │                                                      │
    │  while true; do                                     │
    │    pg_dump > /backups/continuous-TIMESTAMP.sql      │
    │    find /backups -name "continuous-*.sql" |         │
    │      sort -nr | tail -n +11 | xargs rm  # Keep 10  │
    │    sleep 1800                                       │
    │  done                                               │
    └────────┬───────────────────────────────────────────┘
             │
             │ Schreibt zu
             ▼
    ┌────────────────────────┐
    │ PVC:                   │
    │ postgres-backup-pvc    │
    │ 5Gi                    │
    │ Prune: false           │
    │                        │
    │ /backups/              │
    │  ├─ continuous-        │
    │  │  20260203-1130.sql  │
    │  ├─ continuous-        │
    │  │  20260203-1200.sql  │
    │  └─ ... (10 files)     │
    └────────────────────────┘
             ▲
             │
    ┌────────┴──────────────────────────────────┐
    │  PowerShell Scripts                       │
    │                                            │
    │  1. backup-now.ps1                        │
    │     → Sofort-Backup                       │
    │     → kubectl exec ... pg_dump            │
    │                                            │
    │  2. backup-to-daemon.ps1                  │
    │     → Backup + Upload zum Daemon          │
    │     → kubectl cp local → pod:/backups/    │
    │                                            │
    │  3. restore-backup.ps1                    │
    │     → Backup wiederherstellen             │
    │     → kubectl exec ... psql < backup.sql  │
    └───────────────────────────────────────────┘
```

**Disaster Recovery Szenarien:**

| Szenario | PVCs Status | Daten-Status | Recovery |
|----------|-------------|--------------|----------|
| **Pod crashed** | ✓ Intakt | ✓ Safe | Auto-Restart |
| **Deployment deleted** | ✓ Intakt | ✓ Safe | Re-deploy |
| **App deleted (ArgoCD)** | ✓ Intakt (Prune=false) | ✓ Safe | Sync |
| **Namespace deleted** | ❌ PVC deleted | ✓ PV bleibt! | Rebind PV |
| **Cluster reset** | ❌ Alles weg | ✓ Backups in PV | Restore |

---

## 🔒 Security Layers

```
┌────────────────────────────────────────────────────────────────┐
│                     SECURITY ARCHITECTURE                       │
└────────────────────────────────────────────────────────────────┘

1. Network Layer (Services)
   │
   ├─► ClusterIP Services (nicht von außen erreichbar)
   │   ├─ postgres-service:5432  → Nur innerhalb Kubernetes
   │   └─ manifest-app-service:80 → Nur über Ingress
   │
   └─► Ingress (kontrollierter Außenzugriff)
       └─ localhost → manifest-app (80 → 8080)

2. Pod Security Context
   │
   ├─► App-Pods:
   │   ├─ runAsNonRoot: true
   │   ├─ runAsUser: 1000 (nicht Root!)
   │   └─ capabilities: drop ALL
   │
   └─► Postgres-Pod:
       ├─ runAsUser: 0 (nur für hostpath notwendig)
       └─ capabilities: nur CHOWN, FSETID, FOWNER

3. Secrets Management
   │
   ├─► Git: NIEMALS Secrets committen!
   │   └─ secrets/ in .gitignore
   │
   ├─► Kubernetes Secrets (Base64-encoded)
   │   ├─ db-credentials (username/password)
   │   └─ harbor-regcred (Docker login)
   │
   └─► Zugriff:
       ├─ Als Umgebungsvariable (POSTGRES_PASSWORD)
       └─ Als Volume Mount (/etc/app-secrets/db_password)

4. RBAC (Role-Based Access Control)
   │
   └─► ArgoCD ServiceAccount
       ├─ Darf: read/write in development Namespace
       └─ Darf nicht: andere Namespaces ändern

5. Image Security
   │
   ├─► Private Registry (Harbor)
   │   └─ ImagePullSecret erforderlich
   │
   ├─► Image Scanning (Harbor-Feature)
   │   └─ CVE-Checks bei Push
   │
   └─► imagePullPolicy: Always
       └─ Immer neueste Version pullen

6. Resource Limits
   │
   └─► Verhindert DoS durch einzelne Pods:
       ├─ CPU Limit: 500m (0.5 Core)
       └─ Memory Limit: 512Mi
```

---

## 📊 Monitoring & Observability

```
┌────────────────────────────────────────────────────────────────┐
│              OBSERVABILITY STACK (optional)                     │
└────────────────────────────────────────────────────────────────┘

1. Kubernetes Events
   │
   └─► kubectl get events -n development -w
       ├─ Pod Created
       ├─ Image Pulled
       ├─ Container Started
       └─ Probe Failed

2. Pod Logs
   │
   └─► kubectl logs -n development <POD-NAME>
       ├─ Application Logs
       ├─ Error Messages
       └─ Database Connection Attempts

3. Health Checks
   │
   ├─► startupProbe → Ist App gestartet?
   ├─► livenessProbe → Läuft App noch?
   └─► readinessProbe → Bereit für Traffic?

4. ArgoCD Monitoring
   │
   └─► ArgoCD UI (localhost:8080)
       ├─ Sync Status (Synced/OutOfSync)
       ├─ Health Status (Healthy/Degraded/Progressing)
       └─ Deployment History (Rollback-fähig)

5. Prometheus (falls installiert)
   │
   └─► Annotations in Deployment:
       ├─ prometheus.io/scrape: "true"
       ├─ prometheus.io/port: "8080"
       └─ prometheus.io/path: "/metrics"
```

---

## 🔧 Technology Stack

| Layer | Technology | Version | Zweck |
|-------|-----------|---------|-------|
| **Orchestration** | Kubernetes | 1.28+ | Container-Orchestrierung |
| **GitOps** | ArgoCD | 2.9+ | Kontinuierliche Delivery |
| **Registry** | Harbor | 2.9+ | Image-Storage |
| **Ingress** | NGINX Ingress | 1.9+ | HTTP-Routing |
| **Database** | PostgreSQL | 15 | Relationale DB |
| **Backend** | ASP.NET Core | 8.0 | REST API |
| **Language** | C# | 12 | App-Logik |
| **ORM** | Entity Framework Core | 8.0 | DB-Zugriff |
| **Storage** | hostpath StorageClass | - | Persistenz (Dev) |

---

## 📈 Skalierungs-Szenarien

### **Horizontal Scaling (Mehr Pods)**

```yaml
# k8s/Student-api/Deployment.yaml
spec:
  replicas: 5  # War: 2

# Ergebnis:
# manifest-app-xxx-1  ✓ Running
# manifest-app-xxx-2  ✓ Running
# manifest-app-xxx-3  ✓ Running (NEU)
# manifest-app-xxx-4  ✓ Running (NEU)
# manifest-app-xxx-5  ✓ Running (NEU)

# Load-Balancing automatisch durch Service!
```

### **Vertical Scaling (Mehr Ressourcen)**

```yaml
# k8s/Student-api/Deployment.yaml
resources:
  limits:
    cpu: 1000m     # War: 500m
    memory: 1024Mi # War: 512Mi
```

### **Auto-Scaling (HPA - Horizontal Pod Autoscaler)**

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: manifest-app-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: manifest-app
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70

# Bedeutung: Bei >70% CPU-Last → automatisch mehr Pods (bis 10)
```

---

## 🌐 Multi-Environment Setup (Später)

```
manifest/
├── k8s/
│   ├── base/                  # Gemeinsame Ressourcen
│   │   ├── deployment.yaml
│   │   ├── service.yaml
│   │   └── kustomization.yaml
│   │
│   ├── overlays/
│   │   ├── development/       # Dev-spezifisch
│   │   │   ├── replicas: 2
│   │   │   ├── ingress: localhost
│   │   │   └── kustomization.yaml
│   │   │
│   │   ├── staging/           # Staging-spezifisch
│   │   │   ├── replicas: 3
│   │   │   ├── ingress: staging.example.com
│   │   │   └── kustomization.yaml
│   │   │
│   │   └── production/        # Prod-spezifisch
│   │       ├── replicas: 5
│   │       ├── ingress: api.example.com
│   │       ├── resources: erhöht
│   │       └── kustomization.yaml
│   │
│   └── argocd/
│       ├── app-dev.yaml
│       ├── app-staging.yaml
│       └── app-prod.yaml
```

---

**Nächste Schritte:**
- **Quick Start:** `QUICK-START-GUIDE.md`
- **Vollständige Anleitung:** `DEPLOYMENT-BLUEPRINT.md`
- **YAML-Erklärungen:** `YAML-EXAMPLES.md`
