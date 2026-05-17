#!/bin/bash
# =============================================================================
# hardware-tools.sh — Herramientas EDA y programación de hardware
# Herramientas: KiCad, Arduino IDE, Vivado, LaTeX
# =============================================================================

# Importar detección de OS y funciones de log
SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SELF_DIR/preflight.sh"


# Directorio de logs (se crea automáticamente)
LOG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/logs"
mkdir -p "$LOG_DIR"
chmod 755 "$LOG_DIR"
# Si el log existe y es de root, tomar ownership automáticamente
if [ -f "$LOG_DIR/hardware-tools.log" ] && [ ! -w "$LOG_DIR/hardware-tools.log" ]; then
    sudo chown "$USER":"$USER" "$LOG_DIR/hardware-tools.log"
fi
LOG_FILE="$LOG_DIR/hardware-tools.log"
touch "$LOG_FILE"
chmod 644 "$LOG_FILE"
exec > >(tee -a "$LOG_FILE")

# =============================================================================
# FUNCIONES DE INSTALACIÓN — aquí pegas tu código
# =============================================================================

install_kicad() {
    section "KiCad"
    log "Iniciando instalación de KiCad..."

    # ─── PEGA TU CÓDIGO AQUÍ ────────────────────────────────────────────────
    case $PKG_MANAGER in
        apt)


            ## https://launchpad.net/~kicad
            ## Verify current version for the PPA 
            sudo add-apt-repository ppa:kicad/kicad-10.0-releases                   #Update with latest stable version kicad-<version>-releases

            sudo apt update                                                         #Update package lists

            sudo apt install --install-recommends kicad                             #Install KiCad with recommended dependencies

            sudo apt update && sudo apt upgrade -y                                  #Upgrade all packages to latest versions -y es para responder "sí" automáticamente a cualquier pregunta


            # tu código para ubuntu/debian
            ;;
        dnf)
            # tu código para fedora
            ;;
        pacman)
            # tu código para arch
            ;;
        *)
            warn "KiCad: instalación manual → https://www.kicad.org/download/"
            return 1
            ;;
    esac
    # ────────────────────────────────────────────────────────────────────────

    success "KiCad instalado correctamente"
}

# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
install_arduino() {
 
 
    INSTALL_DIR="/opt/arduino-ide"
 
    section "Arduino IDE 2"
    log "Iniciando instalación de Arduino IDE..."
 
    INSTALLER=$(wait_for_file ~/Downloads "arduino-ide_*.zip" "Arduino IDE")
    
    # extract() retorna la ruta del tmpdir via echo
    EXTRACTED=$(extract "$INSTALLER" "arduino")
    # EXTRACTED = /tmp/arduino-XXXXXX/
 
    echo "🚀 Iniciando instalación de Arduino IDE..."
    
 
    # Cachear credenciales sudo para evitar interrupciones
    sudo -v
 
    # Mover contenido a /opt/
    sudo rm -rf /opt/arduino-ide && echo "rm ok" || echo "rm falló"
    sudo mv "$EXTRACTED"/arduino-ide_* /opt/arduino-ide && echo "mv ok" || error "mv falló"
    rm -rf "$EXTRACTED"
 
    # --- 2. Asignar propiedad al usuario ---
    echo "🔑 Asignando permisos..."
    sudo chown -R "$USER":"$USER" "$INSTALL_DIR"
    
    # --- 3. Configurar chrome-sandbox ---
    echo "🔒 Configurando sandbox..."
    sudo chown root:root "$INSTALL_DIR/chrome-sandbox"
    sudo chmod 4755 "$INSTALL_DIR/chrome-sandbox"
    
    # --- 4. Grupo dialout para acceso a hardware ---
    echo "🔌 Agregando usuario al grupo dialout..."
    sudo usermod -aG dialout "$USER"
    
    # --- 5. Crear configuración del CLI para evitar error de JSON ---
    echo "⚙️  Creando configuración del CLI..."
    mkdir -p ~/.arduinoIDE
cat > ~/.arduinoIDE/arduino-cli.yaml << EOF
board_manager:
    additional_urls: []
directories:
    data: $HOME/.arduino15
    downloads: $HOME/.arduino15/staging
    user: $HOME/Arduino    
EOF


    # --- 6. Wrapper para terminal ---
    echo "🔗 Creando comando 'arduino-ide' en terminal..."
    sudo tee /usr/local/bin/arduino-ide > /dev/null << 'WRAPPER'
#!/bin/bash
exec /opt/arduino-ide/arduino-ide --no-sandbox "$@"
WRAPPER
    sudo chmod +x /usr/local/bin/arduino-ide
 
    # --- 7. Acceso directo en el menú ---
    echo "🖥️  Creando acceso directo en el menú..."
    mkdir -p ~/.local/share/applications
    cat > ~/.local/share/applications/arduino-ide.desktop << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Arduino IDE
Comment=Arduino IDE 2
Exec=$INSTALL_DIR/arduino-ide --no-sandbox
Icon=$INSTALL_DIR/resources/app/resources/icons/512x512.png
Terminal=false
Categories=Development;IDE;
StartupNotify=true
EOF
    chmod +x ~/.local/share/applications/arduino-ide.desktop || true
 
    # Registrar .desktop sin cerrar sesión
    update-desktop-database ~/.local/share/applications
    gtk-update-icon-cache -f -t ~/.local/share/icons 2>/dev/null || true
    if command -v gdbus &>/dev/null; then
        gdbus call --session \
            --dest org.gnome.Shell \
            --object-path /org/gnome/Shell \
            --method org.gnome.Shell.Eval \
            "Main.overview.hide();" 2>/dev/null || true
    fi
 
    echo ""
    echo "✅ Arduino IDE instalado correctamente en $INSTALL_DIR"
    echo "   Terminal: arduino-ide"
    echo ""
 
    success "Arduino IDE instalado correctamente"
}



# -----------------------------------------------------------------------------
install_latex() {
    section "LaTeX (TeX Live)"
    log "Iniciando instalación de LaTeX..."

    # ─── PEGA TU CÓDIGO AQUÍ ────────────────────────────────────────────────
    # Nota: texlive-full pesa ~5 GB. Si quieres versión ligera usa texlive-base
    case $PKG_MANAGER in
        apt)
        
            # Verify the mirror repositories for the latest TeX Live distribution
            # https://www.tug.org/texlive/quickinstall.html
            
            # ✅ Envolver en subshell — el cd queda aislado
            (
                cd /tmp
                wget https://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz
                zcat < install-tl-unx.tar.gz | tar xf -
                cd install-tl-2*
                sudo perl ./install-tl --no-interaction
            )

            # Esto va FUERA de la subshell — solo si no existe ya
            if ! grep -q "texlive" "$HOME/.bashrc"; then
                echo 'export PATH=/usr/local/texlive/2026/bin/x86_64-linux:$PATH' >> ~/.bashrc
            fi

           # En lugar de pdflatex --version, agregar esto:
            warn "Abre una terminal nueva y ejecuta 'pdflatex --version' para verificar la instalación"
            #If all works fine, you can view this output 
            #pdfTeX <your-version> (TeX Live <your current year>)
            # tu código aquí
            ;;
        dnf)
            ;;
        pacman)
            ;;
    esac
    # ────────────────────────────────────────────────────────────────────────

    success "LaTeX instalado correctamente"
}

# -----------------------------------------------------------------------------
install_vivado() {
    section "Vivado (AMD/Xilinx)"
    # Vivado no tiene instalación automática — requiere cuenta AMD
    # Este bloque guía al usuario y abre el navegador
    warn "Vivado requiere descarga manual desde AMD."
    echo ""
    echo -e "  ${CYAN}1.${NC} Crea cuenta en:  https://www.amd.com/en/registration"
    echo -e "  ${CYAN}2.${NC} Descarga desde:  https://www.xilinx.com/support/download.html"
    echo -e "  ${CYAN}3.${NC} Guarda el instalador en ~/Downloads"
    echo -e "  ${CYAN}4.${NC} Vuelve a ejecutar este script"
    echo ""

    # Buscar si ya existe el instalador descargado
    # INSTALLER=$(find ~/Downloads -name "Xilinx_Vivado_*.tar.gz" 2>/dev/null | head -1)

    INSTALLER=$(wait_for_file ~/Downloads "Xilinx_Vivado_*.sh" "Vivado")

    log "Instalador encontrado: $INSTALLER"

    # ─── PEGA TU CÓDIGO DE INSTALACIÓN AQUÍ ─────────────────────────────────

    # ────────────────────────────────────────────────────────────────────────
}

# =============================================================================
# MENÚ — no modificar esta sección
# =============================================================================

show_menu() {
    clear
    echo -e "${BOLD}${BLUE}"
    echo "  ╔══════════════════════════════════════╗"
    echo "  ║      🔧  Hardware Tools              ║"
    echo "  ╚══════════════════════════════════════╝"
    echo -e "${NC}"
    print_os_info

    echo -e "  Selecciona qué instalar:\n"
    echo -e "  ${GREEN}1)${NC} KiCad             — EDA para PCB y esquemáticos"
    echo -e "  ${GREEN}2)${NC} Arduino IDE 2     — Placas Arduino / ESP32"
    echo -e "  ${GREEN}3)${NC} LaTeX             — Redacción técnica y reportes"
    echo -e "  ${GREEN}4)${NC} Vivado            — FPGA (AMD/Xilinx)"
    echo -e "  ${GREEN}a)${NC} Todo              — Instalar todas las herramientas"
    echo -e "  ${RED}q)${NC} Volver al menú principal\n"
    read -rp "  Selección: " choice
}

main() {
    check_not_root
    check_internet

    # Si se llama con --all desde install.sh, instala todo sin menú
    if [[ "${1:-}" == "--all" ]]; then
        install_kicad
        install_arduino
        install_latex
        install_vivado
        return
    fi

    show_menu

    case $choice in
        1) install_kicad ;;
        2) install_arduino ;;
        3) install_latex ;;
        4) install_vivado ;;
        a)
            install_kicad
            install_arduino
            install_latex
            install_vivado
            ;;
        q) exit 0 ;;
        *)
            error "Opción no válida: '$choice'"
            sleep 1
            main  # Vuelve a mostrar el menú
            ;;
    esac

    echo ""
    read -rp "  Presiona Enter para continuar..." _
}

main "$@"
