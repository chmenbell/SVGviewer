#version v0.0.2

#!/bin/bash

# Importar configuraciones si es necesario
source $(dirname "$0")/config.sh

# Funciones de utilidad
error() { 
    echo -e "${RED}[ERROR] $1${NC}" | tee -a $LOG_FILE
    exit 1 
}

success() { 
    echo -e "${GREEN}[ÉXITO] $1${NC}" | tee -a $LOG_FILE 
}

warning() { 
    echo -e "${YELLOW}[ADVERTENCIA] $1${NC}" | tee -a $LOG_FILE 
}

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> $LOG_FILE
}

# Verificar root
check_root() {
    [ $(id -u) -ne 0 ] && error "Ejecutar como root: sudo $0"
}

check_module() {
    if [ ! -f "$1" ]; then
        error "Módulo no encontrado: $1"
    fi
}

# Instalar paquete si no existe
install_package() {
    if ! dpkg -l | grep -q "^ii  $1 "; then
        apt install -y "$1" || error "Error instalando $1"
    fi
}

#Validar IP
validate_ip() {
    if [[ ! $SERVER_IP =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        error "IP del servidor no válida: $SERVER_IP"
    fi
}

# Crear directorio con permisos
setup_directories() {
    log "Creando estructura de directorios..."
    mkdir -p ${INSTALL_DIR}/{backend,frontend,media/uploads,media/conversions,static,templates} || error "Error creando directorios"
    chown -R www-data:www-data ${MEDIA_DIR}
    chmod -R 775 ${MEDIA_DIR}
    success "Directorios creados"
}

# Configurar entorno virtual Python
setup_python_venv() {
    python3 -m venv "$1" || error "Error creando venv"
    source "$1/bin/activate" || error "Error activando venv"
}