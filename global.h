#include <stdbool.h>

/* structs */
#define MAX_TABLE_LENGTH 256
#define MAX_WORD_LENGTH 256

struct variableTable 
{
   char var[MAX_TABLE_LENGTH][MAX_WORD_LENGTH];
   char value[MAX_TABLE_LENGTH][MAX_WORD_LENGTH];
};

struct aliasTable 
{
	char name[MAX_TABLE_LENGTH][MAX_WORD_LENGTH];
	char word[MAX_TABLE_LENGTH][MAX_WORD_LENGTH];
};

struct command
{
   char name[MAX_WORD_LENGTH];
   int argCount;
   char args[MAX_TABLE_LENGTH][MAX_WORD_LENGTH];
   char inputFileName [MAX_WORD_LENGTH];
   char outputFileName [MAX_WORD_LENGTH];
};

struct commandTable
{
   struct command entries[MAX_TABLE_LENGTH];
   int entriesCount;
};

/* global variables/objects */

struct variableTable varTable;
struct aliasTable aliasTable;
struct commandTable commandTable;

char cwd[4096];

bool aliasExpansion;
bool isGeneric;





