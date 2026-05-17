#!/bin/bash
# =============================================================================
# dev-tools.sh — Herramientas de desarrollo general
# Herramientas: VS Code, Git, Docker, JetBrains Toolbox, Node.js, Vite/React
# =============================================================================

source "$(dirname "$0")/detect-os.sh"

LOG_FILE="$(dirname "$0")/../logs/dev-tools.log"
mkdir -p "$(dirname "$LOG_FILE")"
exec > >(tee -a "$LOG_FILE") 2>&1

# =============================================================================
# FUNCIONES DE INSTALACIÓN — aquí pegas tu código
# =============================================================================

install_vscode() {
    section "Visual Studio Code"
    log "Iniciando instalación de VS Code..."


    # ─── PEGA TU CÓDIGO AQUÍ ────────────────────────────────────────────────
    # Matlab no tiene instalación automática en Linux — requiere cuenta MathWorks
    # Este bloque guía al usuario y abre el navegador
    warn "Matlab requiere descarga manual desde VS Code"
    echo ""
    echo -e "  ${CYAN}1.${NC} https://code.visualstudio.com/download"
    echo -e "  ${CYAN}2.${NC} Guarda el instalador en ~/Downloads"
    echo -e "  ${CYAN}3.${NC} Vuelve a ejecutar este script"
    echo ""

    # Buscar si ya existe el instalador descargado
    INSTALLER=$(find ~/Downloads -name "code_*.deb" 2>/dev/null | head -1)

    if [ -z "$INSTALLER" ]; then
        warn "Instalador no encontrado. Abriendo navegador..."
        xdg-open "https://code.visualstudio.com/download" 2>/dev/null
        return 1
    fi

    log "Instalador encontrado: $INSTALLER"


    # ─── PEGA TU CÓDIGO AQUÍ ────────────────────────────────────────────────
    case $PKG_MANAGER in
        apt)
            # Instalar .deb en archivo en Downloads
            sudo apt install "$INSTALLER"

            ;;
        dnf)
            ;;
        pacman)
            ;;
    esac
    # ────────────────────────────────────────────────────────────────────────

    success "VS Code instalado correctamente"
}

# -----------------------------------------------------------------------------
install_git() {
    section "Git + configuración"
    log "Iniciando configuración de Git..."

    # ─── PEGA TU CÓDIGO AQUÍ ────────────────────────────────────────────────
    # Sugerencia: pide nombre y email con read, luego usa git config --global

    # ────────────────────────────────────────────────────────────────────────
    sudo apt install git 

    ssh-keygen -t ed25519 -C "tu@email.com"                 ## Replace tu@email.com with your current email address. This will generate a new SSH key using the Ed25519 algorithm, which is more secure than the older RSA algorithm.

    ssh -T git@github.com                                   ## This command tests the connection to GitHub using SSH. If successful, you should see a message like "Hi username! You've successfully authenticated, but GitHub does not provide shell access."
    
    ## Hi user! You've successfully authenticated, but GitHub does not provide shell access.

    # Show the public key so the user can copy it to GitHub or other services
    cat ~/.ssh/id_ed25519.pub
    
    ssh-ed25519 <your_ssh_key> <youremail@email.com>    ## Add the generated SSH key to the ssh-agent to manage your keys more easily. This step is optional but recommended if you have multiple SSH keys or want to avoid entering your passphrase every time.



    success "Git configurado correctamente"
}

# -----------------------------------------------------------------------------
install_docker() {
    section "Docker"
    log "Iniciando instalación de Docker..."

    # ─── PEGA TU CÓDIGO AQUÍ ────────────────────────────────────────────────
    case $PKG_MANAGER in
        apt)


            ;;
        dnf)
            ;;
        pacman)
            ;;
    esac
    # ────────────────────────────────────────────────────────────────────────

    success "Docker instalado correctamente"
}

# -----------------------------------------------------------------------------
install_jetbrains() {
    section "JetBrains Toolbox"
    log "Iniciando instalación de JetBrains Toolbox..."

    # ─── PEGA TU CÓDIGO AQUÍ ────────────────────────────────────────────────
    # JetBrains Toolbox se descarga como .tar.gz desde:
    # https://www.jetbrains.com/toolbox-app/
    # Descomprimir, dar chmod +x y ejecutar
    # ────────────────────────────────────────────────────────────────────────
    sudo tar -xvf ~/Downloads/jetbrains-toolbox-*.tar.gz -C /opt/           #Verificar nombre exacto del archivo descargado si no solicitarlo al usuario


    sudo mv /opt/jetbrains-toolbox-* /opt/jetbrains-toolbox
    sudo chown -R $USER:$USER /opt/jetbrains-toolbox
    /opt/jetbrains-toolbox/bin/jetbrains-toolbox


    success "JetBrains Toolbox instalado"
    warn "Ejecuta 'jetbrains-toolbox' para instalar WebStorm, CLion, etc."
}

# -----------------------------------------------------------------------------
install_nodejs() {
    section "Node.js"
    log "Iniciando instalación de Node.js..."

    # ─── PEGA TU CÓDIGO AQUÍ ────────────────────────────────────────────────
    # Recomendado: instalar via nvm para manejar versiones fácilmente
    #   Ruta para descargar nvm:
    #   https://nodejs.org/en/download 
    # ────────────────────────────────────────────────────────────────────────
    #Verificar si nvm esta instalado 
    if ! command -v nvm &>/dev/null; then
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash
    fi
    # Cargar nvm en el entorno actual
    \. "$HOME/.nvm/nvm.sh"

    # Download and install the latest LTS version of Node.js
    nvm install 24                  #verificar si sirve --lts o si es necesario especificar la version exacta

    # Verify the Node.js version:
    node -v # Should print "current node version".

    # Verify npm version:
    npm -v # Should print "Current npm version".

    success "Node.js instalado correctamente"
}

# -----------------------------------------------------------------------------
install_vite_react() {
    section "Vite + React (scaffolding)"
    log "Verificando dependencias para Vite/React..."

    # Vite no se instala globalmente, se usa via npx
    # Este bloque verifica que Node.js esté disponible
    if ! command -v node &>/dev/null; then
        warn "Node.js no está instalado."
        read -rp "  ¿Instalar Node.js ahora? [s/N]: " confirm
        # El patrón [sS] acepta 's' o 'S'
        if [[ "$confirm" =~ ^[sS]$ ]]; then
            install_nodejs
        else
            error "Instala Node.js primero. Abortando."
            return 1
        fi
    fi

    # ─── PEGA TU CÓDIGO AQUÍ ────────────────────────────────────────────────
    # npm install -g vite  (opcional, normalmente se usa via npx)
    # Muestra al usuario cómo crear un proyecto nuevo

    # ────────────────────────────────────────────────────────────────────────

    success "Entorno Vite/React listo"
    log "Crear proyecto nuevo: npx create-vite@latest mi-proyecto --template react"
}

install_matlab() {
    section "Matlab"
    log "Iniciando instalación de Matlab..."

    # ─── PEGA TU CÓDIGO AQUÍ ────────────────────────────────────────────────
    # Matlab no tiene instalación automática en Linux — requiere cuenta MathWorks
    # Este bloque guía al usuario y abre el navegador
    warn "Matlab requiere descarga manual desde MathWorks."
    echo ""
    echo -e "  ${CYAN}1.${NC} Crea cuenta en:  https://www.mathworks.com/login"
    echo -e "  ${CYAN}2.${NC} Descarga desde:  https://www.mathworks.com/downloads"
    echo -e "  ${CYAN}3.${NC} Guarda el instalador en ~/Downloads"
    echo -e "  ${CYAN}4.${NC} Vuelve a ejecutar este script"
    echo ""

    # Buscar si ya existe el instalador descargado
    INSTALLER=$(find ~/Downloads -name "matlab_*.iso" 2>/dev/null | head -1)

    if [ -z "$INSTALLER" ]; then
        warn "Instalador no encontrado. Abriendo navegador..."
        xdg-open "https://www.mathworks.com/downloads" 2>/dev/null
        return 1
    fi

    log "Instalador encontrado: $INSTALLER"

    # ─── PEGA TU CÓDIGO DE INSTALACIÓN AQUÍ ─────────────────────────────────

    chmod +x "$INSTALLER"
    unzip "$INSTALLER"

    chmod +x install
    sudo sudo ./install

    nano ~/.local/share/applications/matlab.desktop

    ## Add this to the file and save it:

    [Desktop Entry]
    Version=1.0
    Type=Application
    Name=MATLAB
    Comment=Scientific computing environment
    Exec=/usr/local/bin/matlab -desktop
    Icon=/usr/local/MATLAB/R202Xb/toolbox/shared/dastudio/resources/Matlab_Logo_64.png
    Terminal=false
    Categories=Development;Science;Mathematics;

    ```bash
    sudo usermod -a -G dialout $USER
    ```

    # ────────────────────────────────────────────────────────────────────────
}



# =============================================================================
# MENÚ — no modificar esta sección
# =============================================================================

show_menu() {
    clear
    echo -e "${BOLD}${BLUE}"
    echo "  ╔══════════════════════════════════════╗"
    echo "  ║      💻  Dev Tools                   ║"
    echo "  ╚══════════════════════════════════════╝"
    echo -e "${NC}"
    print_os_info

    echo -e "  Selecciona qué instalar:\n"
    echo -e "  ${GREEN}1)${NC} VS Code          — Editor con extensiones embedded"
    echo -e "  ${GREEN}2)${NC} Git              — Control de versiones + config SSH"
    echo -e "  ${GREEN}3)${NC} Docker           — Contenedores"
    echo -e "  ${GREEN}4)${NC} JetBrains        — Toolbox (WebStorm, CLion, etc.)"
    echo -e "  ${GREEN}5)${NC} Node.js          — Runtime JavaScript"
    echo -e "  ${GREEN}6)${NC} Vite + React     — Scaffolding frontend"
    echo -e "  ${GREEN}7)${NC} Matlab           — Numerical computing software"    
    echo -e "  ${GREEN}a)${NC} Todo             — Instalar todas las herramientas"
    echo -e "  ${RED}q)${NC} Volver al menú principal\n"
    read -rp "  Selección: " choice
}

main() {
    check_not_root
    check_internet

    if [[ "${1:-}" == "--all" ]]; then
        install_vscode
        install_git
        install_docker
        install_jetbrains
        install_nodejs
        install_vite_react
        install_matlab
        return
    fi

    show_menu

    case $choice in
        1) install_vscode ;;
        2) install_git ;;
        3) install_docker ;;
        4) install_jetbrains ;;
        5) install_nodejs ;;
        6) install_vite_react ;;
        7) install_matlab ;;
        a)
            install_vscode
            install_git
            install_docker
            install_jetbrains
            install_nodejs
            install_vite_react
            install_matlab
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
