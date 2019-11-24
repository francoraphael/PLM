.section .data

divide_tela:            .asciz "\n==================================================="
titulo:                 .asciz "\nSimulador de elevador"
subindo:                .asciz "Subindo..."
descendo:               .asciz "Descendo..."
insira_andares:         .asciz "\nInsira a quantidade de andares: "
insira_probabilidade:   .asciz "\nInsira a probabilidade (em %) do evento de um andar sorteado ocorrer: "
pessoas_saindo:         .asciz "\n%d pessoa(s) saindo do elevador"
pessoas_entrando:       .asciz "\n%d pessoa(s) entrando no elevador"
pessoas_no_elevador:    .asciz "\n%d pessoa(s) dentro do elevador"
formato_int:            .asciz "%d"
chamadas_internas:      .asciz "\nChamada interna %d ida ao andar: %d"
string_teste:           .asciz "\nTeste leitura valores: %d e %d\n"
qtd_andares:            .int 0
qtd_pessoas_elevador:   .int 0
probabilidade_evento:   .int 0
direcao:                .int 0 # SUBINDO (0) ou DESCENDO (1)
andar_atual:            .int 0
qtd_pessoas_entrando:   .int 0
contador:               .int 0
tempo:                  .int 4
string_debug:           .asciz "\n Teste: %d"
string_debug_2:         .asciz "\n Teste: %X"

.section .bss

.lcomm lista_externa, 120
.lcomm lista_interna, 120

.section .text

verifica_lista_externa:
  movl $0x4, %eax # move 4 para eax
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
  pushl $pessoas_entrando # poem string para exibir qtd pessoas saindo na pilha
  call printf # chamada externa printf
  addl $8, %esp # limpa pilha
  pushl $tempo
  call time
  pushl tempo
  call srand
  addl $8, %esp
  movl qtd_pessoas_entrando, %ecx
loop_insere_lista_interna:

  loop loop_insere_lista_interna
  ret # retorna

verifica_lista_interna:
  movl $0x4, %eax # move 4 para eax
  movl andar_atual, %ebx # colocar o valor da qtd de andares em ebx
  mull %ebx # eax = eax * ebx || isso eh pra calcular o offset em bytes a ser andado na lista
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

.globl main
main:
  #movl $lista_interna, %edi
  #movl $2, (%edi)
  #movl $1, 4(%edi)

  movl $lista_externa, %edi
  movl $3, (%edi)
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

    pushl $divide_tela # insere string divide_tela na pilha
    call  printf # chamada externa ao printf
    addl $4, %esp # limpa pilha

    pushl %ecx
    call verifica_lista_interna # verifica lista interna no andar atual, imprime e remove
    call verifica_lista_externa # verifica lista externa no andar atual, imprime e adiciona
    popl %ecx

    pushl qtd_pessoas_elevador # insere quantidade de pessoas na pilha
    pushl $pessoas_no_elevador # insere string para exibir qtd de pessoas na pilha
    call printf # chamada externa ao printf

    addl $8, %esp #limpa pilha
   
    # INFOS SOBRE O ESTADO DO ELEVADOR DEVEM SER COLOCADAS AQUI

    pushl $divide_tela # insere string divide_tela na pilha
    call  printf # chamada externa ao printf
    addl $4, %esp
    
    jmp fim
    loop loop_infinito # verifica se %ecx e maior que 0, se for, vai para loop_infinito

  fim:
    pushl $0
    call  exit
