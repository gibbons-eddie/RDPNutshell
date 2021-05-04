%{
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include "global.h"

int yylex(void);
int yyerror(char* s);
int runCD(char* arg);
int runUnalias(char* name);
void runListAlias();
void addToAliasTable(char* var, char* val);
int isInfiniteAlias(char* name, char * word);

void setEnvVar(char* envVarName, char* val);
void listEnvVar();
void deleteEnvVar(char* envVarName);

%}

%union {char* string;}

%token <string> SETENV PRINTENV UNSETENV CD ALIAS UNALIAS BYE END WORD PIPE LEFTC RIGHTC AMPERSAND REDIRECTIONF REDIRECTIONA

%%

part_four:
	|part_three AMPERSAND						{ commandTable.backgroundProcessing = true;}
	|part_three END								{ return 1; }
	|part_four END								{ return 1; }
	;

part_three:
	|part_two REDIRECTIONF WORD					{ commandTable.redirect = true; commandTable.redirectFile = true; strcpy(commandTable.redirectFileName, $3); }
	|part_two REDIRECTIONA						{ commandTable.redirect = true; }
	|part_two									{ }
	|part_two END								{ return 1; }

	;

part_two:
	part_one RIGHTC WORD						{ commandTable.outputFile = true; strcpy(commandTable.outputFileName, $3); }
	|part_one RIGHTC RIGHTC WORD				{ commandTable.outputFile = true; commandTable.append = true; strcpy(commandTable.outputFileName, $4); }
	|part_one									{ }
	|part_one END								{ return 1; }
	;

part_one:
	cmd_combined LEFTC WORD						{ commandTable.inputFile = true; strcpy(commandTable.inputFileName, $3); }
	|cmd_combined								{ }
	|cmd_combined END							{ return 1; }
	;

cmd_combined:
	cmd_g										{ }
	|cmd_bi										{ }
	;

cmd_bi    :
	BYE END 		               			{ printf("Goodbye.\n"); exit(1); return 1; }
	| CD WORD END        					{ runCD($2); return 1; }
	| CD END								{ runCD(varTable.value[HOME_INDEX]); return 1;}
	| ALIAS END								{ runListAlias(); return 1; }
	| ALIAS WORD WORD END					{ addToAliasTable($2, $3); return 1; }
	| ALIAS WORD PRINTENV END				{ addToAliasTable($2, $3); return 1; }
	| ALIAS WORD UNSETENV END				{ addToAliasTable($2, $3); return 1; }
	| ALIAS WORD CD END						{ addToAliasTable($2, $3); return 1; }
	| ALIAS WORD ALIAS END					{ addToAliasTable($2, $3); return 1; }
	| ALIAS WORD UNALIAS END				{ addToAliasTable($2, $3); return 1; }
	| ALIAS WORD BYE END					{ addToAliasTable($2, $3); return 1; }
	| UNALIAS WORD END						{ runUnalias($2); return 1; }
	| SETENV WORD WORD END					{ setEnvVar($2, $3); return 1; }
	| PRINTENV END							{ listEnvVar(); return 1; }
	| UNSETENV WORD END						{ deleteEnvVar($2); return 1; }
	| PRINTENV								{ commandTable.entriesCount++; commandTable.entries[commandTable.entriesCount-1].isBuiltin = true; commandTable.entries[commandTable.entriesCount-1].builtinPointer = listEnvVar;}
	| ALIAS									{ commandTable.entriesCount++; commandTable.entries[commandTable.entriesCount-1].isBuiltin = true; commandTable.entries[commandTable.entriesCount-1].builtinPointer = runListAlias; }
	| BYE  		               				{ printf("Goodbye.\n"); exit(1); return 1; }

	;

cmd_g:
	WORD									{ strcpy(commandTable.entries[commandTable.entriesCount++].name, $1); strcpy(commandTable.entries[commandTable.entriesCount-1].args[commandTable.entries[commandTable.entriesCount-1].argCount++], $1); commandTable.entries[commandTable.entriesCount-1].isBuiltin = false; }
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
		if(chdir(arg) == 0) 
		{
			getcwd(cwd, sizeof(cwd));
			strcpy(varTable.value[0], cwd);
			return 1;
		}
		else 
		{
			printf("Directory not found");
			return 1;
		}

}


int isInfiniteAlias(char *name, char *word)
{
	int expansions = 0;
	int oldExpansions = 0;
	int checkTable[MAX_TABLE_LENGTH] = {0};
	char buf[MAX_WORD_LENGTH];
	strcpy(buf, word);
	do
	{
		expansions = oldExpansions;
		for(int i = 0; i < MAX_TABLE_LENGTH; i++)
		{
			if (strcmp(buf, aliasTable.name[i])==0)
			{
				if(checkTable[i]==1)
				{
					return 1;
				}
				else
				{
					checkTable[i] = 1;
					strcpy(buf, aliasTable.word[i]);
					expansions++;
				}
				checkTable[i] = 1;
			}
		}
	}
	while(expansions!=oldExpansions);
	return 0;
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

void runListAlias()
{
	for (int i = 0; i < MAX_TABLE_LENGTH; i++)
	{
		if(aliasTable.name[i][0] != '\0')
		{
			printf("%s=%s\n",aliasTable.name[i], aliasTable.word[i]);
		}
	}
}

void addToAliasTable(char* name, char* word)
{
	char backupName[MAX_WORD_LENGTH]  = {'\0'};
	char backupWord [MAX_WORD_LENGTH] = {'\0'};
	int backupIndex = -1;
	
	for (int i = 0; i < MAX_TABLE_LENGTH; i++)
		{
			if (strcmp(aliasTable.name[i], name) == 0)
			{
				strcpy(backupName, aliasTable.name[i]);
				strcpy(backupWord, aliasTable.word[i]);
				backupIndex = i;

				strcpy(aliasTable.name[i], name);
				strcpy(aliasTable.word[i], word);
			}
		}

    for(int i = 0; i < MAX_TABLE_LENGTH; i++)
	{
		if(aliasTable.name[i][0]=='\0')
		{
			strcpy(aliasTable.name[i], name);
			strcpy(aliasTable.word[i], word);
			break;
		}
	}	

	if(isInfiniteAlias(name, word) == 1)
	{
		printf("ERROR: would result in an infinite alias.");
		runUnalias(name);
		if(backupIndex!=-1)
		{
			strcpy(aliasTable.name[backupIndex], backupName);
			strcpy(aliasTable.word[backupIndex], backupWord);
		}
	}

}

void setEnvVar(char* envVarName, char* val)
{

	for (int i = 0; i < MAX_TABLE_LENGTH; i++)
	{
		if (strcmp(varTable.var[i], envVarName) == 0)
		{
			strcpy(varTable.var[i], envVarName);
			strcpy(varTable.value[i], val);
			return;
		}
	}

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
			if(i == PWD_INDEX || i == HOME_INDEX || i == PROMPT_INDEX || i == PATH_INDEX)
			{
				printf("You cannot unset PWD, HOME, PROMPT, or PATH.");
			}
			else
			{
				strcpy(varTable.var[i], "");
				strcpy(varTable.value[i], "");
			}
			return;
		}
	}
}
