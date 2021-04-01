default:
	flex -l lexer.l
	bison -dv eddie.y
	gcc -o test eddie.tab.c lex.yy.c -lfl
	clear

clean:
	rm test eddie.tab.c eddie.tab.h lex.yy.c eddie.output
	clear