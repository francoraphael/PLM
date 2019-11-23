.section .data

divide_tela:            .asciz "\n==================================================="
titulo:                 .asciz "\nSimulador de elevador"
subindo:                .asciz "Subindo..."
descendo:               .asciz "Descendo..."
insira_andares:         .asciz "\nInsira a quantidade de andares: "
insira_probabilidade:   .asciz "\nInsira a probabilidade (em %) do evento de um andar sorteado ocorrer: "
pessoas_saindo:         .asciz "\n%d pessoa(s) saindo do elevador"
pessoas_entrando:       .asciz "\n%d pessoa(s) entrando no elevador"
formato_int:            .asciz "%d"
string_teste:           .asciz "\nTeste leitura valores: %d e %d\n"
qtd_andares:            .int 0
qtd_pessoas:            .int 0
probabilidade_evento:   .int 0
direcao:                .int 0 # SUBINDO (0) ou DESCENDO (1)
andar_atual:            .int 0
string_debug:           .asciz "\n Teste: %d"

.section .bss

.lcomm lista_externa, 120
.lcomm lista_interna, 120

.section .text

verifica_lista_interna:
  movl $lista_interna, %edi
  movl 4(%edi), %ecx
  pushl %ecx
  pushl $string_debug
  call printf
  cmpl $0, %ecx
  jle retorno
  pushl 
retorno:
  ret

.globl main
main:
  movl $lista_interna, %edi
  movl $23, 4(%edi)
  movl $50, 8(%edi)

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
    addl $4, %esp

    call verifica_lista_interna
    # INFOS SOBRE O ESTADO DO ELEVADOR DEVEM SER COLOCADAS AQUI

    pushl $divide_tela # insere string divide_tela na pilha
    call  printf # chamada externa ao printf
    addl $4, %esp
    
    jmp fim
    loop loop_infinito # verifica se %ecx e maior que 0, se for, vai para loop_infinito

  fim:
    pushl $0
    call  exit
