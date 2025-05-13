#Version v0.0.2

#!/bin/bash

# Importar funciones y configuración
source $(dirname "$0")/functions.sh
source $(dirname "$0")/config.sh

source $(dirname "$0")/../functions.sh

configure_services() {
    log "Configurando servicios systemd..."
    
    cp $(dirname "$0")/../templates/backend.service /etc/systemd/system/${APP_NAME}-backend.service
    cp $(dirname "$0")/../templates/frontend.service /etc/systemd/system/${APP_NAME}-frontend.service

    systemctl daemon-reload
    systemctl enable ${APP_NAME}-backend.service
    systemctl enable ${APP_NAME}-frontend.service
    systemctl start ${APP_NAME}-backend.service
    systemctl start ${APP_NAME}-frontend.service

    # Configurar firewall
    ufw allow 80
    ufw allow 443
    ufw allow ssh
    ufw --force enable
    
    success "Servicios configurados"
}

configure_services