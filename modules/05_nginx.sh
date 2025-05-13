#!/bin/bash

source $(dirname "$0")/../functions.sh
source $(dirname "$0")/../config.sh

configure_nginx() {
    log "Configurando Nginx..."
    
    mkdir -p /etc/nginx/ssl
    openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
      -keyout /etc/nginx/ssl/${APP_NAME}.key \
      -out /etc/nginx/ssl/${APP_NAME}.crt \
      -subj "/C=ES/ST=Madrid/L=Madrid/O=SVGViewer/CN=${DOMAIN}" || error "Error SSL"

    cp $(dirname "$0")/../templates/nginx.conf /etc/nginx/sites-available/${APP_NAME}
    ln -s /etc/nginx/sites-available/${APP_NAME} /etc/nginx/sites-enabled/
    rm -f /etc/nginx/sites-enabled/default
    systemctl restart nginx || error "Error reiniciando Nginx"
    
    success "Nginx configurado"
}

configure_nginx