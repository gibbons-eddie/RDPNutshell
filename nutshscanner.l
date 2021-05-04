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

bool isEnvVariable(char* var)
{
    for(int i = 0; i < MAX_TABLE_LENGTH; i++)
    {
        if(strcmp(varTable.var[i], var) == 0)
        {
            return true;
        }
    }
    return false;
}

char* getEnvVariableValue(char* var)
{
    for(int i = 0; i < MAX_TABLE_LENGTH; i++)
    {
        if(strcmp(varTable.var[i], var) == 0)
        {
            return varTable.value[i];
        }
    }
    //shouldn't happen
    return NULL;
}




%}
%array
%s quote_condition
%s env_condition
%option noyywrap

CHAR        [.A-Za-z0-9@!\/_:-][.A-Za-z0-9@!\/_,:-]*
ANYCHAR     [)(*&%#@!`;,\.a-zA-Z0-9'/*_=~ -][)(*&%#@!`;,\.a-zA-Z0-9'/*_=~ -]*  

%%

<quote_condition>$\{{ANYCHAR}+\}   {char * copy = strdup(yytext+2);
                                     copy[strlen(copy)-1] = '\0'; 
                                     logicForEnvVarExpansion(copy);
                                    }
  
<quote_condition>{ANYCHAR}+        { strcat(yylval.string, yytext);
                                    }

<quote_condition>[\"]              { BEGIN(INITIAL);  return WORD;}


[ ]             { }
setenv          {   aliasExpansion = false; yylval.string = strdup(yytext); return SETENV; }
printenv        {   aliasExpansion = false; yylval.string = strdup(yytext); return PRINTENV; }
unsetenv        {   aliasExpansion = false; yylval.string = strdup(yytext); return UNSETENV; }
cd              {   aliasExpansion = false; yylval.string = strdup(yytext); return CD; }
alias           {   aliasExpansion = false; yylval.string = strdup(yytext); return ALIAS; }
unalias         {   aliasExpansion = false; yylval.string = strdup(yytext); return UNALIAS; }
bye             {   aliasExpansion = false; yylval.string = strdup(yytext); return BYE; }
"\n"		    {   BEGIN(INITIAL);  aliasExpansion = false; yylval.string = strdup(yytext); return END; }
[\"]            {   yylval.string = strdup(""); aliasExpansion = false;  BEGIN(quote_condition); }
[|]             {   aliasExpansion = false; yylval.string = strdup(yytext); return PIPE; }
[<]             {   aliasExpansion = false; yylval.string = strdup(yytext); return LEFTC; }
2>&1            {   aliasExpansion = false; yylval.string = strdup(yytext); return REDIRECTIONA; }
2>              {   aliasExpansion = false; yylval.string = strdup(yytext); return REDIRECTIONF; }
[>]             {   aliasExpansion = false; yylval.string = strdup(yytext); return RIGHTC; }
[&]             {   aliasExpansion = false; yylval.string = strdup(yytext); return AMPERSAND; }
<<EOF>>         {   return BYE; }
$\{{ANYCHAR}+\} {   char * copy = strdup(yytext+2);
                                     copy[strlen(copy)-1] = '\0'; 
                                     yylval.string = strdup(copy);
                                     logicForEnvVarExpansion(copy); }
{CHAR}+         {
                    if(aliasExpansion == true && isAlias(yytext))
                    {
                        //source: https://www.cs.princeton.edu/~appel/modern/c/software/flex/flex.html
                        char * definition = strdup(getAliasDefinition(yytext));
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

void logicForEnvVarExpansion(char * copy)
{
    if(isEnvVariable(copy))
    {
        //source: https://www.cs.princeton.edu/~appel/modern/c/software/flex/flex.html
        char * definition = strdup(getEnvVariableValue(copy));
        for (int i = strlen(getEnvVariableValue(copy)) - 1; i >= 0; --i )
        {
            unput(definition[i]);
        }
    free(definition);
    }
    else
    {
        //source: https://www.cs.princeton.edu/~appel/modern/c/software/flex/flex.html
        char * definition = strdup(copy);
        for (int i = strlen(copy) - 1; i >= 0; --i )
        {
            unput(definition[i]);
        }
        free(definition);
    }    

}