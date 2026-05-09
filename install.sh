#!/bin/bash
# =============================================================================
# install.sh — Orquestador principal del entorno de desarrollo
# Autor: [Tu nombre]
# Repo:  https://github.com/[tu-usuario]/dotfiles
#
# Uso:
#   ./install.sh          → menú interactivo
#   ./install.sh --all    → instala todo
#   ./install.sh --hw     → solo hardware tools
#   ./install.sh --dev    → solo dev tools
#   ./install.sh --emb    → solo embedded tools
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
mkdir -p "$SCRIPT_DIR/logs"

# Dar permisos de ejecución a todos los scripts
chmod +x "$SCRIPT_DIR/scripts/"*.sh

# Colores
RED='\033[0;31m'; GREEN='\033[0;32m'
YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'

banner() {
    echo -e "${BLUE}"
    echo "╔══════════════════════════════════════════════════╗"
    echo "║         Dotfiles — Entorno Embedded Linux        ║"
    echo "║         by [Tu nombre] · UNIT Electronics       ║"
    echo "╚══════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

menu() {
    banner
    echo "Selecciona qué instalar:"
    echo ""
    echo -e "  ${GREEN}1)${NC} 🔧 Hardware Tools   (KiCad, OpenOCD, Arduino, Vivado)"
    echo -e "  ${GREEN}2)${NC} 💻 Dev Tools         (VS Code, Docker, Git, JetBrains)"
    echo -e "  ${GREEN}3)${NC} 🔬 Embedded Tools    (ARM GCC, STM32CubeIDE, debug)"
    echo -e "  ${GREEN}a)${NC} 🚀 Todo              (instalación completa)"
    echo -e "  ${RED}q)${NC} Salir"
    echo ""
    read -rp "Selección: " choice

    case $choice in
        1) bash "$SCRIPT_DIR/scripts/hardware-tools.sh" ;;
        2) bash "$SCRIPT_DIR/scripts/dev-tools.sh" ;;
        3) bash "$SCRIPT_DIR/scripts/embedded-tools.sh" ;;
        a)
            bash "$SCRIPT_DIR/scripts/hardware-tools.sh" --all
            bash "$SCRIPT_DIR/scripts/dev-tools.sh" --all
            bash "$SCRIPT_DIR/scripts/embedded-tools.sh" --all
            ;;
        q) echo "Saliendo."; exit 0 ;;
        *) echo -e "${RED}Opción no válida${NC}"; menu ;;
    esac
}

# Flags por línea de comandos
case "${1:-}" in
    --all) bash "$SCRIPT_DIR/scripts/hardware-tools.sh" --all
           bash "$SCRIPT_DIR/scripts/dev-tools.sh" --all
           bash "$SCRIPT_DIR/scripts/embedded-tools.sh" --all ;;
    --hw)  bash "$SCRIPT_DIR/scripts/hardware-tools.sh" ;;
    --dev) bash "$SCRIPT_DIR/scripts/dev-tools.sh" ;;
    --emb) bash "$SCRIPT_DIR/scripts/embedded-tools.sh" ;;
    *)     menu ;;
esac
