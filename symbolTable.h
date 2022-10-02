
//Symbol table header
#include <string.h>
#include <stdio.h>

struct Entry
{
	int itemID;
	char itemName[50];  //the name of the identifier
	char itemKind[8];  //is it a function or a variable?
	char itemType[8];  // Is it int, char, etc.?
	int arrayLength;
	char scope[50];     // global, or the name of the function
	int isUsed;       // 0 = F, 1 = T, is variable used? -optimization
	char value[50];
};

struct Entry symTabItems[100];
int symTabIndex = 0;
int SYMTAB_SIZE = 20;

void symTabAccess(void) {
	printf("::::> Symbol Table accessed.\n");
}

void addItem(char itemName[50], char itemKind[8], char itemType[8], int arrayLength, char scope[50], int isUsed){
	
		// what about scope? should you add scope to this function?
		symTabItems[symTabIndex].itemID = symTabIndex;
		strcpy(symTabItems[symTabIndex].itemName, itemName);
		strcpy(symTabItems[symTabIndex].itemKind, itemKind);
		strcpy(symTabItems[symTabIndex].itemType, itemType);
		symTabItems[symTabIndex].arrayLength = arrayLength;
		strcpy(symTabItems[symTabIndex].scope, scope);
		symTabItems[symTabIndex].isUsed = isUsed;
		symTabIndex++;
		printf("::::> Item added to the Symbol Table.\n");
	
}

void updateValue(char itemName[50], char scope[50], char value[50]) {

	for(int i=0; i<symTabIndex+1; i++){
		int str1 = strcmp(symTabItems[i].itemName, itemName); 
		//printf("\n\n---------> str1=%d: COMPARED: %s vs %s\n\n", str1, symTabItems[i].itemName, itemName);
		int str2 = strcmp(symTabItems[i].scope, scope); 
		//printf("\n\n---------> str2=%d: COMPARED %s vs %s\n\n", str2, symTabItems[i].itemName, itemName);
		if( str1 == 0 && str2 == 0){
			strcpy(symTabItems[i].value, value); // update value in sym table
		}
	}

}

int getItemID(char itemName[50]) {

	for(int i=0; i<symTabIndex+1; i++){
		int str1 = strcmp(symTabItems[i].itemName, itemName); 
		//printf("\n\n---------> str1=%d: COMPARED: %s vs %s\n\n", str1, symTabItems[i].itemName, itemName);
		
		if( str1 == 0 ) {
			return symTabItems[i].itemID;
		}
	}
	return 0;

}


int redundantValue(char itemName[50], char scope[50], char value[50]) {

	for(int i=0; i<symTabIndex+1; i++){
		int str1 = strcmp(symTabItems[i].itemName, itemName); 
		//printf("\n\n---------> str1=%d: COMPARED: %s vs %s\n\n", str1, symTabItems[i].itemName, itemName);
		int str2 = strcmp(symTabItems[i].scope, scope); 
		//printf("\n\n---------> str2=%d: COMPARED %s vs %s\n\n", str2, symTabItems[i].itemName, itemName);
		int str3 = strcmp(symTabItems[i].value, value);

		if( str1 == 0 && str2 == 0 && str3 == 0){
			return 0;
		}
		
	}
	return 1;

}

void isUsed(char itemName[50], char scope[50]) {

	for(int i=0; i<symTabIndex+1; i++){
		int str1 = strcmp(symTabItems[i].itemName, itemName); 
		//printf("\n\n---------> str1=%d: COMPARED: %s vs %s\n\n", str1, symTabItems[i].itemName, itemName);
		int str2 = strcmp(symTabItems[i].scope, scope); 
		//printf("\n\n---------> str2=%d: COMPARED %s vs %s\n\n", str2, symTabItems[i].itemName, itemName);
		if( str1 == 0 && str2 == 0) {
			symTabItems[i].isUsed = 1; // update value in sym table
		}
	}

}

char* getValue(char itemName[50], char scope[50]) {

	for(int i=0; i<symTabIndex+1; i++){
		int str1 = strcmp(symTabItems[i].itemName, itemName); 
		//printf("\n\n---------> str1=%d: COMPARED: %s vs %s\n\n", str1, symTabItems[i].itemName, itemName);
		int str2 = strcmp(symTabItems[i].scope, scope); 
		//printf("\n\n---------> str2=%d: COMPARED %s vs %s\n\n", str2, symTabItems[i].itemName, itemName);
		if( str1 == 0 && str2 == 0){
			return symTabItems[i].value;
		}
	}
	return "NULL";
}

void showSymTable(){
	printf("itemID    itemName    itemKind    itemType     ArrayLength    itemScope    isUsed    value\n");
	printf("-------------------------------------------------------------------------------------------\n");
	for (int i=0; i<symTabIndex; i++){
		printf("%5d %8s  %11s  %10s %12d %15s %9i %9s\n",symTabItems[i].itemID, symTabItems[i].itemName, symTabItems[i].itemKind, symTabItems[i].itemType, symTabItems[i].arrayLength, symTabItems[i].scope, symTabItems[i].isUsed, symTabItems[i].value);
	}
	

	printf("-------------------------------------------------------------------------------------------\n");
}

int found(char itemName[50], char scope[50]){
	// Lookup an identifier in the symbol table
	// what about scope?
	// return TRUE or FALSE
	// Later on, you may want to return additional information

	// Dirty loop, becuase it counts SYMTAB_SIZE times, no matter the size of the symbol table
	for(int i=0; i<symTabIndex+1; i++){
		int str1 = strcmp(symTabItems[i].itemName, itemName); 
		//printf("\n\n---------> str1=%d: COMPARED: %s vs %s\n\n", str1, symTabItems[i].itemName, itemName);
		int str2 = strcmp(symTabItems[i].scope,scope); 
		//printf("\n\n---------> str2=%d: COMPARED %s vs %s\n\n", str2, symTabItems[i].itemName, itemName);
		if( str1 == 0 && str2 == 0){
			//printf("::::> Syntax Error: Variable '%s' already declared.\n\n", itemName);
			return 1; // found the ID in the table
		}
	}
	printf("::::> No variable already declared.\n");
	return 0;
}

int initialized(char itemName[50], char scope[50]){
	// Lookup an identifier in the symbol table
	// what about scope?
	// return TRUE or FALSE
	// Later on, you may want to return additional information

	// Dirty loop, becuase it counts SYMTAB_SIZE times, no matter the size of the symbol table
	for(int i=0; i<symTabIndex+1; i++){
		int str1 = strcmp(symTabItems[i].itemName, itemName); 
		//printf("\n\n---------> str1=%d: COMPARED: %s vs %s\n\n", str1, symTabItems[i].itemName, itemName);
		int str2 = strcmp(symTabItems[i].scope,scope); 
		//printf("\n\n---------> str2=%d: COMPARED %s vs %s\n\n", str2, symTabItems[i].itemName, itemName);
		if( str1 == 0 && str2 == 0){
			printf("::::> Variable '%s' is declared.\n", itemName);
			return 1; // found the ID in the table
		}
	}
	printf("::::> Syntax Error: Variable '%s' has not yet been declared.\n\n", itemName);
	return 0;
}

const char* getVariableType(char itemName[50], char scope[50]){
	//char *name = "int";
	//return name;

	for(int i=0; i<SYMTAB_SIZE; i++){
		int str1 = strcmp(symTabItems[i].itemName, itemName); 
		//printf("\n\n---------> str1=%d: COMPARED: %s vs %s\n\n", str1, symTabItems[i].itemName, itemName);
		int str2 = strcmp(symTabItems[i].scope,scope); 
		//printf("\n\n---------> str2=%d: COMPARED %s vs %s\n\n", str2, symTabItems[i].itemName, itemName);
		if( str1 == 0 && str2 == 0){
			return symTabItems[i].itemType; // found the ID in the table
		}
	}
	return NULL;
}

int compareTypes(char itemName1[50], char itemName2[50],char scope[50]){
	const char* idType1 = getVariableType(itemName1, scope);
	const char* idType2 = getVariableType(itemName2, scope);
	
	printf("%s = %s\n", idType1, idType2);
	
	int typeMatch = strcmp(idType1, idType2);
	if(typeMatch == 0){
		return 1; // types are matching
	}
	else return 0;
}
    