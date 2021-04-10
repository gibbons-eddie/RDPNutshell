%{
#include "global.h"
#include "nutshparser.tab.h"
#include <stdio.h>
#include <string.h>

bool isAlias(char* name)
{
    for(int i = 0; i < MAX_TABLE_LENGTH; i++)
    {
        if(strcmp(aliasTable.name[i], name) == 0)
        {
            return true;
        }
    }
    return false;
}

char* getAliasDefinition(char* name)
{
    for(int i = 0; i < MAX_TABLE_LENGTH; i++)
    {
        if(strcmp(aliasTable.name[i], name) == 0)
        {
            return aliasTable.word[i];
        }
    }
    //shouldn't happen
    return NULL;
}

%}
%array
%s quote_condition
%option noyywrap

CHAR        [.A-Za-z0-9!\/_-][.A-Za-z0-9!\/_-]*
ANYCHAR     [)(*&%$#@!`;,\.a-zA-Z0-9'/*_=~ -][)(*&%$#@!`;,\.a-zA-Z0-9'/*_=~ -]*  

%%

<quote_condition>{ANYCHAR}+        {yylval.string = strdup(yytext); return WORD;}
<quote_condition>[\"]              {BEGIN(INITIAL);}

[ ]         { }
setenv      {  aliasExpansion = false; yylval.string = strdup(yytext); return SETENV; }
printenv    {  aliasExpansion = false; yylval.string = strdup(yytext); return PRINTENV; }
unsetenv    {  aliasExpansion = false; yylval.string = strdup(yytext); return UNSETENV; }
cd          {  aliasExpansion = false; yylval.string = strdup(yytext); return CD; }
alias       {  aliasExpansion = false; yylval.string = strdup(yytext); return ALIAS;}
unalias     {  aliasExpansion = false; yylval.string = strdup(yytext); return UNALIAS; }
bye         {  aliasExpansion = false; yylval.string = strdup(yytext); return BYE; }
"\n"		{  aliasExpansion = false; yylval.string = strdup(yytext); return END; }
[\"]        {  aliasExpansion = false; yylval.string = strdup(yytext); BEGIN(quote_condition); }
[|]         {  aliasExpansion = false;  yylval.string = strdup(yytext); return PIPE; }
[<]         {  aliasExpansion = false;  yylval.string = strdup(yytext); return LEFTC;}
[>]         {  aliasExpansion = false;  yylval.string = strdup(yytext); return RIGHTC;}
[&]         {  aliasExpansion = false;  yylval.string = strdup(yytext); return AMPERSAND;}

(\$\{[A-Za-z]+\})    { aliasExpansion = false; yylval.string = strdup(yytext); return RUNENV; }

{CHAR}+     {
                if(aliasExpansion == true && isAlias(yytext))
                {
                    
                    char* definition = strdup(getAliasDefinition(yytext));
                    for (int i = strlen(getAliasDefinition(yytext)) - 1; i >= 0; --i )
                    {
                        unput(definition[i]);
                    }
                    free(definition);
                }
                else
                {
                    aliasExpansion = false;
                    yylval.string = strdup(yytext);
                    return WORD;
                }    
            }
%%