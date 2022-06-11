%option noyywrap

%{
#include <stdio.h>
#include <string.h>
#include <math.h>

#define YY_DECL int yylex()
#include  "parser.tab.h"

int words = 0;
int chars = 0;
int lines = 1;

// test 

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
CHARLITERAL '([^'\n]|\\n|\\\\)'

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
    
    return CHAR;
}

"int"  {
	words++; chars += strlen(yytext);
	printf("%s : TYPE INT\n", yytext);
    
    return INT;
     
}

"if"  {
	words++; chars += strlen(yytext);
	printf("%s : IF STATEMENT\n", yytext);
    
    return IF;
     
}

"else"  {
	words++; chars += strlen(yytext);
	printf("%s : ELSE STATEMENT\n", yytext);
    
    return ELSE;
     
}

"while"  {
	words++; chars += strlen(yytext);
	printf("%s : WHILE STATEMENT\n", yytext);
    
    return WHILE;
     
}

"print"  {
	words++; chars += strlen(yytext);
	printf("%s : PRINT STATEMENT\n", yytext);
    
    return PRINT;
     
}

"=="  {
	chars += 2;
	printf("%s : OPERATOR\n", yytext);
    
    return DOUBLE_EQ;
     
}

"!="  {
	chars += 2;
	printf("%s : OPERATOR\n", yytext);
    
    return NOT_EQ;
     
}

"<="  {
	chars += 2;
	printf("%s : OPERATOR\n", yytext);
    
    return LT_EQ;
     
}

">="  {
	chars += 2;
	printf("%s : OPERATOR\n", yytext);
    
    return GT_EQ;
     
}

"+="  {
	chars += 2;
	printf("%s : OPERATOR\n", yytext);
    
    return PLUS_EQ;
     
}

"-="  {
	chars += 2;
	printf("%s : OPERATOR\n", yytext);
    
    return MINUS_EQ;
     
}

"*="  {
	chars += 2;
	printf("%s : OPERATOR\n", yytext);
    
    return MULTIPLY_EQ;
     
}

"/="  {
	chars += 2;
	printf("%s : OPERATOR\n", yytext);
    
    return DIVIDE_EQ;
     
}

"<"  {
	chars++;
	printf("%s : OPERATOR\n", yytext);
    
    return LT; 
}

">"  {
	chars++;
	printf("%s : OPERATOR\n", yytext);
    
    return GT;
     
}


"="  {
	chars++;
	printf("%s : OPERATOR\n", yytext);
    
    return EQ;
     
}


"+"  {
	chars++;
	printf("%s : OPERATOR\n", yytext);
    
    return PLUS_OP;
     
}

"*"  {
	chars++;
	printf("%s : OPERATOR\n", yytext);
    
    return MULTIPLY;
     
}

"-"  {
	chars++;
	printf("%s : OPERATOR\n", yytext);
    
    return MINUS;
     
}

"/"  {
	chars++;
	printf("%s : OPERATOR\n", yytext);
    
    return DIVIDE;
     
}

"%"  {
	chars++;
	printf("%s : OPERATOR\n", yytext);
    
    return MODULUS;
     
}

"("  {
	chars++;
	printf("%s : OPERATOR\n", yytext);
    
    return LPAREN;
     
}

")"  {
	chars++;
	printf("%s : OPERATOR\n", yytext);
    
    return RPAREN;
     
}

"{"  {
	chars++;
	printf("%s : OPERATOR\n", yytext);
    
    return LBRACE;
     
}

"}"  {
	chars++;
	printf("%s : OPERATOR\n", yytext);
    
    return RBRACE;
     
}

","  {
	chars++;
	printf("%s : OPERATOR\n", yytext);
    
    return COMMA;
     
}

";"  {
	chars++;
	printf("%s : SEMICOLON\n", yytext);
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
    yylval.number = atoi(strdup(yytext)); 
    return NUMBER;
     
}

.  {printf("%s: UNRECOGNIZED\n", yytext);}

%%