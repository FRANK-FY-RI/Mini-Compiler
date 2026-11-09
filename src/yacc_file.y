%{
#include "support-functions.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

int yylex();
void yyerror(char*);

extern int yychar, yylineno;
extern char* yytext;
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
        char *newlabel = genlabel(); 

        printf("%s: %s = %s\n",
        newlabel, $1, $3);
        free($1);
        free($3);
        printf("\n---------------------\n");
        
        free(newlabel);
     }
    ;

A: A '+' A { emit_assignment($1, "+", $3); $$ = strdup(temp_buf); }

| A '-' A { emit_assignment($1, "-", $3); $$ = strdup(temp_buf); }

| A '*' A { emit_assignment($1, "*", $3); $$ = strdup(temp_buf); }

| A '/' A { emit_assignment($1, "/", $3); $$ = strdup(temp_buf); }

| '(' A ')' { $$ = $2; }

| A GT A { emit_relational($1, ">", $3); $$ = strdup(temp_buf); }

| A LT A { emit_relational($1, "<", $3); $$ = strdup(temp_buf); }

| A LE A { emit_relational($1, "<=", $3); $$ = strdup(temp_buf); }

| A GE A { emit_relational($1, ">=", $3); $$ = strdup(temp_buf); }

| A EQ A { emit_relational($1, "==", $3); $$ = strdup(temp_buf); }

| A NE A { emit_relational($1, "!=", $3); $$ = strdup(temp_buf); }

| A AND A { emit_assignment($1, "&&", $3); $$ = strdup(temp_buf); }

| A OR A { emit_assignment($1, "||", $3); $$ = strdup(temp_buf); }

| NOT A { emit_assignment("", "!", $2); $$ = strdup(temp_buf); }


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
    printf("%s error at line number %d near %c\n", s, yylineno, (char)yychar);
}

int main() {
    yyparse();
    return 0;
}
