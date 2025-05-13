#version v0.0.2

#!/bin/bash

source $(dirname "$0")/../functions.sh
source $(dirname "$0")/../config.sh

configure_react() {
    log "Configurando React..."
    
    cd ${FRONTEND_DIR} || error "Error accediendo frontend"
    npm create vite@latest . -- --template react || warning "Proyecto ya existe"
    npm install || error "Error instalando npm"
    npm install --save-dev @svgr/webpack axios react-dropzone react-toastify js-cookie react-router-dom @mui/material @mui/icons-material @emotion/react @emotion/styled || error "Error instalando dependencias"

    # Copiar componentes React
    mkdir -p src/{components,context,pages}
    cp $(dirname "$0")/../templates/AuthContext.jsx src/context/AuthContext.jsx
    cp $(dirname "$0")/../templates/LoginPage.jsx src/pages/LoginPage.jsx
    cp $(dirname "$0")/../templates/SVGUploader.jsx src/components/SVGUploader.jsx
    cp $(dirname "$0")/../templates/App.jsx src/App.jsx
    cp $(dirname "$0")/../templates/App.css src/App.css

    npm run build || error "Error construyendo frontend"
    chown -R www-data:www-data ${FRONTEND_DIR}/dist
    chmod -R 775 ${FRONTEND_DIR}/dist
    
    success "Frontend React configurado"
}

configure_react