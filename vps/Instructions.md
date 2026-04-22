# VPS (Laboratorio Vulneravel Opcional)

Este modulo implementa um laboratorio de pentest web para uso local e autorizado.
O alvo padrao e um servidor Apache com DVWA (Damn Vulnerable Web Application).

## Objetivo

- Permitir simulacoes de pentest em ambiente controlado.
- Manter uso modular: o VPS pode rodar sozinho, sem depender dos modulos de malware e auditoria.
- Preservar seguranca por padrao com exposicao apenas em localhost.

## Componentes

- `server_machine.dockerfile`: servidor alvo vulneravel (Apache + DVWA).
- `docker-compose.yml`: orquestracao com banco MariaDB e alvo DVWA.

## Como Executar

No diretorio `vps`:

```bash
docker compose --profile vps up -d --build
```

Servicos iniciados:

- `dvwa-db`: banco MariaDB para a aplicacao.
- `vps-target`: servidor Apache com DVWA.

## Acesso ao Alvo

- URL: `http://127.0.0.1:8080`
- Exposicao: somente localhost (nao publica em `0.0.0.0`).

Primeiro acesso ao DVWA:

1. Abrir `http://127.0.0.1:8080/setup.php`.
2. Clicar em **Create / Reset Database**.
3. Fazer login em `http://127.0.0.1:8080/login.php`.
4. Credenciais padrao: `admin` / `password`.

## Testes no Alvo

O alvo pode ser testado a partir do host local em `http://127.0.0.1:8080`.
No futuro, os fluxos ofensivos e ferramentas de teste serao movidos para um modulo dedicado chamado `pentesting`.

## Encerrar Ambiente

```bash
docker compose --profile vps down
```

Para remover tambem o volume do banco:

```bash
docker compose --profile vps down -v
```

## Seguranca e Limites

- Use apenas em laboratorio local e autorizado.
- Nao exponha esta stack em rede publica.
- O modulo foi desenhado para aprendizado e simulacao, nao para producao.
- Caso queira integrar com auditoria, faca de forma opcional e sem remover o isolamento padrao.
- A remocao da maquina guest deste modulo foi intencional para separar responsabilidades com o futuro modulo `pentesting`.
