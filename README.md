#🚀 Este repositório contém scripts automatizados para instalar, manter e atualizar uma instância do Nextcloud utilizando Docker.

#📦 Scripts incluídos:

```setup.sh```: Instala e configura o ambiente Nextcloud com Docker, incluindo usuário administrador, apps de visualização e geração de miniaturas.

```backup.sh```: Realiza backup completo dos dados, banco de dados e configurações, com notificação para o grupo adm.

```update.sh```: Verifica e aplica atualizações da imagem Nextcloud, notificando os administradores.

```bootstrap_nextcloud.sh```: Script inicial que prepara o ambiente, baixa os demais scripts e executa o setup.sh.

#🧰 Requisitos
Linux com curl, docker, docker-compose e whiptail instalados

Permissões de sudo para criação de diretórios e instalação de pacotes

#🚀 Instalação automática
Execute o seguinte comando no terminal:

Use o comando a seguir para instalar:


```bash
curl -fsSL https://raw.githubusercontent.com/Dieguim25/nextcloud-docker-scripts/main/bootstrap_nextcloud.sh | bash
```
Este comando irá:

Criar o diretório /var/scripts/nextcloud_docker

Baixar os scripts setup.sh, backup.sh e update.sh

Ajustar permissões de execução

Iniciar o processo de instalação interativa


📣 Notificações Todos os scripts enviam notificações internas para os membros do grupo adm no Nextcloud, mantendo os administradores informados sobre backups e atualizações.
