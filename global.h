#include <stdbool.h>
//structs
#define MAX_TABLE_LENGTH 256
#define MAX_WORD_LENGTH 256

struct variableTableStruct {
   char var[MAX_TABLE_LENGTH][MAX_WORD_LENGTH];
   char word[MAX_TABLE_LENGTH][MAX_WORD_LENGTH];
};

struct aliasTableStruct {
	char name[MAX_TABLE_LENGTH][MAX_WORD_LENGTH];
	char word[MAX_TABLE_LENGTH][MAX_WORD_LENGTH];
};

//global variables/objects
struct variableTableStruct varTable;
struct aliasTableStruct aliasTable;

char cwd [4096];





