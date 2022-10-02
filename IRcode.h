#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>


void  initIRcodeFile(){
    FILE * IRcode;
    IRcode = fopen("IRcode.ir", "w");
    fprintf(IRcode, "#### IR Code ####\n\n");
    fclose(IRcode);
}

void createBinaryOperation(char op[1], const char* id1, const char* id2){
    FILE * IRcode;
    IRcode = fopen("IRcode.ir", "a");
    fprintf(IRcode, "T1 = %s %s %s", id1, op, id2);
    fclose(IRcode);
}

void createIDtoIDAssignment(char * id1, char * id2) {
    // e.g. x = y;
    // This is the temporary approach, until temporary variables management is implemented
    FILE * IRcode;
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

    FILE * IRcode;
    IRcode = fopen("IRcode.ir", "a");
    int itemID;
    itemID = getItemID(id);

    fprintf(IRcode, "T%d = %s\n", itemID, id);
    fclose(IRcode);
}

void createConstantIntAssignment(char id[50], char num[50]){
    // e.g. x = 5;

    FILE * IRcode;
    IRcode = fopen("IRcode.ir", "a");
    int itemID;
    itemID = getItemID(id);

    fprintf(IRcode, "T%d = %s\n", itemID, num);
    fclose(IRcode);
}

void createWriteId(char id[50]){
    // e.g. write x;

    FILE * IRcode;
    //fprintf (IRcode, "output %s\n", id); // This is the intent... :)

    // This is what needs to be printed, but must manage temporary variables
    // We hardcode T2 for now, but you must implement a mechanism to tell you which one...
    fprintf (IRcode, "output %s\n", "T2");
    fclose(IRcode);
}