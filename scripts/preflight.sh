#!/bin/bash
# =============================================================================
# preflight.sh — Verificaciones y guía antes de instalar
#
# USO: importar con source desde install.sh o cualquier script
#   source "$(dirname "$0")/scripts/preflight.sh"
#
# Provee:
#   preflight_check   → muestra instrucciones y verifica requisitos mínimos
#   wait_for_file     → espera activamente hasta que el usuario descargue un archivo
# =============================================================================

source "$(dirname "${BASH_SOURCE[0]}")/detect-os.sh"

# =============================================================================
# ESPERA ACTIVA — responde tu pregunta 3
# =============================================================================
#
# Uso dentro de cualquier función de instalación:
#
#   INSTALLER=$(wait_for_file ~/Downloads "st-stm32cubeide_*.sh" "STM32CubeIDE")
#
# El script queda en loop revisando cada 5 segundos si el archivo apareció.
# El usuario puede descargar en el navegador mientras tanto.
# Cuando aparece, la función retorna la ruta del archivo.

wait_for_file() {
    local SEARCH_DIR="$1"
    local PATTERN="$2"
    local APP_NAME="$3"

    echo "" >&2
    echo -e "  ${YELLOW}⏳ Esperando descarga de ${BOLD}$APP_NAME${NC}${YELLOW}...${NC}" >&2
    echo -e "  Descarga el archivo y guárdalo en: ${CYAN}$SEARCH_DIR${NC}" >&2
    echo -e "  El script detectará automáticamente cuando aparezca." >&2
    echo -e "  Presiona ${RED}Ctrl+C${NC} para cancelar.\n" >&2

    local FOUND=""
    local DOTS=0

    while true; do
        FOUND=$(find "$SEARCH_DIR" -name "$PATTERN" 2>/dev/null | head -1)

        if [ -n "$FOUND" ]; then
            echo "" >&2
            success "Archivo detectado: $(basename "$FOUND")"
            echo "$FOUND"   # ← único echo sin >&2 — este es el return value
            return 0
        fi

        printf "\r  ${CYAN}Buscando%-*s${NC}" $((DOTS % 4 + 1)) "..." >&2
        DOTS=$((DOTS + 1))
        sleep 5
    done
}

extract() {
    local FILE="$1"
    local APP_NAME="$2"

    # Crear directorio temporal único para esta app
    # mktemp -d crea /tmp/algo-XXXXXX donde X son caracteres aleatorios
    local TMPDIR
    TMPDIR=$(mktemp -d -t "${APP_NAME}-XXXXXX")

    #log "Extrayendo $(basename "$FILE") en $TMPDIR..."
    echo "Extrayendo $(basename "$FILE")..." >&2
    case "$FILE" in
        *.zip)
            unzip -q "$FILE" -d "$TMPDIR"
            ;;
        *.tar.gz)
            tar -xzf "$FILE" -C "$TMPDIR"
            ;;
        *.tar.xz)
            tar -xJf "$FILE" -C "$TMPDIR"
            ;;
        *.tar.bz2)
            tar -xjf "$FILE" -C "$TMPDIR"
            ;;
        *.sh | *.run)
            # No se extrae — solo se prepara para ejecutar
            chmod +x "$FILE"
            # Retornar la ruta del archivo original, no del tmpdir
            echo "$FILE"
            return 0
            ;;
        *.deb)
            # No se extrae — dpkg lo instala directo
            echo "$FILE"
            return 0
            ;;
        *)
            error "Formato no reconocido: $(basename "$FILE")"
            rm -rf "$TMPDIR"
            return 1
            ;;
    esac

    # Retornar la ruta del directorio extraído
    # El caller usa esto para saber dónde trabajar
    echo "$TMPDIR"
}

post_install() {
    section "Post-instalación"
    log "Consolidando permisos de grupo..."

    sudo usermod -aG docker    "$USER" 2>/dev/null
    sudo usermod -aG dialout   "$USER" 2>/dev/null
    sudo usermod -aG plugdev   "$USER" 2>/dev/null
    sudo usermod -aG wireshark "$USER" 2>/dev/null

    echo ""
    success "Instalación completada."
    warn "Cierra sesión UNA VEZ para activar todos los permisos USB y de grupo."
    warn "Después de eso todo funcionará sin sudo."
    echo ""
    section "Verificaciones pendientes"
    log "Ejecuta estos comandos en una terminal nueva para verificar:"
    echo ""
    echo -e "  ${CYAN}pdflatex --version${NC}     — verificar LaTeX"
    echo -e "  ${CYAN}arm-none-eabi-gcc --version${NC} — verificar ARM GCC"
    echo -e "  ${CYAN}docker run hello-world${NC} — verificar Docker"
    echo -e "  ${CYAN}arduino-ide${NC}            — verificar Arduino IDE"
    echo -e "  ${CYAN}kicad${NC}                  — verificar KiCad"
    echo ""
}
# =============================================================================
# PREFLIGHT CHECK — responde tu pregunta 2
# =============================================================================
#
# Muestra instrucciones antes de empezar y verifica requisitos mínimos.
# Se llama desde install.sh antes de mostrar el menú principal.

preflight_check() {
    clear
    echo -e "${BOLD}${BLUE}"
    echo "  ╔══════════════════════════════════════════════════╗"
    echo "  ║     Dotfiles —  Linux Embedded Environment       ║"
    echo "  ║     by Obviousfancy · UNIT Electronics           ║"
    echo "  ╚══════════════════════════════════════════════════╝"
    echo -e "${NC}"

    print_os_info

    section "Antes de empezar — lee esto"

    echo -e "  ${BOLD}Algunas herramientas requieren descarga manual${NC}"
    echo -e "  porque necesitan cuenta o licencia del fabricante."
    echo -e "  Descárgalas ANTES de ejecutar los scripts:"
    echo ""
    echo -e "  ${YELLOW}┌─ Descargas manuales necesarias ──────────────────────┐${NC}"
    echo -e "  ${YELLOW}│${NC}                                                      ${YELLOW}│${NC}"
    echo -e "  ${YELLOW}│${NC}  ${CYAN}STM32CubeIDE${NC} (.sh)                                 ${YELLOW}│${NC}"
    echo -e "  ${YELLOW}│${NC}  → st.com/en/development-tools/stm32cubeide.html     ${YELLOW}│${NC}"
    echo -e "  ${YELLOW}│${NC}                                                      ${YELLOW}│${NC}"
    echo -e "  ${YELLOW}│${NC}  ${CYAN}MATLAB${NC} (.zip)                                       ${YELLOW}│${NC}"
    echo -e "  ${YELLOW}│${NC}  → mathworks.com/downloads                           ${YELLOW}│${NC}"
    echo -e "  ${YELLOW}│${NC}                                                      ${YELLOW}│${NC}"
    echo -e "  ${YELLOW}│${NC}  ${CYAN}Vivado${NC} (.tar.gz)                                    ${YELLOW}│${NC}"
    echo -e "  ${YELLOW}│${NC}  → xilinx.com/support/download.html                 ${YELLOW}│${NC}"
    echo -e "  ${YELLOW}│${NC}                                                      ${YELLOW}│${NC}"
    echo -e "  ${YELLOW}│${NC}  ${CYAN}VS Code${NC} (.deb)                                      ${YELLOW}│${NC}"
    echo -e "  ${YELLOW}│${NC}  → code.visualstudio.com/download                   ${YELLOW}│${NC}"
    echo -e "  ${YELLOW}│${NC}                                                      ${YELLOW}│${NC}"
    echo -e "  ${YELLOW}│${NC}  ${CYAN}JetBrains Toolbox${NC} (.tar.gz)                         ${YELLOW}│${NC}"
    echo -e "  ${YELLOW}│${NC}  → jetbrains.com/toolbox-app                        ${YELLOW}│${NC}"
    echo -e "  ${YELLOW}│${NC}                                                      ${YELLOW}│${NC}"
    echo -e "  ${YELLOW}│${NC}  ${GREEN}Guarda todos los archivos en ~/Downloads${NC}            ${YELLOW}│${NC}"
    echo -e "  ${YELLOW}│${NC}  ${GREEN}Los scripts los detectan automáticamente${NC}            ${YELLOW}│${NC}"
    echo -e "  ${YELLOW}│${NC}                                                      ${YELLOW}│${NC}"
    echo -e "  ${YELLOW}└──────────────────────────────────────────────────────┘${NC}"
    echo ""
    echo -e "  ${GREEN}Las demás herramientas (KiCad, ARM GCC, Docker, etc.)${NC}"
    echo -e "  ${GREEN}se instalan automáticamente — no necesitas hacer nada.${NC}"
    echo ""

    read -rp "  Presiona Enter cuando estés listo para continuar..." _
    echo ""
}
