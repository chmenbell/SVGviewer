#verion v0.0.1

#!/bin/bash
# Obtener directorio base del instalador
INSTALLER_DIR=$(dirname "$(readlink -f "$0")")
source "$INSTALLER_DIR/functions.sh" || error "No se pudo cargar functions.sh"
source "$INSTALLER_DIR/config.sh" || error "No se pudo cargar config.sh"

configure_postgresql() {
    log "Configurando PostgreSQL..."
    
    sudo -u postgres psql -c "CREATE DATABASE ${DB_NAME};" || warning "BD ya existe"
    sudo -u postgres psql -c "CREATE USER ${DB_USER} WITH PASSWORD '${DB_PASSWORD}';" || warning "Usuario ya existe"
    sudo -u postgres psql -c "ALTER USER ${DB_USER} CREATEDB;"
    sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE ${DB_NAME} TO ${DB_USER};"
    sudo -u postgres psql -d ${DB_NAME} -c "GRANT ALL ON SCHEMA public TO ${DB_USER};"
    
    success "PostgreSQL configurado"
}

configure_postgresql