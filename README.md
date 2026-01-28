# Ambiente Virtual Docker - Análise de Malware

## Sobre

Toda essa ideia foi um lapso que tive na mente e decidi aplicar e entender se funciona. Algo semelhante já passou em minha mente com relação a ambiente de containers para monitoramento e análise de comportamento dos hosts, mas nunca saiu do papel e ficou na teoria e bibliografias que deixei guardado por lá. A parte parecida entre essas ideias é a questão de conexões entre containers na rede e com a máquina host, sendo uma possível "chama" para continuar o outro projeto após a conclusão desse.

## Ideia Inicial

O que pensei: montar um sistema de containers para análise de malwares. A ideia inicial é em analisar documentos e verificar se há um potencial malware que é executado ao abrir o arquivo. Usarei uma imagem do Kali linux (pode ser o container de uma distro de sua escolha) que estará conectado a uma rede docker e por meio do próprio terminal do host conectar ao container por meio do SSH. Nessa conexão os arquivos serão e combinado com um script automatizado será retornado um log e o arquivo caso ele não tenha nada suspeito ou retornando apenas o log e mantendo o arquivo em quarentena dentro do container, sendo opcional a decisão de manter, destruir ou tentar reparar o arquivo.

## Hipóteses

Virtualizar dessa forma pode não ser a mais eficiente por conta do consumo de RAM do container que imagino que será alto. Executando os devidos testes sobre seu consumo e custo de processamentos terei de fato uma conclusão sobre. Tudo isso é experimental podendo levar a ideias futuras.

## Referências

- https://hub.docker.com/r/kalilinux/kali-rolling
- https://www.tecmint.com/install-openssh-server-in-linux/
- https://www.dropvps.com/blog/how-docker-uses-ports-for-container-networking/?utm_source=chatgpt.com
- https://christian-schou.com/blog/ssh-from-docker-container-to-host/?utm_source=chatgpt.com
