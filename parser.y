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

%token <string> WRITE

%token <number> NUMBER
%token <string> ID
%token <character> SEMICOLON

%type <ast> Program DeclList Decl VarDecl StmtList Stmt Expr

%start Program

%%

Program: DeclList  
;

DeclList:	Decl DeclList
	| Decl
;

Decl:	VarDecl
	| StmtList
;

VarDecl:	TYPE ID SEMICOLON	{ printf("\n RECOGNIZED RULE: Variable declaration %s\n", $2);
								  //printf("Items recognized: %s, %s, %c \n", $1, $2, $3);
								}
;

StmtList:	
	| Stmt StmtList
;

Stmt:	SEMICOLON
	| Expr SEMICOLON
;

Expr:	ID { printf("\n RECOGNIZED RULE: Simplest expression\n"); }
	| ID EQ ID 	{ printf("\n RECOGNIZED RULE: Assignment statement\n"); }
	| ID EQ NUMBER 	{ printf("\n RECOGNIZED RULE: Assignment statement\n"); }
	| WRITE ID 	{ printf("\n RECOGNIZED RULE: WRITE statement\n"); }

%%

int main(int argc, char**argv)
{
/*
	#ifdef YYDEBUG
		yydebug = 1;
	#endif
*/
	printf("Compiler started. \n\n");
	
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
