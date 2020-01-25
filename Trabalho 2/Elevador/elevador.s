.section .data

divide_tela:                               .asciz "===================================================\n"
titulo:                                    .asciz "Simulador de elevador\n"
string_subindo:                            .asciz "Elevador %d Subindo...\n"
string_descendo:                           .asciz "Elevador %d Descendo...\n"
insira_andares:                            .asciz "Insira a quantidade de andares: "
insira_peso_maximo_elevador:               .asciz "Insira o peso maximo do elevador %d: "
insira_qtd_maxima_pessoas_elevador:        .asciz "Insira a quantidade maxima de pessoas do elevador %d: "
insira_probabilidade:                      .asciz "Insira a probabilidade (em %) do evento de um andar sorteado ocorrer: "
string_pessoas_saindo:                     .asciz "%d pessoa(s) saindo do elevador %d\n"
string_pessoas_entrando:                   .asciz "%d pessoa(s) entrando no elevador %d\n"
string_pessoas_no_elevador:                .asciz "%d pessoa(s) dentro do elevador %d\n"
string_andar_atual:                        .asciz "Andar atual elevador %d: %d\n"
string_chamada_interna:                    .asciz "- Chamada interna elevador %d ida ao andar: %d\n"
string_chamadas_externas:                  .asciz "%d chamada(s) externa(s) foram feita(s) no andar %d\n"
string_limite_andares:                     .asciz "Erro: quantidade de andares deve ser entre 0 e 50\n"
string_limite_probabilidade:               .asciz "Erro: probabilidade deve ser entre 0 e 100\n"
formato_int:                               .asciz "%d"
teste_inicializacao:                       .asciz "Pos %d -> %d\n"
qtd_andares:                               .int 0
qtd_pessoas_elevador_1:                    .int 0
qtd_pessoas_elevador_2:                    .int 0
probabilidade_evento:                      .int 0
direcao_elevador1:                         .int 0 # SUBINDO (0) ou DESCENDO (1)
direcao_elevador2:                         .int 0 # SUBINDO (0) ou DESCENDO (1)
andar_atual_elevador_1:                    .int 0
andar_atual_elevador_2:                    .int 0
contador:                                  .int 0
tempo:                                     .int 0
andar_sorteado:                            .int 0
pessoas_sorteadas:                         .int 0
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

retorna:
  ret

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
  movl %ebp, %esp
  pushl 8(%ebp) # coloca andar na pilha
  pushl 12(%ebp) # coloca lista na pilha
  call caminha_na_lista # retorna em eax endereço do andar
  addl $8, %esp # limpa pilha
  movl $0, %edx # coloca primeiro valor de comparação em edx
  movl (%eax), %edi # move valor do endereço de retorno para edi
  verifica_fim_encontra_pessoa_mais_velha:
    cmpl $-1, (%eax) # verifica se mais pessoas a verificar
    je fim_encontra_pessoa_mais_velha 
  loop_encontra_pessoa_mais_velha:
    movl (%eax), %eax # move o endereço da pessoa para eax
    movl 4(%eax), %ecx # move o endereco de idade para ecx
    cmpl (%ecx), %edx # verifica se a idade no contador já é a mais velha
    jg loop_ou_fim_encontra_pessoa_mais_velha
    movl %eax, %edi # move o endereço da pessoa mais velha para eax
    movl (%ecx), %edx # move a idade da pessoa mais velha para edx
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
  movl $0, %ecx # move qtd pessoas entraram elevador
  cmpl $-1, (%eax) # verifica se existe alguem naquele andar na lista externa
  je fim_remocao_lista_externa
  loop_insere_lista_interna:
    movl 12(%ebp), %edx # move qtd_pessoas_elevador para %edx
    cmpl %edx, 16(%ebp) # compara qtd_pessoas_elevador == qtd_maxima_pessoas
    je fim_remocao_lista_externa
    pushl $lista_externa # coloca a lista na pilha
    pushl 8(%ebp) # coloca andar na pilha
    call encontra_pessoa_mais_velha # retorna em %eax endereco da pessoa mais velha
    addl $8, %esp # limpa pilha
    movl 20(%ebp), %edx # coloca peso atual em %edx
    movl 8(%eax), %edi # coloca endereco do peso da pessoa em edi
    addl (%edi), %edx # soma peso pessoa ao peso atual
    cmpl %edx, 24(%ebp)
    jl fim_remocao_lista_externa
    pushl $lista_externa # coloca a lista na pilha
    pushl %eax # coloca a pessoa na pilha
    call remove_pessoa_lista # remove pessoa da lista externa
    popl %eax # recupera pessoa da pilha
    addl $4, %esp # limpa pilha
    pushl %eax # coloca pessoa na pilha
    pushl 28(%ebp) # coloca lista_interna na pilha
    # TODO, mudar andar da pessoa
    call adiciona_pessoa_lista # adiciona pessoa na lista interna
    addl $8, %esp # limpa pilha
    jmp loop_insere_lista_interna

  fim_remocao_lista_externa:
    xchg %ecx, %eax
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

    pushl $lista_interna_elevador1
    pushl $peso_atual_elevador_1
    pushl $qtd_pessoas_elevador_1
    pushl andar_atual_elevador_1
    call verifica_lista_interna 
    addl $8, %esp
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
    addl $8, %esp
    pushl $2
    pushl %eax
    pushl $string_pessoas_saindo
    call printf
    addl $12, %esp



    # DESENVOLVER AQUI

    pushl $divide_tela # insere string divide_tela na pilha
    call  printf # chamada externa ao printf
    addl $8, %esp # limpa pilha

    call getchar # para ler o resultado antes o elevador continuar. apertar apenas ENTER

    jmp loop_infinito # loop

  fim:
    pushl $0
    call  exit
