all: lexer parser
	g++ y.tab.c lex.yy.c  -o parser

lexer: Korgoth.lex
	lex Korgoth.lex

parser: Korgoth.yacc
	yacc -dy -v Korgoth.yacc

clean:
	rm -f lex.yy.c y.tab.c y.output y.tab.h parser parse.tab.c parse.output

test:
	./parser < Korgoth.test