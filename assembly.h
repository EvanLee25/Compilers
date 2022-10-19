#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

FILE * MIPScode;
FILE * tempMIPS;

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

    printf("\nContent in %s appended to %s", source, destination);
    fclose(fp1);
    fclose(fp2);

}

void createMIPSIDtoIDAssignment(char id1[50], char id2[50], char scope[50]){
    // e.g. x = y;

    tempMIPS = fopen("tempMIPS.asm", "a");
    int itemID1;
    int itemID2;
    char* itemValue1;
    char* itemValue2;
    int typeInt = strcmp(getVariableType(id1, "G"), "INT");
    int typeChar = strcmp(getVariableType(id1, "G"), "CHR");
    int typeFloat = strcmp(getVariableType(id1, "G"), "FLT");

    itemID1 = getItemID(id1);
    itemID2 = getItemID(id2);
    itemValue1 = getValue(id1, scope);
    itemValue2 = getValue(id2, scope);

    if (typeInt == 0) { // if not char

        fprintf(tempMIPS, "\nli $t%d, %s       # load the value of %s into $t%d\n", itemID1, itemValue1, id2, itemID1);
        fprintf(tempMIPS, "move $t%d, $t%d    # move the value of %s into %s\n", itemID2, itemID1, id2, id1); // TODO: i think rn this moves the second regidster to the first instead of copying

    } else if (typeChar == 0) { // if char

        fprintf(tempMIPS, "\nli $t%d, '%s'       # load the value of %s into $t%d\n", itemID1, itemValue1, id2, itemID1);
        fprintf(tempMIPS, "move $t%d, $t%d    # move the value of %s into %s\n", itemID2, itemID1, id2, id1); // TODO: i think rn this moves the second regidster to the first instead of copying

    } else if (typeFloat == 0) {

        fprintf(tempMIPS, "\nl.s $f%d, %s       # load the value of %s into $t%d, %s = %s\n", itemID1, id2, id2, itemID1, id1, id2);

    }
    fclose(tempMIPS);
}

void createMIPSIntAssignment (char id[50], char num[50]){
    // e.g. x = 5;

    tempMIPS = fopen("tempMIPS.asm", "a");
    int itemID;

    itemID = getItemID(id);

    fprintf(tempMIPS, "\nli $t%d, %s       # load the value of %s into $t%d\n", itemID, num, id, itemID);

    fclose(tempMIPS);

}

void createMIPSFloatAssignment (char id[50], char num[50]){
    // e.g. f = 5;

    // SEPARATE FILE FOR f: .float 1.0 HERE
    MIPScode = fopen("MIPScode.asm", "a");

    fprintf(MIPScode, "%s: .float %s\n", id, num);

    fclose(MIPScode);

    tempMIPS = fopen("tempMIPS.asm", "a");
    int itemID;

    itemID = getItemID(id);

    fprintf(tempMIPS, "\nl.s $f%d, %s       # load the value of %s into $t%d\n", itemID, id, id, itemID);

    fclose(tempMIPS);

}

void createMIPSCharAssignment (char id[50], char chr[50]) {
    // e.g. x = 5;

    tempMIPS = fopen("tempMIPS.asm", "a");
    int itemID;

    itemID = getItemID(id);

    fprintf(tempMIPS, "\nli $t%d, '%s'     # load the value of %s into $t%d\n", itemID, chr, id, itemID);

    fclose(tempMIPS);
}

void createMIPSIntDeclaration(char id[50]) {
    // e.g. int x;

    tempMIPS = fopen("tempMIPS.asm", "a");
    int itemID;

    itemID = getItemID(id);

    fprintf(tempMIPS, "li $t%d, %s\n", itemID, id);

    fclose(tempMIPS);

}

void createMIPSWriteInt(char id[50]){
    
    tempMIPS = fopen("tempMIPS.asm", "a");
    int itemID;

    itemID = getItemID(id);

    fprintf(tempMIPS, "\nli $v0, 1       # call code to print an integer\n");
    fprintf(tempMIPS, "move $a0, $t%d   # move the value of %s into $a0\n", itemID, id);
    fprintf(tempMIPS, "syscall         # system call to print integer\n");

    fclose(tempMIPS);

}

void createMIPSWriteFloat(char id[50]){
    
    tempMIPS = fopen("tempMIPS.asm", "a");
    int itemID;

    itemID = getItemID(id);

    fprintf(tempMIPS, "\nli $v0, 2         # call code to print a float\n");
    fprintf(tempMIPS, "mov.s $f12, $f%d   # move the value of %s into $f12\n", itemID, id);
    fprintf(tempMIPS, "syscall           # system call to print float\n");

    fclose(tempMIPS);

}

void createMIPSWriteChar(char id[50]){
    
    tempMIPS = fopen("tempMIPS.asm", "a");
    int itemID;

    itemID = getItemID(id);

    fprintf(tempMIPS, "\nli $v0, 11      # call code to print a single char\n");
    fprintf(tempMIPS, "move $a0, $t%d   # move the value of %s into $a0\n", itemID, id);
    fprintf(tempMIPS, "syscall         # system call to print char\n");

    fclose(tempMIPS);

}

void createMIPSAddition(char id[50], char num[50]) {
    // e.g. x = 5 + y + 7 + 12;
    // this calculation is optimized to be done in the parser, so this is just another integer assignment

    tempMIPS = fopen("tempMIPS.asm", "a");
    int itemID;

    itemID = getItemID(id);

    fprintf(tempMIPS, "\nli $t%d, %s       # load the added value of %s into $t%d\n", itemID, num, id, itemID);

    fclose(tempMIPS);

}

void makeMIPSNewLine() {

    tempMIPS = fopen("tempMIPS.asm", "a");

    fprintf(tempMIPS, "\naddi $a0, $0 0xA  # new line\n");
    fprintf(tempMIPS, "addi $v0, $0 0xB  # new line\n");
    fprintf(tempMIPS, "syscall           # syscall to print new line\n");

    fclose(tempMIPS);

}

void createEndOfAssemblyCode(){

    tempMIPS = fopen("tempMIPS.asm", "a");

    fprintf(tempMIPS, "\n# -----------------------\n");
    fprintf(tempMIPS, "#  done, terminate program.\n\n");
    fprintf(tempMIPS, "li $v0, 10      # call code to terminate program\n");
    fprintf(tempMIPS, "syscall         # system call (terminate)\n");
    fprintf(tempMIPS, ".end main\n");
    fclose(tempMIPS);
}