# VPS (Experimento)

Este ambiente está em andamento e serve como base para simular cenários de comunicação entre uma máquina host e uma máquina guest usando containers Docker.

## Status Atual

**Estado:** Em desenvolvimento.

Até o momento, a pasta `./vps` contém dois Dockerfiles com imagem base Ubuntu e utilitários de rede instalados para testes de conectividade e troubleshooting.

Arquivos existentes:
- `host_machine.dockerfile`
- `guest_machine.dockerfile`

## Ideia Inicial

**Ideia:** Montar um laboratório de rede simples para validar comportamento de comunicação entre dois ambientes isolados (host e guest), simulando um cenário próximo de uma VPS com testes operacionais.

**Objetivo:** Fornecer uma base para experimentar conectividade, diagnóstico de rede e transferência de dados entre containers antes da definição final da arquitetura.

## Ferramentas Instaladas nas Imagens

As duas imagens atualmente incluem:
- `curl`
- `net-tools`
- `iputils-ping`
- `netcat-traditional`

Essas ferramentas permitem validar DNS, IP, portas abertas, rotas e conexão entre serviços.

## Funcionamento Previsto (em construção)

Fluxo pretendido para o ambiente:

1. Construir a imagem da máquina host.
2. Construir a imagem da máquina guest.
3. Iniciar os containers em uma rede Docker definida para testes.
4. Validar comunicação usando ping, nc e curl.
5. Ajustar regras de acesso e serviços conforme a evolução do projeto.

## Execução Básica (prévia)

Build da imagem host:

```bash
sudo docker build -t vps-host -f host_machine.dockerfile .
```

Build da imagem guest:

```bash
sudo docker build -t vps-guest -f guest_machine.dockerfile .
```

Execução de teste (modo interativo):

```bash
sudo docker run --rm -it --name vps-host-test vps-host bash
```

```bash
sudo docker run --rm -it --name vps-guest-test vps-guest bash
```

## Próximos Passos

- Definir orquestração com `docker-compose.yml` para subir host e guest juntos.
- Definir rede e política de comunicação entre os containers.
- Adicionar serviços reais para teste de acesso remoto (ex.: SSH ou HTTP interno).
- Documentar fluxo completo de uso quando o ambiente estiver estabilizado.

## Observações

- Esta documentação é uma prévia e pode mudar conforme o ambiente evoluir.
- Como ainda não há compose para a pasta `vps`, os comandos acima são focados em build e teste inicial das imagens.
