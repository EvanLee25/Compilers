#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

FILE * MIPScode;

void  initAssemblyFile(){
    // Creates a MIPS file with a generic header that needs to be in every file       
    MIPScode = fopen("MIPScode.asm", "w");
    
    fprintf(MIPScode, ".globl main\n");
    fprintf(MIPScode, ".text\n");
    fprintf(MIPScode, "main:\n");
    fprintf(MIPScode, "# -----------------------\n");
    fclose(MIPScode);

}

void createMipsIDtoIDAssignment(char id1[50], char id2[50], char scope[50]){
    // e.g. x = y;

    MIPScode = fopen("MIPScode.asm", "a");
    int itemID1;
    int itemID2;
    char* itemValue1;
    char* itemValue2;

    itemID1 = getItemID(id1);
    itemID2 = getItemID(id2);
    itemValue1 = getValue(id1, scope);
    itemValue2 = getValue(id2, scope);

    fprintf(MIPScode, "li $t%d, %s\n", itemID1, itemValue1);
    //fprintf(MIPScode, "li $t%d, %s\n", itemID2, itemValue2); // this just prints that the second id is the value that it already is, redundant
    fprintf(MIPScode, "move $t%d, $t%d\n", itemID2, itemID1); // TODO: i think rn this moves the second regidster to the first instead of copying

    fclose(MIPScode);
}

void createMipsIntAssignment (char id[50], char num[50]){
    // e.g. x = 5;

    MIPScode = fopen("MIPScode.asm", "a");
    int itemID;

    itemID = getItemID(id);

    fprintf(MIPScode, "\nli $t%d, %s       # load the value of %s into $t%d\n", itemID, num, id, itemID);

    fclose(MIPScode);
}

void createMipsCharAssignment (char id[50], char chr[50]) {
    // e.g. x = 5;

    MIPScode = fopen("MIPScode.asm", "a");
    int itemID;

    itemID = getItemID(id);

    // the char takes the first apostrophe for some reason, need to remove this
    char *result = chr + 1; // removes first character

    fprintf(MIPScode, "\nli $t%d, '%s'     # load the value of %s into $t%d\n", itemID, result, id, itemID);

    fclose(MIPScode);
}

void createMipsIntDeclaration(char id[50]) {
    // e.g. int x;

    MIPScode = fopen("MIPScode.asm", "a");
    int itemID;

    itemID = getItemID(id);

    fprintf(MIPScode, "li $t%d, %s\n", itemID, id);

    fclose(MIPScode);

}

void createMIPSWriteInt(char id[50]){
    
    MIPScode = fopen("MIPScode.asm", "a");
    int itemID;

    itemID = getItemID(id);

    fprintf(MIPScode, "\nli $v0, 1       # call code to print an integer\n");
    fprintf(MIPScode, "move $a0, $t%d   # move the value of %s into $a0\n", itemID, id);
    fprintf(MIPScode, "syscall         # system call to print integer\n");

    fclose(MIPScode);

}

void createMIPSWriteChar(char id[50]){
    
    MIPScode = fopen("MIPScode.asm", "a");
    int itemID;

    itemID = getItemID(id);

    fprintf(MIPScode, "\nli $v0, 11      # call code to print a single character\n");
    fprintf(MIPScode, "move $a0, $t%d   # move the value of %s into $a0\n", itemID, id);
    fprintf(MIPScode, "syscall         # system call to print integer\n");

    fclose(MIPScode);

}

void createEndOfAssemblyCode(){

    MIPScode = fopen("MIPScode.asm", "a");

    fprintf(MIPScode, "\n# ----------------------\n");
    fprintf(MIPScode, "#  done, terminate program.\n\n");
    fprintf(MIPScode, "li $v0, 10      # call code to terminate program\n");
    fprintf(MIPScode, "syscall         # system call (terminate)\n");
    fprintf(MIPScode, ".end main\n");
    fclose(MIPScode);
}