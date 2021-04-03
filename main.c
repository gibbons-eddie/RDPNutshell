#include <stdio.h>
#include "global.h"

int yyparse();



void shell_init()
{
    getcwd(cwd, sizeof(cwd));


    memset(varTable.var,'\0', sizeof(varTable.var));
    memset(varTable.word, '\0', sizeof(varTable.word));
    memset(aliasTable.name, '\0', sizeof(aliasTable.name));
    memset(aliasTable.word, '\0', sizeof(aliasTable.word));

    addToVarTable("HOME", cwd);
    addToVarTable("PWD", cwd);
    addToVarTable("PROMPT", "nutshell");
    addToVarTable("PATH",  ".:/bin");

}

int main()
{
    shell_init();

    for (;;)
    {
        printf("RDPSHELL:");
        yyparse();

        //this for loop is for debugging only, I left it in so you can get an idea of how the alias table looks.
        for(int i = 0; i < 5; i++)
        {
            //prints first 5 aliases in table for debugging
            printf("%i. %s ~~~ %s\n", i, aliasTable.name[i], aliasTable.word[i]);
        }

        printf("\n");
    }
}


