#!/bin/bash

# 🎨 Cores
VERDE='\033[0;32m'
AMARELO='\033[1;33m'
VERMELHO='\033[0;31m'
CIANO='\033[0;36m'
RESET='\033[0m'
echo -e "${CIANO}🔍 Verificando dependências...${RESET}"

# Verifica e instala Docker
if ! command -v docker &> /dev/null; then
  echo -e "${AMARELO}⚠️ Docker não encontrado. Instalando...${RESET}"
  sudo apt update
  sudo apt install -y docker.io
  sudo systemctl enable --now docker
else
  echo -e "${VERDE}✅ Docker já está instalado.${RESET}"
fi

# Verifica e instala Docker Compose
if ! command -v docker-compose &> /dev/null; then
  echo -e "${AMARELO}⚠️ Docker Compose não encontrado. Instalando...${RESET}"
  sudo apt install -y docker-compose
else
  echo -e "${VERDE}✅ Docker Compose já está instalado.${RESET}"
fi
# Define comando Compose compatível
if command -v docker compose &> /dev/null; then
  COMPOSE_CMD="docker compose"
else
  COMPOSE_CMD="docker-compose"
fi

# Verifica se o whiptail está instalado
if ! command -v whiptail &> /dev/null; then
  echo -e "${AMARELO}📦 Instalando whiptail...${RESET}"
  sudo apt update && sudo apt install -y whiptail
fi

USE_EXISTING_ENV=false
if [ -f .env ]; then
  echo -e "${AMARELO}⚠️ Arquivo .env detectado.${RESET}"
  if whiptail --yesno "Deseja usar os dados existentes do arquivo .env?" 12 60 --title "Usar .env existente" 3>&1 1>&2 2>&3; then
    source .env
    USE_EXISTING_ENV=true
  else
    rm .env
  fi
fi

if [ "$USE_EXISTING_ENV" = false ]; then
  MYSQL_ROOT_PASSWORD=$(openssl rand -hex 16)
  MYSQL_PASSWORD=$(openssl rand -hex 16)

  while true; do
    USER_DATA_PATH=$(whiptail --inputbox "Digite o caminho para os dados dos usuários:" 10 60 "/mnt/ncdata" --title "Caminho dos Dados" 3>&1 1>&2 2>&3)
    if (whiptail --yesno "Você digitou: ${USER_DATA_PATH}\nEstá correto?" 10 60 --title "Confirmar Caminho" 3>&1 1>&2 2>&3); then
      break
    fi
  done

  echo -e "${CIANO}📝 Criando .env...${RESET}"
  cat <<EOF > .env
MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD
MYSQL_PASSWORD=$MYSQL_PASSWORD
USER_DATA_PATH=$USER_DATA_PATH
EOF
fi

# Verifica se a pasta contém dados
if [ "$(ls -A "$USER_DATA_PATH" 2>/dev/null)" ]; then
  echo -e "${AMARELO}⚠️ A pasta $USER_DATA_PATH contém arquivos.${RESET}"
  if whiptail --yesno "Deseja continuar usando essa pasta?" 12 60 --title "Dados existentes" 3>&1 1>&2 2>&3; then
    if whiptail --yesno "Deseja fazer um backup da pasta antes de continuar?" 10 60 --title "Backup recomendado" 3>&1 1>&2 2>&3; then
      BACKUP_PATH="${USER_DATA_PATH}_backup_$(date +%Y%m%d_%H%M%S)"
      sudo cp -r "$USER_DATA_PATH" "$BACKUP_PATH"
      echo -e "${VERDE}📦 Backup criado em: $BACKUP_PATH${RESET}"
    fi
  else
    echo -e "${VERMELHO}🛑 Instalação cancelada.${RESET}"
    exit 1
  fi
else
  sudo mkdir -p "$USER_DATA_PATH"
  sudo chown -R 33:33 "$USER_DATA_PATH"
fi

# Restauração de banco
LATEST_DB_BACKUP=$(ls "$USER_DATA_PATH"/db_backup_*.sql 2>/dev/null | sort | tail -n 1)
if [ -f "$LATEST_DB_BACKUP" ]; then
  echo -e "${AMARELO}🗄️ Backup de banco detectado: $(basename "$LATEST_DB_BACKUP")${RESET}"
  if whiptail --yesno "Deseja restaurar esse backup do banco de dados?" 10 60 --title "Restaurar banco" 3>&1 1>&2 2>&3; then
    docker exec -i nextcloud-db sh -c 'exec mysql -uroot -p"$MYSQL_ROOT_PASSWORD"' < "$LATEST_DB_BACKUP"
    echo -e "${VERDE}✅ Banco restaurado.${RESET}"
  fi
fi

# Usuário admin
while true; do
  ADMIN_USER=$(whiptail --inputbox "Nome do usuário administrador:" 10 60 "admin" --title "Usuário Admin" 3>&1 1>&2 2>&3)
  if (whiptail --yesno "Você digitou: ${ADMIN_USER}\nEstá correto?" 10 60 --title "Confirmar Usuário" 3>&1 1>&2 2>&3); then
    break
  fi
done

while true; do
  ADMIN_PASS=$(whiptail --inputbox "Digite a senha para ${ADMIN_USER}:" 10 60 --title "Senha Admin" 3>&1 1>&2 2>&3)

  # Mostra a senha digitada e pede confirmação
  if (whiptail --yesno "Você digitou a senha:\n\n${ADMIN_PASS}\n\nDeseja continuar com essa senha?" 12 60 --title "Confirmar Senha" 3>&1 1>&2 2>&3); then
    break
  fi
done


export OC_PASS="$ADMIN_PASS"

echo -e "${CIANO}🐳 Subindo containers...${RESET}"
docker-compose build
docker-compose up -d

echo -e "${CIANO}⏳ Aguardando Nextcloud iniciar...${RESET}"
sleep 45

echo -e "${CIANO}👤 Criando usuário administrador...${RESET}"
docker exec -u www-data nextcloud-app php occ user:add --password-from-env "$ADMIN_USER"
docker exec -u www-data nextcloud-app php occ group:add adm
docker exec -u www-data nextcloud-app php occ group:adduser adm "$ADMIN_USER"
unset OC_PASS

# Escolha do timezone
TIMEZONE=$(whiptail --title "Fuso horário do servidor Nextcloud" --menu "Escolha o timezone:" 15 60 6 \
"America/Sao_Paulo" "Brasil (padrão)" \
"America/Fortaleza" "Nordeste" \
"America/Manaus" "Amazonas" \
"America/Recife" "Pernambuco" \
"America/Belem" "Pará" \
"America/Cuiaba" "Centro-Oeste" \
3>&1 1>&2 2>&3)

if [ -z "$TIMEZONE" ]; then
  TIMEZONE="America/Sao_Paulo"
  echo -e "${AMARELO}⚠️ Nenhum timezone escolhido. Usando padrão: $TIMEZONE${RESET}"
else
  echo -e "${VERDE}🌍 Timezone selecionado: $TIMEZONE${RESET}"
fi

docker exec -u www-data nextcloud-app php occ config:system:set default_timezone --value="$TIMEZONE"

echo -e "${CIANO}📦 Instalando apps de preview...${RESET}"
docker exec -u www-data nextcloud-app php occ app:install previewgenerator
docker exec -u www-data nextcloud-app php occ app:enable previewgenerator
docker exec -u www-data nextcloud-app php occ app:install video_player
docker exec -u www-data nextcloud-app php occ app:enable video_player

echo -e "${CIANO}⚙️ Configurando previews...${RESET}"
docker exec -u www-data nextcloud-app php occ config:system:set preview_max_x --value="2048"
docker exec -u www-data nextcloud-app php occ config:system:set preview_max_y --value="2048"
docker exec -u www-data nextcloud-app php occ config:system:set enabledPreviewProviders 0 --value="OC\\Preview\\Image"
docker exec -u www-data nextcloud-app php occ config:system:set enabledPreviewProviders 1 --value="OC\\Preview\\Movie"
docker exec -u www-data nextcloud-app php occ config:system:set enabledPreviewProviders 2 --value="OC\\Preview\\MP4"
docker exec -u www-data nextcloud-app php occ config:system:set enabledPreviewProviders 3 --value="OC\\Preview\\TXT"
docker exec -u www-data nextcloud-app php occ config:system:set enabledPreviewProviders 4 --value="OC\\Preview\\MarkDown"

echo -e "${CIANO}🖼️ Gerando miniaturas iniciais...${RESET}"
docker exec -u www-data nextcloud-app php occ preview:generate-all -vvv

echo -e "${CIANO}📅 Configurando agendamentos via cron...${RESET}"

# Comandos de agendamento
CRON_BACKUP="0 2 * * * /var/scripts/nextcloud_docker/backup.sh >> /var/log/nextcloud_backup.log 2>&1"
CRON_UPDATE="0 3 * * 0 /var/scripts/nextcloud_docker/update.sh >> /var/log/nextcloud_update.log 2>&1"

# Adiciona ao crontab se ainda não estiver presente
(crontab -l 2>/dev/null | grep -qF "$CRON_BACKUP") || (crontab -l 2>/dev/null; echo "$CRON_BACKUP") | crontab -
(crontab -l 2>/dev/null | grep -qF "$CRON_UPDATE") || (crontab -l 2>/dev/null; echo "$CRON_UPDATE") | crontab -

echo -e "${VERDE}✅ Agendamentos adicionados ao crontab:${RESET}"
echo -e "${VERDE}🕒 Backup diário às 2h${RESET}"
echo -e "${VERDE}🕒 Atualização semanal aos domingos às 3h${RESET}"

echo -e "${VERDE}✅ Setup concluído com sucesso!${RESET}"
