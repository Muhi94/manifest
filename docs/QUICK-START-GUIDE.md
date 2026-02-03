# ⚡ Quick Start Guide - Von 0 auf 100 in 15 Minuten

## 🎯 Ziel
Deine Student-API läuft und ist erreichbar unter `http://localhost/swagger`

---

## ✅ Voraussetzungen (5 Min)

### 1. Docker Desktop läuft?
```powershell
docker version
```
✅ Sollte Version-Infos zeigen (Client + Server)  
❌ Fehler? → Docker Desktop starten

### 2. Kubernetes aktiv?
```powershell
kubectl get nodes
```
✅ Sollte `docker-desktop   Ready` zeigen  
❌ Fehler? → Docker Desktop → Settings → Kubernetes → ✓ Enable Kubernetes

### 3. Harbor läuft?
**Browser öffnen:** `http://localhost:30002`  
✅ Login-Seite sichtbar  
❌ Fehler? → Harbor neu installieren

### 4. ArgoCD installiert?
```powershell
kubectl get pods -n argocd
```
✅ Zeigt mehrere Pods (alle Running)  
❌ Fehler? → ArgoCD installieren:
```powershell
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

---

## 🚀 Deployment in 10 Schritten

### **Schritt 1️⃣: Harbor-Projekt erstellen** (1 Min)

**Was:** Erstelle einen Ordner für deine Images in Harbor

**Wo:** Browser → `http://localhost:30002`

**Wie:**
1. Login:
   - Username: `admin`
   - Password: `Harbor12345`
2. Klicke: **"+ NEW PROJECT"**
3. Eingeben:
   - Project Name: `studenten`
   - Access Level: **Public** (oder Private mit Registrierung)
4. Klicke: **"OK"**

✅ **Erfolgreich wenn:** Du siehst "studenten" in der Projektliste

---

### **Schritt 2️⃣: Docker bei Harbor anmelden** (30 Sek)

**Was:** Docker authentifizieren, damit `push` funktioniert

**PowerShell öffnen:**
```powershell
docker login localhost:30002
```

**Eingeben:**
```
Username: admin
Password: Harbor12345
```

✅ **Erfolgreich wenn:** `Login Succeeded`

---

### **Schritt 3️⃣: Image bauen & pushen** (2 Min)

**Was:** Deine App als Docker-Image verpacken und zu Harbor hochladen

```powershell
# Zum Projektordner
cd C:\Users\hedin\source\repos\manifest\manifest\manifest

# Automatisches Build & Push
.\pipeline.ps1
```

**Was passiert im Hintergrund:**
```powershell
# 1. Image bauen
docker build -t localhost:30002/studenten/manifest-app:latest ./StudentApi

# 2. Mit Zeitstempel taggen
docker tag localhost:30002/studenten/manifest-app:latest \
  localhost:30002/studenten/manifest-app:v1-20260203-1154

# 3. Zu Harbor pushen
docker push localhost:30002/studenten/manifest-app:latest
docker push localhost:30002/studenten/manifest-app:v1-20260203-1154
```

✅ **Erfolgreich wenn:**  
`Done! Pushed localhost:30002/studenten/manifest-app:v1-...`

**Prüfen in Harbor:**
1. Browser: `http://localhost:30002`
2. Klicke: **Projects** → `studenten` → **Repositories**
3. Du solltest sehen: `manifest-app` mit Tag `latest`

---

### **Schritt 4️⃣: Kubernetes-Namespace erstellen** (10 Sek)

**Was:** Erstelle den "Ordner" in Kubernetes

```powershell
kubectl create namespace development
```

✅ **Erfolgreich wenn:** `namespace/development created`

**Oder falls schon existiert:**
```
Error from server (AlreadyExists): namespaces "development" already exists
```
→ Das ist OK! ✅

---

### **Schritt 5️⃣: ImagePullSecret erstellen** (30 Sek)

**Was:** Passwort für Kubernetes, damit es dein Image von Harbor holen kann

```powershell
kubectl create secret docker-registry harbor-regcred `
  --docker-server=localhost:30002 `
  --docker-username=admin `
  --docker-password=Harbor12345 `
  --docker-email=admin@local `
  --namespace=development
```

**Befehl erklärt:**
- `docker-registry`: Typ des Secrets (für Container-Registries)
- `harbor-regcred`: Name (muss in `Deployment.yaml` unter `imagePullSecrets` stehen!)
- `--docker-server`: Adresse deiner Harbor-Instanz
- `--docker-username`: Dein Harbor-Login
- `--docker-password`: Dein Harbor-Passwort
- `--namespace`: In welchem Namespace

✅ **Erfolgreich wenn:** `secret/harbor-regcred created`

**Prüfen:**
```powershell
kubectl get secret harbor-regcred -n development
```
Sollte zeigen: `harbor-regcred   kubernetes.io/dockerconfigjson   1      5s`

---

### **Schritt 6️⃣: ArgoCD UI öffnen** (1 Min)

**Was:** Zugriff auf ArgoCD Web-Interface

#### A) Passwort abrufen
```powershell
$secret = kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}"
[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($secret))
```

**Kopiere das Passwort!** (z.B. `xY3k9mP4qR7s`)

#### B) Port-Forward starten
```powershell
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

**Lass das Terminal offen!** (Port-Forward läuft bis du STRG+C drückst)

#### C) Browser öffnen
```
https://localhost:8080
```

**Warnung ignorieren:**  
"Your connection is not private" → **Erweitert** → **Fortfahren zu localhost**

**Login:**
- Username: `admin`
- Password: (das von oben)

✅ **Erfolgreich wenn:** Du siehst das ArgoCD Dashboard

---

### **Schritt 7️⃣: Application in ArgoCD erstellen** (2 Min)

**Was:** Sag ArgoCD, dass es dein Git-Repo überwachen soll

#### **Option A: Via UI (empfohlen für Anfänger)**

**Oben links:** Klicke **"+ NEW APP"**

**Formular ausfüllen:**

**📍 GENERAL**
```
Application Name:  manifest-app
Project Name:      default          [Dropdown]
Sync Policy:       [Toggle] Automatic
  ✓ PRUNE RESOURCES
  ✓ SELF HEAL
```

**📍 SOURCE**
```
Repository URL:    https://github.com/Muhi94/manifest.git
Revision:          cursor           (oder HEAD für main)
Path:              k8s
```

**📍 DESTINATION**
```
Cluster URL:       https://kubernetes.default.svc   [Dropdown]
Namespace:         development
```

**📍 SYNC OPTIONS (erweitern)**
```
✓ AUTO-CREATE NAMESPACE
✓ SERVER SIDE APPLY
```

**Unten:** Klicke **"CREATE"**

---

#### **Option B: Via Terminal (schneller)**

```powershell
kubectl apply -f argocd/application.yaml
```

✅ **Erfolgreich wenn:** `application.argoproj.io/manifest-app created`

---

### **Schritt 8️⃣: Synchronisation prüfen** (2 Min)

**In ArgoCD UI:**

Du siehst jetzt eine Karte: **manifest-app**

**Status-Entwicklung:**
```
1. OutOfSync → Syncing → Synced     ✅
2. Missing   → Progressing → Healthy ✅
```

**Dauer:** 1-3 Minuten

**Was passiert gerade?**
- Namespace `development` wird erstellt
- Postgres-Datenbank wird gestartet
- 2x App-Pods werden gestartet
- Backup-Daemon wird gestartet
- Ingress wird konfiguriert

**Live-Ansicht:**

Klicke auf die **manifest-app** Karte → Du siehst eine Grafik mit allen Ressourcen:
```
manifest-app (Application)
 ├─ Namespace: development
 ├─ ConfigMap: app-config
 ├─ Secret: db-credentials
 ├─ Deployment: manifest-app (2 Pods)
 ├─ Service: manifest-app-service
 ├─ Ingress: manifest-app-ingress
 ├─ StatefulSet: postgres (1 Pod)
 ├─ Service: postgres-service
 ├─ PVC: postgres-data-postgres-0
 ├─ Deployment: postgres-backup-daemon
 └─ PVC: postgres-backup-pvc
```

---

### **Schritt 9️⃣: Pods prüfen** (1 Min)

**Terminal öffnen:**
```powershell
kubectl get pods -n development
```

**Sollte zeigen (alle READY 1/1, STATUS Running):**
```
NAME                                      READY   STATUS    RESTARTS   AGE
manifest-app-7f75894c77-abc12             1/1     Running   0          2m
manifest-app-7f75894c77-def34             1/1     Running   0          2m
postgres-0                                1/1     Running   0          2m
postgres-backup-daemon-569446944d-ghi56   1/1     Running   0          2m
```

✅ **Alle Running?** → Weiter zu Schritt 10!

❌ **Fehler? (z.B. ImagePullBackOff, CrashLoopBackOff)**
```powershell
# Details ansehen
kubectl describe pod <POD-NAME> -n development

# Logs ansehen
kubectl logs <POD-NAME> -n development
```

**Häufige Fehler → Siehe Troubleshooting unten**

---

### **Schritt 🔟: App testen!** (2 Min)

#### 🌐 **Browser öffnen:**
```
http://localhost/swagger
```

✅ **Erfolgreich wenn:** Swagger UI wird geladen mit Endpunkten:
- `GET /api/student`
- `POST /api/student`
- `DELETE /api/student/{id}`

---

#### 📝 **Student anlegen (POST):**

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
5. Response Code: **201 Created** ✅

---

#### 📖 **Student abrufen (GET):**

1. Klicke auf: **GET `/api/student`**
2. Klicke: **"Try it out"**
3. Klicke: **"Execute"**
4. Response:
   ```json
   [
     {
       "id": 1,
       "name": "Max Mustermann",
       "age": 25
     }
   ]
   ```

---

## 🎉 **GRATULATION!**

Deine App läuft in Kubernetes! 🚀

---

## 📊 Status-Übersicht

### **Alles auf einen Blick:**
```powershell
kubectl get all -n development
```

**Sollte zeigen:**
```
NAME                                          READY   STATUS
pod/manifest-app-7f75894c77-xxxxx             1/1     Running
pod/manifest-app-7f75894c77-yyyyy             1/1     Running
pod/postgres-0                                1/1     Running
pod/postgres-backup-daemon-569446944d-zzzzz   1/1     Running

NAME                           TYPE        CLUSTER-IP      PORT(S)
service/manifest-app-service   ClusterIP   10.96.x.x       80/TCP
service/postgres-service       ClusterIP   10.96.x.x       5432/TCP
service/postgres-headless      ClusterIP   None            5432/TCP

NAME                                     READY   UP-TO-DATE   AVAILABLE
deployment.apps/manifest-app             2/2     2            2
deployment.apps/postgres-backup-daemon   1/1     1            1

NAME                                                DESIRED   CURRENT   READY
replicaset.apps/manifest-app-7f75894c77             2         2         2
replicaset.apps/postgres-backup-daemon-569446944d   1         1         1

NAME                        READY
statefulset.apps/postgres   1/1
```

---

## 🔄 Daily Workflow: Änderungen deployen

### **Szenario 1: Code geändert (App-Logik)**

```powershell
# 1. Code ändern in StudentApi/
# ... deine Änderungen ...

# 2. Neu bauen & pushen
.\pipeline.ps1

# 3. Pods neu starten
kubectl rollout restart deployment/manifest-app -n development

# 4. Warten
kubectl rollout status deployment/manifest-app -n development

# 5. Testen
http://localhost/swagger
```

---

### **Szenario 2: Kubernetes-Config geändert (z.B. Replicas)**

```yaml
# k8s/Student-api/Deployment.yaml
spec:
  replicas: 3  # War vorher 2
```

```powershell
# 1. Git Commit & Push
git add k8s/Student-api/Deployment.yaml
git commit -m "Scale to 3 replicas"
git push origin cursor

# 2. Warten (ArgoCD synct automatisch in ~3 Min)
# ODER: In ArgoCD UI auf "SYNC" klicken

# 3. Prüfen
kubectl get pods -n development
# Sollte jetzt 3x manifest-app Pods zeigen
```

---

## 🛠️ Troubleshooting

### ❌ **Problem 1: ImagePullBackOff**

**Symptom:**
```
manifest-app-xxx   0/1   ImagePullBackOff
```

**Ursache:** Kubernetes kann Image nicht von Harbor holen

**Lösung:**
```powershell
# 1. Prüfe Secret
kubectl get secret harbor-regcred -n development

# Falls nicht existiert:
kubectl create secret docker-registry harbor-regcred \
  --docker-server=localhost:30002 \
  --docker-username=admin \
  --docker-password=Harbor12345 \
  --docker-email=admin@local \
  -n development

# 2. Pod löschen (wird neu erstellt)
kubectl delete pod -n development -l app=manifest-app

# 3. Prüfen
kubectl get pods -n development -w
```

---

### ❌ **Problem 2: CrashLoopBackOff (Postgres)**

**Symptom:**
```
postgres-0   0/1   CrashLoopBackOff
```

**Ursache:** Postgres kann nicht auf Daten-Volume schreiben

**Lösung:**
```powershell
# Logs ansehen
kubectl logs postgres-0 -n development

# Häufig: Permission-Fehler
# → StatefulSet nutzt runAsUser: 0 (Root) für hostpath

# PVC neu erstellen
kubectl delete pvc postgres-data-postgres-0 -n development
kubectl delete pod postgres-0 -n development
```

---

### ❌ **Problem 3: App verbindet nicht zur DB**

**Symptom in Logs:**
```
Database not ready yet, retrying...
```

**Lösung:**
```powershell
# 1. Prüfe ob Postgres läuft
kubectl get pods -n development postgres-0

# 2. Teste Verbindung manuell
kubectl run pg-test --rm -i --restart=Never -n development \
  --image=postgres:15-alpine \
  --env=PGPASSWORD=SuperSecurePassword123! \
  -- psql -h postgres-service -U app_user -d studentdb -c 'SELECT 1;'

# Sollte zeigen:
#  ?column? 
# ----------
#         1

# 3. Falls Fehler: Secret prüfen
kubectl get secret db-credentials -n development -o yaml
```

---

### ❌ **Problem 4: localhost funktioniert nicht**

**Symptom:**
```
Diese Seite kann nicht aufgerufen werden
```

**Ursache:** Ingress Controller fehlt

**Lösung:**
```powershell
# 1. Prüfe Ingress
kubectl get ingress -n development

# 2. Prüfe Ingress Controller
kubectl get pods -n ingress-nginx

# Falls keine Pods:
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/cloud/deploy.yaml

# Warte bis Running:
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=120s

# Alternative: Port-Forward direkt zur App
kubectl port-forward svc/manifest-app-service -n development 5000:80
# Dann: http://localhost:5000/swagger
```

---

### ❌ **Problem 5: ArgoCD zeigt OutOfSync**

**Ursache:** Manuelle Änderung in Kubernetes oder Git nicht aktuell

**Lösung:**
```powershell
# In ArgoCD UI:
# 1. Klicke auf manifest-app
# 2. Klicke "SYNC"
# 3. Wähle "SYNCHRONIZE"

# ODER im Terminal:
kubectl patch app manifest-app -n argocd \
  --type merge \
  -p '{"metadata":{"annotations":{"argocd.argoproj.io/refresh":"hard"}}}'
```

---

## 🧹 Cleanup: Alles löschen

### **Option 1: Nur die App (Daten bleiben!)**
```powershell
# Application löschen
kubectl delete application manifest-app -n argocd

# PVCs bleiben bestehen (Daten safe!)
kubectl get pvc -n development
```

### **Option 2: Alles inkl. Daten**
```powershell
# ⚠️ WARNUNG: ALLE DATEN GEHEN VERLOREN!
# Erst Backup machen:
.\backup-now.ps1 -BackupName "before-delete" -Download

# Dann löschen:
kubectl delete namespace development
kubectl delete application manifest-app -n argocd
```

### **Option 3: Nur Pods neu starten (Daten bleiben)**
```powershell
# Nur App neu starten
kubectl rollout restart deployment/manifest-app -n development

# Alles neu starten
kubectl delete pod --all -n development
```

---

## 📚 Weiterführende Guides

- **Vollständige Dokumentation:** `DEPLOYMENT-BLUEPRINT.md`
- **YAML-Erklärungen:** `YAML-EXAMPLES.md`
- **Backup-System:** `k8s/postgres/BACKUP-README.md`
- **Persistenz:** `k8s/postgres/PVC-README.md`

---

## 🎯 Checkliste: Ist alles ready?

```
□ Harbor erreichbar (localhost:30002)
□ Image sichtbar in Harbor (studenten/manifest-app:latest)
□ Namespace existiert (kubectl get ns development)
□ Secret existiert (kubectl get secret harbor-regcred -n development)
□ ArgoCD UI erreichbar (localhost:8080)
□ Application in ArgoCD: Status "Synced", Health "Healthy"
□ Alle Pods Running (kubectl get pods -n development)
□ Swagger öffnet (localhost/swagger)
□ POST /api/student funktioniert
□ GET /api/student zeigt Daten
□ Backup-Daemon läuft (kubectl logs -n development -l app=postgres-backup)
```

**Alle ✓?** → **Du bist fertig! 🎉**

---

## 💡 Pro-Tipps

### **Tip 1: Watch-Mode für Live-Updates**
```powershell
# Pods live beobachten
kubectl get pods -n development -w

# Events live sehen
kubectl get events -n development -w

# Logs live folgen
kubectl logs -f -n development -l app=manifest-app
```

### **Tip 2: Schneller Port-Forward**
```powershell
# App direkt erreichen (ohne Ingress)
kubectl port-forward svc/manifest-app-service -n development 5000:80
# → http://localhost:5000/swagger

# Postgres direkt erreichen (z.B. mit pgAdmin)
kubectl port-forward svc/postgres-service -n development 5432:5432
# → Host: localhost, Port: 5432, User: app_user
```

### **Tip 3: Alias für häufige Befehle**
```powershell
# In PowerShell-Profil ($PROFILE) eintragen:
function k { kubectl $args }
function kgp { kubectl get pods -n development $args }
function kl { kubectl logs -n development $args }
function kd { kubectl describe -n development $args }

# Dann nutzbar:
k get pods -n development  # → kgp
k logs pod-name            # → kl pod-name
```

### **Tip 4: Backup vor jedem großen Update**
```powershell
# Automatisch mit Zeitstempel
.\backup-now.ps1 -Download

# Oder als Datum
.\backup-now.ps1 -BackupName "vor-update-$(Get-Date -Format 'yyyyMMdd')" -Download
```

---

**Viel Erfolg! 🚀**
