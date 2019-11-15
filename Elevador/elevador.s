.section .data

divide_tela:  .asciz "===================================================\n"
titulo:       .asciz "Simulador de elevador\n"
subindo:      .asciz "Subindo..."
descendo:     .asciz "Descendo..."

.section .text

.globl main
main:
  pushl $divide_tela
  call  printf

  pushl $titulo
  call  printf

  pushl $divide_tela
  call  printf

  addl  $16,  %esp
  
  pushl $0
  call  exit
