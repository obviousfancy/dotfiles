#!/bin/bash
# =============================================================================
# dev-tools.sh — Herramientas de desarrollo general
# Herramientas: VS Code, Git, Docker, JetBrains Toolbox, Node.js, Vite/React, MATLAB
# =============================================================================

source "$(dirname "$0")/detect-os.sh"

LOG_FILE="$(dirname "$0")/../logs/dev-tools.log"
mkdir -p "$(dirname "$LOG_FILE")"
exec > >(tee -a "$LOG_FILE") 2>&1

# =============================================================================
# FUNCIONES DE INSTALACIÓN
# =============================================================================

install_vscode() {
    section "Visual Studio Code"
    log "Buscando instalador de VS Code..."

    INSTALLER=$(find ~/Downloads -name "code_*.deb" 2>/dev/null | head -1)

    if [ -z "$INSTALLER" ]; then
        warn "Instalador .deb no encontrado en ~/Downloads"
        echo ""
        echo -e "  ${CYAN}1.${NC} Descarga desde: https://code.visualstudio.com/download"
        echo -e "  ${CYAN}2.${NC} Selecciona el paquete .deb (Linux)"
        echo -e "  ${CYAN}3.${NC} Guárdalo en ~/Downloads"
        echo -e "  ${CYAN}4.${NC} Vuelve a ejecutar este script"
        echo ""
        warn "Abriendo navegador..."
        xdg-open "https://code.visualstudio.com/download" 2>/dev/null
        return 1
    fi

    log "Instalador encontrado: $(basename "$INSTALLER")"

    case $PKG_MANAGER in
        apt)
            # dpkg instala el .deb, apt -f install resuelve dependencias faltantes
            sudo dpkg -i "$INSTALLER"
            sudo apt install -f -y
            ;;
        dnf)
            sudo dnf install -y "$INSTALLER"
            ;;
        pacman)
            warn "En Arch usa: yay -S visual-studio-code-bin"
            ;;
    esac

    success "VS Code instalado correctamente"
}

# -----------------------------------------------------------------------------
install_git() {
    section "Git + configuración SSH"
    log "Instalando Git..."

    case $PKG_MANAGER in
        apt)    sudo apt install -y git ;;
        dnf)    sudo dnf install -y git ;;
        pacman) sudo pacman -S --noconfirm git ;;
    esac

    # Pedir datos del usuario
    echo ""
    read -rp "  Nombre para Git (ej: Juan Pérez): " GIT_NAME
    read -rp "  Email para Git (mismo que GitHub): " GIT_EMAIL
    echo ""

    git config --global user.name "$GIT_NAME"
    git config --global user.email "$GIT_EMAIL"
    git config --global init.defaultBranch main
    git config --global pull.rebase false

    # Generar clave SSH solo si no existe
    SSH_KEY="$HOME/.ssh/id_ed25519"
    if [ ! -f "$SSH_KEY" ]; then
        log "Generando clave SSH..."
        # -N "" = sin passphrase (puedes cambiar esto)
        ssh-keygen -t ed25519 -C "$GIT_EMAIL" -f "$SSH_KEY" -N ""
        eval "$(ssh-agent -s)"
        ssh-add "$SSH_KEY"
    else
        warn "Ya existe clave SSH en $SSH_KEY — no se generó una nueva"
    fi

    echo ""
    warn "Copia esta clave pública en GitHub → Settings → SSH Keys:"
    echo "  ────────────────────────────────────────"
    cat "${SSH_KEY}.pub"
    echo "  ────────────────────────────────────────"
    echo ""
    log "Para verificar conexión con GitHub: ssh -T git@github.com"

    success "Git configurado para $GIT_NAME <$GIT_EMAIL>"
}

# -----------------------------------------------------------------------------
install_docker() {
    section "Docker"
    log "Iniciando instalación de Docker..."

    case $PKG_MANAGER in
        apt)
            sudo apt install -y ca-certificates curl
            sudo install -m 0755 -d /etc/apt/keyrings
            curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
                | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
            sudo chmod a+r /etc/apt/keyrings/docker.gpg
            echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.gpg] \
                https://download.docker.com/linux/ubuntu \
                $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
                | sudo tee /etc/apt/sources.list.d/docker.list
            sudo apt update
            sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
            ;;
        dnf)
            sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
            sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
            ;;
        pacman)
            sudo pacman -S --noconfirm docker docker-compose
            ;;
    esac

    sudo systemctl enable --now docker
    sudo usermod -aG docker "$USER"

    success "Docker instalado"
    warn "Reinicia sesión para usar Docker sin sudo"
}

# -----------------------------------------------------------------------------
install_jetbrains() {
    section "JetBrains Toolbox"
    log "Buscando instalador de JetBrains Toolbox..."

    INSTALLER=$(find ~/Downloads -name "jetbrains-toolbox-*.tar.gz" 2>/dev/null | head -1)

    if [ -z "$INSTALLER" ]; then
        warn "Instalador no encontrado en ~/Downloads"
        echo ""
        echo -e "  ${CYAN}1.${NC} Descarga desde: https://www.jetbrains.com/toolbox-app/"
        echo -e "  ${CYAN}2.${NC} Guarda el .tar.gz en ~/Downloads"
        echo -e "  ${CYAN}3.${NC} Vuelve a ejecutar este script"
        echo ""
        xdg-open "https://www.jetbrains.com/toolbox-app/" 2>/dev/null
        return 1
    fi

    log "Instalador encontrado: $(basename "$INSTALLER")"

    sudo tar -xzf "$INSTALLER" -C /opt/
    sudo mv /opt/jetbrains-toolbox-* /opt/jetbrains-toolbox
    sudo chown -R "$USER":"$USER" /opt/jetbrains-toolbox

    # Symlink para acceso desde terminal
    sudo ln -sf /opt/jetbrains-toolbox/jetbrains-toolbox /usr/local/bin/jetbrains-toolbox

    success "JetBrains Toolbox instalado"
    warn "Ejecuta 'jetbrains-toolbox' para instalar WebStorm, CLion, etc."
}

# -----------------------------------------------------------------------------
install_nodejs() {
    section "Node.js (via nvm)"
    log "Verificando nvm..."

    # nvm no se detecta con command -v porque es una función de shell, no un binario
    # Por eso verificamos si existe el directorio de instalación
    if [ ! -d "$HOME/.nvm" ]; then
        log "Instalando nvm..."
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash
    else
        warn "nvm ya está instalado"
    fi

    # Cargar nvm en el proceso actual del script
    # \. es equivalente a source pero más portable
    export NVM_DIR="$HOME/.nvm"
    \. "$NVM_DIR/nvm.sh"

    log "Instalando Node.js LTS..."
    nvm install --lts
    nvm use --lts

    node -v
    npm -v

    success "Node.js instalado correctamente"
    warn "Abre una terminal nueva para que nvm funcione automáticamente"
}

# -----------------------------------------------------------------------------
install_vite_react() {
    section "Vite + React (scaffolding)"
    log "Verificando dependencias para Vite/React..."

    if ! command -v node &>/dev/null; then
        warn "Node.js no está instalado."
        read -rp "  ¿Instalar Node.js ahora? [s/N]: " confirm
        if [[ "$confirm" =~ ^[sS]$ ]]; then
            install_nodejs
        else
            error "Instala Node.js primero. Abortando."
            return 1
        fi
    fi

    # Vite se usa via npx, no necesita instalación global
    # Solo verificamos que npm funcione
    npm install -g vite

    success "Vite instalado globalmente"
    log "Crear proyecto nuevo: npx create-vite@latest mi-proyecto --template react"
}

# -----------------------------------------------------------------------------
install_matlab() {
    section "MATLAB"
    log "Buscando instalador de MATLAB..."

    # MATLAB descarga un .zip o instalador directo
    INSTALLER=$(find ~/Downloads -name "matlab_*.zip" -o -name "Matlab_*" 2>/dev/null | head -1)

    if [ -z "$INSTALLER" ]; then
        warn "Instalador no encontrado en ~/Downloads"
        echo ""
        echo -e "  ${CYAN}1.${NC} Crea cuenta en:  https://www.mathworks.com/login"
        echo -e "  ${CYAN}2.${NC} Descarga desde:  https://www.mathworks.com/downloads"
        echo -e "  ${CYAN}3.${NC} Guarda el instalador en ~/Downloads"
        echo -e "  ${CYAN}4.${NC} Vuelve a ejecutar este script"
        echo ""
        xdg-open "https://www.mathworks.com/downloads" 2>/dev/null
        return 1
    fi

    log "Instalador encontrado: $(basename "$INSTALLER")"

    # Descomprimir y ejecutar instalador
    TMPDIR=$(mktemp -d)
    unzip -q "$INSTALLER" -d "$TMPDIR"
    chmod +x "$TMPDIR/install"
    sudo "$TMPDIR/install"

    # Crear entrada en el menú de aplicaciones
    # Se usa cat con heredoc — todo entre EOF es texto literal que se escribe al archivo
    cat > ~/.local/share/applications/matlab.desktop << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=MATLAB
Comment=Scientific computing environment
Exec=/usr/local/bin/matlab -desktop
Icon=/usr/local/MATLAB/R2025b/toolbox/shared/dastudio/resources/Matlab_Logo_64.png
Terminal=false
Categories=Development;Science;Mathematics;
EOF

    # Acceso a puertos serie (para hardware con MATLAB)
    sudo usermod -aG dialout "$USER"

    # Limpiar archivos temporales
    rm -rf "$TMPDIR"

    success "MATLAB instalado"
    warn "Reinicia sesión para que los permisos de grupo surtan efecto"
}

# =============================================================================
# MENÚ
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
    echo -e "  ${GREEN}5)${NC} Node.js          — Runtime JavaScript (via nvm)"
    echo -e "  ${GREEN}6)${NC} Vite + React     — Scaffolding frontend"
    echo -e "  ${GREEN}7)${NC} MATLAB           — Numerical computing (requiere descarga)"
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
