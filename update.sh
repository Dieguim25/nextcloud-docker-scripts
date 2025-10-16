#!/bin/bash

# 🎨 Cores
VERDE='\033[0;32m'
AMARELO='\033[1;33m'
CIANO='\033[0;36m'
RESET='\033[0m'

# Carrega variáveis do .env
source /var/scripts/nextcloud_docker/.env

echo -e "${CIANO}🔍 Verificando atualizações da imagem Nextcloud...${RESET}"
docker pull nextcloud

echo -e "${CIANO}🧹 Parando containers...${RESET}"
docker-compose down

echo -e "${CIANO}🚀 Subindo containers atualizados...${RESET}"
docker-compose up -d

echo -e "${CIANO}⏳ Aguardando Nextcloud iniciar...${RESET}"
sleep 45

echo -e "${CIANO}🛠️ Aplicando atualizações internas...${RESET}"
docker exec -u www-data nextcloud-app php occ upgrade

echo -e "${VERDE}✅ Atualização concluída com sucesso!${RESET}"

# Notificação interna para o grupo adm
docker exec -u www-data nextcloud-app php occ notification:generate adm "✅ Nextcloud foi atualizado com sucesso via update.sh em $(date +'%d/%m/%Y às %H:%M')"
