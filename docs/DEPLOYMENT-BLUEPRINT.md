# 🚀 Kubernetes Deployment Blueprint für Anfänger
## Student API - Vollständige Deployment-Anleitung

---

## 📚 Inhaltsverzeichnis

1. [Projekt-Übersicht](#projekt-übersicht)
2. [Ordnerstruktur](#ordnerstruktur)
3. [Wichtige Begriffe einfach erklärt](#wichtige-begriffe)
4. [Schritt-für-Schritt Deployment](#schritt-für-schritt-deployment)
5. [Harbor Registry Setup](#harbor-registry-setup)
6. [ArgoCD Setup](#argocd-setup)
7. [Troubleshooting](#troubleshooting)

---

## 📦 Projekt-Übersicht

**Was ist das?**  
Eine Student-API (ASP.NET Core) mit Postgres-Datenbank, die in Kubernetes läuft.

**Was macht die App?**
- Verwaltet Studenten-Datensätze (Erstellen, Lesen, Löschen)
- Bietet eine REST API auf Port 8080
- Hat eine Swagger-UI zum Testen: `http://localhost/swagger`

**Was brauchst du?**
- Docker Desktop mit Kubernetes aktiviert
- Harbor Registry (läuft auf `localhost:30002`)
- ArgoCD installiert im Cluster
- Git Repository (dein aktuelles Projekt)

---

## 📁 Ordnerstruktur

```
manifest/
├── StudentApi/                    # Deine .NET Anwendung
│   ├── Dockerfile                # Bauplan für das Docker-Image
│   ├── Program.cs                # Hauptcode der App
│   └── ...
│
├── k8s/                          # Alle Kubernetes-Dateien
│   ├── Student-api/              # Deine API-Konfiguration
│   │   ├── Namespace.yaml        # Erstellt den "Arbeitsbereich" in Kubernetes
│   │   ├── ConfigMap.yaml        # Nicht-geheime Einstellungen (DB-Host, DB-Name)
│   │   ├── Deployment.yaml       # Wie deine App läuft (2 Kopien, Ressourcen, etc.)
│   │   └── Ingress.yaml          # Macht die App von außen erreichbar (localhost)
│   │
│   └── postgres/                 # Datenbank-Konfiguration
│       ├── persistent-volumes.yaml    # Speicher für Datenbank (bleibt bei Löschen!)
│       ├── StatefulSet.yaml           # Postgres-Container
│       ├── Service.yaml               # Netzwerk-Zugang zur Datenbank
│       ├── backup-continuous.yaml     # Automatische Backups alle 30 Min
│       ├── BACKUP-README.md           # Backup-Dokumentation
│       └── PVC-README.md              # Persistenz-Dokumentation
│
├── argocd/                       # ArgoCD-Konfiguration
│   └── application.yaml          # Sagt ArgoCD: "Deploy alles aus k8s/"
│
├── secrets/                      # Passwörter (NICHT committen!)
│   ├── db_password.txt
│   └── db_user.txt
│
├── pipeline.ps1                  # Script zum Image bauen & pushen
├── backup-now.ps1                # Manuelles Backup
├── backup-to-daemon.ps1          # Sofort-Backup
└── restore-backup.ps1            # Backup wiederherstellen
```

---

## 🎓 Wichtige Begriffe einfach erklärt

### **Kubernetes Basics**

| Begriff | Was ist das? | Beispiel aus deinem Projekt |
|---------|-------------|----------------------------|
| **Pod** | Ein Container, der läuft | `manifest-app-7f75894c77-99d6g` (deine App läuft drin) |
| **Namespace** | Ein "Ordner" in Kubernetes zur Trennung | `development` (alle deine Ressourcen sind darin) |
| **Deployment** | Sagt: "Starte 2 Kopien meiner App" | `k8s/Student-api/Deployment.yaml` (2 replicas) |
| **Service** | Eine feste Adresse, um Pods zu erreichen | `manifest-app-service` (zeigt auf deine App-Pods) |
| **Ingress** | Der "Türsteher" - macht Apps von außen erreichbar | `localhost` → zu deiner App |
| **PVC** | Speicher, der bleibt (wie eine externe Festplatte) | `postgres-data-postgres-0` (10GB für DB-Daten) |
| **ConfigMap** | Nicht-geheime Einstellungen | DB-Host: `postgres-service` |
| **Secret** | Geheime Daten (Passwörter) | DB-User: `app_user`, Passwort: `SuperSecure...` |

### **GitOps & Tools**

| Begriff | Was ist das? | Warum brauchst du es? |
|---------|-------------|----------------------|
| **GitOps** | Kubernetes liest Konfiguration aus Git | Du änderst Code → Git Push → Kubernetes deployt automatisch |
| **ArgoCD** | Ein Tool, das GitOps umsetzt | Überwacht dein Git-Repo und synchronisiert Kubernetes |
| **Harbor** | Private Docker Registry (wie Docker Hub, nur lokal) | Speichert deine selbst gebauten Docker-Images |
| **ImagePullSecret** | Passwort für Harbor | Damit Kubernetes dein Image herunterladen darf |

---

## 🎯 Schritt-für-Schritt Deployment

### **Phase 1: Vorbereitung** (einmalig)

#### Schritt 1: Prüfe ob alles läuft
```powershell
# Docker Desktop läuft?
docker version

# Kubernetes aktiv?
kubectl get nodes
# Sollte zeigen: docker-desktop   Ready

# Harbor läuft?
# Öffne Browser: http://localhost:30002
# Login: admin / Harbor12345
```

#### Schritt 2: Harbor - Projekt erstellen
1. Öffne: `http://localhost:30002`
2. Login: `admin` / `Harbor12345`
3. Klicke: **"New Project"**
4. Name: `studenten`
5. Access Level: **Public** (für einfaches Testing) oder **Private**
6. Klicke: **"OK"**

---

### **Phase 2: Image bauen & pushen**

#### Schritt 3: Bei Harbor anmelden
```powershell
# Terminal öffnen
docker login localhost:30002

# Eingeben:
# Username: admin
# Password: Harbor12345
```

**Was passiert?**  
Docker speichert deine Anmeldedaten, damit `docker push` funktioniert.

#### Schritt 4: Image bauen & hochladen
```powershell
# Zum Projektordner wechseln
cd C:\Users\hedin\source\repos\manifest\manifest\manifest

# Automatisches Build & Push
.\pipeline.ps1
```

**Was macht `pipeline.ps1`?**
1. Baut deine App als Docker-Image
2. Taggt es mit Zeitstempel (z.B. `v1-20260203-1154`)
3. Pusht zu Harbor: `localhost:30002/studenten/manifest-app:latest`

**Erfolgreich wenn du siehst:**
```
Done! Pushed localhost:30002/studenten/manifest-app:v1-XXXXXXXX-XXXX
```

#### Schritt 5: Prüfe in Harbor
1. Browser: `http://localhost:30002`
2. Gehe zu: **Projects** → `studenten`
3. Klicke: **Repositories**
4. Du solltest sehen: `manifest-app` mit Tag `latest`

---

### **Phase 3: Kubernetes Secrets erstellen**

#### Schritt 6: ImagePullSecret erstellen

**Was ist das?**  
Ein Passwort, damit Kubernetes dein Image von Harbor herunterladen darf.

```powershell
kubectl create secret docker-registry harbor-regcred \
  --docker-server=localhost:30002 \
  --docker-username=admin \
  --docker-password=Harbor12345 \
  --docker-email=admin@local \
  -n development
```

**Wenn Namespace noch nicht existiert:**
```powershell
kubectl create namespace development
```

**Prüfen:**
```powershell
kubectl get secret harbor-regcred -n development
# Sollte zeigen: harbor-regcred   kubernetes.io/dockerconfigjson
```

---

### **Phase 4: ArgoCD Setup**

#### Schritt 7: ArgoCD UI öffnen

```powershell
# Finde ArgoCD Passwort
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | 
  ForEach-Object { [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($_)) }

# Port-Forward zu ArgoCD
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

**Öffne Browser:**
- URL: `https://localhost:8080`
- Username: `admin`
- Password: (das aus dem Befehl oben)
- **Warnung ignorieren:** "Your connection is not private" → Fortfahren

#### Schritt 8: Application in ArgoCD erstellen

**Option A: Via UI (einfacher für Anfänger)**

1. Klicke oben links: **"+ NEW APP"**

2. **GENERAL**
   - Application Name: `manifest-app`
   - Project: `default`
   - Sync Policy: `Automatic` ✓
     - ✓ `PRUNE RESOURCES`
     - ✓ `SELF HEAL`

3. **SOURCE**
   - Repository URL: `https://github.com/Muhi94/manifest.git`
   - Revision: `cursor` (oder `HEAD` für main-Branch)
   - Path: `k8s`

4. **DESTINATION**
   - Cluster URL: `https://kubernetes.default.svc` (sollte schon drin sein)
   - Namespace: `development`

5. **SYNC POLICY** (erweitert)
   - Sync Options: ✓ `AUTO-CREATE NAMESPACE`

6. Klicke: **"CREATE"**

**Option B: Via Terminal (schneller)**

```powershell
kubectl apply -f argocd/application.yaml
```

#### Schritt 9: Warte auf Sync

In der ArgoCD UI siehst du jetzt:
- **Status:** `OutOfSync` → `Syncing` → `Synced`
- **Health:** `Progressing` → `Healthy`

**Dauer:** 1-3 Minuten

**Was passiert gerade?**
- ArgoCD liest dein Git-Repo
- Erstellt Namespace `development`
- Deployt Postgres (Datenbank)
- Deployt deine App (2 Pods)
- Startet Backup-Daemon
- Erstellt Ingress (localhost)

---

### **Phase 5: Prüfen ob alles läuft**

#### Schritt 10: Pods prüfen

```powershell
kubectl get pods -n development
```

**Sollte zeigen (alle READY 1/1):**
```
NAME                                      READY   STATUS
manifest-app-7f75894c77-xxxxx             1/1     Running
manifest-app-7f75894c77-yyyyy             1/1     Running
postgres-0                                1/1     Running
postgres-backup-daemon-569446944d-zzzzz   1/1     Running
```

**Falls STATUS nicht `Running`:**
```powershell
# Zeige Details
kubectl describe pod <POD-NAME> -n development

# Zeige Logs
kubectl logs <POD-NAME> -n development
```

#### Schritt 11: Services prüfen

```powershell
kubectl get svc -n development
```

**Sollte zeigen:**
```
NAME                   TYPE        CLUSTER-IP      PORT(S)
manifest-app-service   ClusterIP   10.x.x.x        80
postgres-service       ClusterIP   10.x.x.x        5432
postgres-headless      ClusterIP   None            5432
```

#### Schritt 12: Ingress prüfen

```powershell
kubectl get ingress -n development
```

**Sollte zeigen:**
```
NAME                   CLASS   HOSTS       ADDRESS     PORTS
manifest-app-ingress   nginx   localhost   localhost   80
```

---

### **Phase 6: App testen**

#### Schritt 13: Swagger UI öffnen

**Browser öffnen:**
```
http://localhost/swagger
```

**Du solltest sehen:**
- Swagger UI mit `/api/Student` Endpoints
- GET, POST, DELETE Operationen

#### Schritt 14: Ersten Student anlegen

**In Swagger UI:**

1. Klicke auf: **POST `/api/student`**
2. Klicke: **"Try it out"**
3. Ändere JSON:
   ```json
   {
     "name": "Max Mustermann",
     "age": 25
   }
   ```
4. Klicke: **"Execute"**
5. **Response:** `201 Created` ✓

#### Schritt 15: Studenten abrufen

1. Klicke auf: **GET `/api/student`**
2. Klicke: **"Try it out"**
3. Klicke: **"Execute"**
4. **Response:**
   ```json
   [
     {
       "id": 1,
       "name": "Max Mustermann",
       "age": 25
     }
   ]
   ```

**🎉 Gratulation! Deine App läuft!**

---

## 🔐 Harbor Registry Setup (Detailliert)

### **Was ist Harbor?**
Ein privater Ort zum Speichern deiner Docker-Images (wie eine private Cloud für Container).

### **Warum brauchst du das?**
- Docker Hub hat Rate Limits (max. 100 Pulls/6h)
- Firmen-Images sollten nicht öffentlich sein
- Du hast volle Kontrolle

### **ImagePullSecret erstellen**

**Was ist das?**  
Ein Passwort-Tresor, den Kubernetes nutzt, um dein Image von Harbor herunterzuladen.

**Befehl:**
```powershell
kubectl create secret docker-registry harbor-regcred \
  --docker-server=localhost:30002 \
  --docker-username=admin \
  --docker-password=Harbor12345 \
  --docker-email=admin@local \
  --namespace=development
```

**Parameter erklärt:**
- `docker-registry`: Typ des Secrets (für Docker Registries)
- `harbor-regcred`: Name des Secrets (frei wählbar, muss in Deployment.yaml passen)
- `--docker-server`: Adresse deiner Harbor-Instanz
- `--docker-username`: Dein Harbor-Login
- `--docker-password`: Dein Harbor-Passwort
- `--docker-email`: Beliebig (wird nicht geprüft)
- `--namespace`: In welchem Namespace das Secret erstellt wird

**Prüfen ob es geklappt hat:**
```powershell
kubectl get secret harbor-regcred -n development -o yaml
```

**Sollte zeigen:**
```yaml
type: kubernetes.io/dockerconfigjson
data:
  .dockerconfigjson: eyJ... (verschlüsselt)
```

---

## 🔄 ArgoCD Integration (Klick-für-Klick)

### **Was ist ArgoCD?**
Ein Tool, das dein Git-Repository überwacht. Wenn du Code änderst und pushst, deployt ArgoCD automatisch die neuen Versionen in Kubernetes.

### **Wie funktioniert das?**
1. Du änderst eine Datei in `k8s/` (z.B. `Deployment.yaml`)
2. `git add` → `git commit` → `git push`
3. ArgoCD sieht die Änderung (alle 3 Minuten)
4. ArgoCD wendet die neue Konfiguration an
5. Kubernetes startet neue Pods mit der neuen Version

### **Application anlegen (UI-Anleitung)**

#### 1. ArgoCD UI öffnen

```powershell
# Falls noch nicht geöffnet:
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

Browser: `https://localhost:8080`  
Login: `admin` / (Passwort von oben)

#### 2. Neue Application erstellen

**Oben links:** Klicke **"+ NEW APP"**

#### 3. Formular ausfüllen

**GENERAL Section:**
```
Application Name: manifest-app
Project Name:     default (aus Dropdown)
Sync Policy:      Automatic (Toggle aktivieren)
```

**Wenn Automatic aktiviert:**
- ✓ Haken bei: `PRUNE RESOURCES`  
  *(Bedeutet: Lösche Ressourcen, die nicht mehr im Git sind)*
- ✓ Haken bei: `SELF HEAL`  
  *(Bedeutet: Repariere automatisch, wenn jemand manuell was ändert)*

**SOURCE Section:**
```
Repository URL:    https://github.com/Muhi94/manifest.git
Revision:          cursor        (dein Branch-Name)
Path:              k8s           (Ordner mit allen YAML-Dateien)
```

**DESTINATION Section:**
```
Cluster URL:       https://kubernetes.default.svc   (aus Dropdown)
Namespace:         development
```

**SYNC OPTIONS (erweitern):**
- ✓ Haken bei: `AUTO-CREATE NAMESPACE`

#### 4. Erstellen

**Unten:** Klicke **"CREATE"**

#### 5. Synchronisation starten

**Falls App nicht automatisch synct:**
- Klicke auf die App-Karte
- Oben: Klicke **"SYNC"**
- Im Dialog: Klicke **"SYNCHRONIZE"**

---

## 📝 Workflow - Vom Code bis zum Browser

### **Komplette Checkliste**

```
□ Schritt 1:  Harbor öffnen (localhost:30002) → Projekt "studenten" existiert?
□ Schritt 2:  docker login localhost:30002 (admin / Harbor12345)
□ Schritt 3:  .\pipeline.ps1 (baut & pusht Image)
□ Schritt 4:  kubectl create namespace development (falls nicht existiert)
□ Schritt 5:  kubectl create secret docker-registry harbor-regcred ... (siehe oben)
□ Schritt 6:  kubectl get secret harbor-regcred -n development (prüfen)
□ Schritt 7:  ArgoCD UI öffnen (localhost:8080)
□ Schritt 8:  Application erstellen (Formular ausfüllen, siehe oben)
□ Schritt 9:  Warten auf SYNC (1-3 Min)
□ Schritt 10: kubectl get pods -n development (alle Running?)
□ Schritt 11: Browser: http://localhost/swagger
□ Schritt 12: POST /api/student → Student anlegen
□ Schritt 13: GET /api/student → Student sehen
□ Schritt 14: 🎉 Fertig!
```

---

## 🔄 Änderungen deployen (Daily Workflow)

### **Szenario: Du änderst Code in der App**

```powershell
# 1. Code ändern (z.B. StudentController.cs)
# ... deine Änderungen ...

# 2. Image neu bauen
.\pipeline.ps1

# 3. Pods neu starten (damit sie das neue Image ziehen)
kubectl rollout restart deployment/manifest-app -n development

# 4. Warten
kubectl rollout status deployment/manifest-app -n development

# 5. Testen
# Browser: http://localhost/swagger
```

### **Szenario: Du änderst Kubernetes-Config**

```powershell
# 1. YAML ändern (z.B. k8s/Student-api/Deployment.yaml)
# ... deine Änderungen ...

# 2. Git Commit & Push
git add .
git commit -m "Update deployment replicas to 3"
git push origin cursor

# 3. Warten (ArgoCD synct automatisch in 3 Min)
# ODER: In ArgoCD UI auf "SYNC" klicken

# 4. Prüfen
kubectl get pods -n development
```

---

## 🛠️ Troubleshooting

### **Problem: Pods starten nicht (ImagePullBackOff)**

**Symptom:**
```
manifest-app-xxx   0/1   ImagePullBackOff
```

**Ursache:** Kubernetes kann Image nicht von Harbor holen

**Lösung:**
```powershell
# 1. Prüfe ob harbor-regcred existiert
kubectl get secret harbor-regcred -n development

# Falls nicht:
kubectl create secret docker-registry harbor-regcred \
  --docker-server=localhost:30002 \
  --docker-username=admin \
  --docker-password=Harbor12345 \
  --docker-email=admin@local \
  -n development

# 2. Prüfe ob Image in Harbor existiert
# Browser: localhost:30002 → Projects → studenten → Repositories

# 3. Pod neu starten
kubectl delete pod -n development -l app=manifest-app
```

---

### **Problem: Pods CrashLoopBackOff**

**Symptom:**
```
manifest-app-xxx   0/1   CrashLoopBackOff
```

**Ursache:** App startet, aber stürzt sofort ab

**Lösung:**
```powershell
# Logs ansehen
kubectl logs -n development <POD-NAME>

# Häufige Ursachen:
# - Datenbank nicht erreichbar
# - Falsches Secret
# - Port schon belegt
```

---

### **Problem: Datenbank verbindet nicht**

**Symptom in Logs:**
```
Database not ready yet, retrying...
```

**Lösung:**
```powershell
# 1. Prüfe ob Postgres läuft
kubectl get pods -n development postgres-0
# Sollte: Running (1/1)

# 2. Prüfe Postgres-Logs
kubectl logs -n development postgres-0

# 3. Prüfe Secret
kubectl get secret db-credentials -n development -o yaml

# 4. Teste Verbindung manuell
kubectl run pg-test --rm -i --restart=Never -n development \
  --image=postgres:15-alpine \
  --env=PGPASSWORD=SuperSecurePassword123! \
  -- psql -h postgres-service -U app_user -d studentdb -c 'SELECT 1;'
```

---

### **Problem: localhost funktioniert nicht im Browser**

**Symptom:**
```
Diese Seite kann nicht aufgerufen werden
```

**Ursache:** Ingress Controller fehlt oder falsch konfiguriert

**Lösung:**
```powershell
# 1. Prüfe Ingress
kubectl get ingress -n development

# 2. Prüfe Ingress Controller
kubectl get pods -n ingress-nginx

# Falls nicht installiert:
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/cloud/deploy.yaml

# 3. Alternative: Port-Forward direkt zur App
kubectl port-forward svc/manifest-app-service -n development 5000:80

# Dann Browser: http://localhost:5000/swagger
```

---

### **Problem: ArgoCD zeigt "OutOfSync"**

**Ursache:** Git und Cluster stimmen nicht überein

**Lösung:**
```powershell
# In ArgoCD UI:
# 1. Klicke auf die App
# 2. Klicke "SYNC"
# 3. Klicke "SYNCHRONIZE"

# ODER im Terminal:
kubectl annotate application manifest-app -n argocd \
  argocd.argoproj.io/refresh=hard --overwrite
```

---

## 🔧 Nützliche Befehle

### **Status prüfen**

```powershell
# Alle Pods sehen
kubectl get pods -n development

# Alle Services sehen
kubectl get svc -n development

# Alles auf einmal
kubectl get all -n development

# ArgoCD Status
kubectl get application -n argocd
```

### **Logs ansehen**

```powershell
# Logs eines Pods
kubectl logs -n development <POD-NAME>

# Logs folgen (live)
kubectl logs -n development <POD-NAME> -f

# Logs aller Pods mit Label
kubectl logs -n development -l app=manifest-app --tail=50
```

### **In Container einsteigen (Debugging)**

```powershell
# Shell in Pod öffnen
kubectl exec -it -n development <POD-NAME> -- /bin/sh

# Befehle im Container:
# - ls /app                    (Dateien ansehen)
# - printenv                   (Umgebungsvariablen)
# - cat /etc/app-secrets/db_user   (Secret-Dateien)
# - exit                       (Container verlassen)
```

### **Aufräumen**

```powershell
# Nur Pods neu starten
kubectl rollout restart deployment/manifest-app -n development

# Application löschen (Daten bleiben!)
kubectl delete application manifest-app -n argocd

# Alles löschen (inkl. Daten!)
kubectl delete namespace development
```

---

## 🆘 Schnelle Hilfe

### **"Ich habe meine Daten verloren!"**

```powershell
# 1. Prüfe verfügbare Backups
.\restore-backup.ps1 -ListBackups

# 2. Restore das neueste
.\restore-backup.ps1 -BackupFile continuous-XXXXXX-XXXXXX.sql
```

### **"ArgoCD zeigt Fehler!"**

```powershell
# App-Details ansehen
kubectl get application manifest-app -n argocd -o yaml

# App löschen & neu erstellen
kubectl delete application manifest-app -n argocd
kubectl apply -f argocd/application.yaml
```

### **"Ich will neu anfangen!"**

```powershell
# 1. BACKUP MACHEN!
.\backup-now.ps1 -BackupName "before-reset" -Download

# 2. Alles löschen
kubectl delete namespace development
kubectl delete application manifest-app -n argocd

# 3. Neu deployen
kubectl apply -f argocd/application.yaml

# 4. ImagePullSecret neu erstellen
kubectl create namespace development
kubectl create secret docker-registry harbor-regcred \
  --docker-server=localhost:30002 \
  --docker-username=admin \
  --docker-password=Harbor12345 \
  --docker-email=admin@local \
  -n development

# 5. Warten & prüfen
kubectl get pods -n development -w
```

---

## 📚 Weiterführende Ressourcen

- **Kubernetes Basics:** https://kubernetes.io/de/docs/tutorials/
- **ArgoCD Docs:** https://argo-cd.readthedocs.io/
- **Harbor Docs:** https://goharbor.io/docs/
- **Swagger UI:** `http://localhost/swagger` (deine eigene!)

---

## ✅ Checkliste "Alles läuft"

Wenn du alle folgenden Punkte abhaken kannst, läuft alles perfekt:

```
□ Harbor erreichbar (localhost:30002)
□ Image in Harbor sichtbar (studenten/manifest-app:latest)
□ ArgoCD erreichbar (localhost:8080)
□ Application in ArgoCD: Status "Synced", Health "Healthy"
□ kubectl get pods -n development → alle Running (1/1)
□ kubectl get pvc -n development → 3 PVCs Bound
□ Swagger UI öffnet (localhost/swagger)
□ POST /api/student funktioniert
□ GET /api/student zeigt Daten
□ Backup-Daemon läuft (kubectl logs -n development -l app=postgres-backup)
```

**Wenn ALLES ✓ → Du bist ein Kubernetes-Profi! 🎓**

---

## 🚨 Wichtige Sicherheitshinweise

### **Für Production (später):**

1. ❌ **NIEMALS** `secrets/` Ordner committen!  
   → Steht schon in `.gitignore`, trotzdem aufpassen

2. ❌ **NIEMALS** Passwörter in YAML-Dateien hardcoden  
   → Nutze Secrets (machst du schon ✓)

3. ✅ **IMMER** vor großen Änderungen: `.\backup-now.ps1 -Download`

4. ✅ **Teste Restores** regelmäßig (1x/Monat):  
   → Backup ist nutzlos, wenn Restore nicht funktioniert!

5. ✅ **Überwache Backups:**  
   ```powershell
   # Letztes Backup-Datum prüfen
   $pod = kubectl get pods -n development -l app=postgres-backup -o jsonpath="{.items[0].metadata.name}"
   kubectl exec -n development $pod -- ls -lt /backups/ | head -n 2
   ```

---

**Viel Erfolg mit deinem Deployment! 🚀**

*Bei Fragen: Lies die README-Dateien in `k8s/postgres/` oder schau in die ArgoCD UI.*
