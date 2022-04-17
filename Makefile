makeLexerWithMain:lexerWithMain.l
	flex lexerWithMain.l
	gcc -o mainLexer lex.yy.c
	./mainLexer ctestfile.gcupl

clean:
	clear
	rm -f lex.yy.c mainLexer
	ls -l	