#!/bin/bash
#set -x  # Activar modo debug
#!/bin/bash

# Obtener directorio base del instalador
INSTALLER_DIR=$(dirname "$(readlink -f "$0")")

# Importar funciones y configuración
source "$INSTALLER_DIR/functions.sh" || error "No se pudo cargar functions.sh"
source "$INSTALLER_DIR/config.sh" || error "No se pudo cargar config.sh"

# Verificar root y validar IP
check_root
validate_ip

# Registrar inicio de instalación
log "Iniciando instalación de SVGViewer"

# Verificar módulos
MODULES=(
    "installer/modules/01_dependencies.sh"
    "installer/modules/02_postgresql.sh"
    "installer/modules/03_django.sh"
    "installer/modules/04_react.sh"
    "installer/modules/05_nginx.sh"
    "installer/modules/06_services.sh"
)

for module in "${MODULES[@]}"; do
    check_module "$module"
done

# Mostrar resumen de configuración
echo -e "${GREEN}Configuración de instalación:${NC}"
echo -e "Aplicación: ${YELLOW}${APP_NAME}${NC}"
echo -e "Directorio instalación: ${YELLOW}${APP_DIR}${NC}"
echo -e "IP Servidor: ${YELLOW}${SERVER_IP}${NC}"
echo -e "Usuario DB: ${YELLOW}${DB_USER}${NC}"
echo -e "Admin: ${YELLOW}${ADMIN_USER}/${ADMIN_PASSWORD}${NC}"
echo -e "Log: ${YELLOW}${LOG_FILE}${NC}"

# Preguntar confirmación
read -p "¿Continuar con la instalación? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
fi

# Crear estructura de directorios
setup_directories

# Ejecutar módulos de instalación
for module in "${MODULES[@]}"; do
    log "Ejecutando módulo: $module"
    source "$module"
done

# Finalización
success "¡Instalación completada con éxito!"
echo -e "Accede a: ${YELLOW}https://${SERVER_IP}${NC}"
echo -e "Credenciales admin: ${YELLOW}${ADMIN_USER}/${ADMIN_PASSWORD}${NC}"
log "Instalación completada correctamente"