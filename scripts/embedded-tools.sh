#!/bin/bash
# =============================================================================
# embedded-tools.sh — Toolchain para sistemas embebidos
# Herramientas: ARM GCC, STM32CubeIDE, OpenOCD, bat, colores de terminal
# =============================================================================

source "$(dirname "$0")/preflight.sh"   # carga detect-os automáticamente

LOG_FILE="$(dirname "$0")/../logs/embedded-tools.log"
mkdir -p "$(dirname "$LOG_FILE")"
exec > >(tee -a "$LOG_FILE") 2>&1

# =============================================================================
# FUNCIONES DE INSTALACIÓN
# =============================================================================

install_arm_toolchain() {
    section "ARM GCC Toolchain"
    log "Iniciando instalación de ARM GCC..."

    case $PKG_MANAGER in
        apt)
            sudo apt install -y \
                gcc-arm-none-eabi \
                binutils-arm-none-eabi \
                libnewlib-arm-none-eabi \
                gdb-multiarch \
                cmake \
                ninja-build \
                make
            ;;
        dnf)
            sudo dnf install -y arm-none-eabi-gcc arm-none-eabi-binutils cmake ninja-build make
            ;;
        pacman)
            sudo pacman -S --noconfirm arm-none-eabi-gcc arm-none-eabi-binutils cmake ninja make
            ;;
    esac

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

    # CubeIDE — zip que contiene el .sh
    INSTALLER=$(wait_for_file ~/Downloads "en.st-stm32cubeide_*.zip" "STM32CubeIDE")
    EXTRACTED=$(extract "$INSTALLER" "stm32cubeide")
    SH_INSTALLER=$(find "$EXTRACTED" -name "st-stm32cubeide_*.sh" | head -1)
    chmod +x "$SH_INSTALLER"
    sudo "$SH_INSTALLER"
    rm -rf "$EXTRACTED"

    if [ -d "/opt/stm32cubeide" ]; then
        success "STM32CubeIDE instalado en /opt/stm32cubeide"
    else
        error "No se encontró la instalación después de ejecutar el instalador"
        return 1
    fi

    # CubeMX — opcional
    read -rp "  ¿También instalar STM32CubeMX? [s/N]: " confirm
    if [[ "$confirm" =~ ^[sS]$ ]]; then
        INSTALLERMX=$(wait_for_file ~/Downloads "en.stm32cubemx_*.zip" "STM32CubeMX")
        EXTRACTED_MX=$(extract "$INSTALLERMX" "stm32cubemx")
        MX_INSTALLER=$(find "$EXTRACTED_MX" -name "SetupSTM32CubeMX*" -type f | head -1)
        chmod +x "$MX_INSTALLER"
        sudo "$MX_INSTALLER"
        rm -rf "$EXTRACTED_MX"
        success "STM32CubeMX instalado"
    fi

    # Reglas udev para ST-Link sin sudo
    UDEV_RULES=$(find /opt/stm32cubeide -name "*.rules" 2>/dev/null | head -1)
    if [ -n "$UDEV_RULES" ]; then
        sudo cp "$UDEV_RULES" /etc/udev/rules.d/
        sudo udevadm control --reload-rules
        sudo usermod -aG plugdev "$USER"
    fi

    success "STM32CubeIDE instalado correctamente"
}

# -----------------------------------------------------------------------------
install_openocd() {
    section "OpenOCD"
    log "Iniciando instalación de OpenOCD..."

    case $PKG_MANAGER in
        apt)    sudo apt install -y openocd ;;
        dnf)    sudo dnf install -y openocd ;;
        pacman) sudo pacman -S --noconfirm openocd ;;
    esac

    # Reglas udev para acceso a debuggers sin sudo
    if [ -f /usr/share/openocd/contrib/60-openocd.rules ]; then
        sudo cp /usr/share/openocd/contrib/60-openocd.rules /etc/udev/rules.d/
        sudo udevadm control --reload-rules
        sudo usermod -aG plugdev "$USER"
    fi

    success "OpenOCD instalado"
   
}

# -----------------------------------------------------------------------------
install_bat() {
    section "bat (cat con syntax highlighting)"
    log "Instalando bat..."

    case $PKG_MANAGER in
        apt)
            sudo apt install -y bat

            # En Ubuntu el binario se llama batcat — crear symlink para usar como bat
            mkdir -p "$HOME/.local/bin"
            ln -sf /usr/bin/batcat "$HOME/.local/bin/bat"

            # Agregar ~/.local/bin al PATH si no está ya
            # grep -q busca silenciosamente — retorna 0 si encuentra, 1 si no
            if ! grep -q 'export PATH="$HOME/.local/bin:$PATH"' "$HOME/.bashrc"; then
                echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
                log "PATH actualizado en ~/.bashrc"
            fi
            ;;
        dnf)
            sudo dnf install -y bat
            ;;
        pacman)
            sudo pacman -S --noconfirm bat
            ;;
    esac

    success "bat instalado"
    warn "Abre una terminal nueva para usar el comando 'bat'"
}

# -----------------------------------------------------------------------------
configure_terminal_colors() {
    section "Colores y tema de terminal"
    log "Aplicando configuración de colores..."

    CONFIGS_DIR="$(dirname "$0")/../configs"
    BASHRC="$HOME/.bashrc"

    # Activar prompt con colores
    # sed -i edita el archivo en sitio (in-place)
    # Reemplaza "#force_color_prompt=yes" por "force_color_prompt=yes" si existe
    if grep -q "^#force_color_prompt=yes" "$BASHRC"; then
        sed -i 's/^#force_color_prompt=yes/force_color_prompt=yes/' "$BASHRC"
        success "force_color_prompt activado en ~/.bashrc"
    elif grep -q "^force_color_prompt=yes" "$BASHRC"; then
        warn "force_color_prompt ya estaba activado"
    else
        echo "force_color_prompt=yes" >> "$BASHRC"
        log "force_color_prompt agregado al final de ~/.bashrc"
    fi

    # Copiar .dircolors si existe en configs/
    if [ -f "$CONFIGS_DIR/.dircolors" ]; then
        cp "$CONFIGS_DIR/.dircolors" "$HOME/.dircolors"
        # Agregar carga de dircolors si no está ya en .bashrc
        if ! grep -q "dircolors" "$BASHRC"; then
            echo 'eval "$(dircolors -b ~/.dircolors)"' >> "$BASHRC"
        fi
        success ".dircolors aplicado"
    else
        warn "No se encontró configs/.dircolors — agrega tu configuración ahí"
    fi

    # NO hacer source ~/.bashrc aquí — causa loop infinito cuando
    # .bashrc llama a source y source vuelve a cargar .bashrc
    # El usuario debe abrir una terminal nueva

    success "Colores configurados"
    warn "Abre una terminal nueva para ver los cambios"
}

# =============================================================================
# MENÚ
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
