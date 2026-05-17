#!/bin/bash
# =============================================================================
# detect-os.sh — Detección de distro y package manager
#
# USO: no se ejecuta directo, se importa desde otros scripts con:
#   source "$(dirname "$0")/detect-os.sh"
#
# Después de importarlo, tienes disponibles:
#   $OS           → ubuntu | debian | arch | fedora | opensuse
#   $OS_FAMILY    → debian | arch | rhel
#   $OS_VERSION   → 26.04 | 12 | etc.
#   $OS_PRETTY    → "Ubuntu 26.04 LTS"
#   $PKG_MANAGER  → apt | pacman | dnf | zypper
#   $PKG_UPDATE   → comando para actualizar lista
#   $PKG_INSTALL  → comando para instalar (ya incluye -y)
#   $PKG_ADD_REPO → comando para agregar repositorio
# =============================================================================

# -- Colores ------------------------------------------------------------------
# Defínelos aquí una vez, todos los scripts los heredan via source
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color — resetea el color

# -- Funciones de log ---------------------------------------------------------
# Úsalas en cualquier script después de hacer source de este archivo
log()     { echo -e "${CYAN}[·]${NC} $1" >&2; }
success() { echo -e "${GREEN}[✓]${NC} $1" >&2; }
warn()    { echo -e "${YELLOW}[!]${NC} $1" >&2; }
error()   { echo -e "${RED}[✗]${NC} $1" >&2; }
section() { echo -e "\n${BOLD}${BLUE}══ $1 ══${NC}\n" >&2; }

# -- Detección de OS ----------------------------------------------------------
detect_os() {
    # /etc/os-release existe en todas las distros modernas
    # El punto (.) antes de la ruta es equivalente a "source" — importa las variables
    if [ -f /etc/os-release ]; then
        . /etc/os-release          # Carga: ID, ID_LIKE, VERSION_ID, PRETTY_NAME
        OS=$ID                     # ubuntu | debian | arch | fedora
        OS_FAMILY=${ID_LIKE:-$ID}  # Si no hay ID_LIKE, usa ID como familia
        OS_VERSION=${VERSION_ID:-"desconocida"}
        OS_PRETTY=${PRETTY_NAME:-$ID}
    else
        error "No se puede detectar el sistema operativo."
        error "/etc/os-release no existe — distro muy antigua o no estándar."
        exit 1
    fi
}

# -- Detección de package manager ---------------------------------------------
detect_package_manager() {
    # "command -v" busca si el comando existe en el PATH
    # "&>/dev/null" silencia cualquier output (stdout y stderr)
    if command -v apt &>/dev/null; then
        PKG_MANAGER="apt"
        PKG_UPDATE="sudo apt update"
        PKG_INSTALL="sudo apt install -y"
        PKG_ADD_REPO="sudo add-apt-repository -y"

    elif command -v dnf &>/dev/null; then
        PKG_MANAGER="dnf"
        PKG_UPDATE="sudo dnf check-update || true" # dnf devuelve código 100 si hay updates, no es error
        PKG_INSTALL="sudo dnf install -y"
        PKG_ADD_REPO="sudo dnf config-manager --add-repo"

    elif command -v pacman &>/dev/null; then
        PKG_MANAGER="pacman"
        PKG_UPDATE="sudo pacman -Sy"
        PKG_INSTALL="sudo pacman -S --noconfirm"
        PKG_ADD_REPO="" # Arch no tiene add-repo, usa AUR (yay/paru)

    elif command -v zypper &>/dev/null; then
        PKG_MANAGER="zypper"
        PKG_UPDATE="sudo zypper refresh"
        PKG_INSTALL="sudo zypper install -y"
        PKG_ADD_REPO="sudo zypper addrepo"

    else
        error "Package manager no reconocido."
        error "Este script soporta: apt (Ubuntu/Debian), dnf (Fedora), pacman (Arch), zypper (openSUSE)"
        exit 1
    fi
}

# -- Banner de sistema detectado ----------------------------------------------
print_os_info() {
    echo -e "${BOLD}"
    echo    "  ┌─────────────────────────────────────┐"
    echo -e "  │  Sistema detectado                  │"
    echo    "  ├─────────────────────────────────────┤"
    printf  "  │  %-36s│\n" "OS:   $OS_PRETTY"
    printf  "  │  %-36s│\n" "PKG:  $PKG_MANAGER"
    echo    "  └─────────────────────────────────────┘"
    echo -e "${NC}"
}

# -- Verificar que se ejecuta como usuario normal (no root) -------------------
check_not_root() {
    # $EUID es el ID de usuario efectivo; 0 = root
    if [ "$EUID" -eq 0 ]; then
        error "No ejecutes este script como root (sudo)."
        error "El script pide sudo solo cuando lo necesita."
        exit 1
    fi
}

# -- Verificar conexión a internet --------------------------------------------
check_internet() {
    log "Verificando conexión a internet..."
    # ping -c1 = un solo ping, -q = silencioso, &>/dev/null = sin output
    if ! ping -c1 -q 8.8.8.8 &>/dev/null; then
        error "Sin conexión a internet. Conéctate e intenta de nuevo."
        exit 1
    fi
    success "Conexión a internet OK"
}

# -- Ejecutar detección al hacer source ---------------------------------------
# Esto corre automáticamente cuando otro script hace:  source detect-os.sh
detect_os
detect_package_manager
