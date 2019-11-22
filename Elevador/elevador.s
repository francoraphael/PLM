.section .data

divide_tela:            .asciz "\n==================================================="
titulo:                 .asciz "\nSimulador de elevador"
subindo:                .asciz "Subindo..."
descendo:               .asciz "Descendo..."
insira_andares:         .asciz "\nInsira a quantidade de andares: "
insira_probabilidade:   .asciz "\nInsira a probabilidade (em %) do evento de um andar sorteado ocorrer: "
formato_int:            .asciz "%d"
string_teste:           .asciz "\nTeste leitura valores: %d e %d\n"
qtd_andares:            .int 0
probabilidade_evento:   .int 0

.section .text

.globl main
main:
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

    # INFOS SOBRE O ESTADO DO ELEVADOR DEVEM SER COLOCADAS AQUI

    pushl $divide_tela # insere string divide_tela na pilha
    call  printf # chamada externa ao printf
    addl $4, %esp

    loop loop_infinito # verifica se %ecx e maior que 0, se for, vai para loop_infinito

  fim:
    pushl $0
    call  exit
