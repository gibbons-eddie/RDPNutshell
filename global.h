#include <stdbool.h>

/* structs */
#define MAX_TABLE_LENGTH 256
#define MAX_WORD_LENGTH 256
#define PWD_INDEX 0
#define HOME_INDEX 1
#define PROMPT_INDEX 2
#define PATH_INDEX 3


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
   char * args[MAX_TABLE_LENGTH][MAX_WORD_LENGTH];

   bool isBuiltin;
   void (*builtinPointer)();

};

struct commandTable
{
   struct command entries[MAX_TABLE_LENGTH];
   int entriesCount;

   bool inputFile;
   char inputFileName [MAX_WORD_LENGTH];

   bool outputFile;
   bool append;
   char outputFileName [MAX_WORD_LENGTH];

   bool redirect;
   bool redirectFile;
   char redirectFileName [MAX_WORD_LENGTH];

   bool backgroundProcessing;
   
};

struct binaryPaths
{
   char paths[200][200];
   int count;
};

/* global variables/objects */

struct variableTable varTable;
struct aliasTable aliasTable;
struct commandTable commandTable;
struct commandTable emptyCommandTable;

char cwd[4096];

bool aliasExpansion;
bool previousWasQuoteCondition;




