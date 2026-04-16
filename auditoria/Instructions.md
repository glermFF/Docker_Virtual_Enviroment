# Auditoria

Este ambiente foi pensado para centralizar dados de auditoria e permitir análise visual rápida sem precisar instalar ferramentas diretamente no host. A proposta é usar containers para manter o setup reproduzível e facilitar testes em laboratório.

## Ideia Inicial

**Ideia:** Subir um stack de observabilidade com Elasticsearch e Kibana para indexar dados e consultar eventos por meio de dashboards.

**Objetivo:** Criar um ambiente simples para auditoria, consulta e visualização de informações técnicas em tempo real ou por histórico, com persistência local dos dados.

**Containers:**
- Elasticsearch;
- Kibana;
- Rede bridge dedicada;
- Volume persistente para dados de índice.

## Ferramentas

### Elasticsearch

Responsável por armazenar e indexar os documentos. No compose, ele está em modo single-node e com memória Java limitada para facilitar uso local.

### Kibana

Responsável por interface web e exploração dos dados. Ele se conecta ao Elasticsearch internamente pela rede Docker e permite criar visualizações e dashboards.

## Funcionamento do Ambiente (auditoria/docker-compose.yml)

### Fluxo de Operação

1. O serviço Elasticsearch inicia primeiro e cria o nó local de indexação.
2. O volume esdata1 mantém os dados mesmo após parar ou recriar o container.
3. O Kibana sobe em seguida (depends_on) e se conecta ao Elasticsearch.
4. O acesso ao Kibana ocorre pelo navegador na porta 5601.
5. Consultas feitas no Kibana retornam dados armazenados no Elasticsearch.

### Configurações Importantes

- Versão do compose: 2.2.
- Exposição de portas no host:
	- 9200 para Elasticsearch;
	- 5601 para Kibana.
- Rede interna do stack: esnet (driver bridge).
- Persistência: volume nomeado esdata1 em /usr/share/elasticsearch/data.

## Execução

Entre no diretório do ambiente:

```bash
cd auditoria
```

Suba os containers em segundo plano:

```bash
sudo docker compose up -d
```

Verifique se os serviços estão ativos:

```bash
sudo docker compose ps
```

Acesse:

- Elasticsearch: http://localhost:9200
- Kibana: http://localhost:5601

## Comandos Úteis

Ver logs do stack:

```bash
sudo docker compose logs -f
```

Parar o ambiente:

```bash
sudo docker compose stop
```

Parar e remover containers/rede:

```bash
sudo docker compose down
```

Parar e remover também os volumes:

```bash
sudo docker compose down -v
```

## Observações

- O ambiente é voltado para laboratório e estudos, não para produção.
- Em hosts com pouca RAM, ajuste os limites do Elasticsearch antes de uso prolongado.
- Se as portas 9200 ou 5601 já estiverem em uso no host, altere o mapeamento no docker-compose.
