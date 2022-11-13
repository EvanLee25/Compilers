#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

FILE * MIPScode;
FILE * tempMIPS;
FILE * MIPSfuncs;

void initAssemblyFile(){
         
    tempMIPS = fopen("tempMIPS.asm", "w");
    fprintf(tempMIPS, "\n.text\n");
    fprintf(tempMIPS, "main:\n");
    fprintf(tempMIPS, "# -----------------------\n");
    fclose(tempMIPS);

    MIPScode = fopen("MIPScode.asm", "w");
    fprintf(MIPScode, ".globl main\n");
    fprintf(MIPScode, ".data\n\n");
    fclose(MIPScode);

    MIPSfuncs = fopen("MIPSfuncs.asm", "w");
    fprintf(tempMIPS, "\n\n# -----------------------\n");
    fprintf(tempMIPS, "# function declarations\n");
    fprintf(MIPSfuncs, "\n");
    fclose(MIPScode);

    printf(CYAN "MIPS Initialized.\n\n\n" RESET);
}

void appendFiles(char source[50], char destination[50]) {

    FILE *fp1, *fp2;
    char c;

    // Open one file for reading
    fp1 = fopen(source, "r");
    if (fp1 == NULL) {
        printf("%s file does not exist..", source);
        exit(0);
    }

    // Open another file for appending content
    fp2 = fopen(destination, "a");
    if (fp2 == NULL) {
        printf("%s file does not exist...", destination);
        exit(0);
    }

    // Read content from file
    c = fgetc(fp1);
    while (c != EOF) {
        fputc(c,fp2);
        c = fgetc(fp1);
    }

    printf(BCYAN "  Content in %s appended to %s" RESET, source, destination);
    fclose(fp1);
    fclose(fp2);

}

void createMIPSFunction(char funcID[50]) {

    MIPSfuncs = fopen("MIPSfuncs.asm", "a");

    fprintf(MIPSfuncs, "%s:\n", funcID); // function header (e.g. 'func:')

    fclose(MIPSfuncs);

    printf(CYAN "MIPS Created.\n\n\n" RESET);

}

void callMIPSFunction(char funcID[50]) {

    tempMIPS = fopen("tempMIPS.asm", "a");

    fprintf(tempMIPS, "\n\tjal %s       # goto function: %s\n", funcID, funcID);

    fclose(tempMIPS);

    printf(CYAN "MIPS Created.\n\n\n" RESET);

}

void createParameter(char para[50], char index[50]) {

    MIPSfuncs = fopen("MIPSfuncs.asm", "a");



    fclose(MIPSfuncs);

    printf(CYAN "MIPS Created.\n\n\n" RESET);

}

void endMIPSFunction() {

    MIPSfuncs = fopen("MIPSfuncs.asm", "a");

    fprintf(MIPSfuncs, "\n\tjr $ra       # return to main\n\n");
    fclose(MIPSfuncs);

    printf(CYAN "MIPS Function Created.\n\n\n" RESET);

}

void createMIPSFloatFunctionCall(char id[50]) {

    tempMIPS = fopen("tempMIPS.asm", "a");

    fprintf(tempMIPS, "\n\tl.s $f0, G%s       # load the value of %s into $t0\n", id, id);
    fprintf(tempMIPS, "\n\tli $v0, 2         # call code to print a float\n");
    fprintf(tempMIPS, "\tmov.s $f12, $f0   # move the value of %s into $f12\n", id);
    fprintf(tempMIPS, "\tsyscall           # system call to print float\n");
    
    fclose(tempMIPS);

    printf(CYAN "MIPS Function Created.\n\n\n" RESET);

}

void createMIPSIDtoIDAssignment(char id1[50], char id2[50], char scope[50]){
    // e.g. x = y;
/*
    tempMIPS = fopen("tempMIPS.asm", "a");
    int itemID1;
    int itemID2;
    char* itemValue1;
    char* itemValue2;
    int typeInt = strcmp(getVariableType(id1, "G"), "INT");
    int typeChar = strcmp(getVariableType(id1, "G"), "CHR");
    int typeFloat = strcmp(getVariableType(id1, "G"), "FLT");

    itemID1 = getItemID(id1, scope);
    itemID2 = getItemID(id2, scope);
    itemValue1 = getValue(id1, scope);
    itemValue2 = getValue(id2, scope);

    if (typeInt == 0) { // if not char

        fprintf(tempMIPS, "\n\tli $t%d, %s       # load the value of %s into $t%d\n", itemID1, itemValue1, id2, itemID1);
        fprintf(tempMIPS, "\tmove $t%d, $t%d    # move the value of %s into %s\n", itemID2, itemID1, id2, id1); // TODO: i think rn this moves the second regidster to the first instead of copying

    } else if (typeChar == 0) { // if char

        fprintf(tempMIPS, "\n\tli $t%d, '%s'       # load the value of %s into $t%d\n", itemID1, itemValue1, id2, itemID1);
        fprintf(tempMIPS, "\tmove $t%d, $t%d    # move the value of %s into %s\n", itemID2, itemID1, id2, id1); // TODO: i think rn this moves the second regidster to the first instead of copying

    } else if (typeFloat == 0) {

        fprintf(tempMIPS, "\n\tl.s $f%d, %s       # load the value of %s into $t%d, %s = %s\n", itemID1, id2, id2, itemID1, id1, id2);

    }
    fclose(tempMIPS);
    printf(CYAN "MIPS Created.\n\n\n" RESET);
*/

}

void createMIPSIntDecl(char id[50], char scope[50]){
        // e.g. x = 5;

        MIPScode = fopen("MIPScode.asm", "a");
        fprintf(MIPScode, "\t%s%s: .word 0\n", scope, id);
        fclose(MIPScode);
        printf(CYAN "MIPS Created.\n\n\n" RESET); 
}





void createMIPSIntAssignment (char id[50], char num[50], char scope[50]){
    // e.g. x = 5;

        tempMIPS = fopen("tempMIPS.asm", "a");
        fprintf(tempMIPS, "\tla $a0, %s     #store value in $a0\n",num);
        fprintf(tempMIPS, "\tla $t0, %s%s   #load variable address into $t0\n",scope,id);
        fprintf(tempMIPS, "\tsw $a0, 0($t0)  #Move value from $a0 into .word variable\n\n");
        fclose(tempMIPS);
        printf(CYAN "MIPS Created.\n\n\n" RESET); 

}

void createMIPSFloatAssignment (char id[50], char num[50], char scope[50]){
    // e.g. f = 5;

        MIPScode = fopen("MIPScode.asm", "a");
        fprintf(MIPScode, "\t%s%s: .float %s\n", scope, id, num);
        fclose(MIPScode);
        printf(CYAN "MIPS Created.\n\n\n" RESET);

}

void createMIPSCharAssignment (char id[50], char chr[50], char scope[50]) {
    // e.g. x = 5;

        MIPScode = fopen("MIPScode.asm", "a");
        fprintf(MIPScode, "\t%s%s: .asciiz \"%s\"\n", scope, id, chr);
        fclose(MIPScode);
        printf(CYAN "MIPS Created.\n\n\n" RESET);

}

void createMIPSWriteInt(char id[50], char scope[50]){

    int str;
    str = strcmp(scope, "G");

    if (str == 0) {
    
        tempMIPS = fopen("tempMIPS.asm", "a");
        int itemID;

        itemID = getItemID(id, scope);

        fprintf(tempMIPS, "\n\tlw $t0, %s%s       # load the value of %s into $t0\n", scope, id, id);
        fprintf(tempMIPS, "\n\tli $v0, 1       # call code to print an integer\n");
        fprintf(tempMIPS, "\tmove $a0, $t0   # move the value of %s into $a0\n", id);
        fprintf(tempMIPS, "\tsyscall         # system call to print integer\n");

        fclose(tempMIPS);
        printf(CYAN "MIPS Created.\n\n\n" RESET);

    } else {

        MIPSfuncs = fopen("MIPSfuncs.asm", "a");
        int itemID;

        itemID = getItemID(id, scope);

        fprintf(MIPSfuncs, "\n\tlw $t0, %s%s       # load the value of %s into $t0\n", scope, id, id);
        fprintf(MIPSfuncs, "\n\tli $v0, 1       # call code to print an integer\n");
        fprintf(MIPSfuncs, "\tmove $a0, $t0   # move the value of %s into $a0\n", id);
        fprintf(MIPSfuncs, "\tsyscall         # system call to print integer\n");

        fclose(MIPSfuncs);
        printf(CYAN "MIPS Created.\n\n\n" RESET);

    }

}

void createMIPSWriteFloat(char id[50], char scope[50]){

    int str;
    str = strcmp(scope, "G");

    if (str == 0) {
    
        tempMIPS = fopen("tempMIPS.asm", "a");
        int itemID;

        itemID = getItemID(id, scope);

        fprintf(tempMIPS, "\n\tl.s $f0, %s%s       # load the value of %s into $t0\n", scope, id, id);
        fprintf(tempMIPS, "\n\tli $v0, 2         # call code to print a float\n");
        fprintf(tempMIPS, "\tmov.s $f12, $f0   # move the value of %s into $f12\n", id);
        fprintf(tempMIPS, "\tsyscall           # system call to print float\n");

        fclose(tempMIPS);
        printf(CYAN "MIPS Created.\n\n\n" RESET);

    } else {

        MIPSfuncs = fopen("MIPSfuncs.asm", "a");
        int itemID;

        itemID = getItemID(id, scope);

        fprintf(MIPSfuncs, "\n\tl.s $f0, %s%s       # load the value of %s into $t0\n", scope, id, id);
        fprintf(MIPSfuncs, "\n\tli $v0, 2         # call code to print a float\n");
        fprintf(MIPSfuncs, "\tmov.s $f12, $f0   # move the value of %s into $f12\n", id);
        fprintf(MIPSfuncs, "\tsyscall           # system call to print float\n");

        fclose(MIPSfuncs);
        printf(CYAN "MIPS Created.\n\n\n" RESET);

    }

}

void createMIPSWriteChar(char id[50], char scope[50]){

    int str;
    str = strcmp(scope, "G");

    if (str == 0) {
    
        tempMIPS = fopen("tempMIPS.asm", "a");
        int itemID;

        itemID = getItemID(id, scope);

        fprintf(tempMIPS, "\n\tlw $t0, %s%s       # load the value of %s into $t%d\n", scope, id, id, itemID);
        fprintf(tempMIPS, "\n\tli $v0, 11      # call code to print a single char\n");
        fprintf(tempMIPS, "\tmove $a0, $t0   # move the value of %s into $a0\n", id);
        fprintf(tempMIPS, "\tsyscall         # system call to print char\n");

        fclose(tempMIPS);
        printf(CYAN "MIPS Created.\n\n\n" RESET);

    } else {

        MIPSfuncs = fopen("MIPSfuncs.asm", "a");
        int itemID;

        itemID = getItemID(id, scope);

        fprintf(MIPSfuncs, "\n\tlw $t0, %s%s       # load the value of %s into $t%d\n", scope, id, id, itemID);
        fprintf(MIPSfuncs, "\n\tli $v0, 11      # call code to print a single char\n");
        fprintf(MIPSfuncs, "\tmove $a0, $t0   # move the value of %s into $a0\n", id);
        fprintf(MIPSfuncs, "\tsyscall         # system call to print char\n");

        fclose(MIPSfuncs);
        printf(CYAN "MIPS Created.\n\n\n" RESET);

    }

}

void makeMIPSNewLine(char scope[50]) {

    int str;
    str = strcmp(scope, "G");

    if (str == 0) {

        tempMIPS = fopen("tempMIPS.asm", "a");

        fprintf(tempMIPS, "\n\taddi $a0, $0 0xA  # new line\n");
        fprintf(tempMIPS, "\taddi $v0, $0 0xB  # new line\n");
        fprintf(tempMIPS, "\tsyscall           # syscall to print new line\n");

        fclose(tempMIPS);
        printf(CYAN "MIPS Created.\n\n\n" RESET);

    } else {

        MIPSfuncs = fopen("MIPSfuncs.asm", "a");

        fprintf(MIPSfuncs, "\n\taddi $a0, $0 0xA  # new line\n");
        fprintf(MIPSfuncs, "\taddi $v0, $0 0xB  # new line\n");
        fprintf(MIPSfuncs, "\tsyscall           # syscall to print new line\n");

        fclose(MIPSfuncs);
        printf(CYAN "MIPS Created.\n\n\n" RESET);

    }

}

void createEndOfAssemblyCode(){

    tempMIPS = fopen("tempMIPS.asm", "a");

    fprintf(tempMIPS, "\n\t# -----------------------\n");
    fprintf(tempMIPS, "\t#  done, terminate program.\n\n");
    fprintf(tempMIPS, "\tli $v0, 10      # call code to terminate program\n");
    fprintf(tempMIPS, "\tsyscall         # system call (terminate)\n");
    fprintf(tempMIPS, "\t.end main\n");
    fclose(tempMIPS);
    printf(BCYAN "  MIPS End Created.\n" RESET);

}