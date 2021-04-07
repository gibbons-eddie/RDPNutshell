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

char * getAliasDefinition(char* name)
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
%s alias_condition
%s quote_condition
%option noyywrap

CHAR        [.A-Za-z0-9!\/_-][.A-Za-z0-9!\/_-]*
ANYCHAR     [)(*&%$#@!`;,\.a-zA-Z0-9'/*_=~ -][)(*&%$#@!`;,\.a-zA-Z0-9'/*_=~ -]*  

%%

<quote_condition>{ANYCHAR}+        {yylval.string = strdup(yytext); return WORD;}
<quote_condition>[\"]              {BEGIN(INITIAL);}

<alias_condition>[ ]                {}
<alias_condition>{CHAR}+            {yylval.string = strdup(yytext); BEGIN(INITIAL); return NAME;}

[ ]         { }
setenv      {  yylval.string = strdup(yytext); return SETENV; }
printenv    {  yylval.string = strdup(yytext); return PRINTENV; }
unsetenv    {  yylval.string = strdup(yytext); return UNSETENV; }
cd          {  yylval.string = strdup(yytext); return CD; }
alias       {  yylval.string = strdup(yytext); BEGIN(alias_condition); return ALIAS;}
unalias     {  yylval.string = strdup(yytext); BEGIN(alias_condition); return UNALIAS; }
bye         {  yylval.string = strdup(yytext); return BYE; }
"\n"		{  yylval.string = strdup(yytext); return END; }
[\"]        {  yylval.string = strdup(yytext); BEGIN(quote_condition); }
{CHAR}+     {
                if(isAlias(yytext))
                {
                    char * definition = strdup(getAliasDefinition(yytext));
                    for (int i = strlen(getAliasDefinition(yytext)) - 1; i >= 0; --i )
                    {
                        unput(definition[i]);
                    }
                    free(definition);
                }
                else
                {
                    yylval.string = strdup(yytext);
                    return WORD;
                }    
            }
%%