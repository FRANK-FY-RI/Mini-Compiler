SHELL = /bin/bash

build/parser: ./build/lex.yy.o ./build/y.tab.o 
	gcc -O2 ./build/lex.yy.o ./build/y.tab.o -o build/parser

build/debug: ./build/lex.yy.o ./build/y.tab.o 
	gcc -g -O0 -fsanitize=address -fno-omit-frame-pointer \
		./build/lex.yy.o ./build/y.tab.o -o build/debug -lfl

build/lex.yy.o: ./build/lex.yy.c ./build/y.tab.h
	gcc ./build/lex.yy.c -I . -c -o ./build/lex.yy.o

build/lex.yy.c: ./src/lex_file.l
	lex -o ./build/lex.yy.c ./src/lex_file.l

build/y.tab.o: ./build/y.tab.c ./include/support-functions.h
	gcc ./build/y.tab.c -I include/ -c -o ./build/y.tab.o

build/y.tab.c build/y.tab.h &: ./src/yacc_file.y
	yacc -d -o ./build/y.tab.c ./src/yacc_file.y

.PHONY: clean 

clean:
	rm build/*

