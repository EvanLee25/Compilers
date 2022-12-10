#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

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

FILE * IRcode;
FILE * IRFuncs;

int variableCounter;
char variableNames[50][50];
char IRspecifier[50];

void changeIRFile(int specifier){
    switch (specifier){
        case 0: sprintf(IRspecifier, "IRcode.ir"); break;
        case 1: sprintf(IRspecifier, "IRFuncs.ir"); break;
    }
}

void initIRcodeFile(){
    
    IRcode = fopen("IRcode.ir", "w");
    fprintf(IRcode, "# IR Code\n#---------------\n\nmain:\n\n");
    fclose(IRcode);

    IRFuncs = fopen("IRFuncs.ir", "w");
    fprintf(IRFuncs, "\n# Functions\n#---------------\n");
    fclose(IRFuncs);
    printf(BLUE "IR Code Initialized.\n" RESET);

}

void createBinaryOperation(char op[1], const char* id1, const char* id2){
    
    IRcode = fopen(IRspecifier, "a");
    fprintf(IRcode, "T1 = %s %s %s", id1, op, id2);
    fclose(IRcode);
    printf(BLUE "IR Code Created.\n" RESET);
}

void createIDtoIDAssignment(char * id1, char * id2, char scope[50]) {
    // e.g. x = y;
    // This is the temporary approach, until temporary variables management is implemented
    
    IRcode = fopen(IRspecifier, "a");
    int itemID1;
    int itemID2;
    itemID1 = getItemID(id1,scope);
    itemID2 = getItemID(id2,scope);

    //fprintf(IRcode, "T%d = %s\n", itemID1, id1);
    //fprintf(IRcode, "T%d = %s\n", itemID2, id2);
    fprintf(IRcode, "T%d = T%d\n", itemID1, itemID2);
    fclose(IRcode);
    printf(BLUE "IR Code Created.\n" RESET);
}

void createIntDefinition(char id[50], char scope[50]) {
    // e.g int x;

    // add the variable into the list of variables
    strcpy(variableNames[variableCounter], id); // add it to names array
    variableCounter++;

    IRcode = fopen(IRspecifier, "a");

    char str[50];
    strcpy(str, id);

    fprintf(IRcode, "T%d = %s\n", variableCounter-1, str);
    fclose(IRcode);
    printf(BLUE "IR Code Created.\n" RESET);
}

void createFloatDefinition(char id[50], char scope[50]) {
    // e.g float f;

    // add the variable into the list of variables
    strcpy(variableNames[variableCounter], id); // add it to names array
    variableCounter++;
    
    IRcode = fopen(IRspecifier, "a");

    fprintf(IRcode, "T%d = %s\n", variableCounter-1, id);
    fclose(IRcode);
    printf(BLUE "IR Code Created.\n" RESET);
}

void createCharDefinition(char id[50],char scope[50]) {
    // e.g char a;

    // add the variable into the list of variables
    strcpy(variableNames[variableCounter], id); // add it to names array
    variableCounter++;

    IRcode = fopen(IRspecifier, "a");

    fprintf(IRcode, "T%d = %s\n", variableCounter-1, id);
    fclose(IRcode);
    printf(BLUE "IR Code Created.\n" RESET);
}

void createIntAssignment(char id[50], char num[50], char scope[50]){
    // e.g. x = 5;
  
    IRcode = fopen(IRspecifier, "a");
    int itemID;
    itemID = getItemID(id, scope);

    fprintf(IRcode, "T%d = %s\n", itemID, num);
    fclose(IRcode);
    printf(BLUE "IR Code Created.\n" RESET);
}

void createFloatAssignment(char id[50], char num[50], char scope[50]){
    // e.g. f = 5;
  
    IRcode = fopen(IRspecifier, "a");
    int itemID;
    itemID = getItemID(id, scope);

    fprintf(IRcode, "T%d = %s\n", itemID, num);
    fclose(IRcode);
    printf(BLUE "IR Code Created.\n" RESET);
}

void createCharAssignment(char id[50], char chr[50], char scope[50]){
    // e.g. a = 'h';
  
    IRcode = fopen(IRspecifier, "a");
    int itemID;
    itemID = getItemID(id, scope);

    fprintf(IRcode, "T%d = '%s'\n", itemID, chr);
    fclose(IRcode);
    printf(BLUE "IR Code Created.\n" RESET);
}

void createWriteId(char id[50], char scope[50]){
    // e.g. write x;
  
    IRcode = fopen(IRspecifier, "a");
    int itemID;
    itemID = getItemID(id, scope);

    fprintf (IRcode, "output T%d\n", itemID);
    fclose(IRcode);
    printf(BLUE "IR Code Created.\n" RESET);
}

void createFunctionHeader(char id[50]) {

    IRcode = fopen("IRcode.ir", "a");
    fprintf(IRcode, "\ngoto %s\n\n", id);
    fclose(IRcode);

    IRFuncs = fopen("IRFuncs.ir", "a");
    fprintf(IRFuncs, "\n%s:\n", id);
    fclose(IRFuncs);
    printf(BLUE "IR Code Created.\n" RESET);

}

void createFunctionAddition(char id[50]) {

    // get the variables id
    int index = -1;
    for (int i = 0; i < 10; i++) {
        if (strcmp(variableNames[i], id) == 0) {
            index = i;
            break;
        }
    }

    IRcode = fopen("IRFuncs.ir", "a");
    fprintf (IRcode, "T%d = {NUM} + {NUM}\n", index);
    fclose(IRcode);
    printf(BLUE "IR Code Created.\n" RESET);

}

void createFunctionSubtraction(char id[50]) {

    // get the variables id
    int index = -1;
    for (int i = 0; i < 10; i++) {
        if (strcmp(variableNames[i], id) == 0) {
            index = i;
            break;
        }
    }

    IRcode = fopen("IRFuncs.ir", "a");
    fprintf (IRcode, "T%d = {NUM} - {NUM}\n", index);
    fclose(IRcode);
    printf(BLUE "IR Code Created.\n" RESET);

}

void createReturnIDStatement(char id[50]) {

    // get the variables id
    int index = -1;
    for (int i = 0; i < 10; i++) {
        if (strcmp(variableNames[i], id) == 0) {
            index = i;
            break;
        }
    }

    IRcode = fopen("IRFuncs.ir", "a");
    fprintf (IRcode, "return T%d\n\n", index);
    fclose(IRcode);
    printf(BLUE "IR Code Created.\n" RESET);

}

void createWhileStatement(int loopNumber) {

    IRcode = fopen("IRFuncs.ir", "a");
    fprintf (IRcode, "whileloop%d:\n", loopNumber);
    fclose(IRcode);
    printf(BLUE "IR Code Created.\n" RESET);

}

void createWhileCondition(char num1[50], char op[50], char num2[50]) {

    IRcode = fopen("IRFuncs.ir", "a");
    fprintf (IRcode, "goto main if not %s %s %s\n", num1, op, num2);
    fclose(IRcode);
    printf(BLUE "IR Code Created.\n" RESET);

}

void createWriteString(char string[50]) {

    IRcode = fopen(IRspecifier, "a");
    fprintf (IRcode, "output '%s'\n", string);
    fclose(IRcode);
    printf(BLUE "IR Code Created.\n" RESET);

}

void createNewLine() {

    IRcode = fopen(IRspecifier, "a");
    fprintf (IRcode, "output *newline*\n");
    fclose(IRcode);
    printf(BLUE "IR Code Created.\n" RESET);

}


