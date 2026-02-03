#!/bin/bash
# Skript zum Verschluesseln von Secrets mit kubeseal
#
# Voraussetzungen:
# - kubeseal CLI installiert (https://github.com/bitnami-labs/sealed-secrets)
# - kubectl mit Zugriff auf den Cluster konfiguriert
# - Sealed Secrets Controller im Cluster installiert

set -e

CONTROLLER_NAME="${CONTROLLER_NAME:-sealed-secrets-controller}"
CONTROLLER_NAMESPACE="${CONTROLLER_NAMESPACE:-sealed-secrets}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Farben fuer Output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Pruefe ob kubeseal installiert ist
if ! command -v kubeseal &> /dev/null; then
    print_error "kubeseal ist nicht installiert!"
    echo ""
    echo "Installation:"
    echo "  # macOS"
    echo "  brew install kubeseal"
    echo ""
    echo "  # Linux"
    echo "  wget https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.26.1/kubeseal-0.26.1-linux-amd64.tar.gz"
    echo "  tar -xvzf kubeseal-0.26.1-linux-amd64.tar.gz"
    echo "  sudo install -m 755 kubeseal /usr/local/bin/kubeseal"
    exit 1
fi

# Funktion zum Verschluesseln eines Secrets
seal_secret() {
    local input_file="$1"
    local output_file="$2"

    if [[ ! -f "$input_file" ]]; then
        print_error "Datei nicht gefunden: $input_file"
        exit 1
    fi

    print_info "Verschluessele $input_file -> $output_file"

    kubeseal \
        --controller-name="$CONTROLLER_NAME" \
        --controller-namespace="$CONTROLLER_NAMESPACE" \
        --format yaml \
        < "$input_file" \
        > "$output_file"

    print_info "Erfolgreich verschluesselt: $output_file"
}

# Public Key vom Controller holen (fuer Offline-Verschluesselung)
fetch_public_key() {
    local output_file="${1:-sealed-secrets-public-key.pem}"

    print_info "Hole Public Key vom Controller..."

    kubeseal \
        --controller-name="$CONTROLLER_NAME" \
        --controller-namespace="$CONTROLLER_NAMESPACE" \
        --fetch-cert > "$output_file"

    print_info "Public Key gespeichert: $output_file"
}

# Hauptprogramm
case "${1:-}" in
    seal)
        if [[ -z "${2:-}" ]]; then
            print_error "Verwendung: $0 seal <input.yaml> [output.yaml]"
            exit 1
        fi
        input="$2"
        output="${3:-${input%.yaml}-sealed.yaml}"
        output="${output%.template.yaml}-sealed.yaml"
        seal_secret "$input" "$output"
        ;;
    fetch-key)
        fetch_public_key "${2:-}"
        ;;
    db-credentials)
        seal_secret "$SCRIPT_DIR/db-credentials-secret.template.yaml" "$SCRIPT_DIR/db-credentials-sealed.yaml"
        ;;
    *)
        echo "Sealed Secrets Helper Script"
        echo ""
        echo "Verwendung:"
        echo "  $0 seal <input.yaml> [output.yaml]  - Verschluesselt ein Secret"
        echo "  $0 fetch-key [output.pem]           - Holt den Public Key vom Controller"
        echo "  $0 db-credentials                   - Verschluesselt db-credentials"
        echo ""
        echo "Umgebungsvariablen:"
        echo "  CONTROLLER_NAME      - Name des Controllers (default: sealed-secrets-controller)"
        echo "  CONTROLLER_NAMESPACE - Namespace des Controllers (default: sealed-secrets)"
        ;;
esac
