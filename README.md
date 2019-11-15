# PLM

Trabalhos da disciplina de Programação em Linguagem de Montagem

## Acessando ambiente de build

1. Gere um par de chaves SSH. [Este link](https://www.ibm.com/support/knowledgecenter/pt-br/ST3FR7_7.7.0/com.ibm.storwize.v7000.770.doc/svc_generatingsshkeypair_2mu1y4.html) possui um tutorial de como realizar tal ação.
2. Envie o arquivo de sua **chave pública** para ra98336@uem.br.
3. Conecte-se a máquina remota através do comando:  
   `ssh -i CAMINHO_PARA_CHAVE_PRIVADA ubuntu@ec2-3-85-233-207.compute-1.amazonaws.com`
4. Opcionalmente pode ser criado um alias para o comando acima, para isso faça o seguinte:  
   Em `C:\Users\SEU_USER\.ssh` crie um arquivo chamado `config`.  
   Dentro deste arquivo, cole o seguinte:

   > `Host aws_plm`  
   > `HostName ec2-3-85-233-207.compute-1.amazonaws.com`  
   > `User ubuntu`  
   > `IdentityFile CAMINHO_PARA_CHAVE_PRIVADA`

   Após isso, para acessar a máquina use o seguinte comando: `ssh aws_plm`

## Realizando o build

Para realizar o build, execute os seguintes comandos

> `cd ~/PLM/Elevador`  
> `git pull`  
> `make run`

## Gitflow

Desenvolva na branch `develop` faça o build e realize testes. Caso o código esteja estável faça o merge com a `master`.  
Para adicionar suas alterações e fazer o commit use: `git commit --author="SEU_NOME" -am "MENSAGEM_DE_COMMIT"`

## Guidelines

- Toda linha de código deve ser comentada.
- Código na master que estiver quebrado será púnido com empalamento.
