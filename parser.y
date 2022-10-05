%{

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <string.h>

#include "symbolTable.h"
#include "AST.h"
#include "IRcode.h"
#include "assembly.h"
#include "calculator.h"


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
%token <string> LT
%token <string> GT
%token <string> EQ
%token <string> PLUS_OP
%token <string> MULTIPLY
%token <string> MINUS
%token <string> DIVIDE
%token <string> MODULUS
%token <string> LPAREN
%token <string> RPAREN
%token <string> LBRACE
%token <string> RBRACE
%token <string> COMMA
%token <string> SEMICOLON

%token <string> STRINGLITERAL
%token <string> CHARLITERAL
%token <string> WRITE

%token <string> ID
%token <string> NUMBER


%printer { fprintf(yyoutput, "%s", $$); } ID;
//not needed if NUMBER is a string
//%printer { fprintf(yyoutput, "%d", $$); } NUMBER;

%type <ast> Program DeclList Decl VarDecl StmtList Expr IDEQ AddExpr

%start Program

%%

Program: DeclList { printf("\nProgram -> DeclList \n");
		// ast
		$$ = $1;

		printf("\n\n ######################## AST STARTED ######################### \n\n");
		printAST($$,0);
		printf("\n\n ######################### AST ENDED ########################## \n\n");

		// end mips code
		createEndOfAssemblyCode();
		printf("\n\n ######################## MIPS CREATED ######################## \n\n");
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

	} | StmtList { printf("\nDecl -> StmtList \n");
		// ast
		$$ = $1;

};


/*----start vardecl-----------------------------------------------------------------------------------------------------*/


VarDecl:	INT ID SEMICOLON	{ printf("RECOGNIZED RULE: Integer Variable Declaration\n\n");		

							// semantic checks
								// is the variable already declared?
								symTabAccess();
								if (found($2,"G") == 1) {
									printf("ERROR: Variable %s already declared.\n",$2);
									exit(0); // variable already declared
								}

							// symbol table
							addItem($2, "VAR", "INT", 0, "G", 0);

							// ast
							$$ = AST_assignment("TYPE",$1,$2);

							// ir code
							createIntDefinition($2);

							// mips code (JUST FOR CODE TRACKING, DON'T THINK THIS IS NECESSARY IN MIPS)
							//createMipsIntDeclaration($2);
							
							// code optimization
								// N/A

							/*
										VarDecl
									INT        ID
							*/
				
			} |	ID EQ NUMBER SEMICOLON	{ printf("RECOGNIZED RULE: Integer Variable Initialization \n\n");
							
							// semantic checks
								// is the variable already declared
								symTabAccess();
								if (found($1,"G") == 0) { //if variable not declared yet
									printf("::::> SYNTAX ERROR: Variable %s not initialized.\n",$1);
									exit(0); // variable already declared
								}

								// is the statement redundant
								if (redundantValue($1, "G", $3) == 0) { // if statement is redundant
								// NEED TO MAKE THIS NOT PRINT AS IR CODE FOR CODE OPTIMIZATION
									printf("ERROR: Variable %s has already been declared as: %s.\n\n",$1,$3);
									exit(0);
								}

							// symbol table
							updateValue($1, "G", $3); // update the value of whatever id is passed in

							// ast
							$$ = AST_BinaryExpression("=",$1,$3);

							// ir code
							createIntAssignment($1,$3);

							// mips code
							createMipsIntAssignment($1, $3);

							// code optimization
								// N/A

							/*
									=
								ID    NUMBER
							*/

			} |	CHAR ID SEMICOLON	{ printf("RECOGNIZED RULE: Char Variable Declaration \n\n");

							// semantic checks
								// is the variable already declared?
								symTabAccess();
								if (found($2,"G") == 1) {
									exit(0); // variable already declared
								}

							// symbol table	
							addItem($2, "VAR", "CHR", 0, "G", 0);

							// ast
							$$ = AST_assignment("TYPE",$1,$2);

							// ir code
							createCharDefinition($2);
							
							// code optimization
								// N/A

							/*
									VarDecl
								CHAR	   ID
							*/					
			
			} |	ID EQ CHARLITERAL SEMICOLON	  { printf("RECOGNIZED RULE: Char Variable Initialization \n\n");				

							// semantic checks
								// is the variable already declared?
								symTabAccess();
								if (found($1,"G") == 0) { // if variable not declared yet
									printf("ERROR: Variable %s not initialized.\n",$1);
									exit(0); // variable already declared
								}

							// symbol table
							updateValue($1, "G", $3);
							
							// ast
							$$ = AST_BinaryExpression("=",$1,$3);

							// ir code
							createCharAssignment($1, $3);

							// mips code
							createMipsCharAssignment($1, $3);

							// code optimization
								// N/A

							/*
									=
								ID	   CHARLITERAL
							*/

			}
;


/*----end vardecl-------------------------------------------------------------------------------------------------------*/
  


StmtList:	Expr
	| Expr StmtList
;

Expr:	SEMICOLON {

	} |	ID SEMICOLON	{ printf("RECOGNIZED RULE: Simplest Expression\n\n"); 
		
		// @EVAN: are we sure we can do this? no type?


	} |	ID EQ ID SEMICOLON	{ printf("RECOGNIZED RULE: Assignment Statement\n\n"); 

		// semantic checks
			// are both variables already declared?
			symTabAccess();
			printf("\n");
			if (found($1,"G") == 0 || found($3,"G") == 0) { // if variable not declared yet
				printf("ERROR: Variable %s or %s not initialized.\n",$1,$3);
				exit(0); // variable already declared
			}

			// are the id's both variables?
			compareKinds($1, $3, "G");

			// are the types of the id's the same
			compareTypes($1, $3, "G");

		// symbol table
		updateValue($1, "G", getValue($3, "G"));

		// ast
		$$ = AST_BinaryExpression("=",$1,$3);

		// ir code
		createIDtoIDAssignment($1, $3);

		// mips code
		createMipsIDtoIDAssignment($1, $3, "G");

		// code optimization
			// mark the two id's as used
			isUsed($1, "G");
			isUsed($3, "G");


	} |	WRITE ID SEMICOLON 	{ printf("RECOGNIZED RULE: Write Statement\n\n"); 

		// semantic checks
			// is the id initialized as a value?
			initialized($2, "G");

		// symbol table
			// N/A

		// ast
		$$ = AST_BinaryExpression("Expr", $1, getValue($2, "G"));

		// ir code
		createWriteId($2);

		// mips code
			// get the type of the variable
			char* type = getVariableType($2, "G");

			// determine if its int or char
			int isInt = strcmp(type, "INT");
			int isChar = strcmp(type, "CHR");

			// run correct mips function according to type
			if (isInt == 0) { // if the variable is an integer
				createMIPSWriteInt($2);
			} else if (isChar == 0) { // if the variable is a char
				createMIPSWriteChar($2);
			}

		// code optimization
			// mark the id as used
			isUsed($2, "G");


	} | IDEQ SEMICOLON { printf("RECOGNIZED RULE: Addition Statement\n\n"); 

		// ast
		$$ = $1;

	}



IDEQ: ID EQ AddExpr {

	// ast
	// TODO: EVAN
	// TURN AddExpr INTO A STRING

	// calculations
		// turn the integer returned from calculate() into a string
		char total[50];
		sprintf(total, "%d", calculate());

		// wipe the arrays
		wipeArrays();

	// symbol table
	updateValue($1, "G", total);
		
	// ast
	$$ = AST_BinaryExpression("=", $1, getValue($1, "G"));
	
	// remove plus signs and spaces
	// add remaining chars

	} | ID EQ AddExpr {



}
	

AddExpr:	  NUMBER PLUS_OP AddExpr {

				addToNumArray($1);
				addToOpArray($2);

			} | ID PLUS_OP AddExpr {

				addToNumArray(getValue($1, "G"));
				addToOpArray($2);

			} | NUMBER {

				addToNumArray($1);

			} | ID {

				addToNumArray(getValue($1, "G"));

}


%%

int main(int argc, char**argv)
{
/*
	#ifdef YYDEBUG
		yydebug = 1;
	#endif
*/
	printf("\n\n ###################### COMPILER STARTED ###################### \n\n");
	
	// initialize ir code file
	initIRcodeFile();

	// initialize mips code file
	initAssemblyFile();
	
	if (argc > 1){
	  if(!(yyin = fopen(argv[1], "r")))
          {
		perror(argv[1]);
		return(1);
	  }
	}
	yyparse();

	printf("\n\n ####################### COMPILER ENDED ####################### \n\n");
	printf("\n\n ###################### SHOW SYMBOL TABLE ##################### \n\n\n");
	showSymTable();
	printf("\n\n ###################### END SYMBOL TABLE ###################### \n\n\n\n");
}

void yyerror(const char* s) {
	fprintf(stderr, "Parse error: %s\n", s);
	exit(1);
}
