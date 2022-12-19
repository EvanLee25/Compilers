
//Symbol table header
#include <string.h>
#include <stdio.h>
#include <ctype.h>

// color definitions for console output
#define GREEN   "\x1b[32m" // green
#define BGREEN  "\x1b[1;32m" // bold green
#define RED     "\x1b[1;31m" // red
#define ORANGE 	"\x1b[33m" // orange
#define BORANGE "\x1b[1;33m" // bold orange
#define PINK	"\x1b[95m" // pink
#define BPINK	"\x1b[1;95m" // bold pink
#define BLUE    "\x1b[34m" // blue
#define BBLUE   "\x1b[1;94m" // bold blue
#define CYAN	"\x1b[96m" // cyan
#define BCYAN	"\x1b[1;96m" // bold cyan
#define BYELLOW "\x1b[1;103m" // bold yellow
#define GRAY	"\x1b[90m" // gray
#define BOLD	"\e[1;37m" // bold white
#define RESET   "\x1b[0m" // reset color

// definitions of amounts and lengths
#define MAX_SYMBOL_TABLES 50 // maximum numbers of symbol tables
#define MAX_SYMBOL_ENTRIES 150 // maximum symbol table entries
#define MAX_AMOUNT_SCOPES 50 // maximum amount of scopess
#define MAX_NAME_LENGTH 50 // maximum length of a name

// struct for an entry to the symbol table
struct Entry
{
	int itemID; // id of the entry
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
int numOfSymbolTables = 0; // initialize number of symbol tables as 0

// function to access the symbol table
void symTabAccess(void) {

	printf(BGREEN "Symbol Table accessed.\n" RESET); // output to console

}

// function to get the index of the symbol table for the scope that is passed in
int getSymbolTableIndex(char scope[MAX_NAME_LENGTH]){

	// loop from 0 to the number of symbol tables total
	for(int i = 0; i < numOfSymbolTables; i++){
		if (!strcmp(symbolTableScopes[i], scope)) { // if the name of the symbol table is equal to the scope
			return i; // return the index
		}
	}
	printf(RED "\nINDEX DOES NOT EXIST. ERROR IN SYMBOL TABLE: getSymbolTableIndex\n" RESET); // error message
	return -1;
	
}

// function to get the size of the symbol table passed in
int getSymbolTableSize(int symbolTableIndex){

	return symbolTableSizes[symbolTableIndex]; // return the size of the symbol table by accessing the array of symbol table sizes

}

// function to initialize the global symbol table
void initializeSymbolTable(){

	strcpy(symbolTableScopes[numOfSymbolTables], "G"); // copy "G" into the next entry in the symbol table array
	numOfSymbolTables++; // increment number of symbol tables

	// loop from 1 to the maximum symbol table entries
	for (int i = 1; i < MAX_SYMBOL_ENTRIES; i++){
		// loop from 0 to the maximum symbol tables
		for (int j = 0; j < MAX_SYMBOL_TABLES; j++){
			strcpy(symTabItems[j][i].value,"NULL"); // copy NULL into all values in the table
		}
	}

}

// function to remove a character from a string
void removeChar(char * str, char charToRemove){

    int i, j; // initialize two coounter variables
    int len = strlen(str); // compute the length of the string

	// loop from 0 to the length of the string
    for(i = 0; i < len; i++) {
        if(str[i] == charToRemove) { // if the character is the character to remove
			// loop from i to the length
            for(j = i; j < len; j++) {
                str[j] = str[j+1]; // set the current character t the next entry for every char after the char to remove
            }
            len--; // decrement the length
            i--; // decrement i
        }
    }
    
}

// function to remove braces from a string
void removeBraces(char str[MAX_NAME_LENGTH]) {

	char ch = '['; // initialize the left brace char
	char ch2 = ']'; // initialize the right brace char
	removeChar(str, ch); // remove the left brace from the string
	removeChar(str, ch2); // remove the right brace from the string

}

// function to add an item to a symbol table
void addItem(char itemName[MAX_NAME_LENGTH], char itemKind[8], char itemType[8], char scope[MAX_NAME_LENGTH], int isUsed) {

		// loop from 0 to the number of symbol tables
		for (int i = 0; i < numOfSymbolTables; i++){ // iterate through all scopes
			int str1 = strcmp(symbolTableScopes[i], scope); // compare scope to the name of the symbol table
			if (str1 == 0){ // if the scope is equal to the name of the symbol table
				int new = getSymbolTableSize(i); // get the index of the symbol table
				symTabItems[i][new].itemID = new; // set the itemID equal to the index
				strcpy(symTabItems[i][new].itemName, itemName); // set the name according to parameter
				strcpy(symTabItems[i][new].itemKind, itemKind); // set the kind according to parameter
				strcpy(symTabItems[i][new].itemType, itemType); // set the type according to parameter
				strcpy(symTabItems[i][new].scope, scope); // set scope according to current scope
				symTabItems[i][new].isUsed = isUsed; // set isUsed according to parameter
				strcpy(symTabItems[i][new].value, "NULL"); // set value to NULL
				printf(BGREEN "Item added to the Symbol Table.\n" RESET); // console output
				symbolTableSizes[i]++; // increment symbol table sizes
			}
		}
	
}

// function to add a symbol table (when there's a function in the source code)
void addSymbolTable(char scope[MAX_NAME_LENGTH],char itemType[MAX_NAME_LENGTH]){

	strcpy(symbolTableScopes[numOfSymbolTables], scope); // set the symbol table name to the scope
	addItem(scope,"FNC",itemType,"G",0); // add the function to the global scope
	numOfSymbolTables++; // increment number of symbol tables

}

// function to add an array to a symbol table
void addArray(char name[MAX_NAME_LENGTH], char itemKind[MAX_NAME_LENGTH], char itemType[MAX_NAME_LENGTH], char arrayRange[MAX_NAME_LENGTH], char scope[MAX_NAME_LENGTH]){
	
	// determine the correct symbol table to add the array to
	int index = getSymbolTableIndex(scope); // get index
	int size = getSymbolTableSize(index); // get size
	printf(RED "\n %i \n" RESET, size); // console output
	int tempRange = atoi(arrayRange); // set range to arrayRange
	
	// loop from size to size + range
	for (int i = size; i < size + tempRange; i++){
		char arrIndex[MAX_NAME_LENGTH]; // array to hold index
		sprintf(arrIndex, "%s[%d]", name, i - size); // turn i - size into a string
		addItem(arrIndex, itemKind, itemType, scope, 0); // add item to symbol table
	}
}

char* getVariableType(char itemName[MAX_NAME_LENGTH], char scope[MAX_NAME_LENGTH]){
	int index = getSymbolTableIndex(scope);
	int size = getSymbolTableSize(index);

	//search through scoped table first
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

		if( str1 == 0 && str2 == 0 ) {
			strcpy(symTabItems[index][i].value, value); // update value in sym table
		}
	}

}


void updateValue2(char itemName[MAX_NAME_LENGTH], char scope[MAX_NAME_LENGTH], char value[MAX_NAME_LENGTH]) {
	int index = getSymbolTableIndex(scope);
	int size = getSymbolTableSize(index);
	
	if(strcmp(scope,"G") == 1){ //If scope is not global do below
		
		for(int i=0; i<size; i++){
			int str1 = strcmp(symTabItems[index][i].itemName, itemName); 
			if( str1 == 0 ) {
				strcpy(symTabItems[index][i].value, value); // update value in sym table
				return;
			}	
		} 

		size = getSymbolTableSize(0); //get global scope size
		for(int i=0; i<size; i++){
			int str1 = strcmp(symTabItems[0][i].itemName, itemName); 
		
			if( str1 == 0 ) {
				strcpy(symTabItems[0][i].value, value); // update value in sym table
				return;
			}
		} 
	}
	

	else {
		for(int i=0; i<size; i++){
			int str1 = strcmp(symTabItems[index][i].itemName, itemName); 
			if( str1 == 0 ) {
				strcpy(symTabItems[index][i].value, value); // update value in sym table
			}
		}
	}

}

void updateParameter(int indx, char scope[MAX_NAME_LENGTH], char value[MAX_NAME_LENGTH], int count) {
	int index = getSymbolTableIndex(scope);
	int size = getSymbolTableSize(index);

	strcpy(symTabItems[index][indx].value, value); // update value in sym table

}

char* getNameByID(char id[MAX_NAME_LENGTH], char scope[MAX_NAME_LENGTH]) {

	int itemID = atoi(id);
	int index = getSymbolTableIndex(scope);
	int size = getSymbolTableSize(index);

	for(int i=0; i<size; i++) {
		//printf(BPINK "\nHERE\n" RESET);
		int str2 = strcmp(symTabItems[index][i].scope, scope); 
		
		if (symTabItems[index][i].itemID == itemID && str2 == 0) {
			return symTabItems[index][i].itemName;
		}
	}
	return NULL;

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
	//printf(RED "CHECK FAILED: Syntax Error: Variable '%s' has not yet been assigned to a value.\n\n" RESET, itemName);
	//exit(0);
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

int compareIntOp(char str[50], int temp1, int temp2) {
	if (!strcmp(str, "==")) {
		if (temp1 == temp2) {
			printf(BPINK "Condition: %d == %d passed.\n" RESET, temp1, temp2);
			return 1;
		} else {
			printf(BPINK "Condition: %d == %d NOT passed.\n" RESET, temp1, temp2);
		}
	} 
	else if (!strcmp(str, "<")) {
		if (temp1 < temp2) {
			printf(BPINK "Condition: %d < %d passed.\n" RESET, temp1, temp2);
			return 1;
		} else {
			printf(BPINK "Condition: %d < %d NOT passed.\n" RESET, temp1, temp2);
		}
	}
	else if (!strcmp(str, ">")) {
		if (temp1 > temp2) {
			printf(BPINK "Condition: %d > %d passed.\n" RESET, temp1, temp2);
			return 1;
		} else {
			printf(BPINK "Condition: %d > %d NOT passed.\n" RESET, temp1, temp2);
		}
	}
	else if (!strcmp(str, "<=")) {
		if (temp1 <= temp2) {
			printf(BPINK "Condition: %d <= %d passed.\n" RESET, temp1, temp2);
			return 1;
		} else {
			printf(BPINK "Condition: %d <= %d NOT passed.\n" RESET, temp1, temp2);
		}
	}
	else if (!strcmp(str, ">=")) {
		if (temp1 >= temp2) {
			printf(BPINK "Condition: %d >= %d passed.\n" RESET, temp1, temp2);
			return 1;
		} else {
			printf(BPINK "Condition: %d >= %d NOT passed.\n" RESET, temp1, temp2);
		}
	}
	else if (!strcmp(str, "!=")) {
		if (temp1 != temp2) {
			printf(BPINK "Condition: %d != %d passed.\n" RESET, temp1, temp2);
			return 1;
		} else {
			printf(BPINK "Condition: %d != %d NOT passed.\n" RESET, temp1, temp2);
		}
	}
	return 0;
}

int compareFloatOp(char str[50], float temp1, float temp2) {
	if (!strcmp(str, "==")) {
		if (temp1 == temp2) {
			printf(BPINK "Condition: %f == %f passed.\n" RESET, temp1, temp2);
			return 1;
		} else {
			printf(BPINK "Condition: %f == %f NOT passed.\n" RESET, temp1, temp2);
		}
	} 
	else if (!strcmp(str, "<")) {
		if (temp1 < temp2) {
			printf(BPINK "Condition: %f < %f passed.\n" RESET, temp1, temp2);
			return 1;
		} else {
			printf(BPINK "Condition: %f < %f NOT passed.\n" RESET, temp1, temp2);
		}
	}
	else if (!strcmp(str, ">")) {
		if (temp1 > temp2) {
			printf(BPINK "Condition: %f > %f passed.\n" RESET, temp1, temp2);
			return 1;
		} else {
			printf(BPINK "Condition: %f > %f NOT passed.\n" RESET, temp1, temp2);
		}
	}
	else if (!strcmp(str, "<=")) {
		if (temp1 <= temp2) {
			printf(BPINK "Condition: %f <= %f passed.\n" RESET, temp1, temp2);
			return 1;
		} else {
			printf(BPINK "Condition: %f <= %f NOT passed.\n" RESET, temp1, temp2);
		}
	}
	else if (!strcmp(str, ">=")) {
		if (temp1 >= temp2) {
			printf(BPINK "Condition: %f >= %f passed.\n" RESET, temp1, temp2);
			return 1;
		} else {
			printf(BPINK "Condition: %f >= %f NOT passed.\n" RESET, temp1, temp2);
		}
	}
	else if (!strcmp(str, "!=")) {
		if (temp1 != temp2) {
			printf(BPINK "Condition: %f != %f passed.\n" RESET, temp1, temp2);
			return 1;
		} else {
			printf(BPINK "Condition: %f != %f NOT passed.\n" RESET, temp1, temp2);
		}
	}
	return 0;
}

int compareCharOp(char str[50], char temp1[50], float temp2[50]) {
	if (!strcmp(str, "==")) {
		if (!strcmp(temp1, temp2)) {
			printf(BPINK "Condition: %s == %s passed.\n" RESET, temp1, temp2);
			return 1;
		} else {
			printf(BPINK "Condition: %s == %s NOT passed.\n" RESET, temp1, temp2);
		}
	} 
	else if (!strcmp(str, "<")) {
		printf(RED "\nERROR: Cannot do < on variables of type character." RESET);
		showSymTable();
		exit(0);
	}
	else if (!strcmp(str, ">")) {
		printf(RED "\nERROR: Cannot do > on variables of type character." RESET);
		showSymTable();
		exit(0);
	}
	else if (!strcmp(str, "<=")) {
		printf(RED "\nERROR: Cannot do <= on variables of type character." RESET);
		showSymTable();
		exit(0);
	}
	else if (!strcmp(str, ">=")) {
		printf(RED "\nERROR: Cannot do >= on variables of type character." RESET);
		showSymTable();
		exit(0);
	}
	else if (!strcmp(str, "!=")) {
		if (strcmp(temp1, temp2)) {
			printf(BPINK "Condition: %s != %s passed.\n" RESET, temp1, temp2);
			return 1;
		} else {
			printf(BPINK "Condition: %s != %s NOT passed.\n" RESET, temp1, temp2);
		}
	}
	return 0;
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
