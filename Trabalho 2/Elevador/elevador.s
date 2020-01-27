.section .data

divide_tela:                               .asciz "===================================================\n"
titulo:                                    .asciz "Simulador de elevador\n"
string_subindo:                            .asciz "Elevador %d Subindo...\n"
string_descendo:                           .asciz "Elevador %d Descendo...\n"
string_parado:                             .asciz "Elevador %d Parado...\n"
insira_andares:                            .asciz "Insira a quantidade de andares: "
insira_peso_maximo_elevador:               .asciz "Insira o peso maximo do elevador %d: "
insira_qtd_maxima_pessoas_elevador:        .asciz "Insira a quantidade maxima de pessoas do elevador %d: "
insira_probabilidade:                      .asciz "Insira a probabilidade (em %) do evento de um andar sorteado ocorrer: "
string_pessoas_saindo:                     .asciz "%d pessoa(s) saindo do elevador %d\n"
string_pessoas_entrando:                   .asciz "%d pessoa(s) entrando no elevador %d\n"
string_pessoas_no_elevador:                .asciz "%d pessoa(s) dentro do elevador %d\n"
string_andar_atual:                        .asciz "Andar atual elevador %d: %d\n"
string_chamada_interna:                    .asciz "- Chamada interna ida ao andar: %d\n"
string_chamadas_externas:                  .asciz "%d chamada(s) externa(s) foram feita(s) no andar %d\n"
string_limite_andares:                     .asciz "Erro: quantidade de andares deve ser entre 0 e 50\n"
string_limite_probabilidade:               .asciz "Erro: probabilidade deve ser entre 0 e 100\n"
string_teste:                              .asciz "Teste"
formato_int:                               .asciz "%d"
teste_inicializacao:                       .asciz "Pos %d -> %d\n"
qtd_andares:                               .int 0
qtd_pessoas_elevador_1:                    .int 0
qtd_pessoas_elevador_2:                    .int 0
probabilidade_evento:                      .int 0
direcao_elevador1:                         .int 2 # SUBINDO (0) ou DESCENDO (1) ou PARADO (2)
direcao_elevador2:                         .int 2 # SUBINDO (0) ou DESCENDO (1) ou PARADO (2)
andar_atual_elevador_1:                    .int 0
andar_atual_elevador_2:                    .int 0
contador:                                  .int 0
tempo:                                     .int 0
andar_sorteado:                            .int 0
pessoas_sorteadas:                         .int 0
pessoas_entrando:                          .int 0
peso_max_pessoa:                           .int 180
peso_min_pessoa:                           .int 35
idade_max_pessoa:                          .int 100
idade_min_pessoa:                          .int 5
peso_maximo_elevador_1:                    .int 0
peso_maximo_elevador_2:                    .int 0
qtd_maxima_pessoas_elevador_1:             .int 0
qtd_maxima_pessoas_elevador_2:             .int 0
peso_atual_elevador_1:                     .int 0
peso_atual_elevador_2:                     .int 0

limpabuf:                     .string "%*c"
formach:                      .asciz "%c"

.section .bss

# struct pessoa
# andar_alvo # 4 Bytes
# idade # 4 Bytes
# peso # 4 Bytes
# proximo # 4 Bytes

.lcomm lista_interna_elevador1, 200 # lista de ponteiros (4 Bytes cada posicao)
.lcomm lista_interna_elevador2, 200 # lista de ponteiros (4 Bytes cada posicao)
.lcomm lista_externa, 200 # lista de ponteiros (4 Bytes cada posicao)

.section .text

# Registradores utilizados: eax, ecx
# Parametros (lista)
inicializa_lista:
  pushl %ebp
  movl %esp, %ebp
  movl 8(%ebp), %eax
  movl $50, %ecx
  loop_inicializacao_lista:
    movl $-1, (%eax)
    addl $4, %eax
    loop loop_inicializacao_lista

  popl %ebp
  ret

# Registradores utilizados (eax, edi, edx, ecx)
# Retorna em eax o endereço da pessoa mais velha de determinado andar
# Parametros (andar, lista)
encontra_pessoa_mais_velha:
  pushl %ebp
  movl %esp, %ebp
  pushl 12(%ebp) # coloca lista na pilha
  pushl 8(%ebp) # coloca andar na pilha
  call caminha_na_lista # retorna em eax endereço do andar
  addl $8, %esp # limpa pilha
  movl $0, %edx # coloca primeiro valor de comparação em edx
  movl (%eax), %edi # move valor endereco pessoa para edi
  verifica_fim_encontra_pessoa_mais_velha:
    cmpl $-1, (%eax) # verifica se mais pessoas a verificar
    je fim_encontra_pessoa_mais_velha 
  loop_encontra_pessoa_mais_velha:
    movl (%eax), %eax # move o endereço da pessoa para eax
    movl 4(%eax), %ecx # move a idade para ecx
    cmpl %ecx, %edx # verifica se a idade no contador já é a mais velha
    jg loop_ou_fim_encontra_pessoa_mais_velha
    movl %eax, %edi # move o endereço da pessoa mais velha para edi
    movl %ecx, %edx # move a idade da pessoa mais velha para edx
  loop_ou_fim_encontra_pessoa_mais_velha:
    addl $12, %eax # move para o campo próximo
    jmp verifica_fim_encontra_pessoa_mais_velha
  fim_encontra_pessoa_mais_velha:
    xchg %edi, %eax # coloca endereço de retorno em eax
    popl %ebp
    ret

# (ponteiro_pessoa, lista)
remove_pessoa_lista:
  pushl %ebp
  movl %esp, %ebp
  movl 8(%ebp), %edx # colaca pessoa em edx
  pushl 12(%ebp) # coloca lista na pilha
  pushl (%edx) # coloca andar_alvo na pilha
  teste2:
  call caminha_na_lista # retorna em eax endereco do andar
  addl $8, %esp # limpa pilha
  movl 8(%ebp), %edx # coloca pessoa em edx
  loop_remocao:
    cmpl %edx, (%eax)
    je remove_pessoa
    movl (%eax), %eax
    addl $12, %eax
    jmp loop_remocao
  remove_pessoa:
    addl $12, %edx
    movl (%edx), %edx
    movl %edx, (%eax)
  popl %ebp
  ret
              
# Parametros (lista, ponteiro_pessoa)
adiciona_pessoa_lista:
  pushl %ebp
  movl %esp, %ebp
  movl 12(%ebp), %edi # recupera ponteiro_pessoa
  movl (%edi), %eax # move andar_alvo para eax
  movl $4, %edx # move tamanho do ponteiro para edx
  mull %edx # calcula quanto tem de andar na lista
  movl 8(%ebp), %edx # recupera lista
  addl %eax, %edx # desloca a lista em edx
  cmpl $-1, (%edx) # verifica se posicao andar_atual esta vazia na lista
  je insere_proximo
  movl (%edx), %edx
  addl $12, %edx # anda na pessoa para campo ponteiro_proximo
  loop_percorre_lista:
    cmpl $-1, (%edx) # verifica se é um ponteiro_proximo ou fim da lista (-1)
    je insere_proximo
    movl (%edx), %edx # move ponteiro_proximo (nova pessoa), para edi
    addl $12, %edx # desloca na nova pessoa para o campo ponteiro_proximo
    jmp loop_percorre_lista

  insere_proximo:
    movl %edi, (%edx) 
  popl %ebp
  ret

# Parametros (faixa)
gera_random: # gera random com base em uma faixa passada por parametro e retorno em %eax
  pushl %ebp # boilerplate padrão
  movl %esp, %ebp # boilerplate padrão
  
  call rand # gera rand em %eax

  movl 8(%ebp), %edi # recupera faixa
  movl $0, %edx
  divl %edi # resto da divisao pela faixa é o rand de 0 até faixa - 1
  movl %edx, %eax # variavel de retorno #eax

  popl %ebp # devolve %esp original
  ret

sorteia_n_pessoas: # sorteia n de pessoas de 1 a 3 e devolve em eax
  pushl $3 # faixa = 3
  call gera_random # gera um random de 0 a 3 -1
  addl $4, %esp # limpa pilha
  incl %eax # para rand nao ser 0
  ret

sorteia_andar:
  pushl qtd_andares # faixa na pilha
  call gera_random # gera um random de 0 a qtd_andares - 1
  addl $4, %esp # limpa pilha
  ret

# gera peso para uma pessoa e retorna em %eax
gera_peso:
  pushl peso_max_pessoa # peso maximo para uma pessoa
  call gera_random
  addl $4, %esp

  movl peso_min_pessoa, %ebx
  cmpl %ebx, %eax # compara random gerado com peso minimo
  jl gera_peso # para nao retornar peso abaixo do minimo

  ret

# gera idade para uma pessoa e retorna em %eax
gera_idade:
  pushl idade_max_pessoa # idade maximo para uma pessoa
  call gera_random
  addl $4, %esp

  movl idade_min_pessoa, %ebx
  cmpl %ebx, %eax # compara random gerado com idade minima
  jg retorna # para nao retornar idade abaixo do minimo

  movl peso_min_pessoa, %eax
  ret

# gera pessoa e rotorna ponteiro em %eax
# Parametros (andar_sorteado)
gera_pessoa:
  pushl %ebp # boilerplate padrão
  movl %esp, %ebp # boilerplate padrão

  pushl $16 # aloca memoria para struct pessoa
  call malloc # aloca memoria para struct pessoa
  addl $4, %esp # aloca memoria para struct pessoa

  pushl %eax
  movl %eax, %edi

  movl 8(%ebp), %ebx # recupera andar_sorteado
  movl %ebx, (%edi) # preenche andar_alvo da pessoa

  pushl %edi
  call gera_idade # gera idade aleatoria
  popl %edi
  addl $4, %edi
  movl %eax, (%edi) # preenche idade da pessoa

  pushl %edi
  call gera_peso # gera peso aleatorio
  popl %edi
  addl $4, %edi
  movl %eax, (%edi) # preenche peso da pessoa

  addl $4, %edi
  movl $-1, (%edi) # preenche proximo com -1 (NULO)

  popl %eax # recupera endereco da pessoa gerada para retorno em %eax

  popl %ebp # devolve %esp original
  
  ret

calcula_probabilidade:
  pushl $100 # faixa = 100
  call gera_random
  incl %eax
  addl $4, %esp # limpa pilha

  cmpl probabilidade_evento, %eax
  jg falso

  movl $1, %eax
  ret

  falso:
    movl $0, %eax
    ret

# faz o sorteio de 1 ou dois andares
# para cada verifica se deve ser processado com base na probabilidade
# e sorteia 1 a 3 pessoas para fazerema chamdas externas
# modifica lista_externa com base nos sorteios de chamadas externas
sorteia_andares:
  pushl $2 # faixa = 2
  call gera_random # gera um random de 0 a 2 -1
  addl $4, %esp # limpa pilha
  incl %eax # para rand nao ser 0

  movl %eax, %ecx
  verifica_andares:
    pushl %ecx

    call calcula_probabilidade

    cmpl $0, %eax
    jz nao_calcula

    calcula:
      call sorteia_andar
      movl %eax, andar_sorteado # andar_sorteado = andar do sorteio
      
      # cmpl andar_atual, %eax # se o andar sorteado for o atual
      # je calcula # refaz o sorteio

      call sorteia_n_pessoas # sorteia n de pessoas que fizeram a chamada externa (vao entrar no elevador)
      movl %eax, pessoas_sorteadas

      movl pessoas_sorteadas, %ecx
      loop_pessoas:
        pushl %ecx
        pushl andar_sorteado # empilha andar
        call gera_pessoa # gera uma pessoa com idade e peso aleatorios
        pushl %eax  # empilha endereco de memoria da pessoa gerada
        pushl $lista_externa # empilha lista_externa
        call adiciona_pessoa_lista # adiciona pessoa gerada na lista_externa

        addl $12, %esp # limpa pilha

        popl %ecx # loop
        decl %ecx # loop
        cmpl $0, %ecx # loop
        jg loop_pessoas # loop

        pushl andar_sorteado # print n pessoas na chamada externa
        pushl pessoas_sorteadas # print n pessoas na chamada externa
        pushl $string_chamadas_externas # print n pessoas na chamada externa
        call printf # print n pessoas na chamada externa
        addl $12, %esp # print n pessoas na chamada externa
    
    nao_calcula:
      popl %ecx # loop
      decl %ecx # loop
      cmpl $0, %ecx # loop
      jg verifica_andares # loop

  ret

retorna: # metodo dummy para retornar
  ret # retorna
# Devolve em eax o endereço de memoria da região do andar
# Parametros (andar, lista)
caminha_na_lista:
  pushl %ebp
  movl %esp, %ebp
  movl 8(%ebp), %edi # recupera andar
  movl 12(%ebp), %ecx # recupera lista
  movl $4, %eax # tamanho do ponteiro
  mull %edi
  addl %eax, %ecx
  xchg %eax, %ecx # troca para retornar em eax
  popl %ebp
  ret

# Retorna em eax quantas pessoas sairam da lista
# Parametros (andar, qtd_pessoas_elevador, peso_atual_elevador, lista_interna)
verifica_lista_interna:
  pushl %ebp
  movl %esp, %ebp
  pushl 20(%ebp) # empilha lista
  pushl 8(%ebp) # empilha andar
  call caminha_na_lista # retornar em eax endereco do andar
  addl $8, %esp # limpa pilha
  movl $0, %ecx # coloca valor de retorno em ecx caso a comparacao seja true
  movl $0, %edi # armazena peso que saiu
  cmpl $-1, (%eax) # verifica se alguem sai naquele andar
  je fim_remocao_lista_interna
  movl (%eax), %edx # move endereco da primeira pessoa para edx
  movl $-1, (%eax) # remove todos que saem naquele andar
  movl $1, %ecx # inicia a contar quantos sairam do elevador
  loop_conta_pessoas_sairam:
    addl $8, %edx # caminha para o campo de peso
    addl (%edx), %edi # soma o peso ao contador
    addl $4, %edx # caminha para o endereco do campo de ponteiro_proximo
    movl (%edx), %eax # move o ponteiro para eax
    movl %eax, %edx # move o ponteiro para edx
    cmpl $-1, %edx # verifica se existe proximo
    je fim_remocao_lista_interna
    incl %ecx
    jmp loop_conta_pessoas_sairam

  fim_remocao_lista_interna:
    xchg %ecx, %eax # coloca o valor de retorno em eax
    movl 12(%ebp), %ecx # move a qtd_pessoas_elevador para ecx
    subl %eax, (%ecx) # subtrai a qtd_pessoas_sairam de ecx
    movl 16(%ebp), %ecx # move o peso_atual_elevador para ecx
    subl %edi, (%ecx) # subtrai o peso_total_sairam de ecx
    popl %ebp
    ret

# Retorna em eax quantas pessoas entraram
# Parametros (andar, qtd_pessoas_elevador, qtd_maxima_pessoas, peso_atual_elevador, peso_maximo, lista_interna)
verifica_lista_externa:
  pushl %ebp
  movl %esp, %ebp
  pushl $lista_externa
  pushl 8(%ebp) # colocar o andar na pilha
  call caminha_na_lista # retorna em eax o endereco da lista externa daquele andar
  addl $8, %esp # limpa pilha
  movl $0, pessoas_entrando # move qtd pessoas entraram elevador
  cmpl $-1, (%eax) # verifica se existe alguem naquele andar na lista externa
  je fim_remocao_lista_externa
  loop_insere_lista_interna:
    movl 12(%ebp), %edx # move qtd_pessoas_elevador para %edx
    cmpl %edx, 16(%ebp) # compara qtd_pessoas_elevador == qtd_maxima_pessoas
    je fim_remocao_lista_externa
    pushl $lista_externa # coloca a lista na pilha
    pushl 8(%ebp) # coloca andar na pilha
    call encontra_pessoa_mais_velha # retorna em %eax endereco da pessoa mais velha
    teste:
    addl $8, %esp # limpa pilha
    cmpl $-1, %eax
    je fim_remocao_lista_externa
    movl 20(%ebp), %edi # coloca peso atual em %edi
    addl 8(%eax), %edi # soma peso pessoa ao peso atual
    cmpl %edi, 24(%ebp) # verifica se o peso da pessoa entrando é aceito
    jl fim_remocao_lista_externa
    pushl $lista_externa # coloca a lista na pilha
    pushl %eax # coloca a pessoa na pilha
    call remove_pessoa_lista # remove pessoa da lista externa
    popl %eax # recupera pessoa da pilha
    addl $4, %esp # limpa pilha
    pushl %eax # salva pessoa
    pushl qtd_andares # coloca faixa na pilha
    call gera_random # gera um andar random em eax
    addl $4, %esp # limpa pilha
    popl %edi # recupera %eax (pessoa)
    movl %eax, andar_sorteado
    movl %eax, (%edi) # atualiza o andar sorteado na pessoa
    xchg %eax, %edi # troca pessoa para %eax
    pushl %eax # coloca pessoa na pilha
    pushl 28(%ebp) # coloca lista_interna na pilha
    call adiciona_pessoa_lista # adiciona pessoa na lista interna
    addl $8, %esp # limpa pilha
    movl pessoas_entrando, %ecx
    incl %ecx
    movl %ecx, pessoas_entrando
    pushl andar_sorteado
    pushl $string_chamada_interna
    call printf
    addl $8, %esp
    jmp loop_insere_lista_interna

  fim_remocao_lista_externa:
    movl pessoas_entrando, %eax
    popl %ebp
    ret

# Retorna em eax 0 se existe e 1 se não existe
# Parametros (andar_atual, direcao, lista)
existem_chamadas_subindo:
  pushl %ebp
  movl %esp, %ebp
  movl 8(%ebp), %ecx # coloca andar atual na pilha
  movl $1, %edi
  cmpl qtd_andares, %ecx
  je fim_existem_chamadas_subindo
  loop_existem_chamadas_subindo:
    pushl %ecx # salva ecx
    pushl 16(%ebp) # lista
    pushl 8(%ebp) # andar 
    call caminha_na_lista # retorna em eax endereco do andar
    addl $8, %esp # limpa pilha 
    popl %ecx # recupera ecx
    movl $0, %edi # coloca valor de retorno em %edi
    cmpl $-1, %eax # verifica se existe alguem naquele andar
    jne  fim_existem_chamadas_subindo # se tiver, retorna
  	movl $1, %edi # coloca valor de retorno em %edi 
    incl %ecx # incrementar andar a ser verificado
    cmpl qtd_andares, %ecx # verifica se já verificou todos andarem
    je fim_existem_chamadas_subindo # se sim, encerra
    jmp loop_existem_chamadas_subindo # se não, continua
    
  fim_existem_chamadas_subindo:
    xchg %edi, %eax
    popl %ebp
    ret

# Retorna em eax 1 se existe e 0 se não existe
# Parametros (andar_atual, direcao, lista)
existem_chamadas_descendo:
  pushl %ebp
  movl %esp, %ebp
  movl 8(%ebp), %ecx # coloca andar atual na pilha
  movl $0, %edi
  cmpl $0, %ecx
  je fim_existem_chamadas_descendo
  loop_existem_chamadas_descendo:
    pushl %ecx # salva ecx
    pushl 16(%ebp) # lista
    pushl 8(%ebp) # andar 
    call caminha_na_lista # retorna em eax endereco do andar
    addl $8, %esp # limpa pilha 
    popl %ecx # recupera ecx
    movl $1, %edi # coloca valor de retorno em %edi
    cmpl $-1, %eax # verifica se existe alguem naquele andar
    jne  fim_existem_chamadas_descendo # se tiver, retorna
  	movl $0, %edi # coloca valor de retorno em %edi 
    decl %ecx # incrementar andar a ser verificado
    cmpl $0, %ecx # verifica se já verificou todos andarem
    je fim_existem_chamadas_descendo # se sim, encerra
    jmp loop_existem_chamadas_descendo # se não, continua
    
  fim_existem_chamadas_descendo:
    xchg %edi, %eax
    popl %ebp
    ret

# SUBINDO (0) ou DESCENDO (1) ou PARADO (2)
# Retorna em %eax 1 se existem chamadas naquela direcao 0 se não
# Parametros (andar_atual, direcao, lista)
existem_chamadas_direcao:
 pushl %ebp
 movl %esp, %ebp
 cmpl $0, 12(%ebp)
 je fluxo_subindo
 cmpl $1, 12(%ebp)
 je fluxo_descendo

 fluxo_subindo:
  pushl 16(%ebp) # coloca lista na pilha
  pushl 12(%ebp) # coloca direcao na pilha
  pushl 8(%ebp) # coloca andar_atual na pilha
  call existem_chamadas_subindo # retorna em eax: 0 se existe e 1 se não existe
  cmpl $0, %eax
  je fim_existem_chamadas_direcao
  call existem_chamadas_descendo
  cmpl $1, %eax
  je fim_existem_chamadas_direcao
  movl $2, %eax
  jmp fim_existem_chamadas_direcao

 fluxo_descendo:
  pushl 16(%ebp)
  pushl 12(%ebp)
  pushl 8(%ebp)
  call existem_chamadas_descendo
  cmpl $1, %eax
  je fim_existem_chamadas_direcao
  call existem_chamadas_subindo
  cmpl $0, %eax
  je fim_existem_chamadas_direcao
  movl $2, %eax
  jmp fim_existem_chamadas_direcao

fim_existem_chamadas_direcao:
  addl $12, %esp
  popl %ebp
  ret

# Parametros (direcao, andar_atual, n_elevador)
verifica_direcao_informa:
  pushl %ebp
  movl %esp, %ebp
  movl 12(%ebp), %eax # recupera andar
  movl 8(%ebp), %edx # recupera direcao
  teste3:
  cmpl $0, (%edx) # verifica se esta subindo
  je adiciona_andar
  cmpl $2, 8(%ebp)

  remove_andar:
    decl (%eax)
    pushl (%eax)
    pushl $string_descendo
    jmp fim_verifica_direcao_informa

  mantem_andar:
    pushl (%eax)
    pushl $string_parado

  adiciona_andar:
    incl (%eax)
    pushl (%eax)
    pushl $string_subindo

  fim_verifica_direcao_informa:
    call printf
    addl $8, %esp
    popl %ebp
    ret

.globl main
main:
  pushl $tempo # variavel que vai receber a chamada do time
  call time # chamada externa ao time
  addl $4, %esp # limpa pilha

  pushl tempo # coloca o tempo gerado na pilha
  call srand # chamada externa ao srand para modifica seed
  addl $4, %esp # limpa pilha

  inicio_leituras:
    pushl $divide_tela # insere string divide_tela na pilha
    call  printf # chamada externa ao printf

    pushl $titulo # insere string titulo na pilha
    call  printf # chamada externa ao printf

    addl  $4,  %esp # caminha para o endereço da string divide_tela
    call printf # chamada externa ao printf

    pushl $insira_andares # insere a string insira_andares na pilha
    call printf # chamada externa ao printf
    
    pushl $qtd_andares # insere váriavel onde a qtd de andares será armazenada
    pushl $formato_int # insere o formatador de inteiro na pilha
    call scanf # chamada externa ao scanf
    cmpl $50, qtd_andares # valida se a quantidade de andares esta
    jg print_erro_limite_andares # dentro dos limites
    cmpl $0, qtd_andares
    jl print_erro_limite_andares # fim validação

    pushl $insira_probabilidade # insere a string insira_probabilidade na pilha
    call printf # chamada externa ao printf

    pushl $probabilidade_evento # insere na pilha variável onde a probabilidade sera armazenada
    pushl $formato_int # insere o formatador de float na pilha
    call scanf # chamada externa ao scanf
    cmpl $100, probabilidade_evento # valida se o valor da probabilidade
    jg print_erro_limite_probabilidade # esta dentro dos limites
    cmpl $0, probabilidade_evento
    jl print_erro_limite_probabilidade # fim validação
    jmp fluxo_sem_erro # vai para fluxo onde validações passaram

    print_erro_limite_andares:
      pushl $string_limite_andares
      call printf
      addl $20, %esp # limpa pilha até aquele momento
      jmp inicio_leituras

    print_erro_limite_probabilidade:
      pushl $string_limite_probabilidade
      call printf
      addl $20, %esp # limpa pilha até aquele momento
      jmp inicio_leituras

    fluxo_sem_erro:    
      addl $28, %esp # limpa a pilha

      movl qtd_andares, %eax
      incl %eax
      movl %eax, qtd_andares

      pushl $1
      pushl $insira_peso_maximo_elevador
      call printf

      pushl $peso_maximo_elevador_1
      pushl $formato_int
      call scanf

      pushl $2
      pushl $insira_peso_maximo_elevador
      call printf

      pushl $peso_maximo_elevador_2
      pushl $formato_int
      call scanf

      pushl $1
      pushl $insira_qtd_maxima_pessoas_elevador
      call printf

      pushl $qtd_maxima_pessoas_elevador_1
      pushl $formato_int
      call scanf

      pushl $2
      pushl $insira_qtd_maxima_pessoas_elevador
      call printf

      pushl $qtd_maxima_pessoas_elevador_2
      pushl $formato_int
      call scanf

      addl $64, %esp # limpa pilha

      pushl $limpabuf # limpa o buffer do teclado
      call scanf # limpa o buffer do teclado
      addl $4, %esp # limpa o buffer do teclado

      pushl $lista_interna_elevador1
      call inicializa_lista
      addl $4, %esp

      pushl $lista_interna_elevador2
      call inicializa_lista
      addl $4, %esp

      pushl $lista_externa
      call inicializa_lista
      addl $4, %esp

  loop_infinito: # rotulo para loop infinito do elevador
    pushl $divide_tela # insere string divide_tela na pilha
    call  printf # chamada externa ao printf
    addl $4, %esp # limpa pilha
    
    pushl andar_atual_elevador_1
    pushl $1
    pushl $string_andar_atual
    call printf
    
    pushl andar_atual_elevador_2
    pushl $2
    pushl $string_andar_atual
    call printf
    addl $24, %esp

    pushl $lista_interna_elevador1
    pushl $peso_atual_elevador_1
    pushl $qtd_pessoas_elevador_1
    pushl andar_atual_elevador_1
    call verifica_lista_interna 
    addl $16, %esp
    pushl $1
    pushl %eax
    pushl $string_pessoas_saindo
    call printf
    addl $12, %esp

    pushl $lista_interna_elevador2
    pushl $peso_atual_elevador_2
    pushl $qtd_pessoas_elevador_2
    pushl andar_atual_elevador_2
    call verifica_lista_interna 
    addl $16, %esp
    pushl $2
    pushl %eax
    pushl $string_pessoas_saindo
    call printf
    addl $12, %esp

    pushl $lista_interna_elevador1
    pushl peso_maximo_elevador_1
    pushl peso_atual_elevador_1
    pushl qtd_maxima_pessoas_elevador_1
    pushl qtd_pessoas_elevador_1
    pushl andar_atual_elevador_1
    call verifica_lista_externa
    addl $24, %esp

    movl qtd_pessoas_elevador_1, %edx
    addl %eax, %edx
    movl %edx, qtd_pessoas_elevador_1

    pushl $1
    pushl %eax
    pushl $string_pessoas_entrando
    call printf
    addl $12, %esp

    pushl $lista_interna_elevador2
    pushl peso_maximo_elevador_2
    pushl peso_atual_elevador_2
    pushl qtd_maxima_pessoas_elevador_2
    pushl qtd_pessoas_elevador_2
    pushl andar_atual_elevador_2
    call verifica_lista_externa
    addl $24, %esp

    movl qtd_pessoas_elevador_2, %edx
    addl %eax, %edx
    movl %edx, qtd_pessoas_elevador_2

    pushl $2
    pushl %eax
    pushl $string_pessoas_entrando
    call printf
    addl $12, %esp

    pushl $1
    pushl qtd_pessoas_elevador_1 
    pushl $string_pessoas_no_elevador
    call printf

    pushl $2
    pushl qtd_pessoas_elevador_2
    pushl $string_pessoas_no_elevador
    call printf
    addl $24, %esp

    call sorteia_andares # faz os sorteios de andares e chamadas externas e modifica lista_externa
    
####### VERIFICA DIRECAO E INFORMA ELEVADOR 1 #######
    pushl $lista_interna_elevador1
    pushl direcao_elevador1
    pushl andar_atual_elevador_1
    call existem_chamadas_direcao
    addl $12, %esp
    movl %eax, direcao_elevador1

    pushl $1
    pushl $andar_atual_elevador_1
    pushl $direcao_elevador1
    call verifica_direcao_informa
    addl $12, %esp
###### FIM VERIFICA ELEVADOR 1 #######

####### VERIFICA DIRECAO E INFORMA ELEVADOR 2 #######
    pushl $lista_interna_elevador2
    pushl direcao_elevador2
    pushl andar_atual_elevador_2
    call existem_chamadas_direcao
    addl $12, %esp
    movl %eax, direcao_elevador2

    pushl $2
    pushl $andar_atual_elevador_2
    pushl $direcao_elevador2
    call verifica_direcao_informa
    addl $12, %esp

###### FIM VERIFICA ELEVADOR 2 #######

    pushl $divide_tela # insere string divide_tela na pilha
    call  printf # chamada externa ao printf
    addl $8, %esp # limpa pilha

    call getchar # para ler o resultado antes o elevador continuar. apertar apenas ENTER

    jmp loop_infinito # loop

  fim:
    pushl $0
    call  exit
