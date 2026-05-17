#!/bin/bash
# =============================================================================
# install.sh — Orquestador principal del entorno de desarrollo
# Autor: Obviousfancy
# Repo:  https://github.com/Obviousfancy/dotfiles
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
mkdir -p "$SCRIPT_DIR/logs"

chmod +x "$SCRIPT_DIR/scripts/"*.sh

# Cargar preflight (que a su vez carga detect-os)
source "$SCRIPT_DIR/scripts/preflight.sh"

# Colores ya disponibles via detect-os
menu() {
    clear
    echo -e "${BOLD}${BLUE}"
    echo "  ╔══════════════════════════════════════════════════╗"
    echo "  ║         Dotfiles — Entorno Embedded Linux        ║"
    echo "  ║                 by Obviousfancy                  ║"
    echo "  ╚══════════════════════════════════════════════════╝"
    echo -e "${NC}"
    print_os_info

    echo -e "  Selecciona qué instalar:\n"
    echo -e "  ${GREEN}1)${NC} 🔧 Hardware Tools   (KiCad, Arduino, LaTeX, Vivado)"
    echo -e "  ${GREEN}2)${NC} 💻 Dev Tools         (VS Code, Docker, Git, JetBrains)"
    echo -e "  ${GREEN}3)${NC} 🔬 Embedded Tools    (ARM GCC, STM32CubeIDE, OpenOCD)"
    echo -e "  ${GREEN}a)${NC} 🚀 Todo              (instalación completa)"
    echo -e "  ${RED}q)${NC} Salir\n"
    read -rp "  Selección: " choice

    case $choice in
        1) bash "$SCRIPT_DIR/scripts/hardware-tools.sh" ;;
        2) bash "$SCRIPT_DIR/scripts/dev-tools.sh" ;;
        3) bash "$SCRIPT_DIR/scripts/embedded-tools.sh" ;;
        a)
            bash "$SCRIPT_DIR/scripts/hardware-tools.sh" --all
            bash "$SCRIPT_DIR/scripts/dev-tools.sh" --all
            bash "$SCRIPT_DIR/scripts/embedded-tools.sh" --all
            ;;
        q) echo "  Saliendo."; exit 0 ;;
        *) error "Opción no válida"; sleep 1; menu ;;
    esac
}

case "${1:-}" in
    --all)
        preflight_check
        bash "$SCRIPT_DIR/scripts/hardware-tools.sh" --all
        bash "$SCRIPT_DIR/scripts/dev-tools.sh" --all
        bash "$SCRIPT_DIR/scripts/embedded-tools.sh" --all
        ;;
    --hw)  bash "$SCRIPT_DIR/scripts/hardware-tools.sh" ;;
    --dev) bash "$SCRIPT_DIR/scripts/dev-tools.sh" ;;
    --emb) bash "$SCRIPT_DIR/scripts/embedded-tools.sh" ;;
    *)
        preflight_check  # Solo aparece en el flujo interactivo normal
        menu
        ;;
esac
