#!/bin/bash

# 🎨 Cores
VERDE='\033[0;32m'
AMARELO='\033[1;33m'
VERMELHO='\033[0;31m'
CIANO='\033[0;36m'
RESET='\033[0m'

DESTINO="/var/scripts/nextcloud_docker"
REPO_BASE="https://raw.githubusercontent.com/Dieguim25/nextcloud-docker-scripts/main"

echo -e "${CIANO}🔍 Verificando diretório de destino...${RESET}"

if [ ! -d "$DESTINO" ]; then
  echo -e "${AMARELO}📁 Diretório $DESTINO não existe. Criando...${RESET}"
  sudo mkdir -p "$DESTINO"
  sudo chown "$USER":"$USER" "$DESTINO"
else
  echo -e "${VERDE}✅ Diretório $DESTINO já existe.${RESET}"
fi

cd "$DESTINO" || exit 1

SCRIPTS=("setup.sh" "backup.sh" "update.sh")

for script in "${SCRIPTS[@]}"; do
  echo -e "${CIANO}⬇️ Baixando $script...${RESET}"
  curl -fsSL "$REPO_BASE/$script" -o "$script"
  if [ $? -ne 0 ]; then
    echo -e "${VERMELHO}❌ Falha ao baixar $script. Verifique se ele existe no repositório.${RESET}"
    exit 1
  fi
  chmod +x "$script"
done

echo -e "${CIANO}🚀 Executando setup.sh...${RESET}"
./setup.sh
