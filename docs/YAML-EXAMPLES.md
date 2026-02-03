# 📝 Kommentierte YAML-Dateien - Jede Zeile erklärt

## Inhaltsverzeichnis
1. [Namespace](#1-namespace)
2. [ConfigMap](#2-configmap)
3. [Secret](#3-secret)
4. [Deployment](#4-deployment)
5. [Service](#5-service)
6. [Ingress](#6-ingress)
7. [PersistentVolumeClaim](#7-persistentvolumeclaim)

---

## 1. Namespace

**Was ist das?**  
Ein "Ordner" in Kubernetes. Alle deine Ressourcen (Pods, Services, etc.) liegen darin.

**Warum brauchst du das?**  
Trennung von verschiedenen Projekten (z.B. `development`, `production`).

```yaml
# k8s/Student-api/Namespace.yaml

# API-Version: Welche Kubernetes-Version diese Ressource unterstützt
apiVersion: v1

# Art der Ressource: Ein Namespace ist ein "Ordner" für andere Ressourcen
kind: Namespace

# Metadaten: Informationen ÜBER die Ressource
metadata:
  # Name des Namespace - WICHTIG: alle anderen Ressourcen müssen diesen Namen nutzen
  name: development
  
  # Labels: Markierungen zum Filtern und Organisieren (optional)
  labels:
    environment: dev          # Zeigt: das ist die Entwicklungsumgebung
    managed-by: argocd        # Zeigt: ArgoCD verwaltet diesen Namespace
```

---

## 2. ConfigMap

**Was ist das?**  
Speichert **nicht-geheime** Einstellungen (wie DB-Name, Hostnamen).

**Warum nicht direkt im Code?**  
Du kannst Einstellungen ändern, ohne die App neu zu bauen!

```yaml
# k8s/Student-api/ConfigMap.yaml

apiVersion: v1

# Art der Ressource: ConfigMap = Konfigurations-Speicher
kind: ConfigMap

metadata:
  # Name der ConfigMap - wird später in Deployment.yaml referenziert
  name: app-config
  
  # In welchem Namespace liegt diese ConfigMap?
  namespace: development

# data: Die eigentlichen Konfigurations-Daten (Key-Value Paare)
data:
  # Key: database-host, Value: postgres-service
  # Die App liest das später über Umgebungsvariablen
  database-host: "postgres-service"   # Name des Postgres-Service
  
  # Name der Datenbank
  database-name: "studentdb"
```

**Wie nutzt die App das?**  
In `Deployment.yaml` wird das so gemappt:
```yaml
env:
- name: DB_HOST                    # Name der Umgebungsvariable in der App
  valueFrom:
    configMapKeyRef:
      name: app-config              # Name der ConfigMap (oben definiert)
      key: database-host            # Welcher Key aus der ConfigMap
```

---

## 3. Secret

**Was ist das?**  
Speichert **geheime** Daten (Passwörter, API-Keys). Wird verschlüsselt gespeichert.

**Unterschied zu ConfigMap?**  
Secrets sind Base64-kodiert und haben spezielle Berechtigungen.

```yaml
# k8s/Student-api/Secret.yaml (BEISPIEL - in deinem Projekt anders!)

apiVersion: v1

# Art der Ressource: Secret = geheime Daten
kind: Secret

metadata:
  name: db-credentials          # Name des Secrets
  namespace: development

# type: Art des Secrets
# Opaque = generisches Secret (am häufigsten)
# kubernetes.io/dockerconfigjson = für ImagePullSecrets
type: Opaque

# stringData: Daten im Klartext (Kubernetes kodiert automatisch zu Base64)
stringData:
  # Username für die Datenbank
  username: "app_user"
  
  # Passwort für die Datenbank
  password: "SuperSecurePassword123!"

# ALTERNATIV: data (schon Base64-kodiert)
# data:
#   username: YXBwX3VzZXI=                    # Base64 von "app_user"
#   password: U3VwZXJTZWN1cmVQYXNzd29yZDEyMyE=  # Base64 von "SuperSecure..."
```

**Wie erstelle ich Base64?**  
```powershell
# PowerShell
[Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("mein-text"))

# Bash/Linux
echo -n "mein-text" | base64
```

**Wie nutzt die App das?**  
```yaml
env:
- name: POSTGRES_PASSWORD        # Name der Umgebungsvariable
  valueFrom:
    secretKeyRef:
      name: db-credentials        # Name des Secrets
      key: password               # Welcher Key aus dem Secret
```

---

## 4. Deployment

**Was ist das?**  
Die wichtigste Datei! Sagt Kubernetes:
- Welches Image starten?
- Wie viele Kopien (Replicas)?
- Welche Ressourcen (CPU/RAM)?
- Wie prüfen, ob die App läuft?

```yaml
# k8s/Student-api/Deployment.yaml

# API-Version für Deployments
apiVersion: apps/v1

# Art der Ressource: Deployment = verwaltet Pods
kind: Deployment

metadata:
  # Name des Deployments - wird in Befehlen genutzt
  # z.B.: kubectl get deployment manifest-app
  name: manifest-app
  
  namespace: development
  
  # Labels für das Deployment selbst
  labels:
    app: manifest-app          # Haupt-Label (wichtig!)
    version: v1                # Versionierung
    component: api             # Art der Komponente

# spec: Die Spezifikation - WIE soll das Deployment aussehen?
spec:
  # replicas: Wie viele Kopien der App sollen laufen?
  # 2 = Hochverfügbarkeit (wenn eine abstürzt, läuft die andere)
  replicas: 2
  
  # strategy: Wie sollen Updates ablaufen?
  strategy:
    type: RollingUpdate        # Schrittweise ersetzen (kein Downtime)
    rollingUpdate:
      maxSurge: 1              # Maximal 1 Pod mehr als replicas (2+1=3 während Update)
      maxUnavailable: 0        # Mindestens 2 müssen immer laufen (zero-downtime)
  
  # selector: Wie findet Kubernetes die zugehörigen Pods?
  # MUSS mit labels der Pods übereinstimmen!
  selector:
    matchLabels:
      app: manifest-app        # Suche alle Pods mit diesem Label
  
  # template: Die "Vorlage" für jeden Pod
  template:
    # Metadaten für die Pods (nicht für das Deployment!)
    metadata:
      labels:
        app: manifest-app      # MUSS mit selector.matchLabels übereinstimmen!
        version: v1
        component: api
      
      # annotations: Zusätzliche Metadaten (nicht für Selektion)
      annotations:
        # Prometheus-Monitoring (falls installiert)
        prometheus.io/scrape: "true"   # Dieser Pod soll überwacht werden
        prometheus.io/port: "8080"     # Port für Metriken
        prometheus.io/path: "/metrics" # Pfad zu Metriken
    
    # spec: WIE soll der Pod aussehen?
    spec:
      # securityContext: Sicherheitseinstellungen für den ganzen Pod
      securityContext:
        runAsNonRoot: true     # Container NICHT als Root laufen lassen
        runAsUser: 1000        # Nutzer-ID im Container
        fsGroup: 1000          # Gruppen-ID für Dateisystem-Zugriff
      
      # imagePullSecrets: Passwort für private Docker-Registry (Harbor)
      imagePullSecrets:
        - name: harbor-regcred # Name des Secrets (kubectl create secret docker-registry...)
      
      # initContainers: Container, die VOR der App starten
      # Nutzen: Warten bis Datenbank bereit ist
      initContainers:
      - name: wait-for-postgres    # Name des Init-Containers
        image: postgres:15-alpine  # Nutzt Postgres-Image (hat pg_isready)
        
        # command: Was soll dieser Container tun?
        command:
          - sh                # Shell starten
          - -c                # Führe folgenden Befehl aus
          - >                 # Mehrzeiligen Befehl (YAML-Syntax)
            until pg_isready -h postgres-service -U "$POSTGRES_USER" -d "$POSTGRES_DB";
            do echo "waiting for postgres"; sleep 2; done
        # Bedeutung: Wiederhole pg_isready bis Postgres antwortet
        
        # env: Umgebungsvariablen für den Init-Container
        env:
        - name: POSTGRES_DB
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: database-name
        
        - name: POSTGRES_USER
          valueFrom:
            secretKeyRef:
              name: db-credentials
              key: username
        
        - name: POSTGRES_PASSWORD
          valueFrom:
            secretKeyRef:
              name: db-credentials
              key: password
        
        # PGPASSWORD: Spezielle Variable für PostgreSQL-Tools
        - name: PGPASSWORD
          valueFrom:
            secretKeyRef:
              name: db-credentials
              key: password
      
      # containers: Die Haupt-Container (deine App!)
      containers:
      - name: manifest-app         # Name des Containers
        
        # image: Welches Docker-Image starten?
        # Format: registry/project/image:tag
        image: localhost:30002/studenten/manifest-app:latest
        
        # imagePullPolicy: Wann Image neu herunterladen?
        # Always = bei jedem Start (gut für :latest Tag)
        # IfNotPresent = nur wenn nicht lokal vorhanden
        # Never = nie herunterladen (nur lokale Images)
        imagePullPolicy: Always
        
        # ports: Welche Ports öffnet der Container?
        ports:
        - name: http           # Name des Ports (frei wählbar)
          containerPort: 8080  # Port INNERHALB des Containers
          protocol: TCP        # TCP oder UDP
        
        # resources: Wie viel CPU/RAM bekommt der Container?
        resources:
          # requests: Garantierte Ressourcen (Minimum)
          requests:
            cpu: 100m          # 100 Millicores = 0.1 CPU-Core
            memory: 128Mi      # 128 Megabyte RAM
          
          # limits: Maximale Ressourcen (Container wird gedrosselt/beendet)
          limits:
            cpu: 500m          # 500 Millicores = 0.5 CPU-Core
            memory: 512Mi      # 512 Megabyte RAM
        
        # securityContext: Sicherheit für diesen Container
        securityContext:
          allowPrivilegeEscalation: false  # Keine Rechte-Erweiterung
          readOnlyRootFilesystem: false    # Root-Dateisystem beschreibbar (App braucht das)
          capabilities:
            drop:
            - ALL              # Entferne alle Linux-Capabilities (Rechte)
        
        # startupProbe: Ist die App fertig gestartet?
        # Wird nur EINMAL beim Start geprüft
        startupProbe:
          httpGet:
            path: /api/student     # Welcher Pfad soll geprüft werden?
            port: 8080             # Auf welchem Port?
          initialDelaySeconds: 10  # Warte 10 Sek nach Start
          periodSeconds: 5         # Prüfe alle 5 Sek
          timeoutSeconds: 3        # Antwort muss in 3 Sek kommen
          failureThreshold: 10     # 10 Fehlversuche = Pod neustart (10*5=50s max)
        
        # livenessProbe: Läuft die App NOCH?
        # Wenn das fehlschlägt: Pod wird neugestartet
        livenessProbe:
          httpGet:
            path: /api/student
            port: 8080
          initialDelaySeconds: 30  # Warte 30 Sek nach Start
          periodSeconds: 10        # Prüfe alle 10 Sek
          timeoutSeconds: 3
          failureThreshold: 3      # 3 Fehlversuche = Neustart
        
        # readinessProbe: Ist die App bereit für Traffic?
        # Wenn das fehlschlägt: Pod bekommt KEINEN Traffic vom Service
        readinessProbe:
          httpGet:
            path: /api/student
            port: 8080
          initialDelaySeconds: 5   # Prüfe früh
          periodSeconds: 5         # Prüfe oft
          timeoutSeconds: 3
          failureThreshold: 3      # 3 Fehlversuche = aus Loadbalancer entfernen
        
        # env: Umgebungsvariablen für die App
        env:
        # DB_HOST wird aus ConfigMap gelesen
        - name: DB_HOST
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: database-host
        
        # DB_NAME wird aus ConfigMap gelesen
        - name: DB_NAME
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: database-name
        
        # volumeMounts: Verzeichnisse, die in den Container gemountet werden
        volumeMounts:
        - name: secret-volume      # Name muss mit volumes.name übereinstimmen
          mountPath: /etc/app-secrets  # Pfad IM Container
          readOnly: true           # Nur lesen, nicht schreiben
      
      # volumes: Definiert, WOHER die Daten kommen
      volumes:
      - name: secret-volume        # Name für volumeMounts
        secret:
          secretName: db-credentials  # Welches Secret?
          items:                   # Welche Keys als Dateien?
          - key: password          # Key aus Secret
            path: db_password      # Dateiname: /etc/app-secrets/db_password
          - key: username
            path: db_user          # Dateiname: /etc/app-secrets/db_user

---
# Service für das Deployment
# Ein Service ist eine "feste Adresse" für Pods

apiVersion: v1
kind: Service

metadata:
  name: manifest-app-service  # Name des Service (wird von Ingress genutzt)
  namespace: development
  labels:
    app: manifest-app
    component: api

spec:
  # type: Art des Service
  # ClusterIP = nur INNERHALB des Clusters erreichbar (Standard)
  # NodePort = auch von außen erreichbar auf Port 30000-32767
  # LoadBalancer = Cloud-Loadbalancer (AWS ELB, Azure LB, etc.)
  type: ClusterIP
  
  # selector: Welche Pods gehören zu diesem Service?
  # MUSS mit Pod-Labels übereinstimmen!
  selector:
    app: manifest-app
  
  # ports: Welche Ports werden weitergeleitet?
  ports:
  - name: http           # Name des Ports (frei wählbar)
    port: 80             # Port des SERVICE (ClusterIP:80)
    targetPort: 8080     # Port des PODS (Container läuft auf 8080)
    protocol: TCP
  
  # Bedeutung:
  # Traffic auf Service-Port 80 → wird zu Pod-Port 8080 weitergeleitet
```

---

## 5. Service

**Was ist das?**  
Eine "feste Adresse" für deine Pods. Pods haben wechselnde IPs, der Service hat eine stabile IP.

**Warum brauchst du das?**  
Andere Pods/Services können deine App erreichen, egal welcher Pod gerade läuft.

```yaml
# k8s/Student-api/Service.yaml (normalerweise in Deployment.yaml)

apiVersion: v1
kind: Service

metadata:
  name: manifest-app-service
  namespace: development
  labels:
    app: manifest-app

spec:
  # type: Wie ist der Service erreichbar?
  type: ClusterIP        # Nur innerhalb Kubernetes (Standard)
  # Alternativen:
  # - NodePort: Auch von außen auf Node-IP:30000-32767
  # - LoadBalancer: Cloud-Loadbalancer (AWS, Azure, GCP)
  
  # selector: Welche Pods gehören zu diesem Service?
  selector:
    app: manifest-app    # Suche Pods mit diesem Label
  
  # ports: Port-Mapping
  ports:
  - name: http
    port: 80             # Externer Port (andere Services nutzen diesen)
    targetPort: 8080     # Interner Port (Pod lauscht auf diesem)
    protocol: TCP

# Ergebnis:
# Andere Pods können erreichen via:
# - http://manifest-app-service (innerhalb des Namespace)
# - http://manifest-app-service.development (namespace-übergreifend)
# - http://manifest-app-service.development.svc.cluster.local (voller DNS)
```

**Service-Typen im Detail:**

| Typ | Erreichbar von | Use Case | Port-Range |
|-----|---------------|----------|------------|
| **ClusterIP** | Nur innerhalb Kubernetes | Standard, für interne Services | beliebig |
| **NodePort** | Außen über Node-IP | Entwicklung, Testing | 30000-32767 |
| **LoadBalancer** | Außen über Cloud-LB | Produktion in Cloud | beliebig |

---

## 6. Ingress

**Was ist das?**  
Der "Türsteher" - leitet HTTP/HTTPS-Traffic von außen zu deinen Services.

**Warum brauchst du das?**  
Damit du im Browser `http://localhost/swagger` öffnen kannst.

```yaml
# k8s/Student-api/Ingress.yaml

# API-Version für Ingress
apiVersion: networking.k8s.io/v1

# Art der Ressource: Ingress = HTTP-Router
kind: Ingress

metadata:
  name: manifest-app-ingress
  namespace: development
  
  # annotations: Konfiguration für den Ingress Controller
  annotations:
    # Welcher Ingress Controller soll das verarbeiten?
    # nginx = NGINX Ingress Controller (am häufigsten)
    kubernetes.io/ingress.class: "nginx"
    
    # nginx-spezifische Einstellungen
    nginx.ingress.kubernetes.io/rewrite-target: /
    # Bedeutung: /api/student → /api/student (keine Änderung)
    
    # SSL/TLS (HTTPS) - optional
    # nginx.ingress.kubernetes.io/ssl-redirect: "false"  # Kein HTTPS-Zwang

spec:
  # ingressClassName: Moderne Alternative zu annotations
  ingressClassName: nginx
  
  # rules: Routing-Regeln
  rules:
  # host: Für welchen Hostnamen gilt diese Regel?
  - host: localhost      # Nur für localhost
    # Alternativ:
    # - host: api.example.com
    # - host: "*.example.com"  (Wildcard)
    
    http:
      # paths: Welche Pfade werden geroutet?
      paths:
      - path: /          # Alle Pfade ab Root
        
        # pathType: Wie soll der Pfad interpretiert werden?
        # Prefix = alles was mit /api beginnt
        # Exact = nur exakt /api
        # ImplementationSpecific = Controller entscheidet
        pathType: Prefix
        
        # backend: Wohin soll der Traffic gehen?
        backend:
          service:
            name: manifest-app-service  # Name des Service
            port:
              number: 80                # Port des Service

# Ergebnis:
# http://localhost/ → manifest-app-service:80 → Pod:8080
# http://localhost/swagger → manifest-app-service:80 → Pod:8080/swagger
# http://localhost/api/student → manifest-app-service:80 → Pod:8080/api/student
```

**Ingress vs. Service:**

| | Service | Ingress |
|---|---------|---------|
| **Layer** | Layer 4 (TCP/UDP) | Layer 7 (HTTP/HTTPS) |
| **Routing** | Nach IP/Port | Nach Host/Pfad |
| **SSL/TLS** | Nein | Ja |
| **Loadbalancing** | Round-Robin | Konfigurierbar |

**Beispiel-Szenarien:**

```yaml
# Szenario 1: Mehrere Services auf einem Host
rules:
- host: localhost
  http:
    paths:
    - path: /api
      pathType: Prefix
      backend:
        service:
          name: api-service
          port:
            number: 80
    - path: /frontend
      pathType: Prefix
      backend:
        service:
          name: frontend-service
          port:
            number: 80

# Szenario 2: Mehrere Hosts
rules:
- host: api.example.com
  http:
    paths:
    - path: /
      pathType: Prefix
      backend:
        service:
          name: api-service
          port:
            number: 80
- host: app.example.com
  http:
    paths:
    - path: /
      pathType: Prefix
      backend:
        service:
          name: frontend-service
          port:
            number: 80
```

---

## 7. PersistentVolumeClaim

**Was ist das?**  
Eine "Anfrage" für Speicherplatz. Wie eine externe Festplatte für Pods.

**Warum brauchst du das?**  
Container sind "ephemeral" (flüchtig) - Daten verschwinden bei Neustart. PVCs bleiben!

```yaml
# k8s/postgres/persistent-volumes.yaml

apiVersion: v1

# Art der Ressource: PersistentVolumeClaim = Speicher-Anfrage
kind: PersistentVolumeClaim

metadata:
  name: postgres-data-postgres-0  # Name des PVC
  namespace: development
  
  # annotations: Spezielle Anweisungen für ArgoCD
  annotations:
    # Prune=false = ArgoCD darf diesen PVC NICHT löschen!
    # Wichtig: Schützt Datenbank-Daten vor versehentlichem Löschen
    argocd.argoproj.io/sync-options: Prune=false

spec:
  # accessModes: Wie darf auf den Speicher zugegriffen werden?
  accessModes:
  - ReadWriteOnce     # RWO = Ein Pod kann lesen+schreiben
  # Alternativen:
  # - ReadOnlyMany    # ROX = Viele Pods können lesen
  # - ReadWriteMany   # RWX = Viele Pods können lesen+schreiben (NFS, etc.)
  
  # storageClassName: Welche Art von Speicher?
  # hostpath = Lokaler Ordner auf dem Node (Docker Desktop)
  # standard = Cloud-Standard (AWS EBS, Azure Disk)
  # fast = SSD-Storage
  storageClassName: hostpath
  
  # resources: Wie viel Speicher?
  resources:
    requests:
      storage: 10Gi   # 10 Gigabyte

# Nach Erstellung wird automatisch ein PersistentVolume (PV) erstellt und "gebunden"
```

**PVC Lifecycle:**

```
1. PVC erstellt → Status: Pending
2. Kubernetes findet/erstellt PV → Status: Bound
3. Pod nutzt PVC → Daten werden geschrieben
4. Pod gelöscht → PVC bleibt (Status: Bound)
5. PVC gelöscht → PV bleibt (wenn ReclaimPolicy: Retain)
```

**Nutzung in Pod:**

```yaml
# In Deployment/StatefulSet
spec:
  template:
    spec:
      containers:
      - name: postgres
        volumeMounts:
        - name: data              # Name (frei wählbar)
          mountPath: /var/lib/postgresql/data  # Pfad im Container
      
      volumes:
      - name: data                # Muss mit volumeMounts.name übereinstimmen
        persistentVolumeClaim:
          claimName: postgres-data-postgres-0  # Name des PVC
```

**Prüfen:**

```powershell
# PVCs ansehen
kubectl get pvc -n development

# Output:
# NAME                        STATUS   VOLUME                                     CAPACITY   STORAGECLASS
# postgres-data-postgres-0    Bound    pvc-xxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx       10Gi       hostpath

# PVs ansehen
kubectl get pv

# Details
kubectl describe pvc postgres-data-postgres-0 -n development
```

---

## Zusammenfassung: Wie hängt alles zusammen?

```
┌─────────────────────────────────────────────────────────────┐
│ Browser: http://localhost/swagger                            │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      ▼
            ┌─────────────────┐
            │  Ingress         │ (manifest-app-ingress)
            │  Host: localhost │
            └────────┬─────────┘
                     │
                     ▼
           ┌──────────────────┐
           │  Service          │ (manifest-app-service)
           │  ClusterIP:       │ Port 80 → 8080
           │  10.96.x.x:80     │
           └────────┬──────────┘
                    │
        ┌───────────┴───────────┐
        ▼                       ▼
  ┌──────────┐           ┌──────────┐
  │  Pod 1   │           │  Pod 2   │  (2x Replicas)
  │  Image:  │           │  Image:  │
  │  ...app  │           │  ...app  │
  │  :latest │           │  :latest │
  └────┬─────┘           └────┬─────┘
       │                      │
       │ Liest Secrets        │ Liest Secrets
       ▼                      ▼
  ┌──────────────────────────────┐
  │  Secret: db-credentials       │
  │  - username: app_user         │
  │  - password: SuperSecure...   │
  └──────────────────────────────┘
       │
       │ Verbindet zu
       ▼
  ┌──────────────────────────────┐
  │  Service: postgres-service    │ Port 5432
  └────────┬─────────────────────┘
           │
           ▼
     ┌──────────────┐
     │  Pod:        │
     │  postgres-0  │ (StatefulSet)
     └────┬─────────┘
          │
          │ Schreibt/Liest
          ▼
    ┌────────────────────┐
    │  PVC:              │
    │  postgres-data-    │ 10Gi Storage
    │  postgres-0        │
    └────────────────────┘
```

---

## Quick Reference: Häufige YAML-Patterns

### Pattern 1: Umgebungsvariable aus ConfigMap

```yaml
env:
- name: MY_VAR
  valueFrom:
    configMapKeyRef:
      name: my-config
      key: my-key
```

### Pattern 2: Umgebungsvariable aus Secret

```yaml
env:
- name: MY_SECRET
  valueFrom:
    secretKeyRef:
      name: my-secret
      key: password
```

### Pattern 3: Alle Keys aus ConfigMap als Env-Vars

```yaml
envFrom:
- configMapRef:
    name: my-config
# Ergebnis: Jeder Key wird zu einer Env-Var
```

### Pattern 4: Volume aus Secret

```yaml
volumes:
- name: secret-volume
  secret:
    secretName: my-secret
containers:
- name: app
  volumeMounts:
  - name: secret-volume
    mountPath: /etc/secrets
    readOnly: true
# Ergebnis: /etc/secrets/password (Datei mit Inhalt)
```

### Pattern 5: Multi-Container Pod

```yaml
containers:
- name: app
  image: my-app:latest
- name: sidecar
  image: logging-agent:latest
# Beide Container teilen sich Netzwerk & Volumes
```

---

**Nächste Schritte:**  
Lies `DEPLOYMENT-BLUEPRINT.md` für die komplette Deployment-Anleitung!
