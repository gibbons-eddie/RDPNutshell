%{
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include "global.h"

int yylex(void);
int yyerror(char* s);
int runCD(char* arg);
int runSetAlias(char* name, char* word);
int runUnalias(char* name);

void addToVarTable(char* var, char* val);
void addToAliasTable(char* var, char* val);

void setEnvVar(char* envVarName, char* val);
void listEnvVar();

%}

%union {char* string;}

%start cmd_line
%token <string> SETENV PRINTENV UNSETENV CD ALIAS UNALIAS BYE END WORD NAME

%%
cmd_line    :
	BYE END 		                {printf("Goodbye.\n"); exit(1); return 1;}
	| CD WORD END        			{runCD($2); return 1;}
	| ALIAS NAME WORD END			{runSetAlias($2, $3); return 1;}
	| ALIAS NAME PRINTENV END		{runSetAlias($2, $3); return 1;}
	| ALIAS NAME UNSETENV END		{runSetAlias($2, $3); return 1;}
	| ALIAS NAME CD END				{runSetAlias($2, $3); return 1;}
	| ALIAS NAME ALIAS END			{runSetAlias($2, $3); return 1;}
	| ALIAS NAME UNALIAS END		{runSetAlias($2, $3); return 1;}
	| ALIAS NAME BYE END			{runSetAlias($2, $3); return 1;}
	| UNALIAS NAME END				{runUnalias($2); return 1;}
	| SETENV NAME NAME END			{setEnvVar($2, $3); return 1;}
	| PRINTENV END					{listEnvVar(); return 1;}

%%

int yyerror(char* s) 
{
  printf("%s\n",s);
  return 0;
}

int runCD(char* arg) {
	if (arg[0] != '/') 
	{ // arg is relative path
		strcat(varTable.word[0], "/");
		strcat(varTable.word[0], arg);

		if(chdir(varTable.word[0]) == 0) 
		{
			return 1;
		}
		else 
		{
			getcwd(cwd, sizeof(cwd));
			strcpy(varTable.word[0], cwd);
			printf("Directory not found\n");
			return 1;
		}
	}
	else { // arg is absolute path
		if(chdir(arg) == 0)
		{
			strcpy(varTable.word[0], arg);
			return 1;
		}
		else 
		{
			printf("Directory not found\n");
                       	return 1;
		}
	}
}

int runSetAlias(char* name, char* word) {
	for (int i = 0; i < MAX_TABLE_LENGTH; i++) 
	{
		if(strcmp(name, word) == 0)
		{
			printf("Error, expansion of \"%s\" would create a loop.\n", name);
			return 1;
		}
		else if((strcmp(aliasTable.name[i], name) == 0))
		{
			printf("Error, expansion of \"%s\" would create a loop.\n", name);
			return 1;
		}
		else if(strcmp(aliasTable.name[i], name) == 0) 
		{
			strcpy(aliasTable.word[i], word);
			return 1;
		}
	}

	addToAliasTable(name, word);

	return 1;
}

int runUnalias(char* name)
{
	for (int i = 0; i < MAX_TABLE_LENGTH; i++)
	{
		if(strcmp(name, aliasTable.name[i]) == 0)
		{
			memset(aliasTable.name[i], '\0', sizeof(aliasTable.name[i]));
			memset(aliasTable.word[i], '\0', sizeof(aliasTable.word[i]));
		}
	}
	return 1;
}

void addToVarTable(char* var, char* word)
{
	for(int i = 0; i < MAX_TABLE_LENGTH; i++)
	{
		if(varTable.var[i][0]=='\0')
		{
			strcpy(varTable.var[i], var);
			strcpy(varTable.word[i], word);
			return;
		}
	}	

	printf("ERROR: variable table is full.");

}

void addToAliasTable(char* name, char* word)
{
    for(int i = 0; i < MAX_TABLE_LENGTH; i++)
	{
		if(aliasTable.name[i][0]=='\0')
		{
			strcpy(aliasTable.name[i], name);
			strcpy(aliasTable.word[i], word);
			return;
		}
	}	

	printf("ERROR: alias table is full.");

}

void setEnvVar(char* envVarName, char* val)
{
	for (int i = 0; i < MAX_TABLE_LENGTH; i++)
	{
		if (envTable.name[i][0] == '\0')
		{
			strcpy(envTable.name[i], envVarName);
			strcpy(envTable.value[i], val);
			return;
		}
	}

	/*printf("New environment variable: %s\n
			Its value: %s\n");*/
}

void listEnvVar()
{
	for (int i = 0; i < MAX_TABLE_LENGTH; i++)
	{
		char* tempName = envTable.name[i];
		char* tempValue = envTable.value[i];

		if (*tempName != '\0')
		{
			printf("Environment Variable: %s, Value: %s\n", tempName, tempValue);
		}
	}
}
