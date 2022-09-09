%{

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

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

%token <string> CHAR
%token <string> INT
%token <string> IF
%token <string> ELSE
%token <string> WHILE
%token <string> PRINT
%token <string> DOUBLE_EQ
%token <string> NOT_EQ
%token <string> LT_EQ
%token <string> GT_EQ
%token <string> PLUS_EQ
%token <string> MINUS_EQ
%token <string> MULTIPLY_EQ
%token <string> DIVIDE_EQ
%token <character> LT
%token <character> GT
%token <character> EQ
%token <character> PLUS_OP
%token <character> MULTIPLY
%token <character> MINUS
%token <character> DIVIDE
%token <character> MODULUS
%token <character> LPAREN
%token <character> RPAREN
%token <character> LBRACE
%token <character> RBRACE
%token <character> COMMA
%token <character> SEMICOLON

%token <string> STRINGLITERAL
%token <character> CHARLITERAL
%token <string> WRITE

%token <string> ID
%token <number> NUMBER


%printer { fprintf(yyoutput, "%s", $$); } ID;
%printer { fprintf(yyoutput, "%d", $$); } NUMBER;

%type <ast> Program DeclList Decl VarDecl StmtList Expr

%start Program

%%

Program: DeclList { printf("\n Program -> DeclList \n");
		// ast
		$$ = $1;
};

DeclList:	Decl DeclList { printf("\n DeclList -> Decl DeclList \n");

}
			| Decl { printf("\n DeclList -> Decl \n");

};

Decl:	VarDecl
	| StmtList
;

VarDecl:	INT ID SEMICOLON	{ printf("RECOGNIZED RULE: Integer Variable Declaration: %s\n\n", $2);
								  //printf("Items recognized: %s, %s, %c \n", $1, $2, $3);
								}

			|INT ID EQ NUMBER SEMICOLON	{
								  printf("RECOGNIZED RULE: Integer Variable Declaration: %s = %i\n\n", $2, $4);
								  //printf("Items recognized: %s, %s, %c \n", $1, $2, $3);
								}

			|ID EQ NUMBER SEMICOLON	{
								  printf("RECOGNIZED RULE: Integer Variable Declaration: %s\n\n", $1);
								  //printf("Items recognized: %s, %s, %c \n", $1, $2, $3);
								}
			|CHAR ID SEMICOLON	{ printf("RECOGNIZED RULE: Char Variable Declaration: %s\n\n", $2);
								  //printf("Items recognized: %s, %s, %c \n", $1, $2, $3);
								}					
			
			|CHAR ID EQ CHARLITERAL SEMICOLON	{
									  printf("RECOGNIZED RULE: Char Variable Declaration: %s\n\n", $2);
									  //printf("Items recognized: %s, %s, %c \n", $1, $2, $3);
									} 
			|ID EQ CHARLITERAL SEMICOLON	{
								  printf("RECOGNIZED RULE: Char Variable Declaration: %s\n\n", $1);
								  //printf("Items recognized: %s, %s, %c \n", $1, $2, $3);
								}
;

StmtList:	Expr
	| Expr StmtList
;

Expr:	SEMICOLON {}
	| ID SEMICOLON { printf("RECOGNIZED RULE: Simplest Expression\n\n"); }
	| ID EQ ID SEMICOLON	{ printf("RECOGNIZED RULE: Assignment Statement\n\n"); }
	| ID EQ NUMBER SEMICOLON 	{ printf("RECOGNIZED RULE: Assignment Statement\n\n"); }
	| WRITE ID SEMICOLON 	{ printf("RECOGNIZED RULE: WRITE Statement\n\n"); }

%%

int main(int argc, char**argv)
{
/*
	#ifdef YYDEBUG
		yydebug = 1;
	#endif
*/
	printf("\n\n ##### Compiler started ##### \n\n");
	
	if (argc > 1){
	  if(!(yyin = fopen(argv[1], "r")))
          {
		perror(argv[1]);
		return(1);
	  }
	}
	yyparse();

	printf("\n##### COMPILER ENDED #####\n\n");
}

void yyerror(const char* s) {
	fprintf(stderr, "Parse error: %s\n", s);
	exit(1);
}
