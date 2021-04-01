%{
#include <stdio.h>
#include <stdlib.h>
int yylex(); // Defined in lex.yy.c
int yyerror(char* s);
%}

%token STRING_LITERAL NUMBER_LITERAL SEMICOLON EXIT OTHER

%type <name> STRING_LITERAL
%type <number> NUMBER_LITERAL

%union {
	char name[20];
	int number;
}

%%

prog:
	stmts
;

stmts:
	| stmt SEMICOLON stmts


stmt:
	STRING_LITERAL {
					printf("String entered: %s", $1);
	}
	| NUMBER_LITERAL {
					printf("Number entered: %d", $1);
	}
	| OTHER
;

%%

int yyerror(char* s)
{
	printf("Incorrect syntax - line %s\n", s);
	return 0;
}

int main()
{
	yyparse();

	return 0;
}