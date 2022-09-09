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

VarDecl:	INT ID SEMICOLON { printf("RECOGNIZED RULE: Integer Variable Declaration: %s\n\n", $2);
							   
							   // ast
							   $$->left = $1;
							   $$->right = $2;

							}


			|INT BasicIntVarDecl SEMICOLON	{
								  printf("RECOGNIZED RULE: Integer Variable declaration\n\n");

								  //ast
								  //$$->left = $1;
								  //$$->right = $2;

								  /*
								  		 VarDecl
									 INT       \------- BasicIntVarDecl
									 				INT               NUMBER
								  */
		  
								  //printf("Items recognized: %s, %s, %c \n", $1, $2, $3);
								}

			|BasicIntVarDecl SEMICOLON	{
								  printf("RECOGNIZED RULE: Integer Variable declaration \n\n");

								  // ast
								  //$$ = $1;

								  /*
								  		=
									ID	   NUMBER
								  */

								  //printf("Items recognized: %s, %s, %c \n", $1, $2, $3);
								}
			|CHAR ID SEMICOLON	{ printf("RECOGNIZED RULE: Char Variable declaration \n\n");

								  // ast
								  //$$->left = $1;
								  //$$->right = $2;

								  //printf("Items recognized: %s, %s, %c \n", $1, $2, $3);
								}					
			
			|CHAR BasicCharVarDecl SEMICOLON { printf("RECOGNIZED RULE: Char Variable declaration \n\n");
											
											// ast
											//$$->left = $1;
											//$$->right = $2;
									  		//printf("Items recognized: %s, %s, %c \n", $1, $2, $3);
									} 

			|BasicCharVarDecl SEMICOLON	{
								  printf("RECOGNIZED RULE: Char Variable declaration \n\n");
								  //$$ = $1;
								  //printf("Items recognized: %s, %s, %c \n", $1, $2, $3);
								}
;

BasicIntVarDecl: ID EQ NUMBER { printf("RECOGNIZED RULE: Basic Integer Variable declaration \n\n");
								  // ast
								  //$$ = $2;
								  //$$->left = $1;
								  //$$->right = $2;

								  /*
										     =
									 	 ID    NUMBER
									        
								  */

								  //printf("Items recognized: %s, %s, %c \n", $1, $2, $3);
};

BasicCharVarDecl: ID EQ CHARLITERAL { printf("RECOGNIZED RULE: Basic Charliteral Variable declaration \n\n");
								  // ast
								  //$$->left = $1;
								  //$$->right = $2;

								  /*
								  		=
									ID		CHARLITERAL
								  */

								  //printf("Items recognized: %s, %s, %c \n", $1, $2, $3);
								}


StmtList:	Expr
	| Expr StmtList
;

Expr:	SEMICOLON {}
	| ID SEMICOLON { printf("RECOGNIZED RULE: Simplest expression\n\n"); }
	| ID EQ ID SEMICOLON	{ printf("RECOGNIZED RULE: Assignment statement\n\n"); }
	| BasicIntVarDecl SEMICOLON 	{ printf("RECOGNIZED RULE: Assignment statement\n\n"); }
	| WRITE ID SEMICOLON 	{ printf("RECOGNIZED RULE: WRITE statement\n\n"); }

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
