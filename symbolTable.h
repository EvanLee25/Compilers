
//Symbol table header
#include <string.h>
#include <stdio.h>
#include <ctype.h>

//@Hunter TODO: Can you add comments for what each color should be used for?
#define GREEN   "\x1b[32m"
#define BGREEN  "\x1b[1;32m"
#define RED     "\x1b[1;31m"
#define ORANGE 	"\x1b[33m"
#define BORANGE "\x1b[1;33m"
#define PINK	"\x1b[95m"
#define BPINK	"\x1b[1;95m"
#define BLUE    "\x1b[34m"
#define BBLUE   "\x1b[1;94m"
#define CYAN	"\x1b[96m"
#define BCYAN	"\x1b[1;96m"
#define BYELLOW "\x1b[1;103m"
#define GRAY	"\x1b[90m"
#define BOLD	"\e[1;37m"
#define RESET   "\x1b[0m"

#define MAX_SYMBOL_TABLES 50
#define MAX_SYMBOL_ENTRIES 100
#define MAX_AMOUNT_SCOPES 50
#define MAX_NAME_LENGTH 50

struct Entry
{
	int itemID;
	char itemName[MAX_NAME_LENGTH];  // the name of the identifier
	char itemKind[8];  // is it a function or a variable?
	char itemType[8];  // Is it int, char, etc.?
	char scope[MAX_NAME_LENGTH];     // global, or the name of the function
	int isUsed;       // 0 = F, 1 = T, is variable used? -optimization
	char value[MAX_NAME_LENGTH];
};

struct Entry symTabItems[MAX_SYMBOL_TABLES][MAX_SYMBOL_ENTRIES]; //symTabItems[50 symbol tables max][100 items in each symbol table]
char symbolTableScopes[MAX_AMOUNT_SCOPES][MAX_NAME_LENGTH]; //array of strings-> symbolTableScopes[50 different scopes][scope names can be 30 char long]
int symbolTableSizes[MAX_SYMBOL_TABLES] = {0}; //set all sizes to 0
int numOfSymbolTables = 0;

void symTabAccess(void) {
	printf(BGREEN "Symbol Table accessed.\n" RESET);
}

int getSymbolTableIndex(char scope[MAX_NAME_LENGTH]){
	for(int i = 0; i < numOfSymbolTables; i++){
		//printf("\nSYMBOL SCOPE: %s\n",symbolTableScopes[i]);
		//printf("\nSCOPE: %s\n",scope);

		if (!strcmp(symbolTableScopes[i], scope)) {
			return i;
		}
	}

	printf(RED "\nINDEX DOES NOT EXIST. ERROR IN SYMBOL TABLE: getSymbolTableIndex\n" RESET);
	return -1;
	
}

int getSymbolTableSize(int symbolTableIndex){
	return symbolTableSizes[symbolTableIndex];
}

void initializeSymbolTable(){
	strcpy(symbolTableScopes[numOfSymbolTables], "G");
	numOfSymbolTables++; //Now 1 symbol table

	for (int i = 1; i < MAX_SYMBOL_ENTRIES; i++){
		for (int j = 0; j < MAX_SYMBOL_TABLES; j++){
			strcpy(symTabItems[j][i].value,"NULL");
		}
	}

}

void removeChar(char * str, char charToRemove){
    int i, j;
    int len = strlen(str);
    for(i=0; i<len; i++)
    {
        if(str[i] == charToRemove)
        {
            for(j=i; j<len; j++)
            {
                str[j] = str[j+1];
            }
            len--;
            i--;
        }
    }
    
}

void removeBraces(char str[MAX_NAME_LENGTH]) {
	char ch = '[';
	char ch2 = ']';
	removeChar(str, ch);
	removeChar(str, ch2);
}

void addItem(char itemName[MAX_NAME_LENGTH], char itemKind[8], char itemType[8], char scope[MAX_NAME_LENGTH], int isUsed){
		for (int i = 0; i<numOfSymbolTables;i++){ //iterate through all scopes
			int str1 = strcmp(symbolTableScopes[i], scope);
			if (str1 == 0){
				int new = getSymbolTableSize(i);
				symTabItems[i][new].itemID = new;
				strcpy(symTabItems[i][new].itemName, itemName);
				strcpy(symTabItems[i][new].itemKind, itemKind);
				strcpy(symTabItems[i][new].itemType, itemType);
				strcpy(symTabItems[i][new].scope, scope);
				symTabItems[i][new].isUsed = isUsed;
				strcpy(symTabItems[i][new].value, "NULL");
				printf(BGREEN "Item added to the Symbol Table.\n" RESET);
				symbolTableSizes[i]++;
			}
		}
	
}

void addSymbolTable(char scope[MAX_NAME_LENGTH],char itemType[MAX_NAME_LENGTH]){
	strcpy(symbolTableScopes[numOfSymbolTables], scope); //scope name added
	addItem(scope,"FNC",itemType,"G",0);
	numOfSymbolTables++; //Add a symbol table
}

void addArray(char name[MAX_NAME_LENGTH], char itemKind[MAX_NAME_LENGTH], char itemType[MAX_NAME_LENGTH], char arrayRange[MAX_NAME_LENGTH], char scope[MAX_NAME_LENGTH]){
	//find right symb table to add to]
	int index = getSymbolTableIndex(scope);
	int size = getSymbolTableSize(index);
	printf(RED "\n %i \n" RESET, size);
	int tempRange = atoi(arrayRange);
	
	for (int i = size; i < size + tempRange; i++){
		char arrIndex[MAX_NAME_LENGTH]; //foo[0]
		sprintf(arrIndex, "%s[%d]", name, i - size);
		addItem(arrIndex, itemKind, itemType, scope, 0);
	}
}

char* getVariableType(char itemName[MAX_NAME_LENGTH], char scope[MAX_NAME_LENGTH]){
	int index = getSymbolTableIndex(scope);
	int size = getSymbolTableSize(index);

	for(int i=0; i<size; i++){
		int str1 = strcmp(symTabItems[index][i].itemName, itemName); 
		int str2 = strcmp(symTabItems[index][i].scope, scope); 

		if( str1 == 0 && str2 == 0){
			return symTabItems[index][i].itemType;
		}
	}
	return NULL;
}

void updateValue(char itemName[MAX_NAME_LENGTH], char scope[MAX_NAME_LENGTH], char value[MAX_NAME_LENGTH]) {
	int index = getSymbolTableIndex(scope);
	int size = getSymbolTableSize(index);

	for(int i=0; i<size; i++){
		int str1 = strcmp(symTabItems[index][i].itemName, itemName); 
		int str2 = strcmp(symTabItems[index][i].scope, scope); 
		
		// get variable type
		char* type = getVariableType(itemName, scope);

		// determine if its int or char
		int isInt = strcmp(type, "INT");
		int isChar = strcmp(type, "CHR");
		int isFloat = strcmp(type, "FLT");

		if( str1 == 0 && str2 == 0 ) {
			strcpy(symTabItems[index][i].value, value); // update value in sym table
		}
	}

}

void updateParameter(int indx, char scope[MAX_NAME_LENGTH], char value[MAX_NAME_LENGTH], int count) {
	int index = getSymbolTableIndex(scope);
	int size = getSymbolTableSize(index);

	strcpy(symTabItems[index][indx].value, value); // update value in sym table

}

void updateArrayValue(char itemName[MAX_NAME_LENGTH], int arrayIndex ,char scope[MAX_NAME_LENGTH], char type[MAX_NAME_LENGTH], char value[MAX_NAME_LENGTH]){
	int index = getSymbolTableIndex(scope);
	int size = getSymbolTableSize(index);

	char arrIndexName[MAX_NAME_LENGTH]; //foo[0] for lookup
	sprintf(arrIndexName, "%s[%d]", itemName, arrayIndex);

	for(int i=0; i<size; i++){//look for variable in symbol table
		//returns 0 if true/same
		int str1 = strcmp(symTabItems[index][i].itemName, arrIndexName);  //check for same variable name
		int str2 = strcmp(symTabItems[index][i].scope, scope);  //check for same scope
		int str3 = strcmp(symTabItems[index][i].itemType, type); //check for same typing

		if( str1 == 0 && str2 == 0 && str3 == 0 ) {
			
			strcpy(symTabItems[index][i].value, value); // update value in sym table
		}
	}
	printf(BGREEN "Updated Array Index Value.\n"RESET);
}

int getItemID(char itemName[MAX_NAME_LENGTH], char scope[MAX_NAME_LENGTH]) {
	int index = getSymbolTableIndex(scope);
	int size = getSymbolTableSize(index);
	//printf(BPINK "\nSCOPE = %s" RESET, scope);
	//printf(BPINK "\ngetItemID:  itemID = %s" RESET, itemName);
	for(int i=0; i<size; i++){
		int str1 = strcmp(symTabItems[index][i].itemName, itemName); 
		
		if( str1 == 0 ) {
			return symTabItems[index][i].itemID;
		}
	}
	return 0;

}

char* getValue(char itemName[MAX_NAME_LENGTH], char scope[MAX_NAME_LENGTH]) {
	int index = getSymbolTableIndex(scope);
	int size = getSymbolTableSize(index);
	for(int i=0; i<size; i++){
		int str1 = strcmp(symTabItems[index][i].itemName, itemName); 
		int str2 = strcmp(symTabItems[index][i].scope, scope); 
		if( str1 == 0 && str2 == 0){
			return symTabItems[index][i].value;
		}
	}
	return NULL;
}

void showSymTable(){
	
	for (int i = 0; i < numOfSymbolTables; i++){
		int index = i;
		int size = getSymbolTableSize(index);
		printf(BOLD "\n\n--------------------------------%s------------------------------------\n" RESET,symbolTableScopes[i]);
		printf(BOLD "itemID    itemName    itemKind    itemType    itemScope    isUsed    value\n" RESET);
		printf(BOLD "----------------------------------------------------------------------------\n" RESET);

		for (int j=0; j<size; j++){
			printf(BOLD "%3d " RESET, symTabItems[index][j].itemID);
			printf(BORANGE "%11s  " RESET, symTabItems[index][j].itemName);
			printf(BOLD "%11s  %10s %11s %10i " RESET, symTabItems[index][j].itemKind, symTabItems[index][j].itemType, symTabItems[index][j].scope, symTabItems[index][j].isUsed);
			
			// if value is null print gray
			if (strcmp(symTabItems[index][j].value, "NULL") == 0) {
				printf(GRAY "%9s\n" RESET, symTabItems[index][j].value);
			} else {
				printf(BORANGE "%9s\n" RESET, symTabItems[index][j].value);
			}
		}
	}
	
	printf(BOLD "----------------------------------------------------------------------------\n" RESET);
}

int found(char itemName[MAX_NAME_LENGTH], char scope[MAX_NAME_LENGTH]){
	int index = getSymbolTableIndex(scope);
	int size = getSymbolTableSize(index);
	
	for(int i=0; i<size; i++){
		int str1 = strcmp(symTabItems[index][i].itemName, itemName); 
		int str2 = strcmp(symTabItems[index][i].scope,scope); 

		if( str1 == 0 && str2 == 0){
			return 1; // found the ID in the table
		}
	}
	printf(BGREEN "CHECK PASSED: Variable name is not already used.\n" RESET);
	return 0;
}

int initialized(char itemName[MAX_NAME_LENGTH], char scope[MAX_NAME_LENGTH]){
	char val[50];
	int index = getSymbolTableIndex(scope);
	int size = getSymbolTableSize(index);
	
	for(int i=0; i<size; i++){
		int str1 = strcmp(symTabItems[index][i].itemName, itemName); 
		int str2 = strcmp(symTabItems[index][i].scope,scope); 
		int str3 = strcmp(symTabItems[index][i].value, "NULL");

		if(str1 == 0 && str2 == 0){
			if (str3 != 0) {
				printf(BGREEN "CHECK PASSED: Variable '%s' is assigned to a value.\n" RESET, itemName);
				return 1; // found the ID in the table
			}
		}
	}
	printf(RED "CHECK FAILED: Syntax Error: Variable '%s' has not yet been assigned to a value.\n\n" RESET, itemName);
	exit(0);
	return 0;
}

int compareTypes(char itemName1[50], char itemName2[50], char scope[MAX_NAME_LENGTH]){

	char* idType1 = getVariableType(itemName1, scope);
	char* idType2 = getVariableType(itemName2, scope);
	
	int typeMatch = strcmp(idType1, idType2);
	if(typeMatch == 0){
		printf(BGREEN "CHECK PASSED: Types are the same: %s = %s\n" RESET, idType1, idType2);
		return 1; // types are matching
	}
	else {
		printf(RED "CHECK FAILED: Types are not the same: %s = %s\n\n" RESET, idType1, idType2);
		exit(0); // types are not matching
		return 0;
	}
}

char* getVariableKind(char itemName[MAX_NAME_LENGTH], char scope[MAX_NAME_LENGTH]){
	int index = getSymbolTableIndex(scope);
	int size = getSymbolTableSize(index);
	for(int i=0; i<size; i++){
		int str1 = strcmp(symTabItems[index][i].itemName, itemName); 
		int str2 = strcmp(symTabItems[index][i].scope, scope); 

		if( str1 == 0 && str2 == 0){
			return symTabItems[index][i].itemKind;
		}
	}
	return NULL;
}

int compareKinds(char itemName1[50], char itemName2[50], char scope[MAX_NAME_LENGTH]){

	char* idKind1 = getVariableKind(itemName1, scope);
	char* idKind2 = getVariableKind(itemName2, scope);
	
	int kindMatch = strcmp(idKind1, idKind2);
	if(kindMatch == 0){
		printf(BGREEN "CHECK PASSED: Kinds are the same: %s = %s\n" RESET, idKind1, idKind2);
		return 1; // kinds are matching
	}
	else {
		printf(RED "CHECK FAILED: Kinds are not the same: %s = %s\n\n" RESET, idKind1, idKind2);
		exit(0); // kinds are not matching
		return 0;
	}
}
    
/*-----------------OPTIMIZATION FUNCTIONS-----------------------------------*/

int redundantValue(char itemName[MAX_NAME_LENGTH], char scope[MAX_NAME_LENGTH], char value[MAX_NAME_LENGTH]) {
	int index = getSymbolTableIndex(scope);
	int size = getSymbolTableSize(index);
	for(int i=0; i<size; i++){
		int str1 = strcmp(symTabItems[index][i].itemName, itemName); 
		int str2 = strcmp(symTabItems[index][i].scope, scope); 
		int str3 = strcmp(symTabItems[index][i].value, value);

		if( str1 == 0 && str2 == 0 && str3 == 0){
			return 0;
		}	
	}
	return 1;
}

void isUsed(char itemName[MAX_NAME_LENGTH], char scope[MAX_NAME_LENGTH]) {
	int index = getSymbolTableIndex(scope);
	int size = getSymbolTableSize(index);
	for(int i=0; i<size; i++){
		int str1 = strcmp(symTabItems[index][i].itemName, itemName); 
		int str2 = strcmp(symTabItems[index][i].scope, scope); 

		if( str1 == 0 && str2 == 0) {
			symTabItems[index][i].isUsed = 1; // update value in sym table
		}
	}

}

int isChar(char itemName[MAX_NAME_LENGTH], char scope[MAX_NAME_LENGTH]) {
	char* type = getVariableType(itemName, scope);
	int isChar = strcmp(type, "CHR");

	if (isChar == 0) {
		return 1; // check failed
	} else {
		return 0;
	}
}

char* removeApostrophes(char str[50]) {

	char *result = str + 1; // removes first character
    result[strlen(result) - 1] = '\0'; // removes last character
	return result;

}

/*
//go through symbol table and look for isUsed = 0.
//then 
void cleanAssemblyCodeOfUnsuedVariables(){
	int unusedVariables[200]; //make array with size equal to number of variables in symbol table
	int counter = 0;
	printf(BCYAN "Looking for unused variables to remove.\n" RESET);
	
	for(int i=0; i<symTabIndex; i++){
		//check if any variable in the symbol table is unused. If so add to array
		if(symTabItems[i].isUsed == 0){
			//printf("ITEM NAME: %s \n",symTabItems[i].itemName); //troubleshoot
			unusedVariables[counter] = symTabItems[i].itemID;
			counter++;

		}
		
	}	
	
	for(int i=0;i<counter;i++){
		printf(BCYAN "\n$T%i is unused, removing from optimized MIPS code.\n" RESET,unusedVariables[i]);
	}
	//https://stackoverflow.com/questions/3501338/c-read-file-line-by-line


	
	
}
*/
