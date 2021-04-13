#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/wait.h>
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
     // printCommandTable();
     // logic for executing GENERAL commands.

    int index = commandTable.entriesCount - 1;
    int status;
    char* cmd[commandTable.entries[index].argCount + 2];
    
    char path[50], cmdName[50];

    strcpy(path, "/bin/");
    strcpy(cmdName, commandTable.entries[index].name);

    strcat(path, cmdName);

    cmd[0] = commandTable.entries[index].name;
    
    int a = 0;
    for (; a < commandTable.entries[index].argCount; a++)
	{
		cmd[a + 1] = commandTable.entries[index].args[a];
	}
    cmd[a + 1] = NULL;

    // printf("%s\n", path);
    // printf("%s\n", cmd);

    //execv(path, cmd);

    if (fork() == 0)
    {
        execv(path, cmd);
    }
    else
    {
        wait(&status);
    }
    
    /*printf("NAME: %s ", commandTable.entries[index].name);
	printf("ARGS: ");

	for(int j=0; j < commandTable.entries[index].argCount; j++)
	{
		printf("%s ", commandTable.entries[index].args[j]);
	}

	printf("INPUT: %s OUTPUT: %s", commandTable.entries[index].inputFileName, commandTable.entries[index].outputFileName);
	printf("\n");*/


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


