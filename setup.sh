#!/bin/bash

# 🎨 Cores
VERDE='\033[0;32m'
AMARELO='\033[1;33m'
VERMELHO='\033[0;31m'
CIANO='\033[0;36m'
RESET='\033[0m'

echo -e "${CIANO}📁 Criando estrutura do projeto...${RESET}"

mkdir -p nextcloud-docker
cd nextcloud-docker

# Cria arquivos
echo -e "${CIANO}📄 Gerando arquivos...${RESET}"

# Dockerfile
cat <<'EOF' > Dockerfile
FROM nextcloud:latest
RUN apt-get update && \
    apt-get install -y ffmpeg imagemagick ghostscript && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
EOF

# docker-compose.yml
cat <<'EOF' > docker-compose.yml
version: '3.8'
services:
  db:
    image: mariadb:11
    container_name: nextcloud-db
    restart: always
    command: --transaction-isolation=READ-COMMITTED --binlog-format=ROW
    environment:
      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}
      MYSQL_PASSWORD: ${MYSQL_PASSWORD}
      MYSQL_DATABASE: nextcloud
      MYSQL_USER: nextcloud
      TZ: America/Sao_Paulo
    volumes:
      - db_data:/var/lib/mysql
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
      interval: 10s
      timeout: 5s
      retries: 5
  redis:
    image: redis:7
    container_name: nextcloud-redis
    restart: always
    volumes:
      - redis_data:/data
  app:
    build: .
    container_name: nextcloud-app
    restart: always
    ports:
      - 8080:80
    depends_on:
      db:
        condition: service_healthy
      redis:
        condition: service_started
    environment:
      MYSQL_PASSWORD: ${MYSQL_PASSWORD}
      MYSQL_DATABASE: nextcloud
      MYSQL_USER: nextcloud
      MYSQL_HOST: db
      REDIS_HOST: redis
      TZ: America/Sao_Paulo
      DEFAULT_PHONE_REGION: BR
      NEXTCLOUD_MAINTENANCE_WINDOW_START: 7
      PHP_MEMORY_LIMIT: 1024M
      PHP_UPLOAD_LIMIT: 15360M
    deploy:
      resources:
        limits:
          memory: 1024M
    volumes:
      - nextcloud_config:/var/www/html/config
      - ${USER_DATA_PATH}:/var/www/html/data
volumes:
  db_data:
  redis_data:
  nextcloud_config:
EOF

# Adiciona os scripts
cp /caminho/do/seu/setup.sh .
cp /caminho/do/seu/backup.sh .
cp /caminho/do/seu/update.sh .

# README.md
cat <<'EOF' > README.md
# 🚀 Nextcloud com Docker — Setup Automatizado
Este projeto configura um ambiente completo do Nextcloud com Docker, incluindo:
- Pré-visualização de imagens e vídeos
- Backup automático com notificação
- Atualização automática com verificação de versão
- Notificações internas para o grupo `adm`
...
EOF

# Compacta
cd ..
zip -r nextcloud-docker.zip nextcloud-docker

echo -e "${VERDE}✅ Projeto empacotado em nextcloud-docker.zip${RESET}"
