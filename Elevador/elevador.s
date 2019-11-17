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

  pushl $probabilidade_evento # insere na pilha variável onde a probabilidade sera armazenada
  pushl $formato_int # insere o formatador de float na pilha
  call scanf # chamada externa ao scanf

  pushl probabilidade_evento
  pushl qtd_andares
  pushl $string_teste
  call printf

  addl $24, %esp

  pushl $0
  call  exit
