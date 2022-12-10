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

FILE * MIPScode;
FILE * tempMIPS;
FILE * MIPSfuncs;
char MIPSspecifier[50];  // 0 = tempMIPS.asm
                          // 1 = MIPScode.asm
                          // 2 = MIPSfuns.asm

void changeMIPSFile(int specifier){
    switch (specifier){
        case 0: sprintf(MIPSspecifier, "tempMIPS.asm"); break;
        case 1: sprintf(MIPSspecifier, "MIPScode.asm"); break;
        case 2: sprintf(MIPSspecifier, "MIPSfuncs.asm"); break;
    }
}

int counter = 0;

void initAssemblyFile(){
         
    tempMIPS = fopen("tempMIPS.asm", "w");
    fprintf(tempMIPS, "\n.text\n");
    fprintf(tempMIPS, "main:\n");
    fprintf(tempMIPS, "# -----------------------\n\n");
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

    //int id = itemID + 1;

    tempMIPS = fopen(MIPSspecifier, "a");

    fprintf(tempMIPS, "\n\tjal %s       # goto function: %s\n", funcID, funcID);

    fclose(tempMIPS);

    printf(CYAN "MIPS Created.\n\n\n" RESET);

}

void callMIPSLoop(char funcID[50]) {

    //int id = itemID + 1;

    tempMIPS = fopen(MIPSspecifier, "a");

    fprintf(tempMIPS, "\n\tjal %s       # goto loop: %s\n", funcID, funcID);
    fprintf(tempMIPS, "\n\tnext:       # return from loop here\n", funcID, funcID);

    fclose(tempMIPS);

    printf(CYAN "MIPS Created.\n\n\n" RESET);

}

void createIntParameter(char val[50], int index, char scope[50]) {

    tempMIPS = fopen(MIPSspecifier, "a");

    fprintf(tempMIPS, "\n\tli $a%d, %s         # load %s into $a%d as a parameter\n", index, val, val, index);

    fclose(tempMIPS);

    printf(CYAN "MIPS Created.\n\n\n" RESET);

}

void createIntIDParameter(char id[50], int index, char scope[50]) {

    tempMIPS = fopen(MIPSspecifier, "a");

    fprintf(tempMIPS, "\n\tlw $a%d, %s%s         # load %s into $a%d as a parameter\n", index, scope, id, id, index);

    fclose(tempMIPS);

    printf(CYAN "MIPS Created.\n\n\n" RESET);

}

void createFloatParameter(char val[50], int index, char scope[50]) {

    tempMIPS = fopen("tempMIPS.asm", "a");

    fprintf(tempMIPS, "\n\tli.s  $f%d, %s\n", index, val);

    fclose(tempMIPS);

    printf(CYAN "MIPS Created.\n\n\n" RESET);

}

void addEndLoop(){
    MIPSfuncs = fopen("MIPSfuncs.asm", "a");

    fprintf(MIPSfuncs, "endloop:\n"); // function header (e.g. 'func:')
    fprintf(MIPSfuncs, "\n\tjal next       # return to main\n\n");
    fclose(MIPSfuncs);

    printf(CYAN "MIPS Created.\n\n\n" RESET);
}

void endMIPSWhile(char val1[50], char condition[5], char val2[50], char scope[50], int first, int second){

    MIPSfuncs = fopen("MIPSfuncs.asm", "a");

    // load temp registers
    if (first == 0 && second == 0) { // both id's
        fprintf(MIPSfuncs, "\n\tlw $t0, %s%s              # load the variable into $t0", scope, val1);
        fprintf(MIPSfuncs, "\n\tlw $t1, %s%s              # load the variable into $t1", scope, val2);
    }
    else if (first == 0 && second == 1) {
        fprintf(MIPSfuncs, "\n\tlw $t0, %s%s              # load the variable into $t0", scope, val1);
        fprintf(MIPSfuncs, "\n\tli $t1, %s               # load the number into $t1", val2);
    }
    else if (first == 1 && second == 0) {
        fprintf(MIPSfuncs, "\n\tli $t0, %s               # load the number into $t0", val1);
        fprintf(MIPSfuncs, "\n\tlw $t1, %s%s              # load the variable into $t1", scope, val2);
    }
    else if (first == 1 && second == 1) {
        fprintf(MIPSfuncs, "\n\tli $t1, %s               # load the number into $t0", val1);
        fprintf(MIPSfuncs, "\n\tli $t1, %s               # load the number into $t1", val2);
    }

    if(strcmp(condition,"==") == 0){ //while ( _ == _ ){} is true
        //beq $t0, 10, endloop # if $t0 == 10, branch to endloop
        fprintf(MIPSfuncs, "\n\tbne $t0, $t1, endloop   # break loop if true \n", val1, val2);
    }

    else if(strcmp(condition,"!=") == 0){ //while ( _ < _ ){} is true
        fprintf(MIPSfuncs, "\n\tbeq $t0, $t1, endloop   # break loop if true \n", val1, val2);
    }

    else if(strcmp(condition,"<") == 0){ //while ( _ < _ ){} is true
        fprintf(MIPSfuncs, "\n\tbgt $t0, $t1, endloop   # break loop if true \n",val1,val2);
    }

    else if(strcmp(condition,"<=") == 0){ //while ( _ > _ ){} is true
        fprintf(MIPSfuncs, "\n\tbge $t0, $t1, endloop   # break loop if true \n",val1,val2);
    }

    else if(strcmp(condition,">") == 0){ //while ( _ > _ ){} is true
        fprintf(MIPSfuncs, "\n\tblt $t0, $t1, endloop   # break loop if true \n",val1,val2);
    }

    else if(strcmp(condition,">=") == 0){ //while ( _ > _ ){} is true
        fprintf(MIPSfuncs, "\n\tble $t0, $t1, endloop   # break loop if true \n",val1,val2);
    }

    
    fclose(MIPSfuncs);

    printf(CYAN "While Loop Created.\n\n\n" RESET);
}

void MIPSWhileJump(char whileLoopName[50]){
    MIPSfuncs = fopen("MIPSfuncs.asm", "a");

    fprintf(MIPSfuncs, "\n\tj %s       # loop back\n\n", whileLoopName);
    fclose(MIPSfuncs);

    printf(CYAN "While Loop Created.\n\n\n" RESET);
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

void createMIPSReturnStatementNumber(char id[50], char var[50], char num[50], char scope[50]) {
        // e.g. return x;

        MIPScode = fopen("MIPScode.asm", "a");
        fprintf(MIPScode, "\t%s: .word 0\n", id);
        fclose(MIPScode);

        char str[50];
        strcpy(str, scope);
        strcat(str, var);

        MIPSfuncs = fopen("MIPSfuncs.asm", "a");
        fprintf(MIPSfuncs, "\n\tlw $t0, %s   # load the value of the first variable into $t0\n", str);
        fprintf(MIPSfuncs, "\tsw $t0, %sReturn   # store the value of the first variable into the second\n", scope);
        fclose(MIPSfuncs);

        printf(CYAN "MIPS Created.\n\n\n" RESET); 


}

void setVariableToReturn(char var[50], char func[50], char scope[50]) {

        tempMIPS = fopen(MIPSspecifier, "a");
        fprintf(tempMIPS, "\n\tlw $t0, %sReturn     # load the value of the first variable into $t0\n", func);
        fprintf(tempMIPS, "\tsw $t0, G%s   # store the value of the first variable into the second\n", var);
        fclose(tempMIPS);

}

void createMIPSParameterAddition(char var[50], char scope[50]) {

        MIPSfuncs = fopen("MIPSfuncs.asm", "a");
        fprintf(MIPSfuncs, "\n\tadd $t0, $a1, $a2         # add the two values into $t0\n");
        fprintf(MIPSfuncs, "\tsw $t0, %s%s      # store the sum into target variable\n", scope, var);
        fclose(MIPSfuncs);

}

void createMIPSLoopAddition(char scope[50]) {

        MIPSfuncs = fopen("MIPSfuncs.asm", "a");
        fprintf(MIPSfuncs, "\n\tadd $t0, $s0, $s1   # add the two values into $t0\n");
        fprintf(MIPSfuncs, "\tsw $t0, Gx          # store the sum into target variable\n", scope);
        fclose(MIPSfuncs);

}

void createMIPSLoopSubtraction(char scope[50]) {

        MIPSfuncs = fopen("MIPSfuncs.asm", "a");
        fprintf(MIPSfuncs, "\n\tsub $t0, $s0, $s1   # subtract the two values into $t0\n");
        fprintf(MIPSfuncs, "\tsw $t0, Gx          # store the result into target variable\n", scope);
        fclose(MIPSfuncs);

}

void createMIPSAddNumberToRegister(char val[50], int counter) {

        MIPSfuncs = fopen("MIPSfuncs.asm", "a");
        fprintf(MIPSfuncs, "\n\tli $s%d, %s\n", counter, val);
        fclose(MIPSfuncs);

}

void createMIPSAddIDToRegister(char id[50], int counter, char scope[50]) {

        char str[50];
        strcpy(str, scope);
        strcat(str, id);

        MIPSfuncs = fopen("MIPSfuncs.asm", "a");
        fprintf(MIPSfuncs, "\n\tlw $s%d, %s\n", counter, str);
        fclose(MIPSfuncs);

}

void createMIPSSubtraction(char var1[50], char var2[50], char var3[50], char scope[50]) {

        MIPSfuncs = fopen("MIPSfuncs.asm", "a");
        fprintf(MIPSfuncs, "\tsub $t0, $t0, %s    # subtract the two values into $t0\n", var3);
        fprintf(MIPSfuncs, "\tsw $t0, G%s          # store the sum into target variable\n", var1);
        fclose(MIPSfuncs);

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

        tempMIPS = fopen(MIPSspecifier, "a");
        fprintf(tempMIPS, "\tla $a0, %s      # store value in $a0\n",num);
        fprintf(tempMIPS, "\tla $t0, %s%s      # load variable address into $t0\n",scope,id);
        fprintf(tempMIPS, "\tsw $a0, 0($t0)  # move value from $a0 into .word variable\n");
        fclose(tempMIPS);
        printf(CYAN "MIPS Created.\n\n\n" RESET); 

}

void createMIPSFloatAssignment (char id[50], char num[50], char scope[50]){
    // e.g. f = 5.0;

        tempMIPS = fopen(MIPSspecifier, "a");
        //fprintf(tempMIPS, "\t\n", scope, id, num);
        fclose(tempMIPS);
        printf(CYAN "MIPS Created.\n\n\n" RESET);

}

void createMIPSCharAssignment (char id[50], char chr[50], char scope[50]) {
    // e.g. c = '5';

        MIPScode = fopen("MIPScode.asm", "a");
        fprintf(MIPScode, "\t%s%s: .asciiz \"%s\"\n", scope, id, chr);
        fclose(MIPScode);
        printf(CYAN "MIPS Created.\n\n\n" RESET);

}

void defineMIPSTempString(char str[50]) {
    // e.g. write "hello";

        MIPScode = fopen("MIPScode.asm", "a");
        fprintf(MIPScode, "\tTEMP%d: .asciiz \"%s\"\n", counter, str);
        fclose(MIPScode);
        printf(CYAN "MIPS Created.\n\n\n" RESET);
        counter++;

}

void createMIPSWriteString(char str1[50], char scope[50]) {

    int str;
    str = strcmp(scope, "G");

    if (str == 0) {
    
        tempMIPS = fopen(MIPSspecifier, "a");
        int itemID;

        fprintf(tempMIPS, "\n\tli $v0, 4       # call code to print an string\n");
        fprintf(tempMIPS, "\tla $a0, TEMP%d   # print stored string from above\n", counter-1);
        fprintf(tempMIPS, "\tsyscall\n");

        fclose(tempMIPS);
        printf(CYAN "MIPS Created.\n\n\n" RESET);

    } else {

        MIPSfuncs = fopen("MIPSfuncs.asm", "a");
        int index;

        fprintf(MIPSfuncs, "\n\tli   $v0, 4       # call code to print an string\n");
        fprintf(MIPSfuncs, "\tla   $a0, TEMP%d  # print stored string from above\n", counter-1);
        fprintf(MIPSfuncs, "\tsyscall\n");

        fclose(MIPSfuncs);
        printf(CYAN "MIPS Created.\n\n\n" RESET);

    }

}

void createMIPSWriteInt(char id[50], char scope[50]){

    int str;
    str = strcmp(scope, "G");

    if (str == 0) {
    
        tempMIPS = fopen(MIPSspecifier, "a");
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
        int index;

        index = getItemID(id, scope) + 1;

        fprintf(MIPSfuncs, "\n\tli $v0, 1       # call code to print an integer\n");
        fprintf(MIPSfuncs, "\tmove $a0, $a%d   # move the value of %s into $a0\n", index, id);
        fprintf(MIPSfuncs, "\tsyscall         # system call to print integer\n");

        fclose(MIPSfuncs);
        printf(CYAN "MIPS Created.\n\n\n" RESET);

    }

}

void createMIPSWriteFloat(char id[50], char scope[50]){

    int str;
    str = strcmp(scope, "G");

    char value[50];
    strcpy(value, getValue(id, scope));

    if (str == 0) {
    
        tempMIPS = fopen(MIPSspecifier, "a");
        int itemID;

        itemID = getItemID(id, scope);

        fprintf(tempMIPS, "\n\tli.s $f0, %s       # load the value of %s into $f0\n", value, id);
        fprintf(tempMIPS, "\n\tli $v0, 2         # call code to print a float\n");
        fprintf(tempMIPS, "\tmov.s $f12, $f0   # move the value of %s into $f12\n", id);
        fprintf(tempMIPS, "\tsyscall           # system call to print float\n");

        fclose(tempMIPS);
        printf(CYAN "MIPS Created.\n\n\n" RESET);

    } else {

        MIPSfuncs = fopen("MIPSfuncs.asm", "a");
        int index;

        index = getItemID(id, scope) + 1;

        fprintf(tempMIPS, "\n\tli.s $f0, %s       # load the value of %s into $f0\n", value, id);
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
    
        tempMIPS = fopen(MIPSspecifier, "a");
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

        tempMIPS = fopen(MIPSspecifier, "a");

        fprintf(tempMIPS, "\n\taddi $a0, $0 0xA  # new line\n");
        fprintf(tempMIPS, "\taddi $v0, $0 0xB  # new line\n");
        fprintf(tempMIPS, "\tsyscall           # syscall to print new line\n");

        fclose(tempMIPS);
        printf(CYAN "MIPS Created.\n\n\n" RESET);

    } else {

        MIPSfuncs = fopen("MIPSfuncs.asm", "a");

        fprintf(MIPSfuncs, "\n\taddi $a0, $0 0xA  # new line\n");
        fprintf(MIPSfuncs, "\taddi $v0, $0 0xB  # new line\n");
        fprintf(MIPSfuncs, "\tsyscall           # syscall to print new line\n\n");

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