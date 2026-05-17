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

source "$(dirname "$0")/scripts/detect-os.sh"

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
    local SEARCH_DIR="$1"   # Dónde buscar (ej: ~/Downloads)
    local PATTERN="$2"      # Nombre del archivo con wildcards (ej: "st-stm32*.sh")
    local APP_NAME="$3"     # Nombre para mostrar al usuario (ej: "STM32CubeIDE")

    echo ""
    echo -e "  ${YELLOW}⏳ Esperando descarga de ${BOLD}$APP_NAME${NC}${YELLOW}...${NC}"
    echo -e "  Descarga el archivo y guárdalo en: ${CYAN}$SEARCH_DIR${NC}"
    echo -e "  El script detectará automáticamente cuando aparezca."
    echo -e "  Presiona ${RED}Ctrl+C${NC} para cancelar.\n"

    local FOUND=""
    local DOTS=0

    # Loop infinito — sale cuando encuentra el archivo o el usuario cancela
    while true; do
        # Buscar el archivo con el patrón dado
        FOUND=$(find "$SEARCH_DIR" -name "$PATTERN" 2>/dev/null | head -1)

        if [ -n "$FOUND" ]; then
            echo ""
            success "Archivo detectado: $(basename "$FOUND")"
            # "echo" con la variable retorna el valor al caller via $()
            echo "$FOUND"
            return 0
        fi

        # Animación de puntos para que el usuario sepa que está activo
        printf "\r  ${CYAN}Buscando%-*s${NC}" $((DOTS % 4 + 1)) "..."
        DOTS=$((DOTS + 1))
        sleep 5
    done
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
    echo "  ║     Dotfiles — Entorno Embedded Linux            ║"
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
