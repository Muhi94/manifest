# 🎓 Student API - Kubernetes Project

Eine vollständige Student-Verwaltungs-API mit ASP.NET Core, PostgreSQL und Kubernetes-Deployment.

## 🚀 Quick Start

**Neu hier? Start hier:**

👉 **[docs/GETTING-STARTED.md](./docs/GETTING-STARTED.md)**

**In 15 Minuten deployen:**

👉 **[docs/QUICK-START-GUIDE.md](./docs/QUICK-START-GUIDE.md)**

---

## 📚 Dokumentation

Alle Anleitungen findest du im **[docs/](./docs/)** Ordner:

| Dokument | Beschreibung | Dauer |
|----------|--------------|-------|
| **[GETTING-STARTED.md](./docs/GETTING-STARTED.md)** | Einstiegspunkt & Überblick | 10 Min |
| **[QUICK-START-GUIDE.md](./docs/QUICK-START-GUIDE.md)** | 15-Min Schnellstart | 15 Min |
| **[DEPLOYMENT-BLUEPRINT.md](./docs/DEPLOYMENT-BLUEPRINT.md)** | Vollständige Anleitung | 45 Min |
| **[YAML-EXAMPLES.md](./docs/YAML-EXAMPLES.md)** | Jede YAML-Zeile erklärt | 60 Min |
| **[ARCHITECTURE.md](./docs/ARCHITECTURE.md)** | Architektur & Diagramme | 20 Min |
| **[DOCUMENTATION-INDEX.md](./docs/DOCUMENTATION-INDEX.md)** | Dokumentations-Navigation | 5 Min |

---

## 📦 Was ist das?

Eine **Student-API** mit folgenden Features:

✅ Studenten anlegen (POST)  
✅ Studenten auflisten (GET)  
✅ Studenten löschen (DELETE)  
✅ Swagger UI  
✅ PostgreSQL Datenbank  
✅ Automatische Backups (alle 30 Min)  
✅ High Availability (2 Replicas)  
✅ Zero-Downtime Deployments  
✅ GitOps mit ArgoCD

---

## 🛠️ Tech Stack

- **Backend:** ASP.NET Core 8.0
- **Datenbank:** PostgreSQL 15
- **Container:** Docker
- **Orchestrierung:** Kubernetes
- **GitOps:** ArgoCD
- **Registry:** Harbor
- **Ingress:** NGINX

---

## 🎯 Erreichbar unter

Nach dem Deployment:

```
http://localhost/swagger       (Swagger UI)
http://localhost/api/student   (API Endpoint)
```

---

## 📁 Projekt-Struktur

```
manifest/
├── docs/                      # 📚 Komplette Dokumentation
│   ├── GETTING-STARTED.md
│   ├── QUICK-START-GUIDE.md
│   ├── DEPLOYMENT-BLUEPRINT.md
│   ├── YAML-EXAMPLES.md
│   ├── ARCHITECTURE.md
│   └── DOCUMENTATION-INDEX.md
│
├── StudentApi/                # 🛠️ ASP.NET Core App
│   ├── Controllers/
│   ├── Models/
│   ├── Data/
│   └── Dockerfile
│
├── k8s/                       # ☸️ Kubernetes Manifeste
│   ├── Student-api/
│   │   ├── Deployment.yaml
│   │   ├── Service.yaml
│   │   ├── Ingress.yaml
│   │   └── ConfigMap.yaml
│   └── postgres/
│       ├── StatefulSet.yaml
│       ├── persistent-volumes.yaml
│       └── backup-continuous.yaml
│
├── argocd/                    # 🔄 GitOps Config
│   └── application.yaml
│
├── secrets/                   # 🔐 Lokale Secrets (nicht committen!)
│   ├── db_password.txt
│   └── db_user.txt
│
└── *.ps1                      # 🤖 Automation Scripts
    ├── pipeline.ps1           # Build & Push
    ├── backup-now.ps1         # Manuelles Backup
    └── restore-backup.ps1     # Backup Restore
```

---

## 🚀 Schnellstart (Copy & Paste)

```powershell
# 1. Image bauen & pushen
.\pipeline.ps1

# 2. Namespace erstellen
kubectl create namespace development

# 3. ImagePullSecret erstellen
kubectl create secret docker-registry harbor-regcred `
  --docker-server=localhost:30002 `
  --docker-username=admin `
  --docker-password=Harbor12345 `
  --docker-email=admin@local `
  --namespace=development

# 4. ArgoCD Application deployen
kubectl apply -f argocd/application.yaml

# 5. Warten
kubectl get pods -n development -w

# 6. Browser öffnen
Start http://localhost/swagger
```

**Mehr Details:** [docs/QUICK-START-GUIDE.md](./docs/QUICK-START-GUIDE.md)

---

## 💾 Backups

Automatische Backups laufen alle 30 Minuten.

```powershell
# Verfügbare Backups ansehen
.\restore-backup.ps1 -ListBackups

# Backup wiederherstellen
.\restore-backup.ps1 -BackupFile continuous-20260203-1200.sql

# Manuelles Backup erstellen
.\backup-now.ps1 -Download
```

**Mehr Details:** [k8s/postgres/BACKUP-README.md](./k8s/postgres/BACKUP-README.md)

---

## 🛠️ Nützliche Befehle

```powershell
# Status prüfen
kubectl get all -n development

# Logs ansehen
kubectl logs -n development -l app=manifest-app

# Pod neu starten
kubectl rollout restart deployment/manifest-app -n development

# In Container einsteigen
kubectl exec -it <POD-NAME> -n development -- /bin/sh
```

---

## 🆘 Troubleshooting

| Problem | Lösung |
|---------|--------|
| `ImagePullBackOff` | [docs/QUICK-START-GUIDE.md - Problem 1](./docs/QUICK-START-GUIDE.md#-problem-1-imagepullbackoff) |
| `CrashLoopBackOff` | [docs/QUICK-START-GUIDE.md - Problem 2](./docs/QUICK-START-GUIDE.md#-problem-2-crashloopbackoff-postgres) |
| DB verbindet nicht | [docs/QUICK-START-GUIDE.md - Problem 3](./docs/QUICK-START-GUIDE.md#-problem-3-app-verbindet-nicht-zur-db) |
| `localhost` nicht erreichbar | [docs/QUICK-START-GUIDE.md - Problem 4](./docs/QUICK-START-GUIDE.md#-problem-4-localhost-funktioniert-nicht) |

**Vollständiges Troubleshooting:** [docs/QUICK-START-GUIDE.md](./docs/QUICK-START-GUIDE.md#🛠️-troubleshooting)

---

## 📚 Weiterführende Links

- **Kubernetes Docs:** https://kubernetes.io/docs/
- **ArgoCD Docs:** https://argo-cd.readthedocs.io/
- **Harbor Docs:** https://goharbor.io/docs/
- **ASP.NET Core:** https://docs.microsoft.com/aspnet/core/

---

## 🎓 Für Anfänger

Dieses Projekt ist **speziell für Kubernetes-Anfänger** konzipiert:

✅ Alle Begriffe werden erklärt  
✅ Jede YAML-Zeile ist kommentiert  
✅ Schritt-für-Schritt Anleitungen  
✅ Troubleshooting für häufige Fehler  
✅ Keine Vorkenntnisse nötig

**Start hier:** [docs/GETTING-STARTED.md](./docs/GETTING-STARTED.md)

---

## 📞 Support

Fragen? Probleme?

1. **Lies:** [docs/QUICK-START-GUIDE.md - Troubleshooting](./docs/QUICK-START-GUIDE.md#🛠️-troubleshooting)
2. **Prüfe:** `kubectl logs <POD-NAME> -n development`
3. **Checke:** `kubectl get events -n development`

---

**Los geht's!** 👉 [docs/GETTING-STARTED.md](./docs/GETTING-STARTED.md)

---

*Zuletzt aktualisiert: 2026-02-03*
