#!/bin/bash
# =============================================================================
# embedded-tools.sh — Toolchain para sistemas embebidos
# Herramientas: ARM GCC, STM32CubeIDE, OpenOCD, bat, colores de terminal
# =============================================================================

source "$(dirname "$0")/detect-os.sh"

LOG_FILE="$(dirname "$0")/../logs/embedded-tools.log"
mkdir -p "$(dirname "$LOG_FILE")"
exec > >(tee -a "$LOG_FILE") 2>&1

# =============================================================================
# FUNCIONES DE INSTALACIÓN — aquí pegas tu código
# =============================================================================

install_arm_toolchain() {
    section "ARM GCC Toolchain"
    log "Iniciando instalación de ARM GCC..."

    # ─── PEGA TU CÓDIGO AQUÍ ────────────────────────────────────────────────
    case $PKG_MANAGER in
        apt)
            # gcc-arm-none-eabi, binutils-arm-none-eabi, etc.
            ;;
        dnf)
            ;;
        pacman)
            ;;
    esac
    # ────────────────────────────────────────────────────────────────────────

    # Verificar que quedó instalado
    # "command -v" retorna 0 (éxito) si existe, 1 si no
    if command -v arm-none-eabi-gcc &>/dev/null; then
        VERSION=$(arm-none-eabi-gcc --version | head -1)
        success "ARM GCC listo: $VERSION"
    else
        error "arm-none-eabi-gcc no encontrado después de instalar"
    fi
}

# -----------------------------------------------------------------------------
install_stm32cubeide() {
    section "STM32CubeIDE"
    log "Buscando instalador de STM32CubeIDE..."

    # Semi-automático: busca el instalador en ~/Downloads
    # "${HOME}" es equivalente a "~" pero funciona mejor dentro de scripts
    INSTALLER=$(find "${HOME}/Downloads" -name "st-stm32cubeide_*.sh" 2>/dev/null | head -1)
    INSTALLERMX=$(find "${HOME}/Downloads" -name "stm32cubemx*.sh" 2>/dev/null | head -1)  # Algunos nombres de instalador tienen este formato
    if [ -z "$INSTALLER" ]; then
        # -z significa "si la variable está vacía"
        warn "Instalador no encontrado en ~/Downloads"
        echo ""
        echo -e "  ${CYAN}Pasos para obtenerlo:${NC}"
        echo -e "  ${CYAN}1.${NC} Ve a: https://www.st.com/en/development-tools/stm32cubeide.html"
        echo -e "  ${CYAN}2.${NC} Crea cuenta gratuita en st.com"
        echo -e "  ${CYAN}3.${NC} Descarga el instalador .sh para Linux"
        echo -e "  ${CYAN}4.${NC} Guárdalo en ~/Downloads"
        echo -e "  ${CYAN}5.${NC} Vuelve a ejecutar este script"
        echo ""
        warn "Abriendo navegador..."
        xdg-open "https://www.st.com/en/development-tools/stm32cubeide.html" 2>/dev/null
        return 1
    fi

    log "Instalador encontrado: $(basename "$INSTALLER")"

    # ─── PEGA TU CÓDIGO DE INSTALACIÓN AQUÍ ─────────────────────────────────
    # chmod +x "$INSTALLER"
    # sudo "$INSTALLER"
    # configurar reglas udev para ST-Link

    # ────────────────────────────────────────────────────────────────────────

    chmod +x "$INSTALLER"
    unzip "$INSTALLER" -d /tmp/stm32cubeide
    sudo ./tmp/stm32cubeide<version>/install.sh --mode unattended --prefix /opt/stm32cubeide
    # El comando anterior es un ejemplo, debes ajustarlo al nombre exacto del instalador que descargues

    # Verificar que quedó instalado
    if [ -d "/opt/stm32cubeide" ]; then
        success "STM32CubeIDE instalado en /opt/stm32cubeide"
    else
        error "No se encontró la instalación de STM32CubeIDE después de ejecutar el instalador"
    fi

    # Instalar STM32CUBE MX
    chmod +x "$INSTALLERMX"
    sudo ./"$INSTALLERMX" 

    success "STM32CubeIDE and Cube MX installed"
}

# -----------------------------------------------------------------------------
install_openocd() {
    section "OpenOCD"
    log "Iniciando instalación de OpenOCD..."

    # ─── PEGA TU CÓDIGO AQUÍ ────────────────────────────────────────────────
    case $PKG_MANAGER in
        apt)    ;;
        dnf)    ;;
        pacman) ;;
    esac
    # ────────────────────────────────────────────────────────────────────────

    success "OpenOCD instalado"
    warn "Recuerda reiniciar sesión para que los permisos USB surtan efecto"
}

# -----------------------------------------------------------------------------
install_bat() {
    section "bat (cat con syntax highlighting)"
    log "Iniciando instalación de bat..."

    # ─── PEGA TU CÓDIGO AQUÍ ────────────────────────────────────────────────
    # En Ubuntu: sudo apt install bat
    # Nota: en Ubuntu el binario se llama "batcat", no "bat"
    # Para usar como "bat" hay que hacer un alias o symlink:
    #   mkdir -p ~/.local/bin
    #   ln -s /usr/bin/batcat ~/.local/bin/bat

    # ────────────────────────────────────────────────────────────────────────

    sudo apt install bat -y

    batcat ~/.bashrc

    alias bat='batcat'                        #Add an alias to the batcat at this sesion terminal

    echo "alias bat='batcat'" >> ~/.bashrc    #Add the alias at the end of file bashrc

    source ~/.bashrc                          #Refresh the bashrc for keep working

    success "bat instalado"
}

# -----------------------------------------------------------------------------
configure_terminal_colors() {
    section "Colores y tema de terminal"
    log "Aplicando configuración de colores..."

    # Este es un caso especial: no instala nada, copia archivos de config
    # Los archivos de config van en la carpeta configs/ del repo
    CONFIGS_DIR="$(dirname "$0")/../configs"

    # ─── PEGA TU CÓDIGO AQUÍ ────────────────────────────────────────────────
    # Ejemplo de lo que podrías hacer:
    #
    # Copiar tu .bashrc personalizado:
    #   cp "$CONFIGS_DIR/.bashrc" ~/.bashrc
    #
    # Copiar configuración de colores de dircolors:
    #   cp "$CONFIGS_DIR/.dircolors" ~/.dircolors
    #
    # Aplicar sin reiniciar terminal:
    #   source ~/.bashrc

     nano ~/.bashrc
    # We add force_color_prompt=yes , for view colors in terminal, and we add source ~/.bashrc for apply the changes without restart the terminal

     echo "force_color_prompt=yes" >> ~/.bashrc
     echo "source ~/.bashrc" >> ~/.bashrc

     source ~/.bashrc

    # ────────────────────────────────────────────────────────────────────────

    success "Colores de terminal configurados"
    warn "Abre una terminal nueva para ver los cambios"
}

# =============================================================================
# MENÚ — no modificar esta sección
# =============================================================================

show_menu() {
    clear
    echo -e "${BOLD}${BLUE}"
    echo "  ╔══════════════════════════════════════╗"
    echo "  ║      🔬  Embedded Tools              ║"
    echo "  ╚══════════════════════════════════════╝"
    echo -e "${NC}"
    print_os_info

    echo -e "  Selecciona qué instalar:\n"
    echo -e "  ${GREEN}1)${NC} ARM GCC          — Compilación para STM32 / Cortex-M"
    echo -e "  ${GREEN}2)${NC} STM32CubeIDE     — IDE oficial de ST (requiere descarga)"
    echo -e "  ${GREEN}3)${NC} OpenOCD          — Debug JTAG/SWD"
    echo -e "  ${GREEN}4)${NC} bat              — cat mejorado con syntax highlighting"
    echo -e "  ${GREEN}5)${NC} Colores terminal — Tema y colores personalizados"
    echo -e "  ${GREEN}a)${NC} Todo             — Instalar todo"
    echo -e "  ${RED}q)${NC} Volver al menú principal\n"
    read -rp "  Selección: " choice
}

main() {
    check_not_root

    if [[ "${1:-}" == "--all" ]]; then
        install_arm_toolchain
        install_stm32cubeide
        install_openocd
        install_bat
        configure_terminal_colors
        return
    fi

    show_menu

    case $choice in
        1) install_arm_toolchain ;;
        2) install_stm32cubeide ;;
        3) install_openocd ;;
        4) install_bat ;;
        5) configure_terminal_colors ;;
        a)
            install_arm_toolchain
            install_stm32cubeide
            install_openocd
            install_bat
            configure_terminal_colors
            ;;
        q) exit 0 ;;
        *)
            error "Opción no válida: '$choice'"
            sleep 1
            main
            ;;
    esac

    echo ""
    read -rp "  Presiona Enter para continuar..." _
}

main "$@"
