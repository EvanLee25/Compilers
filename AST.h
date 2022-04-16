//Abstract Syntax Tree Implementation
#include <string.h>

struct AST{
	char nodeType[50];
	char LHS[50];
	char RHS[50];
	
	struct AST * left;
	struct AST * right;
	// review pointers to structs in C 
	// complete the tree struct with pointers
};