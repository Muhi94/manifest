# 🎓 Student API - Kubernetes Deployment Guide für Einsteiger

> **Von 0 auf Production-Ready in 15 Minuten**  
> Ein vollständiger Blueprint für absolute Kubernetes-Anfänger

---

## 👋 Willkommen!

Du hast gerade deine erste ASP.NET Core API gebaut und möchtest sie in Kubernetes deployen?  
**Perfekt!** Diese Anleitung führt dich Schritt für Schritt durch den gesamten Prozess.

### Was du hier findest:
✅ **Einfache Erklärungen** (kein Fachchinesisch)  
✅ **Klick-für-Klick Anleitungen** (für Harbor & ArgoCD)  
✅ **Kommentierte YAML-Dateien** (jede Zeile erklärt)  
✅ **Troubleshooting-Guide** (für häufige Fehler)  
✅ **Automatische Backups** (Datenverlust vermeiden)

---

## 🗂️ Dokumentation (Wo anfangen?)

### 🚀 **Neu hier? START HIER:**

#### 1️⃣ [QUICK-START-GUIDE.md](./QUICK-START-GUIDE.md)
**Dauer:** 15 Minuten  
**Inhalt:**
- ✅ Voraussetzungen prüfen
- ✅ Schritt-für-Schritt Deployment (10 Schritte)
- ✅ Harbor Setup (mit Screenshots-Beschreibung)
- ✅ ArgoCD Setup (Klick-für-Klick)
- ✅ Erste Student anlegen & testen

**👉 Perfekt für:** "Ich will einfach, dass es funktioniert!"

---

### 📚 **Tieferes Verständnis?**

#### 2️⃣ [DEPLOYMENT-BLUEPRINT.md](./DEPLOYMENT-BLUEPRINT.md)
**Dauer:** 30-45 Minuten Lesen  
**Inhalt:**
- 📦 Projekt-Übersicht
- 📁 Ordnerstruktur erklärt
- 🎓 Wichtige Begriffe (Pod, Service, Ingress, etc.)
- 🎯 Ausführlicher Workflow (mit Erklärungen)
- 🔐 Harbor & ImagePullSecret detailliert
- 🔄 ArgoCD Integration & GitOps
- 🛠️ Troubleshooting (alle Fehler-Szenarien)
- 📝 Daily Workflow (Code-Änderungen deployen)

**👉 Perfekt für:** "Ich will verstehen, was da passiert!"

---

#### 3️⃣ [YAML-EXAMPLES.md](./YAML-EXAMPLES.md)
**Dauer:** 1 Stunde (Referenz-Dokument)  
**Inhalt:**
- 📝 Jede YAML-Datei vollständig kommentiert
- 🔍 Jede Zeile erklärt (was macht das?)
- 🎨 Visuelle Diagramme (wie hängt alles zusammen?)
- 💡 Quick Reference (häufige Patterns)
- 📖 Namespace, ConfigMap, Secret, Deployment, Service, Ingress, PVC

**👉 Perfekt für:** "Ich will YAML schreiben lernen!"

---

#### 4️⃣ [ARCHITECTURE.md](./ARCHITECTURE.md)
**Dauer:** 20 Minuten (optional)  
**Inhalt:**
- 🏗️ System-Architektur Diagramm
- 🔄 Datenfluss (Browser → Datenbank)
- 🔐 Security Layers
- 💾 Backup & Recovery Architektur
- 🏗️ Image Build Pipeline
- 🔄 GitOps Workflow (visuell)
- 📈 Skalierungs-Szenarien

**👉 Perfekt für:** "Ich will das große Bild sehen!"

---

## 📦 Was ist diese App?

### **Student API - REST Service für Studenten-Verwaltung**

**Funktionen:**
- ✅ Studenten anlegen (POST `/api/student`)
- ✅ Studenten auflisten (GET `/api/student`)
- ✅ Studenten löschen (DELETE `/api/student/{id}`)
- ✅ Swagger UI (interaktive Dokumentation)

**Tech Stack:**
- **Backend:** ASP.NET Core 8.0 (C#)
- **Datenbank:** PostgreSQL 15
- **ORM:** Entity Framework Core
- **API-Doc:** Swagger/OpenAPI
- **Container:** Docker
- **Orchestrierung:** Kubernetes
- **GitOps:** ArgoCD
- **Registry:** Harbor

**Erreichbar unter:**
```
http://localhost/swagger       (Swagger UI)
http://localhost/api/student   (API Endpoint)
```

---

## 🎯 Lernziele

Nach diesem Guide kannst du:

✅ **Docker Images bauen** und zu Harbor pushen  
✅ **Kubernetes Manifeste** verstehen und schreiben  
✅ **Secrets & ConfigMaps** korrekt nutzen  
✅ **Services & Ingress** konfigurieren  
✅ **ArgoCD** für GitOps einsetzen  
✅ **Persistenten Speicher** (PVCs) verwalten  
✅ **Backups** erstellen und wiederherstellen  
✅ **Fehler debuggen** (Logs, Events, Describe)  
✅ **Deployments aktualisieren** (Rolling Updates)  
✅ **Zero-Downtime Deployments** erreichen

---

## 🛠️ Voraussetzungen (5 Min Setup)

### ✅ **Must-Have (lokal installiert):**

| Tool | Version | Zweck | Installation |
|------|---------|-------|--------------|
| **Docker Desktop** | 4.25+ | Container-Runtime + Kubernetes | [Download](https://www.docker.com/products/docker-desktop/) |
| **Kubernetes** | 1.28+ | Orchestrierung (in Docker Desktop aktivieren) | Settings → Kubernetes → ✓ Enable |
| **kubectl** | 1.28+ | Kubernetes CLI (kommt mit Docker Desktop) | `kubectl version` |
| **Harbor** | 2.9+ | Private Registry | Läuft auf `localhost:30002` |
| **ArgoCD** | 2.9+ | GitOps Tool | Installation siehe unten |

### ✅ **Optional (aber empfohlen):**

| Tool | Zweck | Installation |
|------|-------|--------------|
| **Git** | Version Control | [Download](https://git-scm.com/downloads) |
| **PowerShell 7+** | Moderne Shell | [Download](https://github.com/PowerShell/PowerShell) |
| **VS Code** | Editor | [Download](https://code.visualstudio.com/) |
| **Postman** | API-Testing (Alternative zu Swagger) | [Download](https://www.postman.com/) |

---

### 🔧 **Schnell-Check:**

```powershell
# Alle Tools installiert?
docker version          # Sollte Client + Server zeigen
kubectl version --client # Sollte Version zeigen
kubectl get nodes       # Sollte: docker-desktop   Ready

# Harbor läuft?
# Browser: http://localhost:30002 (Login-Seite sichtbar?)

# ArgoCD installiert?
kubectl get pods -n argocd  # Sollte mehrere Pods zeigen
```

**Alle ✅?** → Weiter zum Quick-Start!  
**Fehler?** → Siehe [Voraussetzungen-Setup](#voraussetzungen-setup) unten

---

## 🚀 Schnellstart (15 Min)

### **Option A: Ich will sofort starten!**

```powershell
# 1. Repo klonen (falls noch nicht)
cd C:\Users\hedin\source\repos\manifest\manifest\manifest

# 2. Image bauen & pushen
.\pipeline.ps1

# 3. Namespace & Secret erstellen
kubectl create namespace development

kubectl create secret docker-registry harbor-regcred `
  --docker-server=localhost:30002 `
  --docker-username=admin `
  --docker-password=Harbor12345 `
  --docker-email=admin@local `
  --namespace=development

# 4. ArgoCD Application deployen
kubectl apply -f argocd/application.yaml

# 5. Warten (2-3 Min)
kubectl get pods -n development -w

# 6. Browser öffnen
Start http://localhost/swagger
```

**Funktioniert nicht?** → Siehe [QUICK-START-GUIDE.md](./QUICK-START-GUIDE.md) für detaillierte Schritte

---

### **Option B: Ich will verstehen, was passiert!**

📖 **Lies erst:** [DEPLOYMENT-BLUEPRINT.md](./DEPLOYMENT-BLUEPRINT.md)  
Dann folge den Schritten dort.

---

## 📁 Projekt-Struktur (Überblick)

```
manifest/
│
├── 📚 DOKUMENTATION (NEU!)
│   ├── GETTING-STARTED.md         ← DU BIST HIER
│   ├── QUICK-START-GUIDE.md       ← 15-Min Schnellstart
│   ├── DEPLOYMENT-BLUEPRINT.md    ← Vollständiger Guide
│   ├── YAML-EXAMPLES.md           ← Alle YAMLs erklärt
│   └── ARCHITECTURE.md            ← Architektur-Diagramme
│
├── 🛠️ APP-CODE
│   ├── StudentApi/                ← ASP.NET Core App
│   │   ├── Controllers/
│   │   ├── Models/
│   │   ├── Data/
│   │   ├── Dockerfile             ← Image-Bauplan
│   │   └── Program.cs
│   └── docker-compose.yml         ← Lokale Entwicklung
│
├── ☸️ KUBERNETES
│   ├── k8s/                       ← Alle Kubernetes-Manifeste
│   │   ├── Student-api/
│   │   │   ├── Namespace.yaml     ← Erstellt "development" Namespace
│   │   │   ├── ConfigMap.yaml     ← Nicht-geheime Einstellungen
│   │   │   ├── Deployment.yaml    ← Hauptdatei (App + Pods)
│   │   │   └── Ingress.yaml       ← HTTP-Routing (localhost)
│   │   │
│   │   └── postgres/
│   │       ├── persistent-volumes.yaml  ← Speicher (bleibt bei Löschen!)
│   │       ├── StatefulSet.yaml         ← Postgres-Container
│   │       ├── Service.yaml             ← Netzwerk-Zugang
│   │       ├── backup-continuous.yaml   ← Auto-Backups (alle 30 Min)
│   │       ├── BACKUP-README.md         ← Backup-Dokumentation
│   │       └── PVC-README.md            ← Persistenz-Dokumentation
│   │
│   └── argocd/
│       └── application.yaml       ← ArgoCD-Konfiguration
│
├── 🔐 SECRETS (LOKAL, NICHT COMMITTEN!)
│   └── secrets/
│       ├── db_password.txt        ← Datenbank-Passwort
│       └── db_user.txt            ← Datenbank-User
│
└── 🤖 AUTOMATION
    ├── pipeline.ps1               ← Build & Push zu Harbor
    ├── backup-now.ps1             ← Manuelles Backup
    ├── backup-to-daemon.ps1       ← Sofort-Backup (persistent)
    └── restore-backup.ps1         ← Backup wiederherstellen
```

---

## 🎓 Wichtige Begriffe (Einfach erklärt)

### **Kubernetes Basics**

| Begriff | Was ist das? | Analogie |
|---------|-------------|----------|
| **Pod** | Ein laufender Container | Wie ein Prozess auf deinem PC |
| **Deployment** | Verwaltet mehrere Pods | Wie ein Task-Manager für Pods |
| **Service** | Feste Adresse für Pods | Wie eine Domain (immer gleiche Adresse) |
| **Ingress** | HTTP-Router von außen | Wie ein Reverse-Proxy (nginx) |
| **Namespace** | Ordner in Kubernetes | Wie ein Projekt in Visual Studio |
| **ConfigMap** | Nicht-geheime Einstellungen | Wie appsettings.json |
| **Secret** | Geheime Daten | Wie Azure Key Vault |
| **PVC** | Persistenter Speicher | Wie eine externe Festplatte |

### **GitOps & Tools**

| Begriff | Was ist das? | Warum wichtig? |
|---------|-------------|----------------|
| **GitOps** | Git als Single Source of Truth | Alles versioniert & nachvollziehbar |
| **ArgoCD** | Automatisches Deployment aus Git | Du pushst Code → ArgoCD deployt |
| **Harbor** | Private Docker Registry | Deine Images sicher speichern |
| **kubectl** | Kubernetes CLI | Wie `docker` für Kubernetes |

---

## 🔄 Typischer Workflow (Daily)

### **Szenario 1: Code geändert**

```powershell
# 1. Code ändern (z.B. StudentController.cs)
# ... deine Änderungen ...

# 2. Image neu bauen & pushen
.\pipeline.ps1

# 3. Pods neu starten
kubectl rollout restart deployment/manifest-app -n development

# 4. Warten (~30 Sek)
kubectl rollout status deployment/manifest-app -n development

# 5. Testen
Start http://localhost/swagger
```

**Ergebnis:** Zero-Downtime Update! (Alte Pods bleiben, bis neue laufen)

---

### **Szenario 2: Kubernetes-Config geändert**

```powershell
# 1. YAML ändern (z.B. k8s/Student-api/Deployment.yaml)
# ... z.B. replicas: 3 statt 2 ...

# 2. Git Commit & Push
git add .
git commit -m "Scale to 3 replicas"
git push origin cursor

# 3. Warten (~3 Min)
# ArgoCD synct automatisch!

# 4. Prüfen
kubectl get pods -n development
# Sollte jetzt 3x manifest-app zeigen
```

**Ergebnis:** GitOps in Action! Kein manuelles `kubectl apply` nötig.

---

## 🆘 Hilfe & Troubleshooting

### **Häufige Fehler:**

| Fehler | Ursache | Lösung |
|--------|---------|--------|
| `ImagePullBackOff` | Harbor-Credentials fehlen | [Quick-Start Schritt 5](./QUICK-START-GUIDE.md#schritt-5️⃣-imagepullsecret-erstellen-30-sek) |
| `CrashLoopBackOff` | App startet nicht | `kubectl logs <POD-NAME> -n development` |
| `OutOfSync` in ArgoCD | Git ≠ Cluster | ArgoCD UI → SYNC |
| `localhost` funktioniert nicht | Ingress fehlt | [Troubleshooting Problem 4](./QUICK-START-GUIDE.md#-problem-4-localhost-funktioniert-nicht) |

### **Nützliche Befehle:**

```powershell
# Status prüfen
kubectl get all -n development

# Logs ansehen
kubectl logs -n development <POD-NAME>

# Fehler debuggen
kubectl describe pod <POD-NAME> -n development

# Events live sehen
kubectl get events -n development -w

# In Container einsteigen
kubectl exec -it <POD-NAME> -n development -- /bin/sh
```

### **Vollständiges Troubleshooting:**
📖 [QUICK-START-GUIDE.md - Troubleshooting](./QUICK-START-GUIDE.md#🛠️-troubleshooting)

---

## 💾 Backups (Datenverlust vermeiden)

### **Automatische Backups:**

✅ **Backup-Daemon läuft** (alle 30 Minuten)  
✅ **Letzte 10 Backups** werden behalten  
✅ **Backups bleiben** auch bei App-Löschung

```powershell
# Verfügbare Backups ansehen
.\restore-backup.ps1 -ListBackups

# Backup wiederherstellen
.\restore-backup.ps1 -BackupFile continuous-20260203-1200.sql
```

### **Manuelles Backup:**

```powershell
# Sofort-Backup erstellen
.\backup-now.ps1 -BackupName "vor-großer-änderung" -Download

# Backup zum Daemon hochladen
.\backup-to-daemon.ps1 -BackupName "manual-backup"
```

**Mehr Details:** [k8s/postgres/BACKUP-README.md](./k8s/postgres/BACKUP-README.md)

---

## 🔐 Sicherheit (Production Checklist)

### ⚠️ **Für Production wichtig:**

```
❌ NIEMALS secrets/ committen (steht in .gitignore)
❌ NIEMALS Passwörter in YAML hardcoden
❌ NIEMALS admin/Harbor12345 in Production nutzen
❌ NIEMALS runAsUser: 0 ohne Grund
❌ NIEMALS imagePullPolicy: Always in Production (besser: Tag mit Version)

✅ IMMER vor Updates: Backup erstellen
✅ IMMER Resource Limits setzen
✅ IMMER Health Checks konfigurieren
✅ IMMER HTTPS nutzen (TLS-Zertifikat)
✅ IMMER RBAC aktivieren
```

**Mehr Details:** [ARCHITECTURE.md - Security Layers](./ARCHITECTURE.md#🔒-security-layers)

---

## 📚 Weiterführende Ressourcen

### **Offizielle Dokumentation:**

- **Kubernetes:** https://kubernetes.io/docs/
- **ArgoCD:** https://argo-cd.readthedocs.io/
- **Harbor:** https://goharbor.io/docs/
- **ASP.NET Core:** https://docs.microsoft.com/aspnet/core/

### **Tutorials:**

- **Kubernetes Basics:** https://kubernetes.io/docs/tutorials/kubernetes-basics/
- **GitOps mit ArgoCD:** https://argo-cd.readthedocs.io/en/stable/getting_started/
- **Docker Best Practices:** https://docs.docker.com/develop/dev-best-practices/

### **Tools:**

- **kubectl Cheat Sheet:** https://kubernetes.io/docs/reference/kubectl/cheatsheet/
- **YAML Validator:** https://www.yamllint.com/
- **JSON zu YAML:** https://www.json2yaml.com/

---

## 🎯 Nächste Schritte

### **Level 1: Anfänger (Du bist hier!)**
```
✅ App deployen mit Quick-Start
✅ Grundbegriffe verstehen
✅ Swagger UI nutzen
✅ Backup/Restore testen
```

### **Level 2: Fortgeschritten**
```
□ YAML selbst schreiben/ändern
□ Horizontal Scaling (mehr Replicas)
□ Monitoring mit Prometheus
□ Multi-Environment Setup (dev/staging/prod)
□ CI/CD Pipeline bauen
```

### **Level 3: Profi**
```
□ Helm Charts erstellen
□ Custom Resource Definitions (CRDs)
□ Service Mesh (Istio/Linkerd)
□ GitOps mit Flux CD
□ Kubernetes Operators schreiben
```

---

## ✅ Bereit? Los geht's!

### **Dein nächster Schritt:**

👉 **[QUICK-START-GUIDE.md](./QUICK-START-GUIDE.md)** öffnen  
👉 **15 Minuten** Zeit nehmen  
👉 **Schritt für Schritt** folgen  
👉 **http://localhost/swagger** im Browser sehen  
👉 **Stolz sein!** 🎉

---

## 📞 Support & Feedback

### **Probleme?**

1. **Lies:** [QUICK-START-GUIDE - Troubleshooting](./QUICK-START-GUIDE.md#🛠️-troubleshooting)
2. **Prüfe:** Logs mit `kubectl logs <POD-NAME> -n development`
3. **Checke:** Events mit `kubectl get events -n development`
4. **Suche:** GitHub Issues im Projekt

### **Fragen?**

- **Kubernetes Slack:** https://kubernetes.slack.com/
- **ArgoCD Slack:** https://argoproj.github.io/community/join-slack/
- **Stack Overflow:** Tag `kubernetes`, `argocd`, `harbor`

---

**Viel Erfolg mit deinem Kubernetes-Journey! 🚀**

*"The journey of a thousand miles begins with a single step."*  
*— Lao Tzu*

**Dein erster Schritt:** [QUICK-START-GUIDE.md](./QUICK-START-GUIDE.md) 👈
