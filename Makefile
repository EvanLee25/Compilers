all:
	make clean
	clear
	time make parser

parser.tab.c parser.tab.h: parser.y
	bison -t -v -d parser.y

lex.yy.c: lexer.l parser.tab.h
	flex lexer.l

parser: lex.yy.c parser.tab.c parser.tab.h
	gcc -w -o parser parser.tab.c lex.yy.c
	./parser testing.gcupl


makeLexerWithMain:lexerWithMain.l
	flex lexerWithMain.l
	gcc -w -o mainLexer lex.yy.c
	./mainLexer ctestfile.gcupl

clean:
	clear
	rm -f lex.yy.c mainLexer lexer parser.tab.c lex.yy.c parser.tab.h parser.output
	ls -l	