# Sealed Secrets

Sealed Secrets ermoeglicht die sichere Speicherung von Kubernetes Secrets in Git-Repositories.

## Architektur

```
+------------------+     kubeseal      +-------------------+
|  Secret (YAML)   | ----------------> |  SealedSecret     |
|  (Klartext)      |   Public Key      |  (Verschluesselt) |
+------------------+                   +-------------------+
                                              |
                                              | kubectl apply
                                              v
                                   +---------------------+
                                   | Sealed Secrets      |
                                   | Controller          |
                                   | (im Cluster)        |
                                   +---------------------+
                                              |
                                              | Private Key
                                              v
                                   +---------------------+
                                   | Kubernetes Secret   |
                                   | (Entschluesselt)    |
                                   +---------------------+
```

## Installation

### 1. Sealed Secrets Controller installieren

**Option A: Standalone (empfohlen fuer Docker Desktop/Minikube)**

```bash
kubectl apply -f controller-standalone.yaml
```

**Option B: Mit Helm**

```bash
helm repo add sealed-secrets https://bitnami-labs.github.io/sealed-secrets
helm install sealed-secrets sealed-secrets/sealed-secrets \
  --namespace sealed-secrets \
  --create-namespace
```

### 2. kubeseal CLI installieren

**macOS:**
```bash
brew install kubeseal
```

**Linux:**
```bash
KUBESEAL_VERSION="0.26.1"
wget "https://github.com/bitnami-labs/sealed-secrets/releases/download/v${KUBESEAL_VERSION}/kubeseal-${KUBESEAL_VERSION}-linux-amd64.tar.gz"
tar -xvzf kubeseal-${KUBESEAL_VERSION}-linux-amd64.tar.gz
sudo install -m 755 kubeseal /usr/local/bin/kubeseal
```

**Windows:**
```powershell
# Mit scoop
scoop install kubeseal

# Oder manuell von GitHub Releases herunterladen
```

### 3. Controller-Status pruefen

```bash
kubectl get pods -n sealed-secrets
kubectl logs -n sealed-secrets -l app.kubernetes.io/name=sealed-secrets
```

## Verwendung

### Neues SealedSecret erstellen

1. **Secret Template erstellen** (oder bestehendes verwenden):

```yaml
# my-secret.yaml (NICHT in Git committen!)
apiVersion: v1
kind: Secret
metadata:
  name: my-secret
  namespace: development
type: Opaque
stringData:
  username: mein-benutzer
  password: mein-passwort
```

2. **Mit kubeseal verschluesseln:**

```bash
kubeseal \
  --controller-name=sealed-secrets-controller \
  --controller-namespace=sealed-secrets \
  --format yaml \
  < my-secret.yaml \
  > my-secret-sealed.yaml
```

3. **Oder mit dem Helper-Skript:**

```bash
./seal-secret.sh seal my-secret.yaml
```

4. **SealedSecret anwenden:**

```bash
kubectl apply -f my-secret-sealed.yaml
```

### db-credentials verschluesseln

Das Template fuer die Datenbank-Anmeldedaten befindet sich in `db-credentials-secret.template.yaml`.

```bash
# Mit Helper-Skript
./seal-secret.sh db-credentials

# Oder manuell
kubeseal \
  --controller-name=sealed-secrets-controller \
  --controller-namespace=sealed-secrets \
  --format yaml \
  < db-credentials-secret.template.yaml \
  > db-credentials-sealed.yaml
```

## Dateistruktur

```
k8s/sealed-secrets/
├── README.md                           # Diese Dokumentation
├── controller.yaml                     # Controller mit Flux/Helm
├── controller-standalone.yaml          # Controller ohne Flux
├── controller-kustomization.yaml       # Kustomization fuer Controller
├── kustomization.yaml                  # Kustomization fuer Secrets
├── seal-secret.sh                      # Helper-Skript
├── db-credentials-secret.template.yaml # Template (NICHT committen!)
└── db-credentials-sealed.yaml          # Verschluesseltes Secret (sicher fuer Git)
```

## Wichtige Hinweise

### Sicherheit

- **NIEMALS** unverschluesselte Secrets in Git committen
- Template-Dateien (`*.template.yaml`) sind in `.gitignore` aufgefuehrt
- Nur `*-sealed.yaml` Dateien koennen sicher committed werden

### Backup der Schluessel

Der Controller generiert einen asymmetrischen Schluesselpaar:
- **Public Key**: Wird fuer die Verschluesselung verwendet
- **Private Key**: Wird im Cluster gespeichert (als Secret)

**Wichtig:** Bei Verlust des Private Keys koennen bestehende SealedSecrets nicht mehr entschluesselt werden!

```bash
# Schluessel sichern
kubectl get secret -n sealed-secrets \
  -l sealedsecrets.bitnami.com/sealed-secrets-key \
  -o yaml > sealed-secrets-keys-backup.yaml
```

### Scope von SealedSecrets

- **strict** (default): Secret kann nur im angegebenen Namespace/Name verwendet werden
- **namespace-wide**: Secret kann im angegebenen Namespace mit beliebigem Namen verwendet werden
- **cluster-wide**: Secret kann ueberall im Cluster verwendet werden

```bash
# Namespace-wide
kubeseal --scope namespace-wide ...

# Cluster-wide
kubeseal --scope cluster-wide ...
```

## Troubleshooting

### Controller startet nicht

```bash
kubectl describe pod -n sealed-secrets -l app.kubernetes.io/name=sealed-secrets
```

### Secret wird nicht erstellt

```bash
# SealedSecret Status pruefen
kubectl get sealedsecret -n development db-credentials -o yaml

# Controller-Logs pruefen
kubectl logs -n sealed-secrets -l app.kubernetes.io/name=sealed-secrets
```

### Zertifikat erneuern

```bash
# Public Key neu abrufen
./seal-secret.sh fetch-key

# Oder manuell
kubeseal --fetch-cert \
  --controller-name=sealed-secrets-controller \
  --controller-namespace=sealed-secrets \
  > sealed-secrets-public-key.pem
```
