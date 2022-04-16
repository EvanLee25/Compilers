%{

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* #include "symbolTable.h" */
#include "AST.h"


extern int yylex();
extern int yyparse();
extern FILE* yyin;

void yyerror(const char* s);
char currentScope[50]; /* global or the name of the function */

%}


%union {
	int number;
	char character;
	char* string;
	struct AST* ast;
}

%token <number> TYPE

%token <string> DOUBLE_EQ
%token <string> NOT_EQ
%token <string> LT_EQ
%token <string> GT_EQ
%token <character> LT
%token <character> GT
%token <character> EQ
%token <string> PLUS_EQ
%token <string> MINUS_EQ
%token <string> MULTIPLY_EQ
%token <string> DIVIDE_EQ
%token <character> PLUS_OP
%token <character> MULTIPLY
%token <character> MINUS
%token <character> DIVIDE
%token <character> MODULUS

%token <string> ID
%token <string> STRING

%type <ast> 

%start Program

%%









%%

int main(int argc, char**argv)	
{
/*
	#ifdef YYDEBUG
		yydebug = 1;
	#endif
*/
	printf("\n\n##### COMPILER STARTED #####\n\n");
	
	if (argc > 1){
	  if(!(yyin = fopen(argv[1], "r")))
          {
		perror(argv[1]);
		return(1);
	  }
	}
	yyparse();
}

void yyerror(const char* s) {
	fprintf(stderr, "Parse error: %s\n", s);
	exit(1);
}
