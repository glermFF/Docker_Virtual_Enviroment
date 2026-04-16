# Ambiente Virtual Docker

## Sobre

O repositório tem como intuito disponibilizar ferramentas usando como cerne containers que possam ser executados em qualquer computador sem dificuldades. Cada container possui diferentes funcionalidades, podendo ser integrados em sistemas já existentes de modo a facilitar otimização e melhoria sem perder tempo com configurações dos containers. Parte dos ambientes do repositório são experimentos, então leia o documento ``Instructions.md`` antes de instalar e reclamar que não funciona.

## Ambientes

| Ambiente | Local | Objetivo | Serviços | Persistência de dados | Exposição de portas | Isolamento e segurança | Diferença principal |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Auditoria | `auditoria/docker-compose.yml` | Coleta, indexação e visualização de dados com Elastic Stack | Elasticsearch + Kibana | Volume nomeado `esdata1` em `/usr/share/elasticsearch/data` | `9200` (Elasticsearch) e `5601` (Kibana) expostas no host | Rede `bridge` padrão (`esnet`) para comunicação entre serviços | Ambiente voltado para observabilidade e análise interativa, com interface web acessível no host |
| Malware | `malware/docker-compose.yml` | Análise de amostras em container isolado | `malware-analyzer` (imagem construída localmente) | Bind mounts: `${HOME}/amostras` (entrada, somente leitura) e `./resultados` (saída, leitura/escrita) | Não expõe portas para o host | `read_only: true`, `cap_drop: ALL`, `no-new-privileges`, rede `internal: true` | Ambiente voltado para execução mais restrita, sem interface pública, focado em segurança operacional |

### Diferença entre os ambientes

- O ambiente de Auditoria prioriza acesso e visualização de dados no navegador, por isso publica portas e usa dois serviços integrados.
- O ambiente de Malware prioriza contenção e mínimo privilégio, sem portas expostas e com sistema de arquivos do container em modo somente leitura.
- A persistência na Auditoria usa volume nomeado do Docker, enquanto no Malware usa pastas do host para entrada e saída dos arquivos de análise.




## Referências

- https://hub.docker.com/r/kalilinux/kali-rolling
- https://www.tecmint.com/install-openssh-server-in-linux/
- https://www.dropvps.com/blog/how-docker-uses-ports-for-container-networking/?utm_source=chatgpt.com
- https://christian-schou.com/blog/ssh-from-docker-container-to-host/?utm_source=chatgpt.com
- https://www.amtso.org/security-features-check/
- https://www.kali.org/tools/clamav/
- https://www.kali.org/tools/binwalk/
