#!/bin/bash

# 🎨 Cores
VERDE='\033[0;32m'
AMARELO='\033[1;33m'
CIANO='\033[0;36m'
RESET='\033[0m'

# Carrega variáveis do .env
source /var/scripts/nextcloud_docker/.env

# Gera timestamp
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Caminhos
DB_BACKUP="${USER_DATA_PATH}/db_backup_${TIMESTAMP}.sql"
DATA_BACKUP="${USER_DATA_PATH}/ncdata_backup_${TIMESTAMP}.tar.gz"

echo -e "${CIANO}🗄️ Gerando backup do banco de dados...${RESET}"
docker exec nextcloud-db sh -c 'exec mysqldump -uroot -p"$MYSQL_ROOT_PASSWORD" nextcloud' > "$DB_BACKUP"

echo -e "${CIANO}📦 Compactando dados do Nextcloud...${RESET}"
tar -czf "$DATA_BACKUP" -C "$USER_DATA_PATH" .

echo -e "${VERDE}✅ Backup concluído:${RESET}"
echo -e "${VERDE}📁 Banco: $DB_BACKUP${RESET}"
echo -e "${VERDE}📁 Dados: $DATA_BACKUP${RESET}"

# Notificação (exemplo)
docker exec -u www-data nextcloud-app php occ notification:generate adm "Backup concluído em $TIMESTAMP"
