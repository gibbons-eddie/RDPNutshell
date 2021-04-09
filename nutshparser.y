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
void addToAliasTable(char* var, char* val);

void setEnvVar(char* envVarName, char* val);
void listEnvVar();
void deleteEnvVar(char* envVarName);

%}

%union {char* string;}

%token <string> SETENV PRINTENV UNSETENV CD ALIAS UNALIAS BYE END WORD PIPE LEFTC RIGHTC AMPERSAND

%%

part_four:
	|part_three AMPERSAND						{ }
	|part_three END								{ return 1; }
	|part_four END								{ return 1; }
	;

part_three:
	part_two WORD RIGHTC WORD					{ }
	|part_two WORD RIGHTC AMPERSAND WORD		{ }
	|part_two END								{ return 1; }

	;

part_two:
	part_one RIGHTC WORD						{ strcpy(commandTable.entries[commandTable.entriesCount-1].outputFileName, $3); }
	|part_one RIGHTC RIGHTC WORD				{ strcpy(commandTable.entries[commandTable.entriesCount-1].outputFileName, $3); }
	|part_one									{ }
	|part_one END								{ return 1; }
	;

part_one:
	cmd_combined LEFTC WORD						{ strcpy(commandTable.entries[commandTable.entriesCount-1].inputFileName, $3); }
	|cmd_combined								{ }
	|cmd_combined END							{ return 1; }
	;

cmd_combined:
	cmd_g									{}
	|cmd_bi									{}
	;

cmd_bi    :
	BYE END 		               			{ printf("Goodbye.\n"); exit(1); return 1; }
	| CD WORD END        					{ runCD($2); return 1; }
	| ALIAS END								{ runListAlias(); return 1; }
	| ALIAS WORD WORD END					{ runSetAlias($2, $3); return 1; }
	| ALIAS WORD PRINTENV END				{ runSetAlias($2, $3); return 1; }
	| ALIAS WORD UNSETENV END				{ runSetAlias($2, $3); return 1; }
	| ALIAS WORD CD END						{ runSetAlias($2, $3); return 1; }
	| ALIAS WORD ALIAS END					{ runSetAlias($2, $3); return 1; }
	| ALIAS WORD UNALIAS END				{ runSetAlias($2, $3); return 1; }
	| ALIAS WORD BYE END					{ runSetAlias($2, $3); return 1; }
	| UNALIAS WORD END						{ runUnalias($2); return 1; }
	| SETENV WORD WORD END					{ setEnvVar($2, $3); return 1; }
	| PRINTENV END							{ listEnvVar(); return 1; }
	| UNSETENV WORD END						{ deleteEnvVar($2); return 1; }
	;

cmd_g:
	WORD									{ isGeneric = true; strcpy(commandTable.entries[commandTable.entriesCount++].name, $1); }
	|cmd_g WORD								{ strcpy(commandTable.entries[commandTable.entriesCount-1].args[commandTable.entries[commandTable.entriesCount-1].argCount++], $2); }
	|cmd_g PIPE cmd_g						{ }
	;

%%

int yyerror(char* s) 
{
    printf("%s\n",s);
    return 0;
}

int runCD(char* arg) {
	if (arg[0] != '/') 
	{ // arg is relative path
		strcat(varTable.value[0], "/");
		strcat(varTable.value[0], arg);

		if(chdir(varTable.value[0]) == 0) 
		{
			return 1;
		}
		else 
		{
			getcwd(cwd, sizeof(cwd));
			strcpy(varTable.value[0], cwd);
			printf("Directory not found\n");
			return 1;
		}
	}
	else { // arg is absolute path
		if(chdir(arg) == 0)
		{
			strcpy(varTable.value[0], arg);
			return 1;
		}
		else 
		{
			printf("Directory not found\n");
                       	return 1;
		}
	}
}

int runSetAlias(char* name, char* word)
{
	for (int i = 0; i < MAX_TABLE_LENGTH; i++) 
	{
		#pragma endregion test
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

int runListAlias()
{
	for (int i = 0; i < MAX_TABLE_LENGTH; i++)
	{
		if(aliasTable.name[i][0] != '\0')
		{
			printf("alias %s='%s'\n",aliasTable.name[i], aliasTable.word[i]);
		}
	}
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
		if (varTable.var[i][0] == '\0')
		{
			strcpy(varTable.var[i], envVarName);
			strcpy(varTable.value[i], val);
			return;
		}
	}

	printf("ERROR: variable table is full.");
}

void listEnvVar()
{
	for (int i = 0; i < MAX_TABLE_LENGTH; i++)
	{
		char* tempName = varTable.var[i];
		char* tempValue = varTable.value[i];

		if (*tempName != '\0')
		{
			printf("%s=%s\n", tempName, tempValue);
		}
	}
}

void deleteEnvVar(char* envVarName)
{
	for (int i = 0; i < MAX_TABLE_LENGTH; i++)
	{
		char* tempName = varTable.var[i];
		char* tempValue = varTable.value[i];

		if (*tempName == *envVarName)
		{
			strcpy(varTable.var[i], "");
			strcpy(varTable.value[i], "");

			return;
		}
	}
}

void printCommandTable()
{
	for (int i = 0; i < commandTable.entriesCount; i++)
	{
		printf("NAME: %s ", commandTable.entries[i].name);
		printf("ARGS: ");

		for(int j=0; j < commandTable.entries[i].argCount; j++)
		{
			printf("%s ", commandTable.entries[i].args[j]);
		}

		printf("INPUT: %s OUTPUT: %s", commandTable.entries[i].inputFileName, commandTable.entries[i].outputFileName);

		printf("\n");

	}
}