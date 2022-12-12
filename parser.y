%{

// import libraries
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <string.h>

// import all accessory files
#include "symbolTable.h"
#include "AST.h"
#include "IRcode.h"
#include "assembly.h"
#include "calculator.h"
#include "ctype.h"

// flex
extern int yylex();
extern int yyparse();
extern FILE* yyin;
void yyerror(const char* s);

// static value definitions for easier readability when determining what is running loop and if statement-wise
#define IN_ELSE_BLOCK 0 // inside else statement
#define IN_IF_BLOCK 1 // inside if statement

#define RUN_ELSE_BLOCK 0 // will run else block
#define RUN_IF_BLOCK 1 // will run if block

#define UPDATE_IF_ELSE 0 // will update the if-else
#define UPDATE_WHILE 1 // will update the while loop

// static value definitions for ir code and mips file choices to print to
#define IR_CODE 0 // (default) main
#define IR_FUNC 1 // functions/loops
#define TEMP_MIPS 0  // (default) middle section, main:
#define MIPS_CODE 1  // top section, var decls
#define MIPS_FUNC 2  // bottom section for functions/while loops

// various variables for tracking
char currentScope[50]; /* global or the name of the function */
char IDArg[50]; // if an argument is an ID, it's name is temporarily stored here
int argIsID = 0; // boolean to determine if an argument is an ID
int argCounter = 0; // how many arguments there are
char *args[50]; // argument array, names stored here
char **argptr = args; // argument array pointer

// two different operator chars to hold a current operator
char operator; // holds current operator in math statements
char op; // holds current operator in conditions

// temporary variables to hold two numbers in a binary math statement
char num1[50]; // first number
char num2[50]; // second number

// boolean values for if-else and while loop logic in parser
int runIfElseBlock = 0; // 1 - run if block;  0 - run else block;
int ifElseCurrentBlock = 0; // 1 - in if statment; 0 - in else statement;
int runWhileBlock = 0; // 1 - run while block;  0 - exit while loop
int inElseOrWhile = 0; //boolean flag to determine if runIfElseBlock or runWhileBlock should be updated
					   // 0 - if/else        1 - while

// while loop variables
int numOfWhileLoops = 0; // counter for amount of while loops, used for making name of while loop in mips
char whileName[50]; // name of the while loop, used for naming it in mips
int registerCounter = 0; // counts the registers for parameters in mips

// initialize scope as global and symbol table
char scope[50] = "G"; // set scope to global

%}

// different types of tokens
%union {
	int number;
	char character;
	char* string;
	struct AST* ast;
}

// token declarations: words
%token <string> CHAR // word: char
%token <string> INT // word: int
%token <string> FLOAT // word: float
%token <string> VOID // word: void
%token <string> IF // word: if
%token <string> ELSE // word: else
%token <string> WHILE // word: while
%token <string> WRITE // word: write
%token <string> RETURN // word: return

// token declarations: etc. words
%token <string> COMMA // word: ,
%token <string> SEMICOLON // word: ;
%token <string> NEWLINECHAR // word: ~nl

// token declarations: operators
%token <string> DOUBLE_EQ // operator: ==
%token <string> NOT_EQ // operator: !=
%token <string> LT_EQ // operator: <=
%token <string> GT_EQ // operator: >=
%token <string> LT // operator: <
%token <string> GT // operator: >
%token <string> EQ // operator: =
%token <string> PLUS_OP // operator: +
%token <string> MULT_OP // operator: *
%token <string> SUB_OP // operator: -
%token <string> DIV_OP // operator: /
%token <string> EXPONENT // operator: *
%token <string> LPAREN // operator: (
%token <string> RPAREN // operator: )
%token <string> LBRACKET // operator: [
%token <string> RBRACKET // operator: ]
%token <string> LBRACE // operator: {
%token <string> RBRACE // operator: }

// token declarations: regex's
%token <string> NUMBER // number regex: 1
%token <string> FLOAT_NUM // float regex: 1.0
%token <string> STRINGLITERAL // string regex: "string"
%token <string> CHARLITERAL // char regex: 'c'
%token <string> ID // id regex: var

// printer function
%printer { fprintf(yyoutput, "%s", $$); } ID;

// token declarations: nonterminals
%type <ast> Program DeclList Decl VarDecl FuncDecl ParamDeclList WhileStmt IfStmt ElseStmt Condition ParamDecl ArgDeclList ArgDecl Block BlockDeclList BlockDecl StmtList Expr IDEQExpr MathStmt Math Operator CompOperator ArrDecl

// start the parser
%start Program

%%

// program consists of a list of declarations
Program: DeclList {
		// ast
		$$ = $1;

		// output the start of the ast
		printf("\n\n ########################" RESET);
		printf(BPINK " AST STARTED " RESET);
		printf("######################### \n\n" RESET);

		// print the ast
		//printAST($$,0);

		// output the end of the ast
		printf("\n\n #########################" RESET);
		printf(PINK " AST ENDED " RESET);
		printf("########################## \n\n" RESET);

		// append the two ir code files to each other
		appendFiles("IRFuncs.ir", "IRcode.ir");

		// end mips code
		addEndLoop(); // add the endloop function to the bottom of mips for any loops to jump to to get to main
		createEndOfAssemblyCode(); // add the end line of mips to kill the program

		// append the three mips files to each other
		appendFiles("tempMIPS.asm", "MIPScode.asm");
		printf("\n");
		appendFiles("MIPSfuncs.asm", "MIPScode.asm");

		// output that mips was generated
		printf("\n\n #######################" RESET);
		printf(BPINK " MIPS GENERATED " RESET);
		printf("####################### \n\n" RESET);

};

// declList consists of a recursive list of declarations
DeclList:      Decl DeclList {

				// ast
				$1->left = $2;
				$$ = $1;

			} | Decl {

				// ast
				$$ = $1;

};

// declaration types, any of these can show at any time in the source code
Decl:	   FuncDecl { // function declaration

			// ast
			$$ = $1;

		} | VarDecl { // variable declaration

			// ast
			$$ = $1;

		} | StmtList { // statement declaration list

			// ast
			$$ = $1;

		} | WhileStmt { // while statement declaration
			
			// ast
			$$ = $1;
	
		} |	IfStmt { // if statement declaration

			// ast
			$$ = $1;
	
};

// function declaration types: void, int, float, char
FuncDecl:				 VOID ID LPAREN { printf(GRAY "RECOGNIZED RULE: Void Function Initialization \n\n" RESET); // void function declaration
								
								// symbol table
								symTabAccess(); // access symbol table
								addSymbolTable($2,"VOID"); // add void function to symbol table
								strcpy(scope,$2); // set scope to function name

								// ir code
								createFunctionHeader($2); // create function
								changeIRFile(IR_FUNC); // change file to print block to the function IR code file

								// mips
								createMIPSFunction($2); // create function
	
							// second part of the function, including parameter list, right parentheses, and block
							} ParamDeclList RPAREN Block { printf(BGREEN "\nVoid Function End.\n" RESET); // void function end

								// ast
								$$ = AST_assignment("FNC",$1,$2); // add the function to the ast

								// ir code
								changeIRFile(IR_CODE); // change file back to main file

								// mips
								endMIPSFunction(); // end function in mips
						

						} | INT ID LPAREN {printf(GRAY "RECOGNIZED RULE: Integer Function Initialization \n\n" RESET); // int function declaration

								// symbol table
								symTabAccess(); // access symbol table
								addSymbolTable($2,"INT"); // add int function to symbol table
								strcpy(scope,$2); // set scope to function name

								// ir code
								createFunctionHeader($2); // create function
								changeIRFile(IR_FUNC); // change file to print block to the function IR code file

								// mips
								createMIPSFunction($2); // create function
						 
						 	// second part of the function, including parameter list, right parentheses, and block
						 	} ParamDeclList RPAREN Block { printf(BGREEN "\nInt Function End.\n" RESET); // void function end

								// ast
								$$ = AST_assignment("FNC",$1,$2); // add the function to the ast

								// ir code
								changeIRFile(IR_CODE); // change file back to main file

								// mips code
								endMIPSFunction(); // end function in mips

						
						} | CHAR ID LPAREN {printf(GRAY "RECOGNIZED RULE: Char Function Initialization \n\n" RESET); // char function declaration

								// symbol table
								symTabAccess(); // access symbol table
								addSymbolTable($2,"CHR"); // add char function to symbol table
								strcpy(scope,$2); // set scope to function name

								// ir code
								createFunctionHeader($2); // create function
								changeIRFile(IR_FUNC); // change file to print block to the function IR code file

								// mips
								createMIPSFunction($2); // create function
						 
						 	// second part of the function, including parameter list, right parentheses, and block
							} ParamDeclList RPAREN Block { printf(BGREEN "\nChar Function End.\n" RESET); // char function end

								// ast
								$$ = AST_assignment("FNC",$1,$2); // add the function to the ast

								// ir code
								changeIRFile(IR_CODE); // change file back to main file

								// mips
								endMIPSFunction(); // end function in mips

						
						} | FLOAT ID LPAREN {printf(GRAY "RECOGNIZED RULE: Float Function Initialization \n\n" RESET); // float function declaration

								// symbol table
								symTabAccess(); // access symbol table
								addSymbolTable($2,"FLT"); // add float function to symbol table
								strcpy(scope,$2); // set scope to function name

								// ir code
								createFunctionHeader($2); // create function
								changeIRFile(IR_FUNC); // change file to print block to the function IR code file

								// mips
								createMIPSFunction($2); // create function
								
							// second part of the function, including parameter list, right parentheses, and block
						 	} ParamDeclList RPAREN Block { printf(BGREEN "\nFloat Function End.\n" RESET); // float function end

								// ast
								$$ = AST_assignment("FNC",$1,$2); // add the function to the ast

								// ir code
								changeIRFile(IR_CODE); // change file back to main file

								// mips
								endMIPSFunction(); // end function in mips
 
}

// parameter declaration list consists of parameters separated by commas or a single parameter
ParamDeclList: ParamDecl COMMA ParamDeclList { // list of parameters separated by commas

					// ast
					$1->left = $2;
					$$ = $1;

				} | ParamDecl { // or single parameter

					// ast
					$$ = $1;

				}

// types of parameter declarations, integer, float, char
ParamDecl:		| INT ID { printf(GRAY "RECOGNIZED RULE: Integer Parameter Initialization \n\n" RESET); // integer parameter declaration

					// symbol table
					addItem($2,"PAR","INT",scope,0); // add integer parameter to symbol table

					// ir code
					printf(BLUE "IR Code" RESET);
					printf(RED " NOT " RESET);
					printf(BLUE "Created.\n" RESET);


				} | FLOAT ID { printf(GRAY "RECOGNIZED RULE: Float Parameter Initialization \n\n" RESET); // float parameter declaration

					// symbol table
					addItem($2,"PAR","FLT",scope,0); // add float parameter to symbol table

					// ir code
					printf(BLUE "IR Code" RESET);
					printf(RED " NOT " RESET);
					printf(BLUE "Created.\n" RESET);


				} | CHAR ID { printf(GRAY "RECOGNIZED RULE: Char Parameter Initialization \n\n" RESET); // char parameter declaration

					// symbol table
					addItem($2,"PAR","CHR",scope,0); // add char parameter to symbol table

					// ir code
					printf(BLUE "IR Code" RESET);
					printf(RED " NOT " RESET);
					printf(BLUE "Created.\n" RESET);
					

}

// argument declaration list for calling a function, e.g. addValue(1,2): 1 & 2 are arguments, either a recursive list of arguments separated by a comma or a single argument
ArgDeclList: ArgDecl COMMA ArgDeclList { // recursive list of arguments

					// ast
					$1->left = $2;
					$$ = $1;

				} | ArgDecl { // or single argument

					// ast
					$$ = $1;

				}

// argdecl holds types of arguments: number, float number, charliteral, id
ArgDecl:	| NUMBER { printf(GRAY "RECOGNIZED RULE: Parameter = %s\n\n" RESET, $1); // number argument

				argptr[argCounter] = $1; // add number to argument array
				argCounter++; // increment argument counter


			} | FLOAT_NUM { printf(GRAY "RECOGNIZED RULE: Parameter = %s\n\n" RESET, $1); // float argument

				argptr[argCounter] = $1; // add float number to argument array
				argCounter++; // increment argument counter


			} | CHARLITERAL { printf(GRAY "RECOGNIZED RULE: Parameter = %s\n\n" RESET, $1); // char argument

				argptr[argCounter] = $1; // add char to argument array
				argCounter++; // increment argument counter
				

			} | ID { printf(GRAY "RECOGNIZED RULE: Parameter = %s\n\n" RESET, getValue($1, "G")); // id argument

				argptr[argCounter] = getValue($1, "G"); // add id value to argument array
				strcpy(IDArg, $1); // copy the name of the id into temporary IDArg variable
				argIsID = 1; // set flag so it knows the parameter is an ID, not a number
				argCounter++; // increment argument counter

}

// block is used for the block in functions, if statements, and while loops
Block: LBRACKET BlockDeclList RBRACKET { // blockDeclList is the recursive list of statements inside the block

	strcpy(scope,"G"); // reset scope back to global after statements are parsed

}

// blockDeclList is a recursive list of statements or single statement, which is similar to DeclList
BlockDeclList: BlockDecl BlockDeclList { // recursive list of statements

				// ast
				$1->left = $2;
				$$ = $1;

		} | BlockDecl { // or single statement

				// ast
				$$ = $1;

}

// blockDecl types: variable declaration, stmtList, while loop, if statement
BlockDecl: VarDecl { // variable declaration

		   // ast
		   $$ = $1;

		} | StmtList { // statement list

			// ast
			$$ = $1;

		} | WhileStmt { // while loop

			//ast
			$$ = $1;
		
		} | IfStmt { // if statement
			// ast
			$$ = $1;

};

// statement list is a recursive list of expressions or a single expression or nothing
StmtList:	| Expr StmtList { // nothing or recursive list of statements
				
				// ast
				$1->left = $2; 
				$$ = $1;
			
			} | Expr { // or single expression
				
				// ast
				$$ = $1;
		
};

/*----start vardecl-----------------------------------------------------------------------------------------------------*/

// variable declaration types
VarDecl:	INT ID SEMICOLON { printf(GRAY "RECOGNIZED RULE: Integer Variable Declaration\n\n" RESET);	// e.g. int x;

						if (ifElseCurrentBlock == runIfElseBlock) { // if we are in an if block, both are 1, if we are in an else block, both are 0

							// semantic checks
								// is the variable already declared?
								symTabAccess(); // access symbol table
								if (found($2,scope) == 1) { // if we find the variable in the symbol table
									printf(RED "\nERROR: Variable '%s' already declared.\n" RESET,$2); // error message
									exit(0); // exit program
								}

							// symbol table
							addItem($2, "VAR", "INT", scope, 0); // add variable to the correct symbol table based on scope

							// ast
							$$ = AST_assignment("TYPE",$1,$2); // add variable to ast

							// ir code
							createIntDefinition($2, scope); // create ir code: T0 = x

							// mips code 
							createMIPSIntDecl($2,scope); // create mips: Gx: .word 0
							
							// code optimization
								// N/A

							/*
										VarDecl
									INT        ID
							*/
						}
				
			} |	ID EQ NUMBER SEMICOLON	{ printf(GRAY "RECOGNIZED RULE: Integer Variable Initialization \n\n" RESET); // e.g. x = 1;

						if (ifElseCurrentBlock == runIfElseBlock) { // if we are in an if block, both are 1, if we are in an else block, both are 0

							// semantic checks
								// is the variable already declared
								symTabAccess(); // access symbol table
								if (scope == "G") { // if the scope is global
									if (found($1,scope) == 0) { // if we don't find the variable in the global symbol table
										printf(RED "\n::::> CHECK FAILED: Variable '%s' not initialized in the global scope.\n\n" RESET,$1); // error message
										exit(0); // exit program
									}
								} 
								else { // else the scope is function
									if (found($1,scope) == 0) { // if we don't find the variable in the function symbol table
										if (found($1, "G") == 0) { // if the variable is not found in the global scope
											showSymTable(); // show the symbol tables
											printf(RED "\n::::> CHECK FAILED: Variable '%s' not initialized in the function or global scope.\n\n" RESET,$1); // error message
											exit(0); // exit program
										}
									}
								}

								// is the statement redundant
								if (redundantValue($1, scope, $3) == 0) { // if statement is redundant
									printf(RED "::::> CHECK FAILED: Variable %s has already been declared as: %s.\n\n" RESET,$1,$3); // error message
									exit(0); // exit program
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
							$$ = AST_BinaryExpression("=",$1,$3); // add binary expression to the ast

							// ir code
							createIntAssignment($1, $3, scope); // create ir code: T0 = 1

							// mips code
							createMIPSIntAssignment($1, $3, scope); // create mips code for int assignment

							// code optimization
								// N/A

							/*
									=
								ID    NUMBER
							*/

						}

			} |	CHAR ID SEMICOLON	{ printf(GRAY "RECOGNIZED RULE: Char Variable Declaration \n\n" RESET); // e.g. char c;

						if (ifElseCurrentBlock == runIfElseBlock) { // if we are in an if block, both are 1, if we are in an else block, both are 0
							// semantic checks
								// is the variable already declared?
								symTabAccess(); // access symbol table
								if (found($2,scope) == 1) { // if we find the variable in the symbol table
									exit(0); // variable already declared
								}

							// symbol table	
							addItem($2, "VAR", "CHR", scope, 0); // add char variable to the symbol table

							// ast
							$$ = AST_assignment("TYPE",$1,$2); // add char variable to the ast

							// ir code
							createCharDefinition($2, scope); // create ir code: T1 = c

							// mips
							printf(CYAN "MIPS Not Needed.\n\n\n" RESET); // mips currently not needed
							
							// code optimization
								// N/A

							/*
									VarDecl
								CHAR	   ID
							*/	

						}				
			
			} |	ID EQ CHARLITERAL SEMICOLON	  { printf(GRAY "RECOGNIZED RULE: Char Variable Initialization \n\n" RESET); // e.g. c = 'a';	

						if (ifElseCurrentBlock == runIfElseBlock) { // if we are in an if block, both are 1, if we are in an else block, both are 0

							// remove apostrophes from charliteral
							char* str = removeApostrophes($3); // symbol table function to return char without apostrophes

							// semantic checks
								// is the variable already declared?
								symTabAccess(); // access symbol table
								if (scope == "G") { // if the scope is global
									if (found($1,scope) == 0) { // if the variable is not found in the global scope
										printf(RED "\n::::> CHECK FAILED: Variable '%s' not initialized in the global scope.\n\n" RESET,$1); // error message
										exit(0); // exit program
									}
								}
								else { // else we are in function scope
									if (found($1,scope) == 0) { // if the variable is not found in the function scope
										if (found($1, "G") == 0) { // if the variable is not found in the global scope
											showSymTable(); // access symbol table
											printf(RED "\n::::> CHECK FAILED: Variable '%s' not initialized in the function or global scope.\n\n" RESET,$1); // error message
											exit(0); // exit program
										}
									}
								}

								// is the statement redundant
								if (redundantValue($1, scope, str) == 0) { // if statement is redundant
									printf(RED "::::> CHECK FAILED: Variable '%s' has already been declared as: %s.\n\n" RESET,$1,$3); // error message
									exit(0); // exit the program
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
							$$ = AST_BinaryExpression("=",$1,str); // add binary expression to ast

							// ir code
							createCharAssignment($1, str, scope); // create it code: T1 = 'a'

							// mips code
							createMIPSCharAssignment($1, str, scope); // create mips

							// code optimization
								// N/A

							/*
									=
								ID	   CHARLITERAL
							*/

						}

			} | FLOAT ID SEMICOLON	{ printf(GRAY "RECOGNIZED RULE: Float Variable Declaration\n\n" RESET);	// e.g. float f;

						if (ifElseCurrentBlock == runIfElseBlock) { // if we are in an if block, both are 1, if we are in an else block, both are 0

							// semantic checks
								// is the variable already declared?
								symTabAccess(); // access symbol table
								if (found($2,scope) == 1) { // if the variable is found in the symbol table
									printf(RED "\nERROR: Variable '%s' already declared.\n" RESET,$2); // error message
									exit(0); // exit program
								}

							// symbol table
							addItem($2, "VAR", "FLT", scope, 0); // add the float variable to the symbol table

							// ast
							$$ = AST_assignment("TYPE",$1,$2); // add the float variable to the ast

							// ir code
							createFloatDefinition($2, scope); // create ir code: T2 = f

							// mips code
							printf(CYAN "MIPS Not Needed.\n\n\n" RESET); // mips currently not necessary
							
							// code optimization
								// N/A

							/*
										VarDecl
									INT        ID
							*/

						}

				} |	ID EQ FLOAT_NUM SEMICOLON	{ printf(GRAY "RECOGNIZED RULE: Float Variable Initialization \n\n" RESET); // e.g. f = 1.0;
							
						if (ifElseCurrentBlock == runIfElseBlock) { // if we are in an if block, both are 1, if we are in an else block, both are 0

							// semantic checks
								// is the variable already declared
								symTabAccess(); // access symbol table
								if (scope == "G") { // if the scope is global
									if (found($1,scope) == 0) { // if the variable is not found in the global scope
										printf(RED "\n::::> CHECK FAILED: Variable '%s' not initialized in the global scope.\n\n" RESET,$1); // error message
										exit(0); // exit program
									}
								} 
								else { // else the scope is function
									if (found($1,scope) == 0) { // if the variable is not found in the function scope
										if (found($1, "G") == 0) { // if the variable is not found in the global scope
											showSymTable(); // show the symbol table
											printf(RED "\n::::> CHECK FAILED: Variable '%s' not initialized in the function or global scope.\n\n" RESET,$1); // error message
											exit(0); // exit program
										}
									}
								}

								// is the statement redundant
								if (redundantValue($1, scope, $3) == 0) { // if statement is redundant
									printf(RED "\n::::> CHECK FAILED: Variable '%s' has already been declared as: %s.\n\n" RESET,$1,$3); // error message
									exit(0); // exit program
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
							$$ = AST_BinaryExpression("=",$1,$3); // add float variable to ast

							// ir code
							createFloatAssignment($1,$3, scope); // create ir code: T3 = 1.0

							// mips code
							createMIPSFloatAssignment($1, $3, scope); // create mips

							// code optimization
								// N/A

							/*
									=
								ID    NUMBER
							*/

						}

				} |	ID EQ ID SEMICOLON	{ printf(GRAY "RECOGNIZED RULE: Assignment Statement\n\n" RESET); // e.g. x = y;

					if (ifElseCurrentBlock == runIfElseBlock) { // if we are in an if block, both are 1, if we are in an else block, both are 0

						// semantic checks
							// are both variables already declared?
							symTabAccess(); // access symbol table
							printf("\n"); // print newline
							if (found($1,scope) == 0 || found($3,scope) == 0) { // if both variables are not found in the scope
								printf(RED "\nERROR: Variable %s or %s not declared.\n\n" RESET,$1,$3); // error message
								exit(0); // exit program
							}

							// does the second id have a value?
							//initialized($3, scope);

							// are the id's both variables?
							//compareKinds($1, $3, scope);

							// are the types of the id's the same
							compareTypes($1, $3, scope);

						// symbol table
						updateValue($1, scope, getValue($3, scope)); // update the value of the first id in the symbol table

						// ast
						$$ = AST_BinaryExpression("=",$1,$3); // add expression to the ast

						// ir code
						createIDtoIDAssignment($1, $3, scope); // create ir code: T0 = T1

						// mips code
						createMIPSIDtoIDAssignment($1, $3, scope); // create mips

						// code optimization
							// mark the two id's as used
							isUsed($1, scope);
							isUsed($3, scope);

					}


				} | IDEQExpr SEMICOLON { printf(GRAY "RECOGNIZED RULE: Addition Statement\n\n" RESET); // id = math statement, e.g. x = 10 - 8;

					if (ifElseCurrentBlock == runIfElseBlock) { // if we are in an if block, both are 1, if we are in an else block, both are 0

						// ast
						$$ = $1;

					}

				} | ArrDecl { // array declaration

};


/*----end vardecl-------------------------------------------------------------------------------------------------------*/





/*----start expr--------------------------------------------------------------------------------------------------------*/


// expr is any possible expression in our language: e.g. write x; or return y;
Expr:	SEMICOLON {  // just a semicolon

	} |	ID EQ ID SEMICOLON { printf(GRAY "RECOGNIZED RULE: Assignment Statement\n\n" RESET); // e.g. x = y like above, but can also be present in a stmtList

		if (ifElseCurrentBlock == runIfElseBlock) { // if we are in an if block, both are 1, if we are in an else block, both are 0

			// semantic checks
				// are both variables already declared?
				symTabAccess(); // access symbole table
				printf("\n"); // print newline
				if (found($1,scope) == 0 || found($3,scope) == 0) { // if both variables are not found in the scope
					printf(RED "\nERROR: Variable %s or %s not declared.\n\n" RESET,$1,$3); // error message
					exit(0); // exit progrma
				}

				// does the second id have a value?
				initialized($3, scope);

				// are the id's both variables?
				compareKinds($1, $3, scope);

				// are the types of the id's the same
				compareTypes($1, $3, scope);

			// symbol table
			updateValue($1, scope, getValue($3, scope)); // update value of first id in symbol table

			// ast
			$$ = AST_BinaryExpression("=",$1,$3); // add expression to the ast

			// ir code
			createIDtoIDAssignment($1, $3, scope); // create ir code: T0 = T1

			// mips code
			createMIPSIDtoIDAssignment($1, $3, scope); // create mips

			// code optimization
				// mark the two id's as used
				isUsed($1, scope);
				isUsed($3, scope);

		}

	} | ID EQ ID LPAREN ArgDeclList RPAREN SEMICOLON { printf(GRAY "RECOGNIZED RULE: ID = Function\n" RESET); // e.g. x = addValue(1,2);

		if (ifElseCurrentBlock == runIfElseBlock) { // if we are in an if block, both are 1, if we are in an else block, both are 0

			// set scope to function
			strcpy(scope, $3);

			// loop through arguments and do parser functions
			for (int i = 0; i < argCounter; i++) { // from 0 to however many arguments there are

				printf(BGREEN "Parameter Accepted.\n" RESET); // output to console

				// ir code
				printf(BLUE "IR Code" RESET);
				printf(RED " NOT " RESET);
				printf(BLUE "Created.\n" RESET); // ir code not yet created

				// variables for getting parameter name based on index
				char itemName[50]; // stores name of parameter
				char itemID[50]; // stores id of the parameter
				char result[50]; // stores the result of below function

				// get parameter name based on index of for loop
				sprintf(itemID, "%d", i); // convert i into a string
				sprintf(itemName, "%s", getNameByID(itemID, scope)); // add the name of the parameter into itemName
				strcpy(result, ""); // redundant
				strcat(result, itemName); // store itemName in result

				// variables to hold the type of the parameter
				char type[50];
				int isInt, isFloat, isChar;

				// get the type of the parameter
				sprintf(type, "%s", getVariableType(itemName, scope));
				
				// determine whether the type is INT, FLT, or CHR
				isInt = strcmp(type, "INT"); // compare type to "INT"
				isFloat = strcmp(type, "FLT"); // compare type to "FLT"
				isChar = strcmp(type, "CHR"); // compare type to "CHR"

				if (isInt == 0) { // if the parameter is an integer
					if (argIsID == 1) { // if parameter is an ID

						// mips
						createIntIDParameter(IDArg, i+1, "G"); // create mips for an id parameter
						argIsID = 0; // revert argIsID to 0 (it gets set to 1 when it sees an ID parameter in ArgDeclList)

					} 
					else { // if parameter is an integer

						// mips
						createIntParameter(args[i], i+1, scope); // create mips for an integer parameter

					}
				} else if (isFloat == 0) { // if parameter is a float

					// mips
					createFloatParameter(args[i], i+1, scope); // create mips for a float parameter
	
				} else if (isChar == 0) { // if parameter is a char

					// mips
					createMIPSCharAssignment(result, args[i], scope); // create mips for a char parameter

				}
				
			}
			argCounter = 0; // revert argCounter to 0 (it gets incremented when counting arguments in ArgDeclList)

			// set scope back to global
			strcpy(scope, "G");

			// symbol table
			printf(BGREEN "Function Call & Parameters Accepted.\n" RESET); // output to console

			// mips again
			callMIPSFunction($3); // create mips for the calling of a function
			setVariableToReturn($1, $3, scope); // update the variable for the return type of this function

		}

	} |	WRITE ID SEMICOLON { printf(GRAY "RECOGNIZED RULE: Write Statement (Variable)\n" RESET); // e.g. write x;

		if (ifElseCurrentBlock == runIfElseBlock) { // if we are in an if block, both are 1, if we are in an else block, both are 0

			// semantic checks
				// is the id initialized as a value?
				initialized($2, scope); // symbol table function: exits if not initialized
			
			// symbol table
				// N/A

			// ast
			$$ = AST_BinaryExpression("Expr", $1, getValue($2, scope)); // add the write statement to the ast

			// ir code
			createWriteId($2, scope); // create ir code: output T0

			// mips
			// get the type of the variable
			char* type = getVariableType($2, scope);

			// determine if its int or char
			int isInt = strcmp(type, "INT"); // compare type to "INT"
			int isChar = strcmp(type, "CHR"); // compare type to "CHR"
			int isFloat = strcmp(type, "FLT"); // compare type to "FLT"

			// run correct mips function according to type
			if (isInt == 0) { // if the variable is an integer
				createMIPSWriteInt($2, scope); // create mips
			} 
			else if (isChar == 0) { // if the variable is a char
				createMIPSWriteChar($2, scope); // create mips
			} 
			else if (isFloat == 0) { // if the variable is a float
				createMIPSWriteFloat($2, scope); // create mips
			}

			// code optimization
				// mark the id as used
				isUsed($2, scope);

			/*
						Expr
				WRITE     getValue(ID)
			*/
		}

	} |	WRITE STRINGLITERAL SEMICOLON { printf(GRAY "RECOGNIZED RULE: Write Statement (Etc. String)\n" RESET); // e.g. write "Hello World!";

		if (ifElseCurrentBlock == runIfElseBlock) { // if we are in an if block, both are 1, if we are in an else block, both are 0

			// semantic checks
				// N/A

			// symbol table
				// N/A

			// ast
			$$ = AST_BinaryExpression("Expr", $1, $2); // add expression to the ast

			// ir code
			char str[50]; // variable to hold string without apostrophes
			strcpy(str, removeApostrophes($2)); // remove apostrophes and copy string into str
			createWriteString(str); // create ir code: output "Hello World!""

			// mips code
			defineMIPSTempString(str); // create mips temp definition at the top of the file to hold the string
			createMIPSWriteString($2, scope); // create mips code to display the string in scope

			// code optimization
				// mark the id as used
				isUsed($2, scope);

		}

	} |	WRITE ID LBRACE NUMBER RBRACE SEMICOLON { printf(GRAY "RECOGNIZED RULE: Write Statement (Array Element)\n" RESET); // e.g. write arr[0];

		if (ifElseCurrentBlock == runIfElseBlock) { // if we are in an if block, both are 1, if we are in an else block, both are 0

			// concatenate the array in this format: "$2[$4]"
			char elementID[50]; // holds the id of the element in the array
			strcpy(elementID, $2); // elementID: arr
			strcat(elementID, "["); // elementID: arr[
			strcat(elementID, $4); // elementID: arr[0
			strcat(elementID, "]"); // elementID: arr[0]

			// semantic checks
				// is the id initialized as a value?
				initialized(elementID, scope); // symbol table function: exits if not initialized
				
			// symbol table
				// N/A

			// ast
			$$ = AST_BinaryExpression("Expr", $1, getValue(elementID, scope)); // add expression to ast

			// ir code
			createWriteId(elementID, scope); // create ir code: T0 = arr[0]

			// mips code
				// get the type of the element
				char* type = getVariableType(elementID, scope); // symbol table function that returns type

				// determine if its int or char
				int isInt = strcmp(type, "INT"); // compare type to "INT"
				int isChar = strcmp(type, "CHR"); // compare type to "CHR"
				int isFloat = strcmp(type, "FLT"); // compare type to "FLT"

				// run correct mips function according to type
				if (isInt == 0) { // if the elemnt is an integer
					removeBraces(elementID); // remove the braces to make its name in mips
					createMIPSWriteInt(elementID, scope); // create mips to write the element
				} 
				else if (isChar == 0) { // if the element is a char
					removeBraces(elementID); // remove the braces to make its name in mips
					createMIPSWriteChar(elementID, scope); // create mips to write the element
				} 
				else if (isFloat == 0) { // if the element is a float
					removeBraces(elementID); // remove the braces to make its name in mips
					createMIPSWriteFloat(elementID, scope); // create mips to write the element
				}

			// code optimization
				// mark the id as used
				isUsed($2, scope);

		}

	} | WRITE NEWLINECHAR SEMICOLON { printf(GRAY "RECOGNIZED RULE: Print New Line\n\n" RESET); // e.g. write ~nl;

		if (ifElseCurrentBlock == runIfElseBlock) { // if we are in an if block, both are 1, if we are in an else block, both are 0

			// ast
			$$ = AST_BinaryExpression("Expr", $1, "NEWLINE"); // add newline expression to ast

			// symbol table
			printf(BGREEN "Symbol Table Not Needed.\n" RESET); // output to console

			// ir code
			createNewLine(); // create ir code: output *newline*

			// mips
			makeMIPSNewLine(scope); // create newline in mips

		}

	} | IDEQExpr SEMICOLON { printf(GRAY "RECOGNIZED RULE: Math Statement\n\n" RESET); // e.g. x = 3 - 1; same as above, just can also be in a stmtList

		if (ifElseCurrentBlock == runIfElseBlock) { // if we are in an if block, both are 1, if we are in an else block, both are 0

			// ast
			$$ = $1;

		}

	} | ID LBRACE NUMBER RBRACE EQ NUMBER SEMICOLON { printf(GRAY "RECOGNIZED RULE: Modify Integer Array Index\n\n" RESET); // e.g. arr[0] = 1;

		if (ifElseCurrentBlock == runIfElseBlock) { // if we are in an if block, both are 1, if we are in an else block, both are 0

			// add backets to id
			char temp[50]; // temp variable to hold id with brackets
			sprintf(temp,"%s[%s]",$1,$3); // fills temp with: arr[0] for example

			// convert index to integer
			int index = atoi($3); // stores converted integer in index variable

			// symbol table
			updateArrayValue($1, index, scope, "INT", $6); // update value of the array element in the symbol table

			// symbol table
			if (strcmp(scope, "G") != 0) { // if scope is in function

				if (found(temp, scope) == 1) { // if the variable is found in the function's sym table

					updateArrayValue($1, index, scope, "INT", $6); // update value in function sym table

				} else if (found(temp, "G") == 1) { // if the variable is found in the global scope

					updateArrayValue($1, index, "G", "INT", $6); // update value in global sym table

				} else { // variable not found

					showSymTable(); // show symbol table
					printf(RED "\nERROR: Variable '%s' does not exist.\n\n" RESET, temp); // error message
					exit(0); // exit program

				}

			} else { // if scope is global
				updateArrayValue($1, index, scope, "INT", $6); // update value normally
			}

			// ast
			$$ = AST_assignment($1,$3,$6); // add expression to the ast

			// ir code
			createIntAssignment(temp, $6, scope); // create ir code

			// mips code
			if (strcmp(scope, "G") != 0) { // if scope is function

				if (found(temp, scope) == 1) { // if the variable is found in the function's sym table

					removeBraces(temp); // remove the braces to make its name in mips
					createMIPSIntAssignment(temp, $6, scope); // create mips to update the array element

				} else if (found(temp, "G") == 1) { // if the variable is found in the global scope

					removeBraces(temp); // remove the braces to make its name in mips
					createMIPSIntAssignment(temp, $6, "G"); // create mips to update the array element

				} else { // variable not found

					showSymTable(); // show symbol table
					printf(RED "\nERROR: Variable '%s' does not exist.\n\n" RESET, temp); // error message
					exit(0); // exit program

				}

			} 
			else { // if scope is global
				removeBraces(temp); // remove the braces to make its name in mips
				createMIPSIntAssignment(temp, $6, scope); // create mips to update the array element
			}

		}

	} | ID LBRACE NUMBER RBRACE EQ Math SEMICOLON { printf(GRAY "RECOGNIZED RULE: Modify Integer Array Index (Math)\n\n" RESET); // e.g. arr[0] = 1 + 2;

		if (ifElseCurrentBlock == runIfElseBlock) { // if we are in an if block, both are 1, if we are in an else block, both are 0

			system("python3 calculate.py"); // perform calculation
	
			char result[100]; // store result of calculation
			readEvalOutput(&result); // read the output and store in result
			clearCalcInput(); // clear the input to the calculator
			printf(RED"\nResult from evaluation ==> %s \n"RESET,result); // output result to console
	
			// convert index to integer
			int index = atoi($3); // convert index to integer and store in index variable

			// symbol table
			updateArrayValue($1, index, scope, "INT", result); // update array element in symbol table

			// ast
			$$ = AST_assignment($1,$3,result); // add expression to symbol table

			// ir code
			char temp[50]; // temp variable to hold id with brackets
			sprintf(temp,"%s[%s]",$1,$3); // fills temp with: arr[0] for example
			createIntAssignment(temp, result, scope); // create ir code

			// mips code
			if (strcmp(scope, "G") != 0) { // if scope is in function
				if (found(temp, scope) == 1) { // if the variable is found in the function scope
					removeBraces(temp); // remove the braces to make its name in mips
					createMIPSIntAssignment(temp, result, scope); // create mips to update the array element
				} 
				else if (found(temp, "G") == 1) { // if the variable is found in the global scope
					removeBraces(temp); // remove the braces to make its name in mips
					createMIPSIntAssignment(temp, result, "G"); // create mips to update the array element
				} 
				else { // variable not found
					showSymTable(); // show symbol table
					printf(RED "\nERROR: Variable '%s' does not exist.\n\n" RESET, temp); // error message
					exit(0); // exit program
				}
			} else { // if scope is global
				removeBraces(temp); // remove the braces to make its name in mips
				createMIPSIntAssignment(temp, result, scope); // create mips to update the array element
			}
		}
	
	} | ID LBRACE NUMBER RBRACE EQ CHARLITERAL SEMICOLON { printf(GRAY "RECOGNIZED RULE: Modify Char Array Index\n\n" RESET); // e.g. arr[0] = 'c';

		if (ifElseCurrentBlock == runIfElseBlock) { // if we are in an if block, both are 1, if we are in an else block, both are 0

			// add brackets to id for sym table searches
			char temp[50]; // temp variable to hold id with brackets
			sprintf(temp,"%s[%s]",$1,$3); // fills temp with: arr[0] for example

			// convert index to integer
			int index = atoi($3); // store converted array index in index variable

			// remove apostrophes from charliteral
			char* str = removeApostrophes($6); // remove apostrophes function from symbol table

			// symbol table
			if (strcmp(scope, "G") != 0) { // if scope is in function

				if (found(temp, scope) == 1) { // if the variable is found in the function's sym table

					updateArrayValue($1, index, scope, "CHR", str); // update value in function sym table

				} else if (found(temp, "G") == 1) { // if the variable is found in the global scope

					updateArrayValue($1, index, "G", "CHR", str); // update value in global sym table

				} else { // variable not found

					showSymTable(); // show symbol table
					printf(RED "\nERROR: Variable '%s' does not exist.\n\n" RESET, temp); // error message
					exit(0); // exit program

				}

			} else { // if scope is global
				updateArrayValue($1, index, scope, "CHR", str); // update value normally
			}

			// ast
			$$ = AST_assignment($1,$3,str); // add expression to the ast

			// ir code
			createIntAssignment(temp, str, scope); // create ir code

			// mips code
			if (strcmp(scope, "G") != 0) { // if scope is in function

				if (found(temp, scope) == 1) { // if the variable is found in the function's sym table

					removeBraces(temp); // remove the braces to make its name in mips
					createMIPSCharAssignment(temp, str, scope); // create mips to update the array element

				} else if (found(temp, "G") == 1) { // if the variable is found in the global scope

					removeBraces(temp); // remove the braces to make its name in mips
					createMIPSCharAssignment(temp, str, "G"); // create mips to update the array element

				} else { // variable not found

					showSymTable(); // show symbol table
					printf(RED "\nERROR: Variable '%s' does not exist.\n\n" RESET, temp); // error message
					exit(0); // exit program

				}

			} else { // if scope is global
				removeBraces(temp); // remove the braces to make its name in mips
				createMIPSCharAssignment(temp, str, scope); // create mips to update the array element
			}
		}

	} | ID LPAREN ArgDeclList RPAREN SEMICOLON { printf(GRAY "RECOGNIZED RULE: Call Function\n\n" RESET); // e.g. addValue(1,2);

		if (ifElseCurrentBlock == runIfElseBlock) { // if we are in an if block, both are 1, if we are in an else block, both are 0

			// set scope to function
			strcpy(scope, $1);

			// loop through arguments
			for (int i = 0; i < argCounter; i++) {

				printf(BGREEN "Parameter Accepted.\n" RESET); // output to console

				// ir code
				printf(BLUE "IR Code" RESET);
				printf(RED " NOT " RESET);
				printf(BLUE "Created.\n" RESET); // ir code not yet created

				// variables for getting parameter name based on index
				char itemName[50]; // stores name of parameter
				char itemID[50]; // stores id of the parameter
				char result[50]; // stores the result of below function

				// get parameter name based on index of for loop
				sprintf(itemID, "%d", i); // convert i into a string
				sprintf(itemName, "%s", getNameByID(itemID, scope)); // add the name of the parameter into itemName
				strcpy(result, ""); // redundant
				strcat(result, itemName); // store itemName in result

				// variables to hold the type of the parameter
				char type[50];
				int isInt, isFloat, isChar;

				// get the type of the parameter
				sprintf(type, "%s", getVariableType(itemName, scope));
				
				// get type of parameter
				isInt = strcmp(type, "INT"); // compare type to "INT"
				isFloat = strcmp(type, "FLT"); // compare type to "FLT"
				isChar = strcmp(type, "CHR"); // compare type to "CHR"

				// run mips based on type
				if (isInt == 0) { // if parameter is an integer
					if (argIsID == 1) { // if parameter is an ID
						createIntIDParameter(IDArg, i+1, scope); // create integer ID parameter in mips
						argIsID = 0; // reset argIsID to 0 (gets changed to 1 in argDeclList)
					} 
					else { // if parameter is an integer number
						createIntParameter(args[i], i+1, scope); // create integer parameter in mips
					}
				} 
				else if (isFloat == 0) { // if parameter is a float
					createFloatParameter(args[i], i+1, scope); // create float parameter in mips
				} 
				else if (isChar == 0) { // if parameter is a char
					createMIPSCharAssignment(result, args[i], scope); // create char parameter in mips
				}
			}
			argCounter = 0; // reset argCounter to 0 (gets set to 1 when counting arguments in argDeclList)

			// set scope back to global
			strcpy(scope, "G");

			// symbol table
			printf(BGREEN "Function Call & Parameters Accepted.\n" RESET); // output to console

			// ast
			$$ = AST_assignment($1,$2,$4); // add expression to the ast

			// ir code
			printf(BLUE "IR Code" RESET);
			printf(RED " NOT " RESET);
			printf(BLUE "Created.\n" RESET); // ir code currently not needed

			// mips
			callMIPSFunction($1); // create function call in mips

		}

	} | RETURN ID SEMICOLON { printf(GRAY "RECOGNIZED RULE: Return Statement (ID)\n\n" RESET); // e.g. return x; (inside a function)

		if (ifElseCurrentBlock == runIfElseBlock) { // if we are in an if block, both are 1, if we are in an else block, both are 0

			// symbol table
			updateValue(scope, "G", getValue($2, scope)); // update the value of the function in the global table
			printf(BGREEN "Updated ID Return Value of Function.\n" RESET); // output to console

			// ir code
			printf(BLUE "IR Code" RESET);
			printf(RED " NOT " RESET);
			printf(BLUE "Created.\n" RESET); // ir code not currently needed

			// temp variables
			char str[50]; // temp string to hold variable type
			strcpy(str, getVariableType($2, scope)); // store variable type in 'str'

			char str1[50]; // temp string to hold "G{scope}"
			strcpy(str1, "G"); // store "G" in 'str1'
			strcat(str1, scope); // concatenate the scope to 'str1'

			char str2[50]; // temp string to hold "{scope}Return" for function return variable in mips
			strcpy(str2, scope); // store scope in 'str2'
			strcat(str2, "Return"); // concatenate "Return" to 'str2'
			
			// mips based on type
			if (strcmp(str, "INT") == 0) { // if the id is an integer

				// ir code
				createReturnIDStatement($2); // create ir code: return T2

				// mips
				createMIPSReturnStatementNumber(str2, $2, getValue($2, scope), scope); // create mips return variable

			} 
			else if (strcmp(str, "FLT") == 0) { // if the id is a float

				// ir code
				createReturnIDStatement($2); // create ir code: return T2

				// mips
				createMIPSFloatAssignment("", getValue($2, scope), str1); // create mips return variable

			} 
			else if (strcmp(str, "CHR") == 0) { // if the id is char

				// ir code
				createReturnIDStatement($2); // create ir code: return T2

				// mips
				createMIPSCharAssignment("", getValue($2, scope), str1); // create mips return variable
			}
			
		}

	} | RETURN NUMBER SEMICOLON { printf(GRAY "RECOGNIZED RULE: Return Statement (Int Number)\n\n" RESET);

		if (ifElseCurrentBlock == runIfElseBlock) { // if we are in an if block, both are 1, if we are in an else block, both are 0
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
		}

	} | RETURN FLOAT_NUM SEMICOLON {

		if (ifElseCurrentBlock == runIfElseBlock) { // if we are in an if block, both are 1, if we are in an else block, both are 0
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
		}

	} | RETURN CHARLITERAL SEMICOLON {

		if (ifElseCurrentBlock == runIfElseBlock) { // if we are in an if block, both are 1, if we are in an else block, both are 0
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

}

/*----end expr----------------------------------------------------------------------------------------------------------*/



IDEQExpr: ID EQ MathStmt {

	// ast
	// TODO: EVAN
	if (scope == "G" && inElseOrWhile != UPDATE_WHILE) { // ADD CHECK HERE FOR IF NOT IN WHILE LOOP, IF IN WHILE LOOP, NEED TO DO ELSE

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

	} else {

		if (scope != "G" && inElseOrWhile != UPDATE_WHILE) { // in a function

			if (op == '+') {

				// ir code
				createFunctionAddition($1);

				// mips
				createMIPSParameterAddition($1, scope);

			} else if (op == '-') {

				// ir code
				createFunctionSubtraction($1);

				// mips
				createMIPSSubtraction($1, num1, num2, scope);
			}
		
		} else { // in a while loop

			if (op == '+') {

				// ir code
				createFunctionAddition($1);

				// mips
				createMIPSLoopAddition(scope);
			} else if (op == '-') {

				// ir code
				createFunctionSubtraction($1);

				// mips
				createMIPSLoopSubtraction(scope);
			}

		}

	}

}

MathStmt: Math MathStmt {

}

		| Math {

}


Math: LPAREN {addToInputCalc($1);}
		| RPAREN {addToInputCalc($1);}
		| ID {
			addToInputCalc(getValue($1,scope)); 
			strcpy(num1, $1);

			//printf(BORANGE "inElseOrWhile: %s\nUPDATE_WHILE: %d\n", inElseOrWhile, UPDATE_WHILE);
			
			if (inElseOrWhile == UPDATE_WHILE) {

				createMIPSAddIDToRegister($1, registerCounter, scope);
				registerCounter++;
				
			}


		} 

		| NUMBER {
			addToInputCalc($1); 
			strcpy(num2, $1); 

			if (inElseOrWhile == UPDATE_WHILE) {

				createMIPSAddNumberToRegister($1, registerCounter);
				registerCounter++;

			}
		
		}
		| FLOAT_NUM {addToInputCalc($1);}
		| EXPONENT {addToInputCalc("**");}
		| Operator {addToInputCalc($1);}



Operator: PLUS_OP {op = '+';}	
		| SUB_OP {op = '-';}
		| MULT_OP {op = '*';}
		| DIV_OP {op = '/';}


CompOperator: DOUBLE_EQ {}
			| LT {}
			| GT {}
			| LT_EQ {}
			| GT_EQ {}
			| NOT_EQ {}

// ARRAY DECLARATIONS ----------------------------------------------------------------------
ArrDecl:	
			INT ID LBRACE RBRACE SEMICOLON { printf(GRAY "RECOGNIZED RULE: Integer Array Initialization Without Range\n\n" RESET);
				//int foo[]; //We should only have arrays be declared with range imo.



			} | CHAR ID LBRACE RBRACE SEMICOLON { printf(GRAY "RECOGNIZED RULE: Char Array Initialization Without Range\n\n" RESET);
				//char foo[]; //We should only have arrays be declared with range imo.

			

			} | INT ID LBRACE NUMBER RBRACE SEMICOLON { printf(GRAY "RECOGNIZED RULE: Integer Array Initialization With Range\n\n" RESET);
				// e.g. int foo[4];

						if (ifElseCurrentBlock == runIfElseBlock) {
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
						}

			} | CHAR ID LBRACE NUMBER RBRACE SEMICOLON { printf(GRAY "RECOGNIZED RULE: Char Array Initialization With Range\n\n" RESET);
				// e.g. char foo[5];
	
						if (ifElseCurrentBlock == runIfElseBlock) {
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
						}

}; 

WhileStmt:	WHILE { inElseOrWhile = UPDATE_WHILE;
					
					sprintf(whileName, "whileLoop%d",numOfWhileLoops);
					createMIPSFunction(whileName);  //create while loop function in MIPS
					callMIPSLoop(whileName);
					numOfWhileLoops++;
					changeIRFile(IR_FUNC);
					changeMIPSFile(MIPS_FUNC); //add block code to while loop function 

					// ir code
					createWhileStatement(numOfWhileLoops-1);

						} LPAREN Condition RPAREN { printf(GRAY "RECOGNIZED RULE: While Statement Initialization \n\n" RESET);							 
						 
							//inElseOrWhile = 0; //reset before block since Condition has been run already

						 } Block { 
							
							printf(GRAY "\nRECOGNIZED RULE: While Statement Block\n\n" RESET);
							MIPSWhileJump(whileName);
							changeIRFile(IR_CODE);
							changeMIPSFile(TEMP_MIPS); //change MIPS file location back to default (main:)
							//current = 0;

}

IfStmt: IF {inElseOrWhile = UPDATE_IF_ELSE;} LPAREN Condition RPAREN { printf(GRAY "RECOGNIZED RULE: If-Else Statement Initialization \n\n" RESET);
						
						inElseOrWhile = 0; //reset before block since Condition has been run already		 
						ifElseCurrentBlock = IN_IF_BLOCK;
						 
						 } Block { printf(GRAY "\nRECOGNIZED RULE: If-Else: IF Statement Block\n\n" RESET);

							if (runIfElseBlock == RUN_IF_BLOCK) {
								
								printf(BORANGE "Done with If Statement.\n\n" RESET);

							}

							ifElseCurrentBlock = IN_ELSE_BLOCK;

						 } ElseStmt { printf(GRAY "\nRECOGNIZED RULE: If-Else: ELSE Statement Block\n\n" RESET);

							if (runIfElseBlock == RUN_ELSE_BLOCK) {
								
								printf(BORANGE "Done With Else Statement.\n\n" RESET);

							}
							runIfElseBlock = 0; // reset the pass variable
							ifElseCurrentBlock = 0; // reset the current variable

}

ElseStmt: | ELSE Block

Condition: NUMBER CompOperator NUMBER {

				int temp1, temp2;
				temp1 = atoi($1);
				temp2 = atoi($3);

				if (compareIntOp($2, temp1, temp2) && inElseOrWhile == UPDATE_IF_ELSE) {
					runIfElseBlock = 1;
				}
				if (compareIntOp($2, temp1, temp2) && inElseOrWhile == UPDATE_WHILE) {
					if(strcmp($2,"==") == 0){
						printf(BORANGE "\nWARNING: Possible infinite loop detected.\n" RESET);
					}
					createWhileCondition($1, $2, $3);
					endMIPSWhile($1,$2,$3,scope,1,1);
					runWhileBlock = 1;
				}


		} | ID CompOperator ID {

				char type1[50];
				char type2[50];
				strcpy(type1, getVariableType($1, scope));
				strcpy(type2, getVariableType($3, scope));
				//printf(BORANGE "type1: %s\ntype2: %s\n" RESET, type1, type2);

				// semantic checks
				// are the types the same?
				int check;
				check = strcmp(type1, type2);

				if (!check) { // if the types are the same
					printf(BGREEN "\nID types are the same.\n" RESET);
				} else {
					printf(RED "\nERROR: Trying to compare two ID's that are not of the same type.\n" RESET);
					showSymTable();
					exit(0);
				}

				// are the variables intitalized as a value?
				check = strcmp(getValue($1, scope), "NULL");

				if (!check) { // if first ID is NULL
					printf(RED "\nERROR: ID '%s' is not assigned to a value.\n" RESET, $1);
					showSymTable();
					exit(0);
				}

				check = strcmp(getValue($3, scope), "NULL");

				if (!check) { // if second ID is NULL
					printf(RED "\nERROR: ID '%s' is not assigned to a value.\n" RESET, $3);
					showSymTable();
					exit(0);
				}

				// go further based on type of id's
				int typeInt, typeFloat, typeChar;
				typeInt = strcmp(type1, "INT");
				typeFloat = strcmp(type1, "FLT");
				typeChar = strcmp(type1, "CHR");

				if (!typeInt) { // if type is integer
					int temp1, temp2;
					temp1 = atoi(getValue($1, scope));
					temp2 = atoi(getValue($3, scope));
					//printf(BORANGE "temp1: %d\ntemp2: %d\n" RESET, temp1, temp2);

					if (compareIntOp($2, temp1, temp2) && inElseOrWhile == UPDATE_IF_ELSE) {
					runIfElseBlock = 1;
					}
					if (compareIntOp($2, temp1, temp2) && inElseOrWhile == UPDATE_WHILE) {
						if(strcmp($2,"==") == 0){
							printf(BORANGE "\nWARNING: Possible infinite loop detected.\n" RESET);
						}
						createWhileCondition($1, $2, $3);
						endMIPSWhile($1,$2,$3,scope,0,0);
						runWhileBlock = 1;
					}
				}
				else if (!typeFloat) { // if type is float
					float temp1, temp2;
					temp1 = atof(getValue($1, scope));
					temp2 = atof(getValue($3, scope));
					//printf(BORANGE "temp1: %f\ntemp2: %f\n" RESET, temp1, temp2);

					if (compareFloatOp($2, temp1, temp2) && inElseOrWhile == UPDATE_IF_ELSE) {
					runIfElseBlock = 1;
					}
					if (compareFloatOp($2, temp1, temp2) && inElseOrWhile == UPDATE_WHILE) {
						if(strcmp($2,"==") == 0){
							printf(BORANGE "\nWARNING: Possible infinite loop detected.\n" RESET);
						}
						createWhileCondition($1, $2, $3);
						endMIPSWhile($1,$2,$3,scope,0,0);
						runWhileBlock = 1;
					}
				}
				else if (!typeChar) { // if type is char
					char temp1[50], temp2[50];
					strcpy(temp1, getValue($1, scope));
					strcpy(temp2, getValue($3, scope));
					//printf(BORANGE "temp1: %s\ntemp2: %s\n" RESET, temp1, temp2);

					if (compareCharOp($2, temp1, temp2) && inElseOrWhile == UPDATE_IF_ELSE) {
					runIfElseBlock = 1;
					}
					if (compareCharOp($2, temp1, temp2) && inElseOrWhile == UPDATE_WHILE) {
						if(strcmp($2,"==") == 0){
							printf(BORANGE "\nWARNING: Possible infinite loop detected.\n" RESET);
						}
						createWhileCondition($1, $2, $3);
						endMIPSWhile($1,$2,$3,scope,0,0);
						runWhileBlock = 1;
					}
				}


		} | ID CompOperator NUMBER {

				// is the variable intitalized as a value?
				int check;
				check = strcmp(getValue($1, scope), "NULL");

				if (!check) { // if first ID is NULL
					printf(RED "\nERROR: ID '%s' is not assigned to a value.\n" RESET, $1);
					showSymTable();
					exit(0);
				}

				int temp1, temp2;
				temp1 = atoi(getValue($1, scope));
				temp2 = atoi($3);

				if (compareIntOp($2, temp1, temp2) && inElseOrWhile == UPDATE_IF_ELSE) {
					runIfElseBlock = 1;
				}
				if (compareIntOp($2, temp1, temp2) && inElseOrWhile == UPDATE_WHILE) {
					if(strcmp($2,"==") == 0){
						printf(BORANGE "\nWARNING: Possible infinite loop detected.\n" RESET);
					}
					createWhileCondition($1, $2, $3);
					endMIPSWhile($1,$2,$3,scope,0,1);
					runWhileBlock = 1;
				}


		} | FLOAT_NUM CompOperator FLOAT_NUM {

				float temp1, temp2;
				temp1 = atof($1);
				temp2 = atof($3);
				//printf(BORANGE "temp1: %f\ntemp2: %f\n" RESET, temp1, temp2);

				if (compareFloatOp($2, temp1, temp2) && inElseOrWhile == UPDATE_IF_ELSE) {
					runIfElseBlock = 1;
				}
				if (compareFloatOp($2, temp1, temp2) && inElseOrWhile == UPDATE_WHILE) {
					if(strcmp($2,"==") == 0){
						printf(BORANGE "\nWARNING: Possible infinite loop detected.\n" RESET);
					}
					endMIPSWhile($1,$2,$3,scope,1,1);
					runWhileBlock = 1;
				}

		} | CHARLITERAL CompOperator CHARLITERAL {

				char temp1[50], temp2[50];
				strcpy(temp1, $1);
				strcpy(temp2, $3);
				//printf(BORANGE "temp1: %s\ntemp2: %s\n" RESET, temp1, temp2);

				if (compareCharOp($2, temp1, temp2) && inElseOrWhile == UPDATE_IF_ELSE) {
					runIfElseBlock = 1;
				}
				if (compareCharOp($2, temp1, temp2) && inElseOrWhile == UPDATE_WHILE) {
					if(strcmp($2,"==") == 0){
						printf(BORANGE "\nWARNING: Possible infinite loop detected.\n" RESET);
					}
					endMIPSWhile($1,$2,$3,scope,1,1);
					runWhileBlock = 1;
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
	changeIRFile(IR_CODE);
	changeMIPSFile(TEMP_MIPS);

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