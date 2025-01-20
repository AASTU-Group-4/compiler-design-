%{
#include <stdio.h>
#include <stdlib.h>

// Node structure for parse tree
typedef struct Node {
    char *value;
    struct Node *left;
    struct Node *right;
} Node;

// Function prototypes
Node* createNode(char *value, Node *left, Node *right);
void printTree(Node *node, int depth);
void freeTree(Node *node);
%}

%union {
    char *str;
    Node *node;
}

%token <str> NUMBER VARIABLE
%type <node> expression term factor function_call
%type <node> unary_expression

%%

// Grammar rules
program:
    /* Empty */
    | program statement
    ;

statement:
    expression ';' { printf("Result: "); printTree($1, 0); printf("\n"); freeTree($1); }
    | VARIABLE '=' expression ';' { /* Assign variable logic */ }
    | function_call ';' { /* Call built-in function logic */ }
    ;

expression:
    expression '+' term { $$ = createNode("+", $1, $3); }
    | expression '-' term { $$ = createNode("-", $1, $3); }
    | term
    ;

term:
    term '*' factor { $$ = createNode("*", $1, $3); }
    | term '/' factor { $$ = createNode("/", $1, $3); }
    | factor
    ;

factor:
    '(' expression ')' { $$ = $2; }
    | NUMBER { $$ = createNode($1, NULL, NULL); }
    | VARIABLE { $$ = createNode($1, NULL, NULL); }
    | unary_expression { $$ = $1; }
    | function_call { $$ = $1; }
    ;

unary_expression:
    '+' factor { $$ = $2; }
    | '-' factor { $$ = createNode("-", $2, NULL); }
    ;

function_call:
    VARIABLE '(' expression ')' { $$ = createNode($1, $3, NULL); }
    ;

%%

// Error handling function
void yyerror(const char *s) {
    fprintf(stderr, "Syntax error: %s\n", s);
}

// Create a new parse tree node
Node* createNode(char *value, Node *left, Node *right) {
    Node *newNode = (Node *)malloc(sizeof(Node));
    newNode->value = value;
    newNode->left = left;
    newNode->right = right;
    return newNode;
}

// Print parse tree (for debugging)
void printTree(Node *node, int depth) {
    if (node) {
        for (int i = 0; i < depth; i++) printf("  ");
        printf("%s\n", node->value);
        printTree(node->left, depth + 1);
        printTree(node->right, depth + 1);
    }
}

// Free parse tree memory
void freeTree(Node *node) {
    if (node) {
        freeTree(node->left);
        freeTree(node->right);
        free(node);
    }
}

// Main function
int main(void) {
    yyparse();
    return 0;
}