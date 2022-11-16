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
int argCounter = 0;
char *args[50];
char **argptr = args;
int pass = 0;

//initialize scope and symbol table
char scope[50] = "G";

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
%token <string> RETURN

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

%type <ast> Program DeclList Decl VarDecl FuncDecl ParamDeclList IfStmt Condition ParamDecl ArgDeclList ArgDecl Block BlockDeclList BlockDecl StmtList Expr IDEQExpr MathStmt Math Operator ArrDecl

%start Program

%%

Program: Condition { //printf("\nProgram -> DeclList \n");
		// ast
		$$ = $1;

		printf("\n\n ########################" RESET);
		printf(BPINK " AST STARTED " RESET);
		printf("######################### \n\n" RESET);
		//printAST($$,0);
		printf("\n\n #########################" RESET);
		printf(PINK " AST ENDED " RESET);
		printf("########################## \n\n" RESET);

		// end mips code
		createEndOfAssemblyCode();
		appendFiles("tempMIPS.asm", "MIPScode.asm");
		printf("\n");
		appendFiles("MIPSfuncs.asm", "MIPScode.asm");
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

	} | Condition {
		$$ = $1;
	

};


FuncDecl: VOID ID LPAREN { 		printf(GRAY "RECOGNIZED RULE: Void Function Initialization \n\n" RESET); 
								symTabAccess(); addSymbolTable($2,"VOID"); 
								strcpy(scope,$2); 
								//printf(ORANGE "\nCurrent Scope: '%s'\n" RESET, scope)

								// ir code
								printf(BLUE "IR Code" RESET);
								printf(RED " NOT " RESET);
								printf(BLUE "Created.\n" RESET);

								// mips
								createMIPSFunction($2);

								} 
	
							ParamDeclList RPAREN Block { printf(BGREEN "\nVoid Function End.\n" RESET);
								//showSymTable();
								//addItem("testing","FUNC","VOID",$2,0);
								// ast
								$$ = AST_assignment("FNC",$1,$2);

								// ir code
								printf(BLUE "IR Code Not Needed.\n" RESET);

								// mips
								endMIPSFunction();
						
						} | INT ID LPAREN {printf(GRAY "RECOGNIZED RULE: Integer Function Initialization \n\n" RESET);
								symTabAccess();
								addSymbolTable($2,"INT");
								strcpy(scope,$2); 
								//printf(ORANGE "\nCurrent Scope: '%s'\n" RESET, scope);

								// ir code
								printf(BLUE "IR Code" RESET);
								printf(RED " NOT " RESET);
								printf(BLUE "Created.\n" RESET);

								// mips
								createMIPSFunction($2);

								} 
						 
						 ParamDeclList RPAREN Block { printf(BGREEN "\nInt Function End.\n" RESET);
								//showSymTable();

								// ast
								$$ = AST_assignment("FNC",$1,$2);

								// ir code
								printf(BLUE "IR Code Not Needed.\n" RESET);

								// mips code
								endMIPSFunction();

						
						} | CHAR ID LPAREN {printf(GRAY "RECOGNIZED RULE: Char Function Initialization \n\n" RESET);
								symTabAccess();
								addSymbolTable($2,"CHR");
								strcpy(scope,$2); 
								//printf(ORANGE "\nCurrent Scope: '%s'\n" RESET, scope); 

								// ir code
								printf(BLUE "IR Code" RESET);
								printf(RED " NOT " RESET);
								printf(BLUE "Created.\n" RESET);

								// mips
								createMIPSFunction($2);

								} 
						 
						 ParamDeclList RPAREN Block { printf(BGREEN "\nChar Function End.\n" RESET);
								//showSymTable();
								// ast
								$$ = AST_assignment("FNC",$1,$2);

								// ir code
								printf(BLUE "IR Code Not Needed.\n" RESET);

								// mips
								endMIPSFunction();

						
						} | FLOAT ID LPAREN {printf(GRAY "RECOGNIZED RULE: Float Function Initialization \n\n" RESET);
								symTabAccess();
								addSymbolTable($2,"FLT");
								strcpy(scope,$2); 
								//printf(ORANGE "\nCurrent Scope: '%s'\n" RESET, scope); 

								// ir code
								printf(BLUE "IR Code" RESET);
								printf(RED " NOT " RESET);
								printf(BLUE "Created.\n" RESET);

								// mips
								createMIPSFunction($2);
						

								} 
								
						 ParamDeclList RPAREN Block { printf(BGREEN "\nFloat Function End.\n" RESET);
								//showSymTable();

								// ast
								$$ = AST_assignment("FNC",$1,$2);	

								// ir code
								printf(BLUE "IR Code Not Needed.\n" RESET);

								// mips
								endMIPSFunction();

}

ParamDeclList: ParamDecl COMMA ParamDeclList {

					$1->left = $2;
					$$ = $1;

				} | ParamDecl {

					$$ = $1;

				}

ParamDecl:		| INT ID { printf(GRAY "RECOGNIZED RULE: Integer Parameter Initialization \n\n" RESET);

					addItem($2,"PAR","INT",scope,0);

					// ir code
					printf(BLUE "IR Code" RESET);
					printf(RED " NOT " RESET);
					printf(BLUE "Created.\n" RESET);

					// mips
					printf(CYAN "   MIPS" RESET);
					printf(RED " NOT " RESET);
					printf(CYAN "Created.\n\n\n" RESET);


				} | FLOAT ID { printf(GRAY "RECOGNIZED RULE: Float Parameter Initialization \n\n" RESET);

					addItem($2,"PAR","FLT",scope,0);

					// ir code
					printf(BLUE "IR Code" RESET);
					printf(RED " NOT " RESET);
					printf(BLUE "Created.\n" RESET);

					// mips
					printf(CYAN "   MIPS" RESET);
					printf(RED " NOT " RESET);
					printf(CYAN "Created.\n\n\n" RESET);


				} | CHAR ID { printf(GRAY "RECOGNIZED RULE: Char Parameter Initialization \n\n" RESET);

					addItem($2,"PAR","CHR",scope,0);

					// ir code
					printf(BLUE "IR Code" RESET);
					printf(RED " NOT " RESET);
					printf(BLUE "Created.\n" RESET);

					// mips
					printf(CYAN "   MIPS" RESET);
					printf(RED " NOT " RESET);
					printf(CYAN "Created.\n\n\n" RESET);
					

				}

ArgDeclList: ArgDecl COMMA ArgDeclList {

					$1->left = $2;
					$$ = $1;

				} | ArgDecl {

					$$ = $1;

				}

ArgDecl:	| NUMBER {

				argptr[argCounter] = $1;
				argCounter++;
				
				printf(GRAY "RECOGNIZED RULE: Parameter = %s\n\n" RESET, $1);


			} | FLOAT_NUM {

				argptr[argCounter] = $1;
				argCounter++;
				
				printf(GRAY "RECOGNIZED RULE: Parameter = %s\n\n" RESET, $1);


			} | CHARLITERAL {

				argptr[argCounter] = $1;
				argCounter++;
				
				printf(GRAY "RECOGNIZED RULE: Parameter = %s\n\n" RESET, $1);	
			 

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
							createMIPSIntDecl($2,scope);
							printf(CYAN "MIPS Not Needed.\n\n\n" RESET);
							
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
								if (scope == "G") {
									if (found($1,scope) == 0) { //if variable not declared yet
										printf(RED "\n::::> CHECK FAILED: Variable '%s' not initialized in the global scope.\n\n" RESET,$1);
										exit(0); // variable already declared
									}
								} else {
									if (found($1,scope) == 0) { //if variable not declared yet
										if (found($1, "G") == 0) {
											showSymTable();
											printf(RED "\n::::> CHECK FAILED: Variable '%s' not initialized in the function or global scope.\n\n" RESET,$1);
											exit(0); // variable already declared
										}
									}
								}

								// is the statement redundant
								if (redundantValue($1, scope, $3) == 0) { // if statement is redundant
								// NEED TO MAKE THIS NOT PRINT AS IR CODE FOR CODE OPTIMIZATION
									printf(RED "::::> CHECK FAILED: Variable %s has already been declared as: %s.\n\n" RESET,$1,$3);
									exit(0);
								}

							// symbol table
							if (strcmp(scope, "G") != 0) { // if scope is in function

								if (found($1, scope) == 1) { // if the variable is found in the function's sym table

									updateValue($1, scope, $3); // update value in function sym table

								} else if (found($1, "G") == 1) { // if the variable is found in the global scope

									updateValue($1, "G", $3); // update value in global sym table

								}

							} else { // if scope is global
								updateValue($1, scope, $3); // update value normally
							}

							// ast
							$$ = AST_BinaryExpression("=",$1,$3);

							// ir code
							createIntAssignment($1, $3, scope);

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

							// mips
							printf(CYAN "MIPS Not Needed.\n\n\n" RESET);
							
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
								if (scope == "G") {
									if (found($1,scope) == 0) { //if variable not declared yet
										printf(RED "\n::::> CHECK FAILED: Variable '%s' not initialized in the global scope.\n\n" RESET,$1);
										exit(0); // variable already declared
									}
								} else {
									if (found($1,scope) == 0) { //if variable not declared yet
										if (found($1, "G") == 0) {
											showSymTable();
											printf(RED "\n::::> CHECK FAILED: Variable '%s' not initialized in the function or global scope.\n\n" RESET,$1);
											exit(0); // variable already declared
										}
									}
								}

								// is the statement redundant
								if (redundantValue($1, scope, str) == 0) { // if statement is redundant
								// NEED TO MAKE THIS NOT PRINT AS IR CODE FOR CODE OPTIMIZATION
									printf(RED "::::> CHECK FAILED: Variable '%s' has already been declared as: %s.\n\n" RESET,$1,$3);
									exit(0);
								}

							// symbol table
							if (strcmp(scope, "G") != 0) { // if scope is in function

								if (found($1, scope) == 1) { // if the variable is found in the function's sym table

									updateValue($1, scope, str); // update value in function sym table

								} else if (found($1, "G") == 1) { // if the variable is found in the global scope

									updateValue($1, "G", str); // update value in global sym table

								}

							} else { // if scope is global
								updateValue($1, scope, str); // update value normally
							}
							
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
							printf(CYAN "MIPS Not Needed.\n\n\n" RESET);
							
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
								if (scope == "G") {
									if (found($1,scope) == 0) { //if variable not declared yet
										printf(RED "\n::::> CHECK FAILED: Variable '%s' not initialized in the global scope.\n\n" RESET,$1);
										exit(0); // variable already declared
									}
								} else {
									if (found($1,scope) == 0) { //if variable not declared yet
										if (found($1, "G") == 0) {
											showSymTable();
											printf(RED "\n::::> CHECK FAILED: Variable '%s' not initialized in the function or global scope.\n\n" RESET,$1);
											exit(0); // variable already declared
										}
									}
								}


								// is the statement redundant
								if (redundantValue($1, scope, $3) == 0) { // if statement is redundant
								// NEED TO MAKE THIS NOT PRINT AS IR CODE FOR CODE OPTIMIZATION
									printf(RED "\n::::> CHECK FAILED: Variable '%s' has already been declared as: %s.\n\n" RESET,$1,$3);
									exit(0);
								}

							// symbol table
							if (strcmp(scope, "G") != 0) { // if scope is in function

								if (found($1, scope) == 1) { // if the variable is found in the function's sym table

									updateValue($1, scope, $3); // update value in function sym table

								} else if (found($1, "G") == 1) { // if the variable is found in the global scope

									updateValue($1, "G", $3); // update value in global sym table

								}

							} else { // if scope is global
								updateValue($1, scope, $3); // update value normally
							}

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
							printf(RED "\nERROR: Variable %s or %s not declared.\n\n" RESET,$1,$3);
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
				printf(RED "\nERROR: Variable %s or %s not declared.\n\n" RESET,$1,$3);
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

	} | ID EQ ID LPAREN ArgDeclList RPAREN SEMICOLON { printf(GRAY "RECOGNIZED RULE: ID = FUNCTION\n" RESET); 

		// symbol table
		updateValue($1, scope, getValue($3, scope));


	} |	WRITE ID SEMICOLON 	{ printf(GRAY "RECOGNIZED RULE: Write Statement (Variable)\n" RESET); 

		// semantic checks
			// is the id initialized as a value?
			if (scope == "G") {
				initialized($2, scope);
			} else {
				printf(BORANGE "Need Semantic Check to see if ID is a parameter.\n");
			}

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

	} |	WRITE ID LBRACE NUMBER RBRACE SEMICOLON 	{ printf(GRAY "RECOGNIZED RULE: Write Statement (Array Element)\n" RESET); 

		// concatenate the array in this format: "$2[$4]"
		char elementID[50];
		strcpy(elementID, $2);
		strcat(elementID, "[");
		strcat(elementID, $4);
		strcat(elementID, "]");

		// semantic checks
			// is the id initialized as a value?
			if (scope == "G") {
				initialized(elementID, scope);
			} else {
				printf(BORANGE "Need Semantic Check to see if ID is a parameter.\n");
			}

		// symbol table
			// N/A

		// ast
		$$ = AST_BinaryExpression("Expr", $1, getValue(elementID, scope));

		// ir code
		createWriteId(elementID, scope);

		// mips code
			// get the type of the variable
			char* type = getVariableType(elementID, scope);

			// determine if its int or char
			int isInt = strcmp(type, "INT");
			int isChar = strcmp(type, "CHR");
			int isFloat = strcmp(type, "FLT");

			// run correct mips function according to type
			if (isInt == 0) { // if the variable is an integer
				removeBraces(elementID);
				createMIPSWriteInt(elementID, scope);
			} else if (isChar == 0) { // if the variable is a char
				removeBraces(elementID);
				createMIPSWriteChar(elementID, scope);
			} else if (isFloat == 0) {
				removeBraces(elementID);
				createMIPSWriteFloat(elementID, scope);
			}

		// code optimization
			// mark the id as used
			isUsed($2, scope);

		/*
					Expr
			  WRITE     getValue(ID)
		*/

	} | WRITE NEWLINECHAR SEMICOLON { printf(GRAY "RECOGNIZED RULE: Print New Line\n\n" RESET); 

			// ast
			$$ = AST_BinaryExpression("Expr", $1, "NEWLINE");

			// symbol table
			printf(BGREEN "Symbol Table Not Needed.\n" RESET);

			// ir code
			printf(BLUE "IR Code Not Needed.\n" RESET);
			// mips
			makeMIPSNewLine(scope);


	} | IDEQExpr SEMICOLON { printf(GRAY "RECOGNIZED RULE: Math Statement\n\n" RESET); 

		// ast
		$$ = $1;

		/*
					=
				ID	  NUMBER
		*/

	} | ID LBRACE NUMBER RBRACE EQ NUMBER SEMICOLON { printf(GRAY "RECOGNIZED RULE: Modify Integer Array Index\n\n" RESET);

			// add backets to id
			char temp[50];	
			sprintf(temp,"%s[%s]",$1,$3);

			// convert index to integer
			int index = atoi($3);

			// symbol table
			updateArrayValue($1, index, scope, "INT", $6);

			// symbol table
			if (strcmp(scope, "G") != 0) { // if scope is in function

				if (found(temp, scope) == 1) { // if the variable is found in the function's sym table

					updateArrayValue($1, index, scope, "INT", $6); // update value in function sym table

				} else if (found(temp, "G") == 1) { // if the variable is found in the global scope

					updateArrayValue($1, index, "G", "INT", $6); // update value in global sym table

				} else { // variable not found

					showSymTable(); // show symbol table
					printf(RED "\nERROR: Variable '%s' does not exist.\n\n" RESET, temp); // error msg
					exit(0); // exit program

				}

			} else { // if scope is global
				updateArrayValue($1, index, scope, "INT", $6); // update value normally
			}

			// ast
			$$ = AST_assignment($1,$3,$6);

			// ir code
			createIntAssignment(temp, $6, scope);

			// mips code
			// remove braces for mips
			if (strcmp(scope, "G") != 0) { // if scope is in function

				if (found(temp, scope) == 1) { // if the variable is found in the function's sym table

					removeBraces(temp);
					createMIPSIntAssignment(temp, $6, scope);

				} else if (found(temp, "G") == 1) { // if the variable is found in the global scope

					removeBraces(temp);
					createMIPSIntAssignment(temp, $6, "G");

				} else { // variable not found

					showSymTable(); // show symbol table
					printf(RED "\nERROR: Variable '%s' does not exist.\n\n" RESET, temp); // error msg
					exit(0); // exit program

				}

			} else { // if scope is global
				removeBraces(temp);
				createMIPSIntAssignment(temp, $6, scope);
			}


	} | ID LBRACE NUMBER RBRACE EQ Math SEMICOLON {

			system("python3 calculate.py");
	
			char result[100];
			readEvalOutput(&result);
			clearCalcInput();
			printf(RED"\nResult from evaluation ==> %s \n"RESET,result);
	
			// convert index to integer
			int index = atoi($3);

			// array table
			updateArrayValue($1, index, scope, "INT", result); //TODO DOES NOT RESOLVE FLOATS

			// ast
			$$ = AST_assignment($1,$3,result);

			// ir code
			char temp[50];	
			sprintf(temp,"%s[%s]",$1,$3);
			createIntAssignment(temp, result, scope);

			// mips code
			if (strcmp(scope, "G") != 0) { // if scope is in function

				if (found(temp, scope) == 1) { // if the variable is found in the function's sym table

					removeBraces(temp);
					createMIPSIntAssignment(temp, result, scope);

				} else if (found(temp, "G") == 1) { // if the variable is found in the global scope

					removeBraces(temp);
					createMIPSIntAssignment(temp, result, "G");

				} else { // variable not found

					showSymTable(); // show symbol table
					printf(RED "\nERROR: Variable '%s' does not exist.\n\n" RESET, temp); // error msg
					exit(0); // exit program

				}

			} else { // if scope is global
				removeBraces(temp);
				createMIPSIntAssignment(temp, result, scope);
			}

	
	} | ID LBRACE NUMBER RBRACE EQ CHARLITERAL SEMICOLON { printf(GRAY "RECOGNIZED RULE: Modify Char Array Index\n\n" RESET);

			// add brackets to id for sym table searches
			char temp[50];	
			sprintf(temp,"%s[%s]",$1,$3);

			// convert index to integer
			int index = atoi($3);

			// remove apostrophes from charliteral
			char* str = removeApostrophes($6);

			// symbol table
			if (strcmp(scope, "G") != 0) { // if scope is in function

				if (found(temp, scope) == 1) { // if the variable is found in the function's sym table

					updateArrayValue($1, index, scope, "CHR", str); // update value in function sym table

				} else if (found(temp, "G") == 1) { // if the variable is found in the global scope

					updateArrayValue($1, index, "G", "CHR", str); // update value in global sym table

				} else { // variable not found

					showSymTable(); // show symbol table
					printf(RED "\nERROR: Variable '%s' does not exist.\n\n" RESET, temp); // error msg
					exit(0); // exit program

				}

			} else { // if scope is global
				updateArrayValue($1, index, scope, "CHR", str); // update value normally
			}

			// ast
			$$ = AST_assignment($1,$3,str);

			// ir code
			createIntAssignment(temp, str, scope);

			// mips code
			if (strcmp(scope, "G") != 0) { // if scope is in function

				if (found(temp, scope) == 1) { // if the variable is found in the function's sym table

					removeBraces(temp);
					createMIPSCharAssignment(temp, str, scope);

				} else if (found(temp, "G") == 1) { // if the variable is found in the global scope

					removeBraces(temp);
					createMIPSCharAssignment(temp, str, "G");

				} else { // variable not found

					showSymTable(); // show symbol table
					printf(RED "\nERROR: Variable '%s' does not exist.\n\n" RESET, temp); // error msg
					exit(0); // exit program

				}

			} else { // if scope is global
				removeBraces(temp);
				createMIPSCharAssignment(temp, str, scope);
			}
			


	} | ID LPAREN ArgDeclList RPAREN SEMICOLON { printf(GRAY "RECOGNIZED RULE: Call Function\n\n" RESET);

			// set scope to function
			strcpy(scope, $1);

			for (int i = 0; i < argCounter; i++) {
				updateParameter(i, scope, args[i], argCounter);

				printf(BGREEN "Parameter Accepted.\n" RESET);

				printf(BLUE "IR Code" RESET);
				printf(RED " NOT " RESET);
				printf(BLUE "Created.\n" RESET);

				char itemName[50];
				char itemID[50];
				char result[50];
				sprintf(itemID, "%d", i);
				sprintf(itemName, "%s", getNameByID(itemID, scope));
				strcpy(result, "");
				strcat(result, itemName);

				char type[50];
				sprintf(type, "%s", getVariableType(itemName, scope));

				int isInt, isFloat, isChar;
				
				isInt = strcmp(type, "INT");
				isFloat = strcmp(type, "FLT");
				isChar = strcmp(type, "CHR");

				if (isInt == 0) {
					createIntParameter(args[i], i+1, scope);
					//createMIPSIntAssignment(result, args[i], scope);
				} else if (isFloat == 0) {
					createFloatParameter(args[i], i+1, scope);
					//createMIPSFloatAssignment(result, args[i], scope);
				} else if (isChar == 0) {
					createMIPSCharAssignment(result, args[i], scope);
				}
			}
			argCounter = 0;

			// set scope back to global
			strcpy(scope, "G");

			// symbol table
			printf(BGREEN "Function Call & Parameters Accepted.\n" RESET);

			// ast
			$$ = AST_assignment($1,$2,$4);

			// ir code
			printf(BLUE "IR Code" RESET);
			printf(RED " NOT " RESET);
			printf(BLUE "Created.\n" RESET);

			// mips
			callMIPSFunction($1);

			//YYACCEPT;


	} | RETURN ID SEMICOLON { printf(GRAY "RECOGNIZED RULE: Return Statement (ID)\n\n" RESET);

		// symbol table
		updateValue(scope, "G", getValue($2, scope));
		printf(BGREEN "Updated ID Return Value of Function.\n" RESET);

		// ir code
		printf(BLUE "IR Code" RESET);
		printf(RED " NOT " RESET);
		printf(BLUE "Created.\n" RESET);

		// mips
		char str[50];
		strcpy(str, getVariableType($2, scope));

		char str1[50];
		strcpy(str1, "G");
		strcat(str1, scope);
		
		if (strcmp(str, "INT") == 0) {
			createMIPSIntAssignment("", getValue($2, scope), str1);
		} else if (strcmp(str, "FLT") == 0) {
			createMIPSFloatAssignment("", getValue($2, scope), str1);
		} else if (strcmp(str, "CHR") == 0) {
			createMIPSCharAssignment("", getValue($2, scope), str1);
		}


	} | RETURN NUMBER SEMICOLON { printf(GRAY "RECOGNIZED RULE: Return Statement (Int Number)\n\n" RESET);

		// symbol table
		updateValue(scope, "G", $2);
		printf(BGREEN "Updated Integer Return Value of Function.\n" RESET);

		// ir code
		printf(BLUE "IR Code" RESET);
		printf(RED " NOT " RESET);
		printf(BLUE "Created.\n" RESET);

		// mips
		// create scope so that it has G and then the function scope, since
		// we are accessing the global variable that is called the function name
		char str[50];
		strcpy(str, "G");
		strcat(str, scope);

		createMIPSIntAssignment("", $2, str);


	} | RETURN FLOAT_NUM SEMICOLON {

		// symbol table
		updateValue(scope, "G", $2);
		printf(BGREEN "Updated Float Return Value of Function.\n" RESET);

		// ir code
		printf(BLUE "IR Code" RESET);
		printf(RED " NOT " RESET);
		printf(BLUE "Created.\n" RESET);

		// mips
		// create scope so that it has G and then the function scope, since
		// we are accessing the global variable that is called the function name
		char str[50];
		strcpy(str, "G");
		strcat(str, scope);

		createMIPSFloatAssignment("", $2, str);


	} | RETURN CHARLITERAL SEMICOLON {

		// symbol table
		updateValue(scope, "G", $2);
		printf(BGREEN "Updated Char Return Value of Function.\n" RESET);

		// ir code
		printf(BLUE "IR Code" RESET);
		printf(RED " NOT " RESET);
		printf(BLUE "Created.\n" RESET);

		// mips
		char str[50];
		strcpy(str, "G");
		strcat(str, scope);
		createMIPSCharAssignment("", $2, str);

}





IDEQExpr: ID EQ MathStmt {

	// ast
	// TODO: EVAN

	system("python3 calculate.py");
	
	char result[100];
	readEvalOutput(&result);
	clearCalcInput();
	printf(RED"\nResult from evaluation ==> %s \n"RESET,result);

	// semantic checks
		// inside Math

	// calculations: code optimization
		// turn the integer returned from calculate() into a string

	// symbol table

	if (strcmp(scope, "G") != 0) { // if scope is in function

		if (found($1, scope) == 1) { // if the variable is found in the function's sym table

			updateValue($1, scope, result); // update value in function sym table

		} else if (found($1, "G") == 1) { // if the variable is found in the global scope

			updateValue($1, "G", result); // update value in global sym table

		}

	} else { // if scope is global
		updateValue($1, scope, result); // update value normally
	}

	// ast
	$$ = AST_BinaryExpression("=", $1, result);

	
	char type[50];

	strcpy(type,getVariableType($1,scope));

	if (strcmp(type,"INT") == 0){
		// ir code
		createIntAssignment($1, result, scope);

		// mips code
		createMIPSIntAssignment($1, result, scope);
	}

	else if(strcmp(type,"FLT") == 0){
		// ir code
		createFloatAssignment($1, result, scope);

		// mips code
		createMIPSFloatAssignment($1, result, scope);
	}

	
	// code optimization
	// mark the id as used
	isUsed($1, scope);

}

MathStmt: Math MathStmt {

}

		| Math{

}


Math: LPAREN {addToInputCalc($1);}
		| RPAREN {addToInputCalc($1);}
		| ID {addToInputCalc($1);} 
		| NUMBER {addToInputCalc($1);}
		| FLOAT_NUM {addToInputCalc($1);}
		| EXPONENT {addToInputCalc("**");}
		| Operator {addToInputCalc($1);}



Operator: PLUS_OP {}	
		| SUB_OP {}
		| MULT_OP {}
		| DIV_OP {}
		| DOUBLE_EQ {}
		| LT {}
		| GT {}

// ARRAY DECLARATIONS ----------------------------------------------------------------------
ArrDecl:	
			INT ID LBRACE RBRACE SEMICOLON { printf(GRAY "RECOGNIZED RULE: Integer Array Initialization Without Range\n\n" RESET);
				//int foo[]; //We should only have arrays be declared with range imo.



			} | CHAR ID LBRACE RBRACE SEMICOLON { printf(GRAY "RECOGNIZED RULE: Char Array Initialization Without Range\n\n" RESET);
				//char foo[]; //We should only have arrays be declared with range imo.

			

			} | INT ID LBRACE NUMBER RBRACE SEMICOLON { printf(GRAY "RECOGNIZED RULE: Integer Array Initialization With Range\n\n" RESET);
				// e.g. int foo[4];

							// semantic checks
							symTabAccess();

								// is the range > 0?
								if (atoi($4) <= 0) {
									printf(RED "\nERROR: Array range must be greater than 0.\n" RESET,$2);
									showSymTable(); // show symbol table
									exit(0); // array already declared
								}

								// is the array already declared in this scope?			
								// add "[0]" to the ID
								char temp[50];	
								sprintf(temp,"%s[0]",$2);

								if (found(temp, scope) == 1) {
									printf(RED "\nERROR: Array '%s' already declared in this scope.\n" RESET,$2);
									showSymTable(); // show symbol table
									exit(0); // array already declared
								}

							// symbol table
							addArray($2, "ARR", "INT", $4, scope);

							// ast
							$$ = AST_assignment("ARR",$1,$2);

							// ir code
							int range = atoi($4);
							//printf("\n%d\n", range);
							for (int i = 0; i < range; i++) {
								char temp[50];	
								sprintf(temp,"%s[%d]",$2,i);
								createIntDefinition(temp, scope);
							}
							printf("\n\n");


			} | CHAR ID LBRACE NUMBER RBRACE SEMICOLON { printf(GRAY "RECOGNIZED RULE: Char Array Initialization With Range\n\n" RESET);
				// e.g. char foo[5];
	
							// semantic checks
							symTabAccess();

								// is the range > 0?
								if (atoi($4) <= 0) {
									printf(RED "\nERROR: Array range must be greater than 0.\n" RESET,$2);
									showSymTable(); // show symbol table
									exit(0); // array already declared
								}
								// is the array already declared?
								// add "[0]" to the ID
								char temp[50];	
								sprintf(temp,"%s[0]",$2);
								
								if (found(temp, scope) == 1) {
									printf(RED "\nERROR: Array '%s' already declared in this scope.\n" RESET,$2);
									showSymTable();
									exit(0); // variable already declared
								}

							// symbol table
							addArray($2, "ARR", "CHR", $4, scope);

							// ast
							$$ = AST_assignment("ARR",$1,$2);

							// ir code
							int range = atoi($4);
							//printf("\n%d\n", range);
							for (int i = 0; i < range; i++) {
								sprintf(temp,"%s[%d]",$2,i);
								createIntDefinition(temp, scope);
							}
							printf("\n\n");

}; 

IfStmt:	IF LPAREN Condition RPAREN {printf(GRAY "RECOGNIZED RULE: If Statement Initialization \n\n" RESET);
								 
							
						 
						 } LBRACE Block RBRACE { printf(BGREEN "\n\n" RESET);

							if (pass = 1) {
								
							}

						 } 


Condition: NUMBER Operator NUMBER {

				int temp1, temp2;
				temp1 = atoi($1);
				temp2 = atoi($3);

				if (!strcmp($2, "==")) {
					if (temp1 == temp2) {
						printf(BPINK "PASSED" RESET);
					}
				} 
				else if (!strcmp($2, "<")) {
					if (temp1 < temp2) {
						printf(BPINK "PASSED" RESET);
					}
				}

}

ConditionVar:	NUMBER {

			} | ID {
				
			} | FLOAT_NUM {
				
			} | CHARLITERAL {

			}

%%

int main(int argc, char**argv)
{

	/*
	#ifdef YYDEBUG
		yydebug = 1;
	#endif
	*/

	printf(BOLD "\n\n ###################### COMPILER STARTED ###################### \n\n" RESET);
	clearCalcInput();
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
