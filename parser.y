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
#include "ctype.h"


extern int yylex();
extern int yyparse();
extern FILE* yyin;

void yyerror(const char* s);
char currentScope[50]; /* global or the name of the function */
char operator;
//initialize scope and symbol table
char scope[50] = "G" ;

%}


%union {
	int number;
	char character;
	char* string;
	struct AST* ast;
}

%token <string> CHAR
%token <string> INT
%token <string> FLOAT
%token <string> FLOAT_NUM
%token <string> VOID

%token <string> IF
%token <string> ELSE
%token <string> WHILE
%token <string> PRINT
%token <string> DOUBLE_EQ
%token <string> NOT_EQ
%token <string> LT_EQ
%token <string> GT_EQ
%token <string> LT
%token <string> GT
%token <string> EQ
%token <string> PLUS_EQ
%token <string> MULT_EQ
%token <string> SUB_EQ
%token <string> DIV_EQ
%token <string> PLUS_OP
%token <string> MULT_OP
%token <string> SUB_OP
%token <string> DIV_OP
%token <string> EXPONENT
%token <string> MODULUS
%token <string> LPAREN
%token <string> RPAREN
%token <string> LBRACKET
%token <string> RBRACKET
%token <string> LBRACE
%token <string> RBRACE
%token <string> COMMA
%token <string> SEMICOLON
%token <string> NEWLINECHAR
%token <string> APOSTROPHE
%token <string> LETTER

%token <string> STRINGLITERAL
%token <string> CHARLITERAL
%token <string> WRITE

%token <string> ID
%token <string> NUMBER

/* For order of operations:
%left PLUS_OP
%left MINUS
%left MULTIPLY
%left DIVIDE
%right EXPONENT

Binop: '+' | '-' ... | '^'
*/

/* For function decl:
FunDecl: Type ID Leftparen ParamDecl Rightparen Block

Mid rule action:
FunDecl: Type ID {printf("Function declared \n"); SymbtabAdd($1,$2,"G");} Leftparen ParamDecl Rightparen Block

note: return type must match to variable returned
	  for mid action rule, it will currently not work since it will take Type ID as a function before we even know.
	  possible solution, add a keyword to our language to identify function intentionality such as:
	  function int getNum(){return 1;}

AST for function decl:


*/


%printer { fprintf(yyoutput, "%s", $$); } ID;
//not needed if NUMBER is a string
//%printer { fprintf(yyoutput, "%d", $$); } NUMBER;

%type <ast> Program DeclList Decl VarDecl FuncDecl ParamDeclList ParamDecl Block BlockDeclList BlockDecl StmtList Expr IDEQExpr Math Operator ArrDecl

%start Program

%%

Program: DeclList { //printf("\nProgram -> DeclList \n");
		// ast
		$$ = $1;

		printf("\n\n ########################" RESET);
		printf(BPINK " AST STARTED " RESET);
		printf("######################### \n\n" RESET);
		printAST($$,0);
		printf("\n\n #########################" RESET);
		printf(PINK " AST ENDED " RESET);
		printf("########################## \n\n" RESET);

		// end mips code
		createEndOfAssemblyCode();
		appendFiles("tempMIPS.asm", "MIPScode.asm");
		printf("\n\n #######################" RESET);
		printf(BPINK " MIPS GENERATED " RESET);
		printf("####################### \n\n" RESET);
};

DeclList:   Decl DeclList {
		// ast
		$1->left = $2;
		$$ = $1;

}
			| Decl {
			// ast
			$$ = $1;

};

Decl:	FuncDecl {
		// ast
		$$ = $1;

	} | VarDecl {
		// ast
		$$ = $1;

	} | StmtList {
		// ast
		$$ = $1;

};


FuncDecl: VOID ID LPAREN {
								printf(GREEN "Function declared \n" RESET); 
								symTabAccess(); addSymbolTable($2,"VOID"); 
								strcpy(scope,$2); printf("\n:::::::::SCOPE = %s:::::::\n",scope);} 
	
							ParamDeclList RPAREN Block {
								//showSymTable();
								printf("\nFUNCTION DECLARATION FOUND.\n");
								//addItem("testing","FUNC","VOID",$2,0);
								// ast
								$$ = AST_assignment("FNC",$1,$2);
						
						} | INT ID LPAREN {printf(GREEN "Function declared \n" RESET);
								symTabAccess();
								addSymbolTable($2,"INT");
								strcpy(scope,$2); printf("\n:::::::::SCOPE = %s:::::::\n",scope); } 
						 
						 ParamDeclList RPAREN Block {
								//showSymTable();
								printf("\nFUNCTION DECLARATION FOUND.\n");

								// ast
								//$$ = $1;
						
						} | CHAR ID LPAREN {printf(GREEN "Function declared \n" RESET);
								symTabAccess();
								addSymbolTable($2,"CHAR");
								strcpy(scope,$2); printf("\n:::::::::SCOPE = %s:::::::\n",scope); } 
						 
						 ParamDeclList RPAREN Block {
								//showSymTable();
								printf("\nFUNCTION DECLARATION FOUND.\n");

								// ast
								//$$ = $1;
						
						} | FLOAT ID LPAREN {printf(GREEN "Function declared \n" RESET);
								symTabAccess();
								addSymbolTable($2,"FLOAT");
								strcpy(scope,$2); printf("\n:::::::::SCOPE = %s:::::::\n",scope); } 
								
						 ParamDeclList RPAREN Block {
								//showSymTable();
								printf("\nFUNCTION DECLARATION FOUND.\n");

								// ast
								//$$ = $1;	

}

ParamDeclList: ParamDecl COMMA ParamDeclList {

					$1->left = $2;
					$$ = $1;

				} | ParamDecl {

					$$ = $1;

				}

ParamDecl:		| INT ID { printf(GRAY "RECOGNIZED RULE: Integer Parameter Initialization \n\n" RESET);

					addItem($2,"PARA","INT",scope,0);

				} | FLOAT ID { printf(GRAY "RECOGNIZED RULE: Integer Parameter Initialization \n\n" RESET);

					addItem($2,"PARA","FLT",scope,0);

				} | CHAR ID { printf(GRAY "RECOGNIZED RULE: Integer Parameter Initialization \n\n" RESET);

					addItem($2,"PARA","CHR",scope,0);

				}

Block: LBRACKET BlockDeclList RBRACKET {
	// ast
	//$$ = $1;
	
	// reset scope back to global after function is over
	strcpy(scope,"G");
}


BlockDeclList: BlockDecl BlockDeclList {
		// ast
		$1->left = $2;
		$$ = $1;

}
			| BlockDecl {
			// ast
			$$ = $1;
			}

BlockDecl: VarDecl {
		   // ast
		   $$ = $1;

		} | StmtList {
		  // ast
		  $$ = $1;

};


StmtList:	| Expr StmtList {$1->left = $2; $$ = $1;}
			| Expr {$$ = $1;}
;

/*----start vardecl-----------------------------------------------------------------------------------------------------*/


VarDecl:	INT ID SEMICOLON	{ printf(GRAY "RECOGNIZED RULE: Integer Variable Declaration\n\n" RESET);		

							// semantic checks
								// is the variable already declared?
								symTabAccess();
								if (found($2,scope) == 1) {
									printf(RED "\nERROR: Variable '%s' already declared.\n" RESET,$2);
									exit(0); // variable already declared
								}

							// symbol table
							addItem($2, "VAR", "INT", scope, 0);

							// ast
							$$ = AST_assignment("TYPE",$1,$2);

							// ir code
							createIntDefinition($2, scope);

							// mips code (JUST FOR CODE TRACKING, DON'T THINK THIS IS NECESSARY IN MIPS)
							//createMIPSIntDeclaration($2);
							
							// code optimization
								// N/A

							/*
										VarDecl
									INT        ID
							*/
				
			} |	ID EQ NUMBER SEMICOLON	{ printf(GRAY "RECOGNIZED RULE: Integer Variable Initialization \n\n" RESET);
							
							// semantic checks
								// is the variable already declared
								symTabAccess();
								if (found($1,scope) == 0) { //if variable not declared yet
									printf(RED "::::> CHECK FAILED: Variable %s not initialized.\n" RESET,$1);
									exit(0); // variable already declared
								}

								// is the statement redundant
								if (redundantValue($1, scope, $3) == 0) { // if statement is redundant
								// NEED TO MAKE THIS NOT PRINT AS IR CODE FOR CODE OPTIMIZATION
									printf(RED "::::> CHECK FAILED: Variable %s has already been declared as: %s.\n\n" RESET,$1,$3);
									exit(0);
								}

							// symbol table
							updateValue($1, scope, $3); // update the value of whatever id is passed in

							// ast
							$$ = AST_BinaryExpression("=",$1,$3);

							// ir code
							createIntAssignment($1,$3, scope);

							// mips code
							createMIPSIntAssignment($1, $3, scope);

							// code optimization
								// N/A

							/*
									=
								ID    NUMBER
							*/

			} |	CHAR ID SEMICOLON	{ printf(GRAY "RECOGNIZED RULE: Char Variable Declaration \n\n" RESET);

							// semantic checks
								// is the variable already declared?
								symTabAccess();
								if (found($2,scope) == 1) {
									exit(0); // variable already declared
								}

							// symbol table	
							addItem($2, "VAR", "CHR", scope, 0);

							// ast
							$$ = AST_assignment("TYPE",$1,$2);

							// ir code
							createCharDefinition($2, scope);
							
							// code optimization
								// N/A

							/*
									VarDecl
								CHAR	   ID
							*/					
			
			} |	ID EQ CHARLITERAL SEMICOLON	  { printf(GRAY "RECOGNIZED RULE: Char Variable Initialization \n\n" RESET);		

							// remove apostrophes from charliteral
							char* str = removeApostrophes($3);

							// semantic checks
								// is the variable already declared?
								symTabAccess();
								if (found($1,scope) == 0) { // if variable not declared yet
									printf(RED "::::> CHECK FAILED: Variable '%s' not initialized.\n" RESET,$1);
									exit(0); // variable already declared
								}

								// is the statement redundant
								if (redundantValue($1, scope, str) == 0) { // if statement is redundant
								// NEED TO MAKE THIS NOT PRINT AS IR CODE FOR CODE OPTIMIZATION
									printf(RED "::::> CHECK FAILED: Variable '%s' has already been declared as: %s.\n\n" RESET,$1,$3);
									exit(0);
								}

							// symbol table
							updateValue($1, scope, str);
							
							// ast
							$$ = AST_BinaryExpression("=",$1,str);

							// ir code
							createCharAssignment($1, str, scope);

							// mips code
							createMIPSCharAssignment($1, str, scope);

							// code optimization
								// N/A

							/*
									=
								ID	   CHARLITERAL
							*/

			} | FLOAT ID SEMICOLON	{ printf(GRAY "RECOGNIZED RULE: Float Variable Declaration\n\n" RESET);		

							// semantic checks
								// is the variable already declared?
								symTabAccess();
								if (found($2,scope) == 1) {
									printf(RED "\nERROR: Variable '%s' already declared.\n" RESET,$2);
									exit(0); // variable already declared
								}

							// symbol table
							addItem($2, "VAR", "FLT", scope, 0);

							// ast
							$$ = AST_assignment("TYPE",$1,$2);

							// ir code
							createFloatDefinition($2, scope);

							// mips code (JUST FOR CODE TRACKING, DON'T THINK THIS IS NECESSARY IN MIPS)
							//createMIPSIntDeclaration($2);
							
							// code optimization
								// N/A

							/*
										VarDecl
									INT        ID
							*/
				} |	ID EQ FLOAT_NUM SEMICOLON	{ printf(GRAY "RECOGNIZED RULE: Integer Variable Initialization \n\n" RESET);
							
							// semantic checks
								// is the variable already declared
								symTabAccess();
								if (found($1,scope) == 0) { //if variable not declared yet
									printf(RED "\n::::> CHECK FAILED: Variable '%s' not initialized.\n\n" RESET,$1);
									exit(0); // variable already declared
								}

								// is the statement redundant
								if (redundantValue($1, scope, $3) == 0) { // if statement is redundant
								// NEED TO MAKE THIS NOT PRINT AS IR CODE FOR CODE OPTIMIZATION
									printf(RED "\n::::> CHECK FAILED: Variable '%s' has already been declared as: %s.\n\n" RESET,$1,$3);
									exit(0);
								}

							// symbol table
							updateValue($1, scope, $3); // update the value of whatever id is passed in

							// ast
							$$ = AST_BinaryExpression("=",$1,$3);

							// ir code
							createFloatAssignment($1,$3, scope);

							// mips code
							createMIPSFloatAssignment($1, $3, scope);

							// code optimization
								// N/A

							/*
									=
								ID    NUMBER
							*/

				} |	ID EQ ID SEMICOLON	{ printf(GRAY "RECOGNIZED RULE: Assignment Statement\n\n" RESET); 

					// semantic checks
						// are both variables already declared?
						symTabAccess();
						printf("\n");
						if (found($1,scope) == 0 || found($3,scope) == 0) { // if variable not declared yet
							printf("ERROR: Variable %s or %s not declared.\n",$1,$3);
							exit(0); // variable already declared
						}

						// does the second id have a value?
						initialized($3, scope);

						// are the id's both variables?
						compareKinds($1, $3, scope);

						// are the types of the id's the same
						compareTypes($1, $3, scope);

					// symbol table
					updateValue($1, scope, getValue($3, scope));

					// ast
					$$ = AST_BinaryExpression("=",$1,$3);

					// ir code
					createIDtoIDAssignment($1, $3, scope);

					// mips code
					createMIPSIDtoIDAssignment($1, $3, scope);

					// code optimization
						// mark the two id's as used
						isUsed($1, scope);
						isUsed($3, scope);


				} | IDEQExpr SEMICOLON { printf(GRAY "RECOGNIZED RULE: Addition Statement\n\n" RESET); 

						// ast
						$$ = $1;

						/*
									=
								ID	  NUMBER
						*/

				} | ArrDecl {};
;


/*----end vardecl-------------------------------------------------------------------------------------------------------*/
  


Expr:	SEMICOLON {

	} |	ID EQ ID SEMICOLON	{ printf(GRAY "RECOGNIZED RULE: Assignment Statement\n\n" RESET); 

		// semantic checks
			// are both variables already declared?
			symTabAccess();
			printf("\n");
			if (found($1,scope) == 0 || found($3,scope) == 0) { // if variable not declared yet
				printf("ERROR: Variable %s or %s not declared.\n",$1,$3);
				exit(0); // variable already declared
			}

			// does the second id have a value?
			initialized($3, scope);

			// are the id's both variables?
			compareKinds($1, $3, scope);

			// are the types of the id's the same
			compareTypes($1, $3, scope);

		// symbol table
		updateValue($1, scope, getValue($3, scope));

		// ast
		$$ = AST_BinaryExpression("=",$1,$3);

		// ir code
		createIDtoIDAssignment($1, $3, scope);

		// mips code
		createMIPSIDtoIDAssignment($1, $3, scope);

		// code optimization
			// mark the two id's as used
			isUsed($1, scope);
			isUsed($3, scope);


	} |	WRITE ID SEMICOLON 	{ printf(GRAY "RECOGNIZED RULE: Write Statement\n\n" RESET); 

		// semantic checks
			// is the id initialized as a value?
			initialized($2, scope);

		// symbol table
			// N/A

		// ast
		$$ = AST_BinaryExpression("Expr", $1, getValue($2, scope));

		// ir code
		createWriteId($2, scope);

		// mips code
			// get the type of the variable
			char* type = getVariableType($2, scope);

			// determine if its int or char
			int isInt = strcmp(type, "INT");
			int isChar = strcmp(type, "CHR");
			int isFloat = strcmp(type, "FLT");

			// run correct mips function according to type
			if (isInt == 0) { // if the variable is an integer
				createMIPSWriteInt($2, scope);
			} else if (isChar == 0) { // if the variable is a char
				createMIPSWriteChar($2, scope);
			} else if (isFloat == 0) {
				createMIPSWriteFloat($2, scope);
			}

		// code optimization
			// mark the id as used
			isUsed($2, scope);

		/*
					Expr
			  WRITE     getValue(ID)
		*/

	} | WRITE NEWLINECHAR SEMICOLON { printf(GRAY "RECOGNIZED RULE: Print New Line\n\n" RESET); 

			makeMIPSNewLine();


	} | IDEQExpr SEMICOLON { printf(GRAY "RECOGNIZED RULE: Math Statement\n\n" RESET); 

		// ast
		$$ = $1;

		/*
					=
				ID	  NUMBER
		*/

	} | ID LBRACE NUMBER RBRACE EQ NUMBER SEMICOLON { printf(GRAY "RECOGNIZED RULE: Modify Array Index\n\n" RESET);

			// convert index to integer
			int index = atoi($3);

			//symbol table value update
			updateArrayValue($1, index, scope, "INT", $6);

			// ast
			$$ = AST_assignment($1,$3,$6);


	} | ID LBRACE NUMBER RBRACE EQ Math SEMICOLON {

			// turn the integer returned from calculate() into a string
			char total[50];
			sprintf(total, "%d", calculate());
	
			// convert index to integer
			int index = atoi($3);

			// array table
			updateArrayValue($1, index, scope, "INT", total); //TODO DOES NOT RESOLVE FLOATS

			// ast
			$$ = AST_assignment($1,$3,total);

	
	} | ID LBRACE NUMBER RBRACE EQ CHARLITERAL SEMICOLON { printf(GRAY "RECOGNIZED RULE: Modify Array Index\n\n" RESET);

			// convert index to integer
			int index = atoi($3);

			// remove apostrophes from charliteral
			char* str = removeApostrophes($6);

			// array table
			updateArrayValue($1, index, scope, "CHR", str);

			// ast
			$$ = AST_assignment($1,$3,str);


} 



IDEQExpr: ID EQ Math {

	// ast
	// TODO: EVAN

	// semantic checks
		// inside Math

	// calculations: code optimization
		// turn the integer returned from calculate() into a string
		char total[50];
		sprintf(total, "%d", calculate());

		// wipe the arrays
		wipeArrays();

	// symbol table
	updateValue($1, scope, total);
		
	// ast
	$$ = AST_BinaryExpression("=", $1, total);

	// ir code
	createIntAssignment($1, total, scope);

	// mips code
	createMIPSAddition($1, total, scope);

	// code optimization
		// mark the id as used
		isUsed($1, scope);

}

Math: 		NUMBER Operator Math {

				addToNumArray($1);
				addToOpArray($2);

			} | ID Operator Math {

				// semantic checks
					// does the id have a value?
					initialized($1, scope);

					// is the id a char?
					if (isChar($1,scope) == 1) {
						printf(RED "ERROR: Cannot do operations on '%s' to an int variable, type mismatch.\n\n" RESET, $1);
						exit(0);
					}

				// add to number array
				addToNumArray(getValue($1, scope));
				addToOpArray($2);

				// code optimization
					// mark the id as used
					isUsed($1, scope);
			
			} | NUMBER {
 
				// add to number array
				addToNumArray($1);

			} | ID {

				// semantic checks
					// does the id have a value?
					initialized($1, scope);

					// is the id a char?
					if (isChar($1,scope) == 1) {
						printf(RED "\nERROR: Cannot do operations on '%s' to an int variable, type mismatch.\n\n" RESET, $1);
						exit(0);
					}

				// add to number array
				addToNumArray(getValue($1, scope));

				// code optimization
					// mark the id as used
					isUsed($1, scope);

}

Operator: PLUS_OP {}	
		| SUB_OP {}
		| MULT_OP {}
		| DIV_OP {}

// ARRAY DECLARATIONS ----------------------------------------------------------------------
ArrDecl:	
			INT ID LBRACE RBRACE SEMICOLON { printf(GRAY "RECOGNIZED RULE: Integer Array Initialization Without Range\n\n" RESET);
				//int foo[]; //We should only have arrays be declared with range imo.



			} | CHAR ID LBRACE RBRACE SEMICOLON { printf(GRAY "RECOGNIZED RULE: Char Array Initialization Without Range\n\n" RESET);
				//char foo[]; //We should only have arrays be declared with range imo.

			

			} | INT ID LBRACE NUMBER RBRACE SEMICOLON { printf(GRAY "RECOGNIZED RULE: Integer Array Initialization With Range\n\n" RESET);
				//int foo[4];
							// semantic checks
								// is the array already declared?
								symTabAccess();
								if (found($2,scope) == 1) {
									printf(RED "\nERROR: Array '%s' already declared.\n" RESET,$2);
									exit(0); // variable already declared
								}


							addArray($2, "ARR", "INT", $4, scope);

							// ast
							$$ = AST_assignment("ARR",$1,$2);


			} | CHAR ID LBRACE NUMBER RBRACE SEMICOLON { printf(GRAY "RECOGNIZED RULE: Char Array Initialization With Range\n\n" RESET);

							// semantic checks
								// is the array already declared?
								symTabAccess();
								if (found($2,scope) == 1) {
									printf(RED "\nERROR: Array '%s' already declared.\n" RESET,$2);
									exit(0); // variable already declared
								}

							//symboltable
							addArray($2, "ARR", "CHR", $4, scope);

							// ast
							$$ = AST_assignment("ARR",$1,$2);


}; 


%%

int main(int argc, char**argv)
{
/*
	#ifdef YYDEBUG
		yydebug = 1;
	#endif
*/
	printf(BOLD "\n\n ###################### COMPILER STARTED ###################### \n\n" RESET);

	initializeSymbolTable();


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

	printf("\n\n #######################" RESET);
	printf(BOLD " COMPILER ENDED " RESET);
	printf("####################### \n\n" RESET);
	
	printf("\n\n ######################" RESET);
	printf(BPINK " SHOW SYMBOL TABLE " RESET);
	printf("##################### \n\n\n\n" RESET);
	showSymTable();

	//printf("\n\n ######################" RESET);
	//printf(BPINK " SHOW ARRAY TABLES " RESET);
	//printf("##################### \n\n\n\n" RESET);
	//showArrTable();

	printf("\n\n\n ######################" RESET);
	printf(PINK " END SYMBOL TABLE " RESET);
	printf("###################### \n\n" RESET);
	
	//printf("\n\n\n ######################" RESET);
	//printf(PINK " REMOVE UNUSED VARIABLES " RESET);
	//printf("###################### \n\n\n\n" RESET);
	//cleanAssemblyCodeOfUnsuedVariables();
	//printf("############################################# \n\n\n\n" RESET);
}

void yyerror(const char* s) {
	fprintf(stderr, RED "\nBison Parse Error: %s\n" RESET, s);
	showSymTable();
	exit(1);
}
