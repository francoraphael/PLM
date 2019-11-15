elevador: elevador.o
        gcc -m32 elevador.o -o elevador

elevador.o: elevador.s
        gcc -c -m32 elevador.s -o elevador.o

run: elevador
        ./elevador

.PHONY: run