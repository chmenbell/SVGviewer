# Version v0.0.2

#!/bin/bash

# Obtener directorio base del instalador
INSTALLER_DIR=$(dirname "$(readlink -f "$0")")

# Importar funciones y configuración
source "$INSTALLER_DIR/functions.sh" || error "No se pudo cargar functions.sh"
source "$INSTALLER_DIR/config.sh" || error "No se pudo cargar config.sh"

install_dependencies() {
    log "Instalando dependencias del sistema..."
    
    # 1. Actualizar lista de paquetes con reintentos
    echo -e "${GREEN}Actualizando repositorios...${NC}"
    for i in {1..3}; do
        if apt update; then
            break
        elif [ $i -eq 3 ]; then
            warning "Error al actualizar repositorios después de 3 intentos (continuando)"
        else
            warning "Intento $i/3 fallado, reintentando en 5 segundos..."
            sleep 5
        fi
    done
    
    # 2. Manejar actualizaciones del sistema
    echo -e "${GREEN}Manejando actualizaciones del sistema...${NC}"
    upgradable=$(apt list --upgradable 2>/dev/null | wc -l)
    
    if [ $upgradable -gt 1 ]; then
        echo -e "${YELLOW}Hay $((upgradable-1)) actualizaciones disponibles${NC}"
        
        # Excluir paquetes problemáticos específicos
        problematic_packages=("open-vm-tools" "ubuntu-drivers-common" "docker.io")
        exclude_string=$(printf "!%s " "${problematic_packages[@]}")
        
        apt-mark hold "${problematic_packages[@]}" >/dev/null 2>&1
        apt upgrade -y --allow-downgrades --fix-broken --fix-missing $exclude_string || \
            warning "Algunas actualizaciones fallaron (continuando instalación)"
        apt-mark unhold "${problematic_packages[@]}" >/dev/null 2>&1
    else
        echo -e "${GREEN}El sistema ya está actualizado${NC}"
    fi
    
    # 3. Instalar paquetes esenciales
    echo -e "${GREEN}Instalando paquetes requeridos...${NC}"
    essential_packages=(
        curl wget git build-essential libssl-dev libffi-dev
        python3-dev python3-pip python3-venv nodejs npm
        postgresql postgresql-contrib ufw fail2ban nginx
        openssl libxml2-dev libxslt-dev libmagic1
    )
    
    apt install -y "${essential_packages[@]}" || error "Error instalando paquetes esenciales"
    
    success "Dependencias instaladas"
}

install_dependencies

# Verificar paquetes esenciales instalados
verify_installation() {
    local missing=()
    for pkg in "${essential_packages[@]}"; do
        if ! dpkg -l | grep -q "^ii  $pkg "; then
            missing+=("$pkg")
        fi
    done
    
    if [ ${#missing[@]} -ne 0 ]; then
        warning "Paquetes no instalados: ${missing[*]}"
        return 1
    fi
    return 0
}

verify_installation || warning "Algunos paquetes no se instalaron correctamente"