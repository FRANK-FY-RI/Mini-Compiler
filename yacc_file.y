%{
#include "support-functions.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

int yylex();
void yyerror(char*);

extern int yychar, yylineno;
extern char* yytext;

char label_buf[32], temp_buf[32];
%}

%union {
    char* name;
    float val;
}

%type <name> A 
%token <name> ID
%token <val> NUM
%token TRUE FALSE

%left OR
%left AND
%left EQ NE
%left LT GT LE GE
%left '+' '-'
%left '*' '/'
%right NOT

%%

S: S Assgn {} 
| Assgn {}
 ;

Assgn: ID '=' A ';' {
        gencode(genlabel(label_buf), $1, $3, "", ""); 
        free($1);
        printf("\n---------------------\n");
     }
    ;

A: A '+' A {
        gencode(genlabel(label_buf), gentemp(temp_buf), $1, "+", $3); 
        
        $$ = strdup(temp_buf); 
    }

 | A '-' A {
        gencode(genlabel(label_buf), gentemp(temp_buf), $1, "-", $3); 
        
        $$ = strdup(temp_buf); 
    }

 | A '*' A { 
        gencode(genlabel(label_buf), gentemp(temp_buf), $1, "*", $3); 
        
        $$ = strdup(temp_buf); 
    }

 | A '/' A {  
        gencode(genlabel(label_buf), gentemp(temp_buf), $1, "/", $3); 

        $$ = strdup(temp_buf); 
    }

 | '(' A ')' {
        $$ = $2;
    }

| A GT A {
        gencode(genlabel(label_buf), gentemp(temp_buf), $1, ">", $3);
        $$ = strdup(temp_buf);
    }

| A LT A {
        gencode(genlabel(label_buf), gentemp(temp_buf), $1, "<", $3);
        $$ = strdup(temp_buf);
    }

| A LE A {
        gencode(genlabel(label_buf), gentemp(temp_buf), $1, "<=", $3);
        $$ = strdup(temp_buf);
    }

| A GE A {
        gencode(genlabel(label_buf), gentemp(temp_buf), $1, ">=", $3);
        $$ = strdup(temp_buf);
    }

| A EQ A {
        gencode(genlabel(label_buf), gentemp(temp_buf), $1, "==", $3);
        $$ = strdup(temp_buf);
    }

| A NE A {
        gencode(genlabel(label_buf), gentemp(temp_buf), $1, "!=", $3);
        $$ = strdup(temp_buf);
    }

| A AND A {
        gencode(genlabel(label_buf), gentemp(temp_buf), $1, "&&", $3);
        $$ = strdup(temp_buf);
    }

| A OR A {
        gencode(genlabel(label_buf), gentemp(temp_buf), $1, "||", $3);
        $$ = strdup(temp_buf);
    }

| NOT A {
        char *t = gentemp(temp_buf);
        printf("%s: %s = !%s\n", genlabel(label_buf), t, $2);
        free($2);
        $$ = strdup(t);
    }


| NUM {
        char buffer[32];
        snprintf(buffer, sizeof(buffer), "%g", $1);
        $$ = strdup(buffer);
    }

| ID { $$ = $1; }

| TRUE { $$ = strdup("1"); }

| FALSE { $$ = strdup("0"); }
;

%%

void yyerror(char* s) {
    printf("%s error at line number %d\n", s, yylineno);
}

int main() {
    yyparse();
    return 0;
}
