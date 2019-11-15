.section .data

divide_tela: .asciz "===================================================\n"
titulo: .asciz "Simulador de elevador\n"
subindo: .asciz "Subindo..."
descendo: .asciz "Descendo..."

.section .text

.globl _start
_start:
  pushl $divide_tela
  call printf
  popl divide_tela

  pushl $titulo
  call printf
  popl titulo

  pushl $divide_tela
  call printf
  popl divide_tela

  pushl $0
  call exit