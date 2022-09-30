#include <string.h>
// ---- Functions to handle IR code emissions ---- //
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

void  initIRcodeFile(){
    FILE * IRcode;
    IRcode = fopen("IRcode.ir", "a");
    fprintf(IRcode, "#### IR Code ####\n\n");
    fclose(IRcode);
}

void createBinaryOperation(char op[1], const char* id1, const char* id2){
    FILE * IRcode;
    IRcode = fopen("IRcode.ir", "a");
    fprintf(IRcode, "T1 = %s %s %s", id1, op, id2);
    fclose(IRcode);
}

void createAssignment(char * id1, char * id2){
  // This is the temporary approach, until temporary variables management is implemented
    FILE * IRcode;
    fprintf(IRcode, "T0 = %s\n", id1);
    fprintf(IRcode, "T1 = %s\n", id2);
    fprintf(IRcode, "T1 = T0\n");
    fclose(IRcode);
}

void createConstantIntAssignment (char id1[50], char num[50]){
    //x = 5
    FILE * IRcode;
    fprintf(IRcode, "%s = %s\n", id1, num);
    fclose(IRcode);
}

void createWriteId(char * id){
    FILE * IRcode;
    //fprintf (IRcode, "output %s\n", id); // This is the intent... :)

    // This is what needs to be printed, but must manage temporary variables
    // We hardcode T2 for now, but you must implement a mechanism to tell you which one...
    fprintf (IRcode, "output %s\n", "T2");
    fclose(IRcode);
}