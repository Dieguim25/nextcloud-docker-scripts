# 🚀 Scripts para Nextcloud com Docker

Este repositório contém scripts automatizados para instalar, manter e atualizar uma instância do Nextcloud utilizando Docker. Ideal para quem deseja uma solução autogerenciável, segura e com recursos avançados como backups, restauração e configuração regional.

---

## 📦 Scripts incluídos

- `setup.sh`: Instala e configura o ambiente Nextcloud com Docker, incluindo:
  - Criação do usuário administrador
  - Escolha interativa do fuso horário
  - Instalação de apps de visualização
  - Geração de miniaturas
  - Detecção e restauração de backups anteriores
  - Backup automático da pasta de dados

- `backup.sh`: Realiza backup completo dos dados e do banco de dados, com nomes padronizados e notificação para o grupo `adm`.

- `update.sh`: Verifica e aplica atualizações da imagem Nextcloud, notificando os administradores.

- `bootstrap_nextcloud.sh`: Script inicial que prepara o ambiente, baixa os demais scripts e executa o `setup.sh`.

---

## 🧰 Requisitos

- Linux com `curl`, `docker`, `docker-compose` e `whiptail` instalados
- Permissões de sudo para criação de diretórios e instalação de pacotes

---

## 🚀 Instalação automática

Execute o seguinte comando no terminal:

```bash
curl -fsSL https://raw.githubusercontent.com/Dieguim25/nextcloud-docker-scripts/main/bootstrap_nextcloud.sh | bash
```
Este comando irá:

Criar o diretório `/var/scripts/nextcloud_docker`

Baixar os scripts `setup.sh`, `backup.sh` e `update.sh`

Ajustar permissões de execução

Iniciar o processo de instalação interativa

🕒 Configuração de Fuso Horário:
Durante a instalação, o script setup.sh oferece uma interface interativa para escolher o fuso horário do servidor Nextcloud. Isso garante que todos os horários exibidos nos aplicativos (como Agenda, Atividades e Notificações) estejam alinhados com a região do usuário.

Timezones sugeridos:

America/Sao_Paulo (padrão)

America/Fortaleza

America/Manaus

America/Recife

America/Belem

America/Cuiaba

O valor escolhido é aplicado diretamente no Nextcloud via:

`docker exec -u www-data nextcloud-app php occ config:system:set default_timezone --value="America/Sao_Paulo"`

🔄 Restauração Automática de Backup:

Se a pasta de dados escolhida já contiver backups anteriores do banco de dados (formato db_backup_YYYYMMDD_HHMMSS.sql), o script detecta automaticamente e oferece a opção de restaurar antes de continuar a instalação.

Exemplo de restauração:

`docker exec -i nextcloud-db sh -c 'exec mysql -uroot -p"$MYSQL_ROOT_PASSWORD"' < db_backup_20251016_1015.sql`

📦 Padrão de nomes para backups:

Os backups gerados seguem uma nomenclatura padronizada para facilitar organização e restauração:

Banco de dados: db_backup_YYYYMMDD_HHMMSS.sql

Dados do Nextcloud: ncdata_backup_YYYYMMDD_HHMMSS.tar.gz

📣 Notificações:

Todos os scripts enviam notificações internas para os membros do grupo adm no Nextcloud, mantendo os administradores informados sobre:

Backups realizados

Atualizações aplicadas

Eventos críticos durante a instalação

🛡️ Segurança e persistência:

Os dados dos usuários são armazenados em volumes persistentes definidos pelo usuário

O banco de dados é protegido por senhas geradas automaticamente

O script detecta instalações anteriores e evita sobrescrita sem confirmação

🤝 Contribuições:

Sinta-se à vontade para abrir issues, sugerir melhorias ou enviar pull requests. Este projeto é mantido com ❤️ por Dieguim25.
