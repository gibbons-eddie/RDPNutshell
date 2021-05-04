CC=/usr/bin/cc

all:  bison-config flex-config main

bison-config:
	bison -d nutshparser.y

flex-config:
	flex nutshscanner.l

main: 
	$(CC) main.c nutshparser.tab.c lex.yy.c -o main -pthread

clean:
	rm nutshparser.tab.c nutshparser.tab.h lex.yy.c main