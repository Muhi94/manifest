# 📚 Dokumentations-Index - Welches Dokument wofür?

## 🎯 Schnellauswahl

| Ich möchte... | Dokument | Dauer | Schwierigkeit |
|---------------|----------|-------|---------------|
| **Sofort deployen** | [QUICK-START-GUIDE.md](./QUICK-START-GUIDE.md) | 15 Min | 🟢 Einfach |
| **Alles verstehen** | [DEPLOYMENT-BLUEPRINT.md](./DEPLOYMENT-BLUEPRINT.md) | 45 Min | 🟡 Mittel |
| **YAML lernen** | [YAML-EXAMPLES.md](./YAML-EXAMPLES.md) | 60 Min | 🟡 Mittel |
| **Architektur sehen** | [ARCHITECTURE.md](./ARCHITECTURE.md) | 20 Min | 🟢 Einfach |
| **Überblick bekommen** | [GETTING-STARTED.md](./GETTING-STARTED.md) | 10 Min | 🟢 Einfach |

---

## 📖 Dokument-Details

### 1. [GETTING-STARTED.md](./GETTING-STARTED.md) ⭐ **START HIER**

**Zweck:** Einstiegspunkt - Orientierung & Überblick

**Inhalt:**
- 👋 Willkommen & Einführung
- 📚 Dokumentations-Übersicht
- 📦 Projekt-Übersicht
- 🎓 Wichtige Begriffe
- 🔄 Typischer Workflow
- 🆘 Schnelle Hilfe
- 📚 Weiterführende Ressourcen

**Für wen?**
- ✅ Absolute Anfänger
- ✅ Erste Orientierung
- ✅ "Was ist das Projekt?"

**Empfohlene Reihenfolge:** **1. Zuerst**

---

### 2. [QUICK-START-GUIDE.md](./QUICK-START-GUIDE.md) 🚀

**Zweck:** 15-Minuten-Deployment ohne viel Theorie

**Inhalt:**
- ✅ Voraussetzungen-Check (5 Min)
- 🚀 10-Schritte-Deployment
- 🔐 Harbor Setup (Klick-für-Klick)
- 🔄 ArgoCD Setup (Klick-für-Klick)
- 🧪 App testen (Swagger)
- 🛠️ Troubleshooting (5 häufigste Fehler)
- 🔄 Daily Workflow
- 🧹 Cleanup
- 💡 Pro-Tipps

**Für wen?**
- ✅ "Ich will es einfach zum Laufen bringen!"
- ✅ Schnellstart ohne Theorie
- ✅ Copy & Paste Befehle

**Empfohlene Reihenfolge:** **2. Direkt nach Getting-Started**

---

### 3. [DEPLOYMENT-BLUEPRINT.md](./DEPLOYMENT-BLUEPRINT.md) 📘

**Zweck:** Vollständige Anleitung mit allen Erklärungen

**Inhalt:**
- 📦 Projekt-Übersicht (ausführlich)
- 📁 Ordnerstruktur (detailliert)
- 🎓 Begriffe einfach erklärt
- 🎯 Schritt-für-Schritt Deployment (mit Erklärungen)
- 🔐 Harbor Registry Setup (detailliert)
- 🔄 ArgoCD Integration (ausführlich)
- 📝 Workflow (vom Code bis zum Browser)
- 🛠️ Troubleshooting (alle Szenarien)
- 🔧 Nützliche Befehle
- 🆘 Schnelle Hilfe
- 🚨 Sicherheitshinweise

**Für wen?**
- ✅ "Ich will verstehen, was passiert!"
- ✅ Tieferes Wissen
- ✅ Referenz-Dokument

**Empfohlene Reihenfolge:** **3. Nach dem Quick-Start**

---

### 4. [YAML-EXAMPLES.md](./YAML-EXAMPLES.md) 📝

**Zweck:** Jede YAML-Zeile verstehen lernen

**Inhalt:**
- 📝 Namespace (vollständig kommentiert)
- 📝 ConfigMap (vollständig kommentiert)
- 📝 Secret (vollständig kommentiert)
- 📝 Deployment (vollständig kommentiert)
- 📝 Service (vollständig kommentiert)
- 📝 Ingress (vollständig kommentiert)
- 📝 PersistentVolumeClaim (vollständig kommentiert)
- 🔗 Wie hängt alles zusammen?
- 💡 Quick Reference (häufige Patterns)

**Für wen?**
- ✅ "Ich will YAML schreiben lernen!"
- ✅ Kubernetes-Manifeste verstehen
- ✅ Jede Zeile erklärt

**Empfohlene Reihenfolge:** **4. Parallel zum Blueprint**

---

### 5. [ARCHITECTURE.md](./ARCHITECTURE.md) 🏗️

**Zweck:** Das große Bild - Wie alles zusammenhängt

**Inhalt:**
- 📐 System-Architektur Diagramm
- 🔄 Datenfluss (HTTP-Request → DB)
- 🔐 Secrets & ConfigMaps Flow
- 🏗️ Image Build & Deployment Pipeline
- 🔄 GitOps Workflow (visuell)
- 💾 Backup & Recovery Architektur
- 🔒 Security Layers
- 📊 Monitoring & Observability
- 🔧 Technology Stack
- 📈 Skalierungs-Szenarien
- 🌐 Multi-Environment Setup

**Für wen?**
- ✅ "Ich will das große Bild sehen!"
- ✅ Visuelles Verständnis
- ✅ Architektur-Entscheidungen

**Empfohlene Reihenfolge:** **5. Optional (zum Vertiefen)**

---

## 🎯 Lernpfade

### **Lernpfad 1: Schnellstart (30 Min)**

```
1. GETTING-STARTED.md     (10 Min) ← Überblick
2. QUICK-START-GUIDE.md   (15 Min) ← Deployen
3. Swagger testen         (5 Min)  ← Erfolg!
```

**Ergebnis:** App läuft, grundlegendes Verständnis

---

### **Lernpfad 2: Tiefes Verständnis (2-3 Std)**

```
1. GETTING-STARTED.md        (10 Min)  ← Überblick
2. QUICK-START-GUIDE.md      (15 Min)  ← Deployen
3. DEPLOYMENT-BLUEPRINT.md   (45 Min)  ← Theorie
4. YAML-EXAMPLES.md          (60 Min)  ← YAML lernen
5. ARCHITECTURE.md           (20 Min)  ← Big Picture
6. Eigene YAMLs schreiben    (30 Min)  ← Praxis
```

**Ergebnis:** Vollständiges Kubernetes-Verständnis

---

### **Lernpfad 3: Troubleshooting (1 Std)**

```
1. QUICK-START-GUIDE.md     (15 Min) ← Deployen
2. Absichtlich Fehler bauen (20 Min) ← z.B. falsches Image
3. QUICK-START Troubleshooting (10 Min) ← Fehler fixen
4. kubectl Befehle üben     (15 Min) ← logs, describe, events
```

**Ergebnis:** Fehler selbstständig debuggen können

---

## 📊 Dokument-Vergleich

| Dokument | Länge | Level | Praxis | Theorie | Diagramme |
|----------|-------|-------|--------|---------|-----------|
| **GETTING-STARTED** | Kurz | 🟢 | 20% | 30% | 10% |
| **QUICK-START** | Mittel | 🟢 | 80% | 10% | 10% |
| **BLUEPRINT** | Lang | 🟡 | 50% | 40% | 10% |
| **YAML-EXAMPLES** | Lang | 🟡 | 30% | 70% | 20% |
| **ARCHITECTURE** | Mittel | 🟢 | 10% | 40% | 50% |

---

## 🔍 Suche nach Thema

| Thema | Dokument | Kapitel |
|-------|----------|---------|
| **Harbor Setup** | QUICK-START | Schritt 1-3 |
| **ImagePullSecret** | QUICK-START | Schritt 5 |
| **ArgoCD UI** | QUICK-START | Schritt 6-7 |
| **YAML Syntax** | YAML-EXAMPLES | Alle Kapitel |
| **Deployment erklärt** | YAML-EXAMPLES | Kapitel 4 |
| **Ingress erklärt** | YAML-EXAMPLES | Kapitel 6 |
| **Datenfluss** | ARCHITECTURE | Kapitel 2 |
| **Backup** | BLUEPRINT | Kapitel Troubleshooting |
| **GitOps** | ARCHITECTURE | Kapitel 4 |
| **Security** | ARCHITECTURE | Kapitel 7 |
| **Skalierung** | ARCHITECTURE | Kapitel 10 |
| **Troubleshooting** | QUICK-START | Kapitel Troubleshooting |
| **Begriffe** | GETTING-STARTED | Kapitel "Wichtige Begriffe" |

---

## 📱 Quick Access Links

### **Ich habe ein Problem:**

| Problem | Lösung |
|---------|--------|
| App deployed nicht | [QUICK-START - Troubleshooting](./QUICK-START-GUIDE.md#🛠️-troubleshooting) |
| ImagePullBackOff | [QUICK-START - Problem 1](./QUICK-START-GUIDE.md#-problem-1-imagepullbackoff) |
| CrashLoopBackOff | [QUICK-START - Problem 2](./QUICK-START-GUIDE.md#-problem-2-crashloopbackoff-postgres) |
| DB verbindet nicht | [QUICK-START - Problem 3](./QUICK-START-GUIDE.md#-problem-3-app-verbindet-nicht-zur-db) |
| localhost nicht erreichbar | [QUICK-START - Problem 4](./QUICK-START-GUIDE.md#-problem-4-localhost-funktioniert-nicht) |
| ArgoCD OutOfSync | [QUICK-START - Problem 5](./QUICK-START-GUIDE.md#-problem-5-argocd-zeigt-outofsync) |

---

### **Ich will etwas tun:**

| Aktion | Anleitung |
|--------|-----------|
| App deployen | [QUICK-START - Schritt 1-10](./QUICK-START-GUIDE.md#🚀-deployment-in-10-schritten) |
| Code ändern & deployen | [QUICK-START - Szenario 1](./QUICK-START-GUIDE.md#szenario-1-code-geändert) |
| YAML ändern & deployen | [QUICK-START - Szenario 2](./QUICK-START-GUIDE.md#szenario-2-kubernetes-config-geändert) |
| Backup erstellen | [BLUEPRINT - Backups](./DEPLOYMENT-BLUEPRINT.md#🆘-schnelle-hilfe) |
| Backup wiederherstellen | [BLUEPRINT - Backups](./DEPLOYMENT-BLUEPRINT.md#🆘-schnelle-hilfe) |
| Skalieren (mehr Pods) | [ARCHITECTURE - Scaling](./ARCHITECTURE.md#📈-skalierungs-szenarien) |

---

### **Ich will etwas lernen:**

| Thema | Ressource |
|-------|-----------|
| Kubernetes Basics | [GETTING-STARTED - Begriffe](./GETTING-STARTED.md#🎓-wichtige-begriffe-einfach-erklärt) |
| YAML schreiben | [YAML-EXAMPLES - Alle Kapitel](./YAML-EXAMPLES.md) |
| GitOps verstehen | [ARCHITECTURE - GitOps](./ARCHITECTURE.md#🔄-gitops-workflow-mit-argocd) |
| Architektur verstehen | [ARCHITECTURE - Diagramme](./ARCHITECTURE.md) |
| Best Practices | [BLUEPRINT - Security](./DEPLOYMENT-BLUEPRINT.md#🚨-wichtige-sicherheitshinweise) |

---

## 🎯 Checkliste: Habe ich alles gelesen?

### **Minimum (Anfänger):**
```
□ GETTING-STARTED.md gelesen
□ QUICK-START-GUIDE durchgeführt
□ App läuft auf localhost/swagger
```

### **Empfohlen (Fortgeschritten):**
```
□ GETTING-STARTED.md gelesen
□ QUICK-START-GUIDE durchgeführt
□ DEPLOYMENT-BLUEPRINT.md gelesen
□ YAML-EXAMPLES teilweise gelesen
□ Eigene YAML-Änderung gemacht
□ Troubleshooting einmal durchgeführt
```

### **Vollständig (Profi):**
```
□ Alle 5 Dokumente gelesen
□ App mehrmals deployed
□ YAMLs selbst geschrieben
□ Backup & Restore getestet
□ Troubleshooting gemeistert
□ Eigene Änderungen gepusht
□ GitOps-Workflow verstanden
```

---

## 📞 Noch Fragen?

### **Weitere Ressourcen:**

- **Projekt-spezifisch:**
  - [k8s/postgres/BACKUP-README.md](../k8s/postgres/BACKUP-README.md) - Backup-System
  - [k8s/postgres/PVC-README.md](../k8s/postgres/PVC-README.md) - Persistenz

- **Offizielle Docs:**
  - [Kubernetes Docs](https://kubernetes.io/docs/)
  - [ArgoCD Docs](https://argo-cd.readthedocs.io/)
  - [Harbor Docs](https://goharbor.io/docs/)

- **Tutorials:**
  - [Kubernetes Basics](https://kubernetes.io/docs/tutorials/kubernetes-basics/)
  - [GitOps Guide](https://www.gitops.tech/)

---

**Bereit? Starte mit:** [GETTING-STARTED.md](./GETTING-STARTED.md) 👈

---

*Zuletzt aktualisiert: 2026-02-03*
