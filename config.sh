#version v0.0.2

#!/bin/bash

# Configuración de la aplicación
APP_NAME="svgviewer"
DOMAIN="localhost"
DB_NAME="svgviewer_db"
DB_USER="svgviewer_user"
DB_PASSWORD="svgviewer_pass123"
ADMIN_USER="admin"
ADMIN_PASSWORD="admin123"
SERVER_IP="192.168.0.201"

# Directorios
APP_DIR="/opt/${APP_NAME}"
BACKEND_DIR="${APP_DIR}/backend"
FRONTEND_DIR="${APP_DIR}/frontend"
MEDIA_DIR="${APP_DIR}/media"
STATIC_DIR="${APP_DIR}/static"
TEMPLATES_DIR="${APP_DIR}/templates"

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Configuración de logging
LOG_FILE="/var/log/svgviewer_install.log"

# Configuración de dependencias
REQUIRED_PACKAGES=(
    curl wget git build-essential libssl-dev libffi-dev
    python3-dev python3-pip python3-venv nodejs npm
    postgresql postgresql-contrib ufw fail2ban nginx
    openssl libxml2-dev libxslt-dev libmagic1
)

# Configuración de Python
PYTHON_DEPS=(
    django djangorestframework psycopg2-binary 
    python-dotenv vsdx svglib gunicorn 
    python-magic django-cors-headers
)

# Configuración de NPM
NPM_DEPS=(
    @svgr/webpack axios react-dropzone 
    react-toastify js-cookie react-router-dom 
    @mui/material @mui/icons-material @emotion/react 
    @emotion/styled
)