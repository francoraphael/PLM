.section .data

divide_tela:                               .asciz "===================================================\n"
titulo:                                    .asciz "Simulador de elevador\n"
string_subindo:                            .asciz "Elevador %d Subindo...\n"
string_descendo:                           .asciz "Elevador %d Descendo...\n"
insira_andares:                            .asciz "Insira a quantidade de andares: "
insira_peso_maximo_elevador:               .asciz "Insira o peso maximo de cada elevador: "
insira_qtd_maxima_pessoas_elevador:        .asciz "Insira a quantidade maxima de pessoas em cada elevador: "
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
qtd_pessoas_elevador1:                     .int 0
qtd_pessoas_elevador2:                     .int 0
probabilidade_evento:                      .int 0
direcao_elevador1:                         .int 0 # SUBINDO (0) ou DESCENDO (1)
direcao_elevador2:                         .int 0 # SUBINDO (0) ou DESCENDO (1)
andar_atual_elevador1:                     .int 0
andar_atual_elevador2:                     .int 0
contador:                                  .int 0
tempo:                                     .int 0
andar_sorteado:                            .int 0
pessoas_sorteadas:                         .int 0
peso_maximo_elevador:                      .int 0
qtd_maxima_pessoas_elevador:               .int 0

limpabuf:                     .string "%*c"
formach:                      .asciz "%c"

.section .bss

# struct pessoa
# andar_alvo # 4 Bytes
# idade # 4 Bytes
# peso # 4 Bytes
# proximo # 4 Bytes

.lcomm lista_interna_elevador1, 200 # lista de pronteiros (4 Bytes cada posicao)
.lcomm lista_interna_elevador2, 200 # lista de pronteiros (4 Bytes cada posicao)
.lcomm lista_externa, 200 # lista de pronteiros (4 Bytes cada posicao)

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

      pushl $insira_peso_maximo_elevador
      call printf

      pushl $peso_maximo_elevador
      pushl $formato_int
      call scanf

      pushl $insira_qtd_maxima_pessoas_elevador
      call printf

      pushl $qtd_maxima_pessoas_elevador
      pushl $formato_int
      call scanf

      pushl $limpabuf # limpa o buffer do teclado
      call scanf # limpa o buffer do teclado
      addl $4, %esp # limpa o buffer do teclado

  loop_infinito: # rotulo para loop infinito do elevador
    pushl $divide_tela # insere string divide_tela na pilha
    call  printf # chamada externa ao printf
    addl $4, %esp # limpa pilha

    pushl $lista_interna_elevador1
    call inicializa_lista
    addl $4, %esp

    pushl $20
    call malloc

    movl $3, (%eax)
    pushl %eax
    pushl $lista_interna_elevador1
    call adiciona_pessoa_lista
    addl $8, %esp

    movl $lista_interna_elevador1, %eax
    addl $12, %eax

    # DESENVOLVER AQUI

    pushl $divide_tela # insere string divide_tela na pilha
    call  printf # chamada externa ao printf
    addl $8, %esp # limpa pilha

    call getchar # para ler o resultado antes o elevador continuar. apertar apenas ENTER

    jmp loop_infinito # loop

  fim:
    pushl $0
    call  exit