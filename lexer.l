%option noyywrap

%{
#include <stdio.h>
#include <string.h>
#include <math.h>
#include <ctype.h>

#define PINK "\x1b[1;95m"
#define RESET "\x1b[0m"

#define YY_DECL int yylex()
#include  "parser.tab.h"

int words = 0;
int chars = 0;
int lines = 1;


%}

%option yylineno

NEWLINE [\n\r]
DELIM   [ \t]
WS      {DELIM}+
LETTER  [_a-zA-Z]
DIGIT   [0-9]
ID      {LETTER}({LETTER}|{DIGIT})*
NUMBER  {DIGIT}+
STRINGLITERAL \"([^\\\"]|\\.)*\"
CHARLITERAL \'([^\\\'']|\\.)*\'

%%  

"/*"    {
				int c;
				while((c = input()) != 0) {
					if(c == '*') {
						if((c = input()) == '/')
							break;
						else
							unput(c);
					}
				}
		}


"char"  {
	words++; chars += strlen(yytext);
	printf("%s : TYPE CHAR\n", yytext);
    yylval.string = strdup(yytext);
    return CHAR;
}

"int"  {
	words++; chars += strlen(yytext);
	printf("%s : TYPE INT\n", yytext);
    yylval.string = strdup(yytext);
    return INT;
     
}

"if"  {
	words++; chars += strlen(yytext);
	printf("%s : IF STATEMENT\n", yytext);
    yylval.string = strdup(yytext);
    return IF;
     
}

"else"  {
	words++; chars += strlen(yytext);
	printf("%s : ELSE STATEMENT\n", yytext);
    yylval.string = strdup(yytext);
    return ELSE;
     
}

"while"  {
	words++; chars += strlen(yytext);
	printf("%s : WHILE STATEMENT\n", yytext);
    yylval.string = strdup(yytext);
    return WHILE;
     
}

"write"  {
	words++; chars += strlen(yytext);
	printf("%s : WRITE STATEMENT\n", yytext);
    yylval.string = strdup(yytext);
    return WRITE;
     
}


"print"  {
	words++; chars += strlen(yytext);
	printf("%s : PRINT STATEMENT\n", yytext);
    yylval.string = strdup(yytext);
    return PRINT;
     
}

"=="  {
	chars += 2;
	printf("%s : OPERATOR\n", yytext);
    yylval.string = strdup(yytext);
    return DOUBLE_EQ;
     
}

"!="  {
	chars += 2;
	printf("%s : OPERATOR\n", yytext);
    yylval.string = strdup(yytext);
    return NOT_EQ;
     
}

"<="  {
	chars += 2;
	printf("%s : OPERATOR\n", yytext);
    yylval.string = strdup(yytext);
    return LT_EQ;
     
}

">="  {
	chars += 2;
	printf("%s : OPERATOR\n", yytext);
    yylval.string = strdup(yytext);
    return GT_EQ;
     
}

"+="  {
	chars += 2;
	printf("%s : OPERATOR\n", yytext);
    yylval.string = strdup(yytext);
    return PLUS_EQ;
     
}

"-="  {
	chars += 2;
	printf("%s : OPERATOR\n", yytext);
    yylval.string = strdup(yytext);
    return MINUS_EQ;
     
}

"*="  {
	chars += 2;
	printf("%s : OPERATOR\n", yytext);
    yylval.string = strdup(yytext);
    return MULTIPLY_EQ;
     
}

"/="  {
	chars += 2;
	printf("%s : OPERATOR\n", yytext);
    yylval.string = strdup(yytext);
    return DIVIDE_EQ;
     
}

"<"  {
	chars++;
	printf("%s : OPERATOR\n", yytext);
    yylval.string = strdup(yytext);
    return LT; 
}

">"  {
	chars++;
	printf("%s : OPERATOR\n", yytext);
    yylval.string = strdup(yytext);
    return GT;
     
}

"="  {
	chars++;
	printf("%s : OPERATOR\n", yytext);
    yylval.string = strdup(yytext);
    return EQ;
     
}


"+"  {
	chars++;
	printf("%s : OPERATOR\n", yytext);
    yylval.string = strdup(yytext);
    return PLUS_OP;
     
}

"*"  {
	chars++;
	printf("%s : OPERATOR\n", yytext);
    yylval.string = strdup(yytext);
    return MULT_OP;
     
}

"-"  {
	chars++;
	printf("%s : OPERATOR\n", yytext);
    yylval.string = strdup(yytext);
    return SUB_OP;
     
}

"/"  {
	chars++;
	printf("%s : OPERATOR\n", yytext);
    yylval.string = strdup(yytext);
    return DIV_OP;
     
}

"^"  {
	chars++;
	printf("%s : OPERATOR\n", yytext);
    yylval.string = strdup(yytext);
    return EXPONENT;
     
}

"%"  {
	chars++;
	printf("%s : OPERATOR\n", yytext);
    yylval.string = strdup(yytext);
    return MODULUS;
     
}

"("  {
	chars++;
	printf("%s : OPERATOR\n", yytext);
    yylval.string = strdup(yytext);
    return LPAREN;
     
}

")"  {
	chars++;
	printf("%s : OPERATOR\n", yytext);
    yylval.string = strdup(yytext);
    return RPAREN;
     
}

"{"  {
	chars++;
	printf("%s : OPERATOR\n", yytext);
    yylval.string = strdup(yytext);
    return LBRACE;
     
}

"}"  {
	chars++;
	printf("%s : OPERATOR\n", yytext);
    yylval.string = strdup(yytext);
    return RBRACE;
     
}

","  {
	chars++;
	printf("%s : OPERATOR\n", yytext);
    yylval.string = strdup(yytext);
    return COMMA;
     
}

";"  {
	chars++;
	printf("%s : SEMICOLON\n", yytext);
	yylval.string = strdup(yytext);
    return SEMICOLON;
     
}

{STRINGLITERAL}  {
	chars++;
	printf("%s : STRING LITERAL\n", yytext);
    yylval.string = strdup(yytext);
    return STRINGLITERAL;
     
}

{CHARLITERAL}  { 
	chars++;
	printf("%s : CHAR LITERAL\n", yytext);
    yylval.string = strdup(yytext);
    return CHARLITERAL;
     
}

{WS}  {

} 

{NEWLINE}  {
	lines++;
}

{ID}  {
	chars += strlen(yytext);
	printf("%s : ID\n", yytext); 
    yylval.string = strdup(yytext);
    return ID;

} 

{NUMBER}  {
	chars += strlen(yytext);
	printf("%s : NUMBER\n", yytext);
    yylval.string = strdup(yytext); 
    return NUMBER;
     
}

.  {printf("%s", yytext);
	printf(PINK" : Unrecognized symbol at line %d char %d\n" RESET, lines,chars);}

%%