
//Symbol table header
#include <string.h>
#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

//@Hunter TODO: Can you add comments for what each color should be used for?
#define GREEN   "\x1b[32m"
#define BGREEN  "\x1b[1;32m"
#define RED     "\x1b[1;31m"
#define ORANGE 	"\x1b[33m"
#define BORANGE "\x1b[1;33m"
#define PINK	"\x1b[95m"
#define BPINK	"\x1b[1;95m"
#define BLUE    "\x1b[34m"
#define BBLUE   "\x1b[1;94m"
#define BCYAN	"\x1b[1;96m"
#define BYELLOW "\x1b[1;103m"
#define GRAY	"\x1b[90m"
#define BOLD	"\e[1;37m"
#define RESET   "\x1b[0m"

struct arrEntry
{
	int index;
	char value[50];
};

struct arrEntry arrTabItems[100];
int arrTabIndex = 0;
int ARRTAB_SIZE = 20;
char name[50];

void arrTabAccess(void) {
	printf(PINK "::::> Array Table accessed.\n" RESET);
}

void addIndex(int index, char value[50]) {

		arrTabItems[arrTabIndex].index = arrTabIndex;
		strcpy(arrTabItems[arrTabIndex].value, value);
		arrTabIndex++;
		printf(PINK "::::> Item added to the array.\n\n" RESET);
	
}

void modifyIndex(int index, char value[50]) {

    for (int i = 0; i < arrTabIndex; i++){
        // if the index is located
        if (index == arrTabItems[i].index) {
            // add the value to the index
            strcpy(arrTabItems[i].value, value);
        }
	}

}

void initArray(char aname[50], char range[50]) {

    // convert range from char to integer
    int intRange = atoi(range);

    // set the name of the array
    strcpy(name, aname);

    // initialize amount of indices based on range
    for (int i = 0; i < intRange; i++) {
        addIndex(i, "NULL");
    }    

}

void showArrTable() {

    printf(GRAY "Array: " RESET);
	printf(BPINK "%s\n" RESET, name);
    printf(GRAY "---------------\n\n" RESET);

	printf(BOLD "index   value\n" RESET);
	printf(BOLD "--------------\n" RESET);

	for (int i=0; i<arrTabIndex; i++){

		printf(BOLD "%3d " RESET, arrTabItems[i].index);
	
		// if value is null print gray
		if (strcmp(arrTabItems[i].value, "NULL") == 0) {
			printf(GRAY "%9s\n" RESET, arrTabItems[i].value);
		} else {
			printf(BPINK "%9s\n" RESET, arrTabItems[i].value);
		}

	}
	

	printf(BOLD "--------------\n" RESET);
}