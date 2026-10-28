#!/usr/bin/env bash
# ==============================================================================
# backup_foodstore.sh
# Proyecto: FoodStore — UTN FRM (Lucas Avila)
# Descripción: Respaldo lógico custom (-Fc) automatizable.
# ==============================================================================

set -euo pipefail

# Parámetros de base de datos
PG_HOST="localhost"
PG_PORT="5432"
PG_DB="foodstore"
PG_USER="postgres"
PG_DUMP=$(which pg_dump || echo "/usr/bin/pg_dump")

# Rutas de directorios
SCRIPT_DIR=$(dirname "$(realpath "$0")")
BACKUP_DIR="${SCRIPT_DIR}/backups"
LOG_DIR="${SCRIPT_DIR}/logs"

mkdir -p "$BACKUP_DIR" "$LOG_DIR"

# Nombres dinámicos con fecha
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
DUMP_FILE="${BACKUP_DIR}/respaldo_${PG_DB}_${TIMESTAMP}.dump"
LOG_FILE="${LOG_DIR}/backup_log_${TIMESTAMP}.txt"

# Función de registro (log)
log_msg() {
    local MSG=$1
    local LEVEL=${2:-INFO}
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] [$LEVEL] $MSG" | tee -a "$LOG_FILE"
}

log_msg "Iniciando respaldo de la base de datos '$PG_DB'."
log_msg "Destino: $DUMP_FILE"

if ! command -v "$PG_DUMP" >/dev/null 2>&1; then
    log_msg "Ejecutable pg_dump no encontrado en el sistema." "ERROR"
    exit 1
fi

# Ejecución (la autenticación usa ~/.pgpass de forma transparente)
if $PG_DUMP -h "$PG_HOST" -p "$PG_PORT" -U "$PG_USER" -Fc -f "$DUMP_FILE" "$PG_DB" 2>> "$LOG_FILE"; then
    FILE_SIZE=$(du -k "$DUMP_FILE" | cut -f1)
    log_msg "Respaldo generado con éxito."
    log_msg "Tamaño final: ${FILE_SIZE} KB"
    log_msg "Ruta absoluta: $DUMP_FILE"
else
    EXIT_CODE=$?
    log_msg "pg_dump reportó un error (Código $EXIT_CODE)." "ERROR"
    log_msg "El respaldo ha fallado." "ERROR"
    exit $EXIT_CODE
fi
