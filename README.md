# Ambiente Virtual Docker - Análise de Malware

## Sobre

Toda essa ideia foi um lapso que pensamento que surgiu e decidi aplicar e entender se funciona. Algo semelhante já passou em minha mente com relação a ambiente de containers para monitoramento e análise de comportamento dos hosts, mas nunca saiu do papel e ficou na hipótese. A parte parecida entre essas ideias é a questão de conexões entre containers na rede e com a máquina host, sendo uma possível fagulha para continuar o outro projeto após a conclusão desse.

## Ideia Inicial

O que pensei: montar um sistema isolado entre containers para análise de malwares. A ideia inicial é em analisar documentos e verificar se há um potencial malware que é executado ao abrir o arquivo. Usarei uma imagem do Kali linux (pode ser o container de uma distro de sua escolha) que estará conectado a uma rede docker e por meio do próprio terminal do host conectar ao container por meio do SSH. Nessa conexão os arquivos serão e combinado com um script automatizado será retornado um log e o arquivo caso ele não tenha nada suspeito ou retornando apenas o log e mantendo o arquivo em quarentena dentro do container, sendo opcional a decisão de manter, destruir ou tentar reparar o arquivo.

A forma que pensei aparentemente apresenta camadas de isolamento para evitar com que o malware saia do contaienr afetando o host, mas deixarei outra forma que decidi testar que é executando o container localmente sem adicionar há uma rede docker. Mais direta e pode funcionar sem muita dor de cabeça em ambiente Windows ou MacOS -- os testes estão sendo feitos em Distro Linux. 

## Ferramentas

As ferramentas escolhidas para a efetuar as análises automatizadas foram o binwalk e clamav combinadas em um pipeline feito em shellscript. Cada ferramenta é focada em uma tarefa diferente. 

A verificação dos arquivos começa pelo ClamAV comparando com assinaturas de malwares existentes em sua base de dados e em caso positivo é marcado no arquivo de saída e enviado para o diretório de quarentena dentro do container. 

A próxima etapa, com o Binwalk, é uma forma de analisar de forma mais profunda e detalhada o arquivo, evitando um possível falso positivo da etapa anterior. Por ser um ferramenta usada em engenharia reversa, ele consegue ver a fundo os binários presentes no arquivo de forma precisa.

## Container Local

Crie um diretório no seu computador:
```bash
mkdir -p ~/amostras
```

Execução do container:
```bash
sudo docker run --rm -it \ 
--name container-name \
--network none \
--read-only \
-v ~/amostras:/amostras:ro \
<dockerfile_image>
```
## Container em Rede Isolada
### Configurações da Rede Docker

Gerar Imagem:
```bash
sudo docker build -t nome_da_imagem .
```

Criar rede docker:
```bash
sudo docker network create network-name
```
### Criação e Execução do Container

Criar e inicia container:
```bash
sudo docker run -it \
--name container-name \
--network network-name \
<image> 
```

Iniciar container:
```bash
sudo docker start container-name
```

Acessa o container por CLI:
```bash
sudo docker exec -it container-name /bin/bash
```

## Outros comandos

**Alternativa para rodar no modo CLI**:

```bash
sudo docker exec -it container-name sh
```

**Criação do container com imagem do dockerfile**:
```bash
# Não precisa usar o comando --network para conectar a bridge padrão
sudo docker run -it container-name <dockerfile_image>
```

**Criar um container referênciada a uma porta do host**:
```bash
sudo docker run -it -p PORT:PORT --name container-name
```

**Se comandos de rede(ip, ping) não funcionarem**:
```bash
apt install -y iproute2 iputils-ping net-tools openssh-client
```

**Executar dentro do Container**:
```bash
hostname -I #Identificar IP do Container
```

```bash
cat /etc/hosts #Verificar conexões do Container
```

```bash
scp <fonte> <destino> #Copia dos arquivos do host para o container
## Hipóteses
```

Essa forma pode não ser a mais eficiente por conta do consumo de RAM do container, que imagino que será alto. Executando os devidos testes sobre seu consumo e custo de processamentos terei de fato uma conclusão sobre. Tudo isso é experimental podendo levar a ideias e futuras melhorias.

Até o momento não foi testado em outros sistemas operacionais, então se você utilizar sistmas Windows ou até sistemas não baseados em Debian pode ser que as configurações não funcionem corretamente ao seguir o passo a passo

## Referências

- https://hub.docker.com/r/kalilinux/kali-rolling
- https://www.tecmint.com/install-openssh-server-in-linux/
- https://www.dropvps.com/blog/how-docker-uses-ports-for-container-networking/?utm_source=chatgpt.com
- https://christian-schou.com/blog/ssh-from-docker-container-to-host/?utm_source=chatgpt.com
- https://www.amtso.org/security-features-check/
- https://www.kali.org/tools/clamav/
- https://www.kali.org/tools/binwalk/
