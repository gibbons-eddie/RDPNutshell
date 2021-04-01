%{
// #include "token.h"
// #include <unistd.h>
#include "eddie.tab.h"
#include <stdio.h>
#include <string.h>
void displayError();
%}

numbers     ([0-9])+
alpha       ([a-zA-Z])+    

%%

"exit"                      {printf("Good night.\n"); exit(1);}
{numbers}                   {yylval.number = atoi(yytext); return (NUMBER_LITERAL);}
{alpha}                     {sscanf(yytext, "%s", yylval.name); return (STRING_LITERAL);}
";"                         {return (SEMICOLON);}
.                           {displayError(); return(OTHER);}

%%

void displayError() {
    printf("Undefined input");
}