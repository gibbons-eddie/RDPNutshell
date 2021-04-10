#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "global.h"

int yyparse();

void shell_init()
{
    system("clear");
    
    getcwd(cwd, sizeof(cwd));

    memset(varTable.var,'\0', sizeof(varTable.var));
    memset(varTable.value, '\0', sizeof(varTable.value));
    memset(aliasTable.name, '\0', sizeof(aliasTable.name));
    memset(aliasTable.word, '\0', sizeof(aliasTable.word));

    setEnvVar("PWD", cwd);
    setEnvVar("HOME", cwd);
    setEnvVar("PROMPT", "RDPSHELL");
    setEnvVar("PATH",  ".:/bin");

    aliasExpansion = true;
    isGeneric = false;

    commandTable.entriesCount = 0;
}

void executeCommandTable()
{
     printf("\n");
     printCommandTable();
     //logic for executing GENERAL commands.
     


}

int main()
{
    shell_init();

    for (;;)
    {
        printf("%s>> ", varTable.value[2]);
        yyparse();

        if(isGeneric)
        {
            executeCommandTable();
        }

        aliasExpansion = true;
        isGeneric = false;

    }
}


