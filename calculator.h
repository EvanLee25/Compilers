#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

void addToInputCalc(char input[100]) {
    // creating file pointer to work with files
    FILE *file;
    // opening file in writing mode
    file = fopen("calc.input", "a");
    fprintf(file, "%s",input);
    fclose(file);

}

void readEvalOutput(char *result){
    // creating file pointer to work with files
    FILE *file;
    // opening file in writing mode
    file = fopen("calc.output", "r");
    fscanf(file,"%s",result);
    if (strcmp(result,"ERROR") == 0){
        exit(0);
    }
    fclose(file);
}

void clearCalcInput(){
    FILE *file;
    file = fopen("calc.input", "w");
    fclose(file);
}




/*
int numArray[50];
char opArray[50];
int numCounter;
int opCounter;

void revIntArray(int arr[], int n)
{
    int aux[n];
 
    for (int i = 0; i < n; i++) {
        aux[n - 1 - i] = arr[i];
    }
 
    for (int i = 0; i < n; i++) {
        arr[i] = aux[i];
    }
}

void revCharArray(char *str1)  
{  
    // declare variable  
    int i, len, temp;  
    len = strlen(str1); // use strlen() to get the length of str string  
      
    // use for loop to iterate the string   
    for (i = 0; i < len/2; i++)  
    {  
        // temp variable use to temporary hold the string  
        temp = str1[i];  
        str1[i] = str1[len - i - 1];  
        str1[len - i - 1] = temp;  
    }  
}  


void addToNumArray(char input[50]) {

    int temp;

    // turn string into int
    temp = atoi(input);

    // add into the array
    numArray[numCounter] = temp;
    //printf("\n%d\n", numArray[counter]); // debug
    numCounter++;

    // creating file pointer to work with files
    FILE *file;
    // opening file in writing mode
    file = fopen("calc.input", "a");
    fprintf(file, "%d",temp);
    fclose(file);

}

void addToOpArray(char input[50]) {

    // this starts with the last operator
    opCounter++;
    strcat(opArray, input);
    //printf("\n\n%s\n\n", input);

    // creating file pointer to work with files
    FILE *file;
    // opening file in writing mode
    file = fopen("calc.input", "a");
    fprintf(file, "%s", input);
    fclose(file);
}

void readEvalOutput(char *result){
    // creating file pointer to work with files
    FILE *file;
    // opening file in writing mode
    file = fopen("calc.output", "r");
    fscanf(file,"%s",result);
    fclose(file);
}

void clearCalcInput(){
    FILE *file;
    file = fopen("calc.input", "w");
    fclose(file);
}

void divide(int i) {

    int total;
    // debug print
    printf(BPINK "'/' found at opArray[%d]\n\n" RESET, i); // debug

    // multiply the two numbers around the operator
    total = numArray[i] / numArray[i+1];
    printf(BGREEN "%d / %d = %d\n" RESET, numArray[i], numArray[i+1], total);
    printf(GRAY "Replaced %d / %d with the total: %d", numArray[i], numArray[i+1], total);


    // remove the two numbers from the array
    // remove first number
    for (int j = i; j < numCounter - 1; j++)
        numArray[j] = numArray[j+1];

    // printf("First number removed:\n");

    // for (int j = 0; j < numCounter - 1; j++)
    //     printf("%d\n", numArray[j]);

    numCounter = numCounter - 1;


    // replace second number with total
    numArray[i] = total;

    // printf("Second number replaced with total:\n");

    // for (int j = 0; j < numCounter; j++)
    //     printf("%d\n", numArray[j]);


    // remove '*' operator
    for (int j = i; j < opCounter - 1; j++)
        opArray[j] = opArray[j+1];

    // printf("'*' operator removed:\n");

    // for (int j = 0; j < opCounter - 1; j++)
    //     printf("%c\n", opArray[j]);

    opCounter = opCounter - 1;


    // debug prints
    // printf(RED "\nnumCounter: %d\n" RESET, numCounter); // debug
    // printf(RED "opCounter: %d\n\n" RESET, opCounter); // debug

    printf("\n\n");
    for (int i = 0; i < numCounter; i++) { 

        printf(BCYAN "%d" RESET, numArray[i]); // debug
        printf(BORANGE " %c " RESET, opArray[i]); // debug

    }
    printf("\n\n");

}

void multiply(int i) {

    int total;
    // debug print
    printf(BPINK "'*' found at opArray[%d]\n\n" RESET, i); // debug

    // multiply the two numbers around the operator
    total = numArray[i] * numArray[i+1];
    printf(BGREEN "%d * %d = %d\n" RESET, numArray[i], numArray[i+1], total);
    printf(GRAY "Replaced %d * %d with the total: %d", numArray[i], numArray[i+1], total);

    // remove first number
    for (int j = i; j < numCounter - 1; j++)
        numArray[j] = numArray[j+1];

    // printf("First number removed:\n");

    // for (int j = 0; j < numCounter - 1; j++)
    //     printf("%d\n", numArray[j]);

    numCounter = numCounter - 1;


    // replace second number with total
    numArray[i] = total;

    // printf("Second number replaced with total:\n");

    // for (int j = 0; j < numCounter; j++)
    //     printf("%d\n", numArray[j]);


    // remove '*' operator
    for (int j = i; j < opCounter - 1; j++)
        opArray[j] = opArray[j+1];

    // printf("'*' operator removed:\n");

    // for (int j = 0; j < opCounter - 1; j++)
    //     printf("%c\n", opArray[j]);

    opCounter = opCounter - 1;


    // debug prints
    // printf(RED "\nnumCounter: %d\n" RESET, numCounter); // debug
    // printf(RED "opCounter: %d\n\n" RESET, opCounter); // debug

    printf("\n\n");
    for (int i = 0; i < numCounter; i++) { 

        printf(BCYAN "%d" RESET, numArray[i]); // debug
        printf(BORANGE " %c " RESET, opArray[i]); // debug

    }
    printf("\n\n");

}

void add(int i) {

    int total;

    // debug print
    printf(BPINK "'+' found at opArray[%d]\n\n" RESET, i); // debug

    // add the two numbers around the operator
    total = numArray[i] + numArray[i+1];
    printf(BGREEN "%d + %d = %d\n" RESET, numArray[i], numArray[i+1], total);
    printf(GRAY "Replaced %d + %d with the total: %d", numArray[i], numArray[i+1], total);

    // remove the two numbers from the array
    // remove first number
    for (int j = i; j < numCounter - 1; j++)
        numArray[j] = numArray[j+1];

    // printf("First number removed:\n");

    // for (int j = 0; j < numCounter - 1; j++)
    //     printf("%d\n", numArray[j]);

    numCounter = numCounter - 1;


    // replace second number with total
    numArray[i] = total;

    // printf("Second number replaced with total:\n");

    // for (int j = 0; j < numCounter; j++)
    //     printf("%d\n", numArray[j]);


    // remove '+' operator
    for (int j = i; j < opCounter - 1; j++)
        opArray[j] = opArray[j+1];

    // printf("'+' operator removed:\n");

    // for (int j = 0; j < opCounter - 1; j++)
    //     printf("%c\n", opArray[j]);

    opCounter = opCounter - 1;

    // debug prints
    // printf(RED "\nnumCounter: %d\n" RESET, numCounter); // debug
    // printf(RED "opCounter: %d\n\n" RESET, opCounter); // debug

    printf("\n\n");
    for (int i = 0; i < numCounter; i++) { 

        printf(BCYAN "%d" RESET, numArray[i]); // debug
        printf(BORANGE " %c " RESET, opArray[i]); // debug

    }
    printf("\n\n");

}

void subtract(int i) {

    int total;

    // debug print
    printf(BPINK "'-' found at opArray[%d]\n\n" RESET, i); // debug

    // add the two numbers around the operator
    total = numArray[i] - numArray[i+1];
    printf(BGREEN "%d - %d = %d\n" RESET, numArray[i], numArray[i+1], total);
    printf(GRAY "Replaced %d - %d with the total: %d", numArray[i], numArray[i+1], total);

    // remove the two numbers from the array
    // remove first number
    for (int j = i; j < numCounter - 1; j++)
        numArray[j] = numArray[j+1];

    // printf("First number removed:\n");

    // for (int j = 0; j < numCounter - 1; j++)
    //     printf("%d\n", numArray[j]);

    numCounter = numCounter - 1;


    // replace second number with total
    numArray[i] = total;

    // printf("Second number replaced with total:\n");

    // for (int j = 0; j < numCounter; j++)
    //     printf("%d\n", numArray[j]);


    // remove '+' operator
    for (int j = i; j < opCounter - 1; j++)
        opArray[j] = opArray[j+1];

    // printf("'+' operator removed:\n");

    // for (int j = 0; j < opCounter - 1; j++)
    //     printf("%c\n", opArray[j]);

    opCounter = opCounter - 1;

    // debug prints
    // printf(RED "\nnumCounter: %d\n" RESET, numCounter); // debug
    // printf(RED "opCounter: %d\n\n" RESET, opCounter); // debug

    printf("\n\n");
    for (int i = 0; i < numCounter; i++) { 

        printf(BCYAN "%d" RESET, numArray[i]); // debug
        printf(BORANGE " %c " RESET, opArray[i]); // debug

    }
    printf("\n\n");

}

int haveMult(char arr[50]) {

    for (int i = 0; i < opCounter; i++) {
        if (arr[i] == '*') {
            return 1;
        }
    }
    return 0;

}

int haveDiv(char arr[50]) {

    for (int i = 0; i < opCounter; i++) {
        if (arr[i] == '/') {
            return 1;
        }
    }
    return 0;

}

int haveSub(char arr[50]) {

    for (int i = 0; i < opCounter; i++) {
        if (arr[i] == '-') {
            return 1;
        }
    }
    return 0;

}

int calculate() {

    // reverse the arrays
    revIntArray(numArray, numCounter);
    revCharArray(opArray);

    int total;
    int temp;
    int k;

    // print num and op counters
    printf(BPINK "\nnumCounter: %d\n" RESET, numCounter);
    printf(BPINK "opCounter: %d\n" RESET, opCounter);
    
    // print out the calculation
    printf("\n");
    for (int i = 0; i < numCounter; i++) { 

        printf(BCYAN "%d" RESET, numArray[i]); // debug
        printf(BORANGE " %c " RESET, opArray[i]); // debug

    }
    printf("\n\n");

    // loop through the operator array and perform order of operations
    while (numCounter != 1) {

        //Look for L and R parentheses

        while (haveMult(opArray) == 1 || haveDiv(opArray) == 1) {

            for (int i = 0; i < opCounter; i++) {

                if (opArray[i] == '*') {

                    multiply(i);

                } 
                if (opArray[i] == '/') {

                    divide(i);

                }

            }
        }

        while (haveSub(opArray) == 1) {

            for (int i = 0; i < opCounter; i++) {

                if (opArray[i] == '-') {

                    subtract(i);

                }

            }
        }

        for (int i = 0; i < opCounter; i++) {

            if (opArray[i] == '+') {
                    
                add(i);

            }
        }
    }

        printf("\n");
       
        temp = numArray[numCounter-1];
        printf(BCYAN "TOTAL = %d\n\n" RESET, temp); // debug 

        printf(BPINK "Calculation Completed, Total = " RESET);
        printf(BOLD "%d" RESET, temp);
        printf(BPINK ".\n" RESET);

        return temp;

}

int calc() {

    // reverse the arrays
    revIntArray(numArray, numCounter);
    revCharArray(opArray);

    int sum = 0;
    
    for (int i = 0; i < numCounter; i++) { 
        //printf("\n%d\n", numArray[i]); // debug
        sum = sum + numArray[i];
    }

    printf(BORANGE "Calculation Completed, Total = " RESET);
    printf(BOLD "%d" RESET, sum);
    printf(GRAY ".\n" RESET);

    return sum;

}

void wipeArrays() {

    for (int i = 0; i < numCounter; i++) {
        //printf("\n\nbefore: %d\n\n", numArray[i]); // debug
        numArray[i] = 0;
        //printf("\n\nafter: %d\n\n", numArray[i]); // debug
    }
    for (int i = 0; i < opCounter; i++) {
        opArray[i] = ' ';
    }
    printf(BPINK "Number Array & Operator Array Wiped.\n" RESET);

    numCounter = 0;
    opCounter = 0;

}
*/