#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

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

}

void addToOpArray(char input[50]) {

    // this starts with the last operator
    strcat(opArray, input);

}

int calculate() {

    // reverse the arrays
    revIntArray(numArray, numCounter);
    //revCharArray(opArray, opCounter);

    int sum = 0;
    
    for (int i = 0; i < numCounter; i++) { 
        //printf("\n%d\n", numArray[i]); // debug
        sum = sum + numArray[i];
    }
    printf("\n%d\n", sum);

    numCounter = 0;

    return sum;

}

void wipeArrays() {

    //memset(numArray, 0, numCounter);
    //memset(opArray, 0, opCounter);
    //counter = 0;

}