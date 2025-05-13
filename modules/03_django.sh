#Version v0.0.2
#set -x  # Activar modo debug
#!/bin/bash

# Obtener directorio base del instalador
INSTALLER_DIR=$(dirname "$(readlink -f "$0")")

# Importar funciones y configuración
source "$INSTALLER_DIR/functions.sh" || error "No se pudo cargar functions.sh"
source "$INSTALLER_DIR/config.sh" || error "No se pudo cargar config.sh"

configure_django() {
    log "Configurando Django..."
    
    # Verificar y crear directorio backend si no existe
    if [ ! -d "$BACKEND_DIR" ]; then
        log "Creando directorio backend en $BACKEND_DIR"
        mkdir -p "$BACKEND_DIR" || error "No se pudo crear directorio backend"
        chown www-data:www-data "$BACKEND_DIR"
        chmod 775 "$BACKEND_DIR"
    fi
    
    log "Accediendo a $BACKEND_DIR"
    cd "$BACKEND_DIR" || error "Error accediendo backend ($BACKEND_DIR)"
    
    python3 -m venv venv || error "Error creando venv"
    source venv/bin/activate || error "Error activando venv"

    pip install --upgrade pip || error "Error actualizando pip"
    pip install django djangorestframework psycopg2-binary python-dotenv vsdx svglib gunicorn python-magic || error "Error instalando dependencias"

    django-admin startproject core . || warning "Proyecto ya existe"
    django-admin startapp svgviewer || warning "App ya existe"

    # Verificar existencia de plantillas
    TEMPLATES_SOURCE="$INSTALLER_DIR/templates"
    if [ ! -d "$TEMPLATES_SOURCE" ]; then
        error "Directorio de plantillas no encontrado en $TEMPLATES_SOURCE"
    fi

    # Copiar plantillas con verificación
    copy_template() {
        local src="$TEMPLATES_SOURCE/$1"
        local dest="$2"
        
        if [ ! -f "$src" ]; then
            warning "Plantilla $1 no encontrada en $src"
            return 1
        fi
        
        mkdir -p "$(dirname "$dest")"
        cp "$src" "$dest" || warning "Error copiando $1 a $dest"
    }

    # Copiar archivos de configuración
    copy_template "settings.py" "core/settings.py"
    copy_template "urls.py" "core/urls.py"
    copy_template "models.py" "svgviewer/models.py"
    copy_template "views.py" "svgviewer/views.py"
    copy_template "login.html" "templates/registration/login.html"

    # Ejecutar migraciones
    python manage.py makemigrations --noinput || warning "Error en makemigrations"
    python manage.py migrate --noinput || warning "Error en migrate"

    # Crear superusuario
    echo "from django.contrib.auth import get_user_model; User = get_user_model(); User.objects.create_superuser('${ADMIN_USER}', 'admin@${APP_NAME}.com', '${ADMIN_PASSWORD}')" | python manage.py shell || warning "Superusuario ya existe"

    pip install django-cors-headers || error "Error instalando django-cors-headers"
    deactivate
    
    success "Backend Django configurado"
}

configure_django