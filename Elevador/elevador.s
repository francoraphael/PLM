.section .data

divide_tela:            .asciz "===================================================\n"
titulo:                 .asciz "Simulador de elevador\n"
subindo:                .asciz "Subindo...\n"
descendo:               .asciz "Descendo...\n"
insira_andares:         .asciz "Insira a quantidade de andares: "
insira_probabilidade:   .asciz "Insira a probabilidade (em %) do evento de um andar sorteado ocorrer: "
pessoas_saindo:         .asciz "%d pessoa(s) saindo do elevador\n"
pessoas_entrando:       .asciz "%d pessoa(s) entrando no elevador\n"
pessoas_no_elevador:    .asciz "%d pessoa(s) dentro do elevador\n"
formato_int:            .asciz "%d"
chamada_interna:        .asciz "Chamada interna %d ida ao andar: %d\n"
string_impressao_lista: .asciz "Lista posicao: %d - %d pessoas\n"
string_teste:           .asciz "\nTeste leitura valores: %d e %d\n"
qtd_andares:            .int 0
qtd_pessoas_elevador:   .int 0
probabilidade_evento:   .int 0
direcao:                .int 0 # SUBINDO (0) ou DESCENDO (1)
andar_atual:            .int 0
qtd_pessoas_entrando:   .int 0
contador:               .int 0
tempo:                  .int 0
faixa:                  .int 0
string_debug:           .asciz "\n Teste: %d"
string_debug_2:         .asciz "\n Teste: %X"

.section .bss

.lcomm lista_externa, 120
.lcomm lista_interna, 120

.section .text

imprime_lista: # imprime uma lista (interna ou externa)
  pushl %ebp
  mov %esp, %ebp
  mov 8(%ebp), %edi # recebe o endereço da lista que deve estar no topo da pilha
  pushl %edi
  pushl $string_debug_2
  call printf
  addl $8, %esp
  movl qtd_andares, %ecx # seta o tamanho do loop
  movl $0, contador # zera o contador de impressão
loop_impressao_lista:
  pushl %ecx # salva na pilha para evitar problemas
  pushl %edi # salva na pilha para evitar problemas

  pushl (%edi) # empilha o valor de edi
  pushl contador # empilha o contador
  pushl $string_impressao_lista # empilha string
  call printf # chamada ao printf

  addl $12, %esp # limpa pilha
  popl %edi # recupera edi
  addl $4, %edi # avança na lista
  popl %ecx # recupera ecx
  incl contador # incrementa o contador
  loop loop_impressao_lista # realiza o loop
  popl %ebp
  ret # retorna

incrementa_andar_na_lista: # recebe da pilha qual a lista e qual andar. nessa ordem
  popl %edx # andar a ser incrementado
  popl %edi # lista a ser incrementada
  movl $4, %eax # coloca 4 em %eax (tamanho de cada pos na lista)
  mull %edx # calcula o offset a ser deslocado e poem em eax
  addl %eax, %edi # desloca na lista
  incl (%edi) # incrementa a qtd de pessoas naquele andar em 1
  ret

verifica_lista_externa: # verifica se alguem vai entrar e faz chamadas internas
  movl $4, %eax # move 4 para eax
  movl andar_atual, %ebx # colocar o valor da qtd de andares em ebx
  mull %ebx # eax = eax * ebx || isso eh pra calcular o offset em bytes a ser andado na lista
  movl $lista_externa, %edi # move o inicio da lista para edi
  addl %eax, %edi # caminha na lista externa para o andar atual
  pushl (%edi)
  popl qtd_pessoas_entrando
  cmpl $0, qtd_pessoas_entrando # verifica se existe alguem que deseja entrar naquele andar
  jle retorno # caso nao exista, sai da funcao
  movl qtd_pessoas_elevador, %ebx # move qtd_pessoas_elevador para ebx
  addl qtd_pessoas_entrando, %ebx # qtd_pessoas_elevador = qtd_pessoas_elevador + qtd_pessoas_entrando
  movl %ebx, qtd_pessoas_elevador # atualiza qtd_pessoas_elevador
  pushl qtd_pessoas_entrando # poem qtd_pessoa_entrando na pilha
  pushl $pessoas_entrando # poem string para exibir qtd pessoas entrnado na pilha
  call printf # chamada externa printf
  addl $8, %esp # limpa pilha
  pushl $tempo
  call time
  addl $4, %esp
  pushl tempo
  call srand
  movl qtd_pessoas_entrando, %ecx
  movl $0, contador
loop_insere_lista_interna:
  #pushl %ecx # coloca o contador do loop na pilha
  incl contador # contador iniciado em 0 para fins de exibição
  call rand # chamada externa ao rand
  divl qtd_andares # sorteia um dos andares como chamada interna, o andar esta no %edx

  pushl $lista_interna
  pushl %edx
  call incrementa_andar_na_lista

  #pushl contador
  #pushl $chamada_interna
  #call printf
  #addl $12, %esp
  #popl %ecx # recupera o contado do loop
  loop loop_insere_lista_interna
  ret # retorna

verifica_lista_interna: # verifica se alguem precisa sair no andar atual
  movl $4, %eax # move 4 para eax
  movl andar_atual, %ebx # colocar o valor da qtd de andares em ebx
  mull %ebx #  calcula o offset em bytes a ser andado na lista
  movl $lista_interna, %edi # move o inicio da lista para edi
  addl %eax, %edi # caminha na lista interna para o andar atual
  cmpl $0, (%edi) # verifica se existe alguem que deseja sair naquele andar
  jle retorno # caso nao exista, sai da funcao
  movl qtd_pessoas_elevador, %ebx # move qtd_pessoas_elevador para ebx
  subl (%edi), %ebx # qtd_pessoas_elevador = qtd_pessoas_elevador - qtd_pessoas_saindo
  movl %ebx, qtd_pessoas_elevador # atualiza qtd_pessoas_elevador
  pushl (%edi) # poem qtd_pessoa_saindo na pilha
  pushl $pessoas_saindo # poem string para exibir qtd pessoas saindo na pilha
  call printf # chamada externa printf
  addl $8, %esp # limpa pilha
  ret # retorna

retorno: # metodo dummy para retornar
  ret # retorna

gera_random: # gera random com base em uma faixa passada por parametro e retorno em %eax
  pushl %ebp
  movl %esp, %ebp
  
  pushl $tempo
  call time
  addl $4, %esp
  
  pushl tempo
  call srand # modifica semente de rand com base na data atual
  call rand # gera rand em %eax
  addl $4, %esp

  movl 8(%ebp), %edi
  movl $0, %edx
  divl %edi # resto da divisao pela faixa é o rand de 0 até faixa - 1
  movl %edx, %eax # variavel de retorno #eax

  popl %ebp # devolve %esp original

  ret

calcula_probabilidade:
  movl $100, faixa
  pushl faixa
  call gera_random
  incl %eax
  addl $4, %esp # limpa pilha

  cmpl %eax, probabilidade_evento
  jg falso

  movl $1, %eax
  ret

  falso:
    movl $0, %eax
  
  ret

sorteia_andares: # sorteia n de pessoas de 1 a 3 e devolve em eax
  movl $2, faixa # faixa = 2
  pushl faixa # faixa na pilha
  call gera_random # gera um random de 0 a 2 -1
  addl $4, %esp # limpa pilha
  incl %eax # para rand nao ser 0

  movl %eax, %ecx
  verifica_andares:
    call calcula_probabilidade
    cmpl %eax, $0
    jg calcula
    ret

    calcula:
      movl qtd_andares, faixa # faixa = qtd_andares
      pushl faixa # faixa na pilha
      call gera_random # gera um random de 0 a qtd_andares - 1
      addl $4, %esp # limpa pilha
      incl %eax # para rand nao ser 0

      # CONTINUAR AQUI *** CALCULAR N DE PESSOAS E INCREMENTAR NA POSICAO DO VETOR LISTA EXTERNA A QTD DE PESSOAS CALCULADA



    loop verifica_andares

  
  ret

sorteia_pessoas: # sorteia n de pessoas de 1 a 3 e devolve em eax
    movl $3, faixa # faixa = 3
    pushl faixa # faixa na pilha
    call gera_random # gera um random de 0 a 3 -1
    addl $4, %esp # limpa pilha
    incl %eax # para rand nao ser 0
    ret

.globl main
main:
  movl $lista_interna, %edi
  movl $2, (%edi)
  movl $1, 4(%edi)

  movl $lista_externa, %edi
  movl $2, (%edi)
  movl $2, 4(%edi)

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

  pushl $insira_probabilidade # insere a string insira_probabilidade na pilha
  call printf # chamada externa ao printf

  pushl $probabilidade_evento # insere na pilha variável onde a probabilidade sera armazenada
  pushl $formato_int # insere o formatador de float na pilha
  call scanf # chamada externa ao scanf

  addl $28, %esp # limpa a pilha

  movl $0, %ecx # seta %ecx para rodar loop infinito

  loop_infinito: # rotulo para loop infinito do elevador
    incl %ecx # incrementa %ecx em 1
    pushl %ecx # salva %ecx

    pushl $divide_tela # insere string divide_tela na pilha
    call  printf # chamada externa ao printf
    addl $4, %esp # limpa pilha

    call sorteia_pessoas

    pushl %eax
    pushl $string_debug
    call printf

    pushl $lista_interna
    pushl $string_debug_2
    call printf
    addl $4, %esp
    call imprime_lista
    call verifica_lista_interna # verifica lista interna no andar atual, imprime e remove
    call verifica_lista_externa # verifica lista externa no andar atual, imprime e adiciona
    pushl $lista_interna
    call imprime_lista

    pushl qtd_pessoas_elevador # insere quantidade de pessoas na pilha
    pushl $pessoas_no_elevador # insere string para exibir qtd de pessoas na pilha
    call printf # chamada externa ao printf

    addl $8, %esp #limpa pilha
   
    # INFOS SOBRE O ESTADO DO ELEVADOR DEVEM SER COLOCADAS AQUI

    pushl $divide_tela # insere string divide_tela na pilha
    call  printf # chamada externa ao printf
    addl $4, %esp
    
    jmp fim

    popl %ecx
    loop loop_infinito # verifica se %ecx e maior que 0, se for, vai para loop_infinito

  fim:
    pushl $0
    call  exit
