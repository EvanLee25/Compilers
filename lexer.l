%option noyywrap

%{
#include <stdio.h>
#include <string.h>
#include <math.h>

#define YY_DECL int yylex()
#include  "parser.tab.h"

%}

%option yylineno

DELIM   [ \t\n]
WS      {DELIM}+
LETTER  [A-Za-z]
DIGIT   [0-9]
ID      {LETTER}({LETTER}|{DIGIT})*
NUMBER  {DIGIT}+(\.{DIGIT}+)?(E[+-]?{DIGIT}+)?

%%  

"char"  {printf("%s : TYPE\n", yytext);
    return TYPE;
}

"int"  {printf("%s : TYPE\n", yytext);
    return TYPE;
}



"=="  {printf("%s : OPERATOR\n", yytext);
    return DOUBLE_EQ;
}

"!="  {printf("%s : OPERATOR\n", yytext);
    return NOT_EQ;
}

"<="  {printf("%s : OPERATOR\n", yytext);
    return LT_EQ;
}

">="  {printf("%s : OPERATOR\n", yytext);
    return GT_EQ;
}

"<"  {printf("%s : OPERATOR\n", yytext);
    return LT;
}

">"  {printf("%s : OPERATOR\n", yytext);
    return GT;
}


"="  {printf("%s : OPERATOR\n", yytext);
    return EQ;
}

"+="  {printf("%s : OPERATOR\n", yytext);
    return PLUS_EQ;
}

"-="  {printf("%s : OPERATOR\n", yytext);
    return MINUS_EQ;
}

"*="  {printf("%s : OPERATOR\n", yytext);
    return MULTIPLY_EQ;
}

"/="  {printf("%s : OPERATOR\n", yytext);
    return DIVIDE_EQ;
}

"+"  {printf("%s : OPERATOR\n", yytext);
    return PLUS;
}

"*"  {printf("%s : OPERATOR\n", yytext);
    return MULTIPLY;
}

"-"  {printf("%s : OPERATOR\n", yytext);
    return MINUS;
}

"/"  {printf("%s : OPERATOR\n", yytext);
    return DIVIDE;
}

"%"  {printf("%s : OPERATOR\n", yytext);
    return MODULUS;
}



";"  {printf("%s : OPERATOR\n", yytext);
    return SEMICOLON;
}

{NUMBER}     {printf("%s : NUMBER\n", yytext);
    return NUMBER;
}

{ID}        {printf("%s : ID\n", yytext);
    return ID;
} 

{WS} {}

.  {printf("%s: anything", yytext);}

%%

int main(int argc, char**argv)
{
	#ifdef YYDEBUG
		yydebug = 1;
	#endif

	printf("Compiler started. \n\n");

	if (argc > 1){
	  if(!(yyin = fopen(argv[1], "r")))
          {
		perror(argv[1]);
		return(1);
	  }
	}
	yylex();
}