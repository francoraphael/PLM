.section .data

divide_tela:            .asciz "\n==================================================="
titulo:                 .asciz "\nSimulador de elevador"
subindo:                .asciz "Subindo..."
descendo:               .asciz "Descendo..."
insira_andares:         .asciz "\nInsira a quantidade de andares: "
insira_probabilidade:   .asciz "\nInsira a probabilidade (em %) do evento de um andar sorteado ocorrer: "
formato_float:          .asciz "%f"
formato_int:            .asciz "%d"
string_teste_int        .asciz "\nTeste leitura inteiro: %d"
qtd_andares:            .int 0
probabilidade_evento:   .float 0


.section .text

.globl main
main:
  pushl $divide_tela # insere string divide_tela na pilha
  call  printf # chamada externa ao printf

  pushl $titulo # insere string titulo na pilha
  call  printf # chamada externa ao printf

  addl  $4,  %esp # caminha para o endereço da string divide_tela
  call printf # chamada externa ao printf

  add $4, %esp # caminha na pilha para descartar as strings divide_tela e titulo

  pushl $insira_andares # insere a string insira_andares na pilha
  call printf

  pushl $qtd_andares
  pushl $formato_int
  call scanf

  pushl %qtd_andares
  pushl %string_teste_int
  call printf

  pushl $0
  call  exit
