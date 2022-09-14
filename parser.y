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

%type <ast> Program DeclList Decl VarDecl BasicIntVarDecl BasicCharVarDecl StmtList Expr

%start Program

%%

Program: DeclList { printf("\nProgram -> DeclList \n");
		// ast
		$$ = $1;

		printf("\n--- Abstract Syntax Tree ---\n\n");
		printAST($$,0);
};

DeclList:	Decl DeclList { printf("\nDeclList -> Decl DeclList \n");
		// ast
		$1->left = $2;
		$$ = $1;

}
			| Decl { printf("\nDeclList -> Decl \n");
			// ast
			$$ = $1;

};

Decl:	VarDecl { printf("\nDecl -> VarDecl \n");
		// ast
		$$ = $1;

}
	| StmtList { printf("\nDecl -> StmtList \n");
		// ast
		$$ = $1;

};


/*----start vardecl-----------------------------------------------------------------------------------------------------*/


VarDecl:	INT ID SEMICOLON	{ printf("RECOGNIZED RULE: Integer Variable Declaration\n\n");
							// WORKS

							// ast
							//$$->left = $1;
							//$$->right = $2;
							

							$$ = AST_assignment("TYPE",$1,$2);
							printf("-----------> %s\n", $$->LHS);
							printf("-----------> %s", $$->RHS);
							/*
							Semantic Analysis
							1. Verify that both variables have been declared
							2. Verify that the type of RHS and LHS is the same
							3. Decide what to do if the types are different
							4. The Main Outcome:
								If all semantic checks passed, generate intermediate representation code
								4.1 Write the external C program to generate IR code
							
							*/

							/*
										VarDecl
									INT        ID
							*/

							}


			|	INT BasicIntVarDecl SEMICOLON	{ printf("RECOGNIZED RULE: Integer Variable Declaration\n\n");
							// WORKS

							// ast
							//$$->left = $1;
							//$$->right = $2;
							//$$ = AST_right_tree_assignment("TYPE",$1,$2);

							/*
									 VarDecl
							      INT       \-------      =
							 					     ID       NUMBER
							 */
		  
							//printf("Items recognized: %s, %s, %c \n", $1, $2, $3);
							}

			|	BasicIntVarDecl SEMICOLON	{ printf("RECOGNIZED RULE: Integer Variable Declaration\n\n");
							// WORKS

							// ast
							$$ = $1;

							/*
									=
								ID	   NUMBER
							*/

							//printf("Items recognized: %s, %s, %c \n", $1, $2, $3);
							}

			|	CHAR ID SEMICOLON	{ printf("RECOGNIZED RULE: Char Variable Declaration \n\n");
							// WORKS

							// ast
							//$$->left = $1;
							//$$->right = $2;

							$$ = AST_assignment("TYPE",$1,$2);
							printf("-----------> %s\n", $$->LHS);
							printf("-----------> %s", $$->RHS);

							/*
									VarDecl
								CHAR	   ID
							*/

							//printf("Items recognized: %s, %s, %c \n", $1, $2, $3);
							}					
			
			|	CHAR BasicCharVarDecl SEMICOLON	  { printf("RECOGNIZED RULE: Char Variable Declaration \n\n");
							// WORKS	

							// ast
							$$->left = $1;
							$$->right = $2;

							/*
									VarDecl
								CHAR	   \------ BasicCharVarDecl
												ID				   CHARLITERAL
							*/
									  		
							//printf("Items recognized: %s, %s, %c \n", $1, $2, $3);
							} 

			|	BasicCharVarDecl SEMICOLON	  { printf("RECOGNIZED RULE: Char Variable Declaration \n\n");
							// WORKS

							// ast
							$$ = $1;

							/*
										 VarDecl
											|
								 	BasicCharVarDecl
							   	  ID				CHARLITERAL
							*/
								  
							//printf("Items recognized: %s, %s, %c \n", $1, $2, $3);
							}
;


/*----end vardecl-------------------------------------------------------------------------------------------------------*/


BasicIntVarDecl: ID EQ NUMBER { //printf("RECOGNIZED RULE: Basic Integer Variable declaration \n\n");
							// WORKS	  

							// ast
							//$$->left = $1;
							//$$->right = $3;
							//$$ = $2; // @evan: this segfaults on Program -> DeclList after more than one variable declaration in source code???
							//$$ = AST_assignment("=",$1,$2);

							/*
									=
								ID    NUMBER
							*/

							//printf("Items recognized: %s, %s, %c \n", $1, $2, $3);
};

BasicCharVarDecl: ID EQ CHARLITERAL { //printf("RECOGNIZED RULE: Basic Charliteral Variable declaration \n\n");
							// WORKS
							
							// ast
							$$->left = $1;
							$$->right = $3;
							//$$ = $2;

							/*
									=
								ID	   CHARLITERAL
							*/

							//printf("Items recognized: %s, %s, %c \n", $1, $2, $3);
};


StmtList:	Expr
	| Expr StmtList
;

Expr:	SEMICOLON {}

	|	ID SEMICOLON	{ printf("RECOGNIZED RULE: Simplest Expression\n\n"); }
		// WORKS

	|	ID EQ ID SEMICOLON	{ printf("RECOGNIZED RULE: Assignment Statement\n\n"); }
		// WORKS

  //|	BasicIntVarDecl SEMICOLON 	{ printf("RECOGNIZED RULE: Assignment Statement\n\n"); }
		// REDUNDANT, SEE LINE 138

	|	WRITE ID SEMICOLON 	{ printf("RECOGNIZED RULE: Write Statement\n\n"); }
		// WORKS

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
