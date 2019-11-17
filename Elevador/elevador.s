.section .data

divide_tela:            .asciz "\n==================================================="
titulo:                 .asciz "\nSimulador de elevador"
subindo:                .asciz "Subindo..."
descendo:               .asciz "Descendo..."
insira_andares:         .asciz "\nInsira a quantidade de andares: "
insira_probabilidade:   .asciz "\nInsira a probabilidade (em %) do evento de um andar sorteado ocorrer: "
formato_float:          .asciz "%f"
formato_int:            .asciz "%d"
string_teste:           .asciz "\nTeste leitura valores: %d e %f\n"
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

  addl  $4, %esp # caminha na pilha para descartar as strings divide_tela e titulo

  pushl $insira_andares # insere a string insira_andares na pilha
  call printf # chamada externa ao printf

  pushl $qtd_andares # insere váriavel onde a qtd de andares será armazenada
  pushl $formato_int # insere o formatador de inteiro na pilha
  call scanf # chamada externa ao scanf

  addl $8, %esp # descarta os endereços de qtd_andares e formato_int da pilha

  pushl $probabilidade_evento # insere na pilha variável onde a probabilidade sera armazenada
  pushl $formato_float # insere o formatador de float na pilha
  call scanf # chamada externa ao scanf

  addl $8, %esp # descarta os endereços de probabilidade_evento e formato_float da pilha

  pushl probabilidade_evento
  pushl qtd_andares
  pushl $string_teste
  call printf

  pushl $0
  call  exit
