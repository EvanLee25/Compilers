#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

FILE * IRcode;

void initIRcodeFile(){
    
    IRcode = fopen("IRcode.ir", "w");
    fprintf(IRcode, "#### IR Code ####\n\n");
    fclose(IRcode);
}

void createBinaryOperation(char op[1], const char* id1, const char* id2){
    
    IRcode = fopen("IRcode.ir", "a");
    fprintf(IRcode, "T1 = %s %s %s", id1, op, id2);
    fclose(IRcode);
}

void createIDtoIDAssignment(char * id1, char * id2) {
    // e.g. x = y;
    // This is the temporary approach, until temporary variables management is implemented
    
    IRcode = fopen("IRcode.ir", "a");
    int itemID1;
    int itemID2;
    itemID1 = getItemID(id1);
    itemID2 = getItemID(id2);

    //fprintf(IRcode, "T%d = %s\n", itemID1, id1);
    //fprintf(IRcode, "T%d = %s\n", itemID2, id2);
    fprintf(IRcode, "T%d = T%d\n", itemID1, itemID2);
    fclose(IRcode);
}

void createIntDefinition(char id[50]) {
    // e.g int x;
    
    IRcode = fopen("IRcode.ir", "a");
    int itemID;
    itemID = getItemID(id);

    fprintf(IRcode, "T%d = %s\n", itemID, id);
    fclose(IRcode);
}

void createFloatDefinition(char id[50]) {
    // e.g float f;
    
    IRcode = fopen("IRcode.ir", "a");
    int itemID;
    itemID = getItemID(id);

    fprintf(IRcode, "T%d = %s\n", itemID, id);
    fclose(IRcode);
}

void createCharDefinition(char id[50]) {
    // e.g char a;

    IRcode = fopen("IRcode.ir", "a");
    int itemID;
    itemID = getItemID(id);

    fprintf(IRcode, "T%d = %s\n", itemID, id);
    fclose(IRcode);
}

void createIntAssignment(char id[50], char num[50]){
    // e.g. x = 5;
  
    IRcode = fopen("IRcode.ir", "a");
    int itemID;
    itemID = getItemID(id);

    fprintf(IRcode, "T%d = %s\n", itemID, num);
    fclose(IRcode);
}

void createFloatAssignment(char id[50], char num[50]){
    // e.g. f = 5;
  
    IRcode = fopen("IRcode.ir", "a");
    int itemID;
    itemID = getItemID(id);

    fprintf(IRcode, "T%d = %s\n", itemID, num);
    fclose(IRcode);
}

void createCharAssignment(char id[50], char chr[50]){
    // e.g. a = 'h';
  
    IRcode = fopen("IRcode.ir", "a");
    int itemID;
    itemID = getItemID(id);

    // remove the apostrophes from the char
    char *result = chr + 1; // removes first character

    fprintf(IRcode, "T%d = %s\n", itemID, result);
    fclose(IRcode);
}

void createWriteId(char id[50]){
    // e.g. write x;
  
    IRcode = fopen("IRcode.ir", "a");
    int itemID;
    itemID = getItemID(id);

    fprintf (IRcode, "output T%d\n", itemID);
    fclose(IRcode);
}