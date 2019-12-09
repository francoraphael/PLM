.section .data

divide_tela:                  .asciz "===================================================\n"
titulo:                       .asciz "Simulador de elevador\n"
string_subindo:               .asciz "Subindo...\n"
string_descendo:              .asciz "Descendo...\n"
insira_andares:               .asciz "Insira a quantidade de andares: "
insira_probabilidade:         .asciz "Insira a probabilidade (em %) do evento de um andar sorteado ocorrer: "
string_pessoas_saindo:        .asciz "%d pessoa(s) saindo do elevador\n"
string_pessoas_entrando:      .asciz "%d pessoa(s) entrando no elevador\n"
string_pessoas_no_elevador:   .asciz "%d pessoa(s) dentro do elevador\n"
string_andar_atual:           .asciz "Andar atual: %d\n"
string_chamada_interna:       .asciz "- Chamada interna ida ao andar: %d\n"
string_chamadas_externas:     .asciz "%d chamada(s) externa(s) foram feita(s) no andar %d\n"
string_limite_andares:        .asciz "Erro: quantidade de andares deve ser entre 0 e 50\n"
string_limite_probabilidade:  .asciz "Erro: probabilidade deve ser entre 0 e 100\n"
formato_int:                  .asciz "%d"
qtd_andares:                  .int 0
qtd_pessoas_elevador:         .int 0
probabilidade_evento:         .int 0
direcao:                      .int 0 # SUBINDO (0) ou DESCENDO (1)
andar_atual:                  .int 0
contador:                     .int 0
tempo:                        .int 0
andar_sorteado:               .int 0
pessoas_sorteadas:            .int 0
limpabuf:                     .string "%*c"

.section .bss

.lcomm lista_externa, 200
.lcomm lista_interna, 200

.section .text

# params
# andar, lista
incrementa_andar_na_lista: # na lista recebida incrementa o número de pessoas naquele andar em uma unidade
  pushl %ebp # boilerplate padrão
  movl %esp, %ebp # boilerplate padrão

  movl 8(%ebp), %edx # andar a ser incrementado
  movl 12(%ebp), %edi # lista a ser incrementada
  movl $4, %eax # coloca 4 em %eax (tamanho de cada pos na lista)
  mull %edx # calcula o offset a ser deslocado e poem em eax
  addl %eax, %edi # desloca na lista
  incl (%edi) # incrementa a qtd de pessoas naquele andar em 1

  popl %ebp
  ret

chamada_lista_interna: # realiza uma chamada aleatória na lista interna
  inicio_chamada_lista_interna:
    pushl qtd_andares # coloca o argumento (faixa) na pilha
    call gera_random # gera um random em eax
    addl $4, %esp # limpa a pilha
    cmpl andar_atual, %eax
    je inicio_chamada_lista_interna

    pushl %eax # adiciona andar sorteado na pilha
    pushl $string_chamada_interna # colocar string a ser printada na pilha
    call printf # chamada externa ao printf
    addl $4, %esp # limpa a pilha
    popl %eax # recupera eax

    pushl $lista_interna # adiciona argumento na pilha
    pushl %eax # adiciona argumento na pilha
    call incrementa_andar_na_lista # altera a lista interna no andar sorteado
    addl $8, %esp # limpa a pilha
    ret

# params
# andar, lista
quantidade_pessoas_andar: # devolve a quantidade de pessoas na lista e andar recebidos
  pushl %ebp # boilerplate padrão
  movl %esp, %ebp # boilerplate padrão
  movl 8(%ebp), %edi # recupera andar
  movl 12(%ebp), %esi # recupera lista
  movl $4, %eax # move o offset a ser multiplicado
  mull %edi # eax = andar * offset em bytes
  addl %eax, %esi # desloca para o andar na lista
  movl (%esi), %eax # move a qtd de pessoas naquele andar da lista pra eax
  popl %ebp
  ret

# params
# lista
existem_chamadas_direcao: # dado uma lista, usa a direção atual e verifica se existem chamadas naquela direção
  pushl %ebp # boilerplate padrão
  movl %esp, %ebp # boilerplate padrão
  movl 8(%ebp), %ebx # coloca a lista em ebx

  cmpl $0, direcao # verifica se esta subindo
  je subindo # caso verdade, pula para logica adequada
  jmp descendo # do contrario, esta descendo

  subindo: # verifica andares acima do andar atual
    movl andar_atual, %eax # move andar_atual para eax
    movl qtd_andares, %ecx # move qtd_andares para ecx
    subl %eax, %ecx # subtrai o andar_atual da qtd_andares
    decl %ecx # desconta uma unidade do ecx
    cmpl $0, %ecx # caso ecx seja zero significa que já está no último andar
    je fim_inverte # nesse caso inverte a direção

    loop_subindo:
      movl andar_atual, %eax # move andar_atual para eax
      addl %ecx, %eax # coloca em eax andar_atual + offset que falta (ecx)
      pushl %ecx  # salva o contador do loop
      pushl %ebx # coloca a lista na pilha
      pushl %eax # coloca o andar a ser verificado
      call quantidade_pessoas_andar
      addl $8, %esp # limpa pilha
      popl %ecx # recupera contador do loop
      cmpl $0, %eax # caso existe alguem no andar acima, prossegue subindo
      jg fim_prossegue

      loop loop_subindo
      jmp fim_inverte # caso todos andares acima estejam vazios, inverte direção

  descendo: # verifica andares abaixo do andar atual
    movl andar_atual, %ecx # move andar_atual para ecx
    cmpl $0, %ecx # caso esteja no terro
    je fim_inverte # inverte a direção pois não pode descer mais

    loop_descendo:
      movl %ecx, %edi # move andar_atual para edi
      decl %edi # decrementa um de edi para começar a validar os andares inferiores
      pushl %ecx # salva contador do loop
      pushl %ebx # coloca lista na pilha
      pushl %edi # coloca andar na pilha
      call quantidade_pessoas_andar # verifica se existe alguma chamada no andar naquela lista
      addl $8, %esp # limpa pilha
      popl %ecx # recupera contador do loop
      cmpl $0, %eax # caso existam chamadas na direção
      jg fim_prossegue # faz o jump para prosseguir descendo

      loop loop_descendo
      jmp fim_inverte # do contrário inverte a direção

  fim_inverte:
    movl $0, %eax # coloca o 0 como retorno em eax, representando que vai inverter a direção
    popl %ebp
    ret

  fim_prossegue: # coloca o 1 como retorno em eax, representando que vai prosseguir na direção
    movl $1, %eax
    popl %ebp
    ret


verifica_chamadas_relativas: # dado a direção do elevador, verifica se o ele prossegue na mesma direção

  pushl $lista_externa # verifica se existem chamadas na direção
  call existem_chamadas_direcao # através lista externa
  addl $4, %esp # limpa pilha
  cmpl $1, %eax # 1 no retorno representa que existem chamadas portanto não
  je prossegue_retorna # precisa verificar a proxima lista

  pushl $lista_interna # verifica se existem chaamadas na direção
  call existem_chamadas_direcao # através lista interna
  addl $4, %esp # limpa pilha
  cmpl $1, %eax # 1 no retorno representa que existem chamadas
  je prossegue_retorna # portanto prossegue

  call inverte # caso não existam chamadas em nenhuma das listas
  ret # dado a direção, inverte ela.

  prossegue_retorna:
    call prossegue
    ret

inverte: # inverte a direção do elevador incrementa ou decrementa andar
  movl direcao, %eax # move direcao para eax
  cmpl $0, %eax # verifica se esta subindo
  je inverte_descer # caso esteja, jump para rotulo adequado
  jmp inverte_subir # do contrário, inverte para subir

  inverte_descer:
    cmpl $0, andar_atual # validação para quando se está no limite inferior
    je inverte_subir # e não tem nada na direção
    movl $1, direcao # seta direção como descendo
    movl andar_atual, %eax # move andar_atual para eax
    decl %eax # decrementa o andar_atual
    movl %eax, andar_atual # atualiza variavel
    ret
  
  inverte_subir:
    movl qtd_andares, %edi # validação para quando se está no limite superior
    decl %edi # e não tem nada na direção
    cmpl andar_atual, %edi
    je inverte_descer # fim validação
    movl $0, direcao # seta direção como subindo
    movl andar_atual, %eax # move andar_atual para eax
    incl %eax # incrementa andar_atual
    movl %eax, andar_atual # atualiza variavel
    ret

prossegue: # prossegue na direção que esta indo
  movl direcao, %eax # move direcao para eax
  cmpl $0, %eax # verifica se esta subindo
  je prossegue_subindo # caso verdade, jump para rotulo adequado
  jmp prossegue_descendo # do contrario, prossegue descendo

  prossegue_subindo:
    movl andar_atual, %eax # move andar_atual para eax
    movl qtd_andares, %edi # move qtd_andares para edi
    decl %edi # decrementa um de edi para representar o último andar
    cmpl %edi, %eax # verifica se esta no ultimo andar
    je inverte_retorna # caso sim, não pode subir, portanto inverte
    incl %eax # incrementa andar atual
    movl %eax, andar_atual # atualiza variavel
    ret

  prossegue_descendo:
    movl andar_atual, %eax # move andar_atual para eax
    cmpl $0, %eax # verifica se esta no terro
    je inverte_retorna # caso sim, não pode descer mais, portanto inverte
    decl %eax # decrementa um andar
    movl %eax, andar_atual # atualiza variavel
    ret

  inverte_retorna: # rotulo para quando é necessário inverter dentro do prossegue
    call inverte
    ret
  

# params
# andar, lista
zera_pessoas_andar: # zera a quantidade de pessoas em um andar de uma lista
  pushl %ebp # boilerplate padrão
  movl %esp, %ebp # boilerplate padrão
  movl 8(%ebp), %edi # recupera andar
  movl 12(%ebp), %esi # recupera lista
  movl $4, %eax # move o offset a ser multiplicado
  mull %edi # eax = andar * offset em bytes
  addl %eax, %esi # desloca para o andar na lista
  movl $0, (%esi) # zera a qtd de pessoas naquele andar da lista
  popl %ebp
  ret

verifica_lista_externa: # verifica se alguem da lista externa vai entrar e faz chamadas internas
  pushl $lista_externa # coloca argumento na pilha
  pushl andar_atual # coloca argumento na pilha
  call quantidade_pessoas_andar # retorna em eax quantas pessoas tem no andar atual
  addl $8, %esp # limpa pilha
  pushl %eax # backup eax
  pushl $lista_externa # coloca argumento na pilha
  pushl andar_atual # coloca argumento na pilha
  call zera_pessoas_andar # remove da lista externa todas as pessoas que estão no andar atual
  addl $8, %esp # limpa pilha
  popl %eax # recupera eax
  movl qtd_pessoas_elevador, %edi # move qtd_pessoas_elevador para edi
  addl %eax, %edi # soma a qtd de pessoas entrando a qtd de pessoas já no elevador
  movl %edi, qtd_pessoas_elevador # atualiza variável
  pushl %eax # coloca a qtd de pessoas entrando na pilha
  pushl $string_pessoas_entrando # coloca string de exibição na pilha
  call printf # chamada externa ao printf
  addl $4, %esp # limpa pilha
  popl %ecx # recupera eax em ecx
  cmpl $0, %ecx # verifica se existem pessoas entrando
  je retorno # do contrário sai da função
  loop_insere_lista_interna:
    pushl %ecx # backup ecx
    call chamada_lista_interna # realiza um chamada aleatória na lista interna
    popl %ecx # recupera ecx
    loop loop_insere_lista_interna # loop
  ret
  
verifica_lista_interna: # verifica se alguem precisa sair no andar atual
  movl $4, %eax # move 4 para eax
  movl andar_atual, %ebx # colocar o valor do andar atual em ebx
  mull %ebx #  calcula o offset em bytes a ser andado na lista
  movl $lista_interna, %edi # move o inicio da lista para edi
  addl %eax, %edi # caminha na lista interna para o andar atual`
  pushl (%edi) # poem qtd_pessoa_saindo na pilha
  pushl $string_pessoas_saindo # poem string para exibir qtd pessoas saindo na pilha
  call printf # chamada externa printf
  addl $4, %esp # limpa pilha
  popl %edi
  cmpl $0, %edi # verifica se existe alguem que deseja sair naquele andar
  jle retorno # caso nao exista, sai da funcao
  movl qtd_pessoas_elevador, %ebx # move qtd_pessoas_elevador para ebx
  subl %edi, %ebx # qtd_pessoas_elevador = qtd_pessoas_elevador - qtd_string_pessoas_saindo
  movl %ebx, qtd_pessoas_elevador # atualiza qtd_pessoas_elevador
  pushl $lista_interna # coloca argumento na pilha
  pushl andar_atual # coloca argumento na pilha
  call zera_pessoas_andar # remove da lista interna todas as pessoas que sairam naquele andar
  addl $8, %esp

  ret # retorna

retorno: # metodo dummy para retornar
  ret # retorna

gera_random: # gera random com base em uma faixa passada por parametro e retorno em %eax
  pushl %ebp #boilerplate padrão
  movl %esp, %ebp # boilerplate padrão
  
  call rand # gera rand em %eax

  movl 8(%ebp), %edi # recupera faixa
  movl $0, %edx
  divl %edi # resto da divisao pela faixa é o rand de 0 até faixa - 1
  movl %edx, %eax # variavel de retorno #eax

  popl %ebp # devolve %esp original
  ret

sorteia_pessoas: # sorteia n de pessoas de 1 a 3 e devolve em eax
    pushl $3 # faixa = 3
    call gera_random # gera um random de 0 a 3 -1
    addl $4, %esp # limpa pilha
    incl %eax # para rand nao ser 0
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
      pushl qtd_andares # faixa na pilha
      call gera_random # gera um random de 0 a qtd_andares - 1
      addl $4, %esp # limpa pilha
      
      movl %eax, andar_sorteado # andar_sorteado = andar do sorteio
      cmpl andar_atual, %eax # se o andar sorteado for o atual
      je calcula # refaz o sorteio

      call sorteia_pessoas # sorteia n de pessoas que fizeram a chamada externa (vao entrar no elevador)
      movl %eax, pessoas_sorteadas

      movl pessoas_sorteadas, %ecx
      loop_pessoas:
        pushl %ecx

        pushl $lista_externa
        pushl andar_sorteado
        call incrementa_andar_na_lista
        addl $8, %esp # limpa pilha

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

      pushl $limpabuf # limpa o buffer do teclado
      call scanf # limpa o buffer do teclado
      addl $4, %esp # limpa o buffer do teclado

  loop_infinito: # rotulo para loop infinito do elevador

    pushl $divide_tela # insere string divide_tela na pilha
    call  printf # chamada externa ao printf
    addl $4, %esp # limpa pilha

    pushl andar_atual # insere quantidade de pessoas na pilha
    pushl $string_andar_atual # insere string para exibir qtd de pessoas na pilha
    call printf # chamada externa ao printf
    addl $8, %esp # limpa pilha

    call verifica_lista_interna # verifica lista interna no andar atual, imprime e remove
    call verifica_lista_externa # verifica lista externa no andar atual, imprime e adiciona

    pushl qtd_pessoas_elevador # insere quantidade de pessoas na pilha
    pushl $string_pessoas_no_elevador # insere string para exibir qtd de pessoas na pilha
    call printf # chamada externa ao printf
    addl $8, %esp # limpa pilha

    call sorteia_andares # faz os sorteios de andares e chamadas externas e modifica lista_externa
    call verifica_chamadas_relativas # movimenta elevador

    cmpl $0, direcao # verifica se esta subindo
    je print_subindo # jump para rotulo adequado
    pushl $string_descendo # do contrario poem string_descendo na pilha
    jmp print_direcao # pula para o printf
    print_subindo:
      pushl $string_subindo # coloca string_subindo na pilha
    print_direcao:
      call printf  # printa a referida string

    pushl $divide_tela # insere string divide_tela na pilha
    call  printf # chamada externa ao printf
    addl $8, %esp # limpa pilha

    call getchar # para ler o resultado antes o elevador continuar. apertar apenas ENTER

    jmp loop_infinito # loop

  fim:
    pushl $0
    call  exit
