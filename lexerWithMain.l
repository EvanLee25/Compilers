%option noyywrap

%{
#include <stdio.h>
#include <string.h>
#include <math.h>

#define YY_DECL int yylex()

int words = 0;
int chars = 0;
int lines = 1;

%}

%option yylineno
NEWLINE [\n]
DELIM   [ \t]
WS      {DELIM}+
LETTER  [_a-zA-Z]
DIGIT   [0-9]
ID      {LETTER}({LETTER}|{DIGIT})*
NUMBER  {DIGIT}+
DIGITLETTER {DIGIT}+{LETTER}+({LETTER}|{DIGIT})*
STRINGLITERAL \"([^\\\"]|\\.)*\"
CHARLITERAL '([^'\n]|\\n|\\\\)'

%% 

"char"  {
	words++; chars += strlen(yytext);
	printf("%s : TYPE\n", yytext);
}

"int"  {
	words++; chars += strlen(yytext);
	printf("%s : TYPE\n", yytext);
     
}

"if"  {
	words++; chars += strlen(yytext);
	printf("%s : IF STATEMENT\n", yytext);
     
}

"else"  {
	words++; chars += strlen(yytext);
	printf("%s : ELSE STATEMENT\n", yytext);
     
}

"while"  {
	words++; chars += strlen(yytext);
	printf("%s : WHILE STATEMENT\n", yytext);
     
}

"print"  {
	words++; chars += strlen(yytext);
	printf("%s : PRINT STATEMENT\n", yytext);
     
}

"=="  {
	chars += 2;
	printf("%s : OPERATOR\n", yytext);
     
}

"!="  {
	chars += 2;
	printf("%s : OPERATOR\n", yytext);
     
}

"<="  {
	chars += 2;
	printf("%s : OPERATOR\n", yytext);
     
}

"<"  {
	chars++;
	printf("%s : OPERATOR\n", yytext);
     
}

">"  {
	chars++;
	printf("%s : OPERATOR\n", yytext);
     
}

">="  {
	chars += 2;
	printf("%s : OPERATOR\n", yytext);
     
}

"="  {
	chars++;
	printf("%s : OPERATOR\n", yytext);
     
}

"+="  {
	chars += 2;
	printf("%s : OPERATOR\n", yytext);
     
}

"-="  {
	chars += 2;
	printf("%s : OPERATOR\n", yytext);
     
}

"*="  {
	chars += 2;
	printf("%s : OPERATOR\n", yytext);
     
}

"/="  {
	chars += 2;
	printf("%s : OPERATOR\n", yytext);
     
}

"+"  {
	chars++;
	printf("%s : OPERATOR\n", yytext);
     
}

"*"  {
	chars++;
	printf("%s : OPERATOR\n", yytext);
     
}

"-"  {
	chars++;
	printf("%s : OPERATOR\n", yytext);
     
}

"/"  {
	chars++;
	printf("%s : OPERATOR\n", yytext);
     
}

"%"  {
	chars++;
	printf("%s : OPERATOR\n", yytext);
     
}

"("  {
	chars++;
	printf("%s : OPERATOR\n", yytext);
     
}

")"  {
	chars++;
	printf("%s : OPERATOR\n", yytext);
     
}

"{"  {
	chars++;
	printf("%s : OPERATOR\n", yytext);
     
}

"}"  {
	chars++;
	printf("%s : OPERATOR\n", yytext);
     
}

","  {
	chars++;
	printf("%s : OPERATOR\n", yytext);
     
}

";"  {
	chars++;
	printf("%s : SEMICOLON\n", yytext);
     
}

{STRINGLITERAL}  {
	chars++;
	printf("%s : STRING LITERAL\n", yytext);
     
}

{CHARLITERAL}  { 
	chars++;
	printf("%s : CHAR LITERAL\n", yytext);
     
}

{DIGITLETTER}  { 
	printf("%s : ERROR on line %i. Variable cannot start with number\n", yytext, lines);
     
}

{WS}  {

} 

{NEWLINE}  {
	lines++;
}

{ID}  {
	chars += strlen(yytext);
	printf("%s : ID\n", yytext); 

} 

{NUMBER}  {
	chars += strlen(yytext);
	printf("%s : NUMBER\n", yytext);
     
}

.  {printf("%s: UNRECOGNIZED\n", yytext);}

%%

int main(int argc, char**argv)
{
	printf("\n-----Lexer started.----- \n\n");

	if (argc > 1){
	  if(!(yyin = fopen(argv[1], "r")))
          {
		perror(argv[1]);
		return(1);
	  }
	}
	yylex();
	printf("\n-----Lexer finished.----- \n\n");
}