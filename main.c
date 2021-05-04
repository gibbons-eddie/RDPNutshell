#include <stdio.h>
#include <string.h>
#include "global.h"
#include <unistd.h>
#include <stdlib.h>
#include <fcntl.h>
#include <pthread.h>

int yyparse();

struct binaryPaths getBinaryPaths();


void shell_init()
{
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
    previousWasQuoteCondition = false;

    emptyCommandTable.entriesCount = 0;
    emptyCommandTable.inputFile = false;
    emptyCommandTable.outputFile = false;
    emptyCommandTable.append = false;
    emptyCommandTable.redirect = false;
    emptyCommandTable.redirectFile = false;
    emptyCommandTable.backgroundProcessing = false;


}

void shell_cleanup()
{
    aliasExpansion = true;
    previousWasQuoteCondition = false;

    commandTable = emptyCommandTable;
}

int main()
{
    shell_init();

    for (;;)
    {
        printf("%s>> ", varTable.value[2]);
        yyparse();

        if(commandTable.entriesCount != 0)
        {
            executeCommandTable();
        }
    printf("\n");
    shell_cleanup();

    }
}

void executeCommandTable()
{
    //checking to see if commands exist in PATH.
    struct binaryPaths binaryPaths = getBinaryPaths(); 

    for(int i = 0; i < commandTable.entriesCount; i++)
    {
        if(commandTable.entries[i].isBuiltin)
        {
            continue;
        }

        bool found = false;
        for(int j = 0; j < binaryPaths.count; j++)
        {
            char pathCopy[MAX_WORD_LENGTH] = {'\0'};
            strcpy(pathCopy, binaryPaths.paths[j]);
            strncat(pathCopy, "/", 1);
            strcat(pathCopy, commandTable.entries[i].name);

            if(access(pathCopy, F_OK) == 0)
            {
                found = true;
                strcpy(commandTable.entries[i].args[0], pathCopy);
                break;
            }
        }

        if(found == false)
        {
            printf("%s not found", commandTable.entries[i].name);
            return;
        }
    }
    if(commandTable.backgroundProcessing)
    {
       
         if(fork()==0)
        {
             pthread_t thr;
             pthread_create(&thr, NULL, executePipeline(), NULL);
             pthread_join(thr, NULL);
        }
    }
    else
    {
      if(fork()==0)
        {
            executePipeline();
        }
        else{
            wait(NULL);
        }  
    }
    
}


int executePipeline()
{
//executePipeline() and forkProcesses() were integrated using the following source for reference. source: https://stackoverflow.com/questions/8082932/connecting-n-commands-with-pipes-in-a-shell
  int fd [2];
  int input = 0;

  if(commandTable.inputFile)
    {
        int opened = open(commandTable.inputFileName, O_RDWR|O_CREAT|O_APPEND, 0600);
        dup2(opened, 0);
    }

  for (int i = 0; i < commandTable.entriesCount - 1; i++)
    {
      pipe(fd);
      forkProcesses(input, fd[1], commandTable.entries[i]);
      close(fd[1]);
      input = fd[0];
    }

  if (input != 0)
  {
    dup2(input, 0);
  }

    if(commandTable.outputFile)
    {
        if(commandTable.append)
        {
            int opened = open(commandTable.outputFileName, O_RDWR|O_CREAT|O_APPEND, 0600);
            dup2(opened, 1);
        }
        else
        {
            int opened = open(commandTable.outputFileName, O_RDWR|O_CREAT|O_TRUNC, 0600);
            dup2(opened, 1);
        }
    }

    if(commandTable.redirect)
    {
        if(commandTable.redirectFile)
        {
            int opened = open(commandTable.redirectFileName, O_RDWR|O_CREAT|O_TRUNC, 0600);
            dup2(opened, 2);
        }
        else
        {
            dup2(1, 2);
        }
    }

    struct command lastCommand = commandTable.entries[commandTable.entriesCount-1];

    if(lastCommand.isBuiltin)
    {
        lastCommand.builtinPointer();
        exit(0);
    }

    else
    {
        char * pseudoArgs[lastCommand.argCount + 1];
        for(int z = 0; z < lastCommand.argCount; z++)
        {
            pseudoArgs[z] = lastCommand.args[z];
        }
        pseudoArgs[lastCommand.argCount] = NULL;

        execv(pseudoArgs[0], pseudoArgs);
    }
  
}

int forkProcesses(int input, int output, struct command cmd)
{
  if (fork() == 0)
    {
      if (input != 0)
        {
          dup2(input, 0);
          close(input);
        }

      if (output != 1)
        {
          dup2(output, 1);
          close(output);
        }

     if(cmd.isBuiltin)
    {
        cmd.builtinPointer();
    }
    else{
        char * pseudoArgs[cmd.argCount + 1];
            for(int z = 0; z < cmd.argCount; z++)
            {
                pseudoArgs[z] = cmd.args[z];
            }
            pseudoArgs[cmd.argCount] = NULL;

        return execv(pseudoArgs[0], pseudoArgs);
        }
    }
  return 0;
}

struct binaryPaths getBinaryPaths()
{
    struct binaryPaths ret;
    ret.count = 0;
    char * str = strdup(varTable.value[PATH_INDEX]);

    char delimiter[] = ":";

    char * tok = strtok(str, delimiter);

    while(tok != NULL)
    {
        strcpy(ret.paths[ret.count++], tok);
        tok = strtok(NULL, delimiter);
    }

    return ret;
}


