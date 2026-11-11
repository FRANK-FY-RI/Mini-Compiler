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
    int instr;
    struct ExprAttr* expr;
}

%type <expr> A E B 
%type <instr> M
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

M: { $$ = nextinstr;}
;

Assgn: ID '=' A ';' {
        char instruction[MAX_INSTRSIZE];

        if ($3->truelist != NULL || $3->falselist != NULL) {
            char *tempvar = gentemp();

            int false_label = nextinstr;
            snprintf(instruction, MAX_INSTRSIZE, "%s = 0", tempvar);
            emit(instruction);

            int goto_end = nextinstr;
            emit("goto ?");

            int true_label = nextinstr;
            snprintf(instruction, MAX_INSTRSIZE, "%s = 1", tempvar);
            emit(instruction);

            backpatch($3->truelist, true_label);
            backpatch($3->falselist, false_label);
            backpatch(makelist(goto_end), nextinstr);

            snprintf(instruction, MAX_INSTRSIZE, "%s = %s", $1, tempvar);
            emit(instruction);
            free(tempvar);
        } else {
            snprintf(instruction, MAX_INSTRSIZE, "%s = %s", $1, $3->place);
            emit(instruction);
            if ($3->place) free($3->place);
        }

        free($1);
        free($3);

        print_TAC();
        printf("\n---------------------\n");    
     }
;

A: E {}
| B {}
;

E: E '+' E
    {
        emit_assignment($1->place, "+", $3->place);
        $$ = create_expr(strdup(temp_buf), NULL, NULL);
        free($1); free($3);
    }

| E '-' E
    {
        emit_assignment($1->place, "-", $3->place);
        $$ = create_expr(strdup(temp_buf), NULL, NULL);
        free($1); free($3);
    }

| E '*' E
    {
        emit_assignment($1->place, "*", $3->place);
        $$ = create_expr(strdup(temp_buf), NULL, NULL);
        free($1); free($3);
    }

| E '/' E
    {
        emit_assignment($1->place, "/", $3->place);
        $$ = create_expr(strdup(temp_buf), NULL, NULL);
        free($1); free($3);
    }

| '(' E ')' { $$= $2; }

| NUM {
        char buffer[32];
        snprintf(buffer, sizeof(buffer), "%g", $1);
        $$ = create_expr(strdup(buffer), NULL, NULL);
    }

| ID { $$ = create_expr($1, NULL, NULL); }
;

B: E GT E
    {
        $$ = emit_relational($1->place, ">", $3->place); 
        free($1); free($3);
    }

| E LT E 
    {
        $$ = emit_relational($1->place, "<", $3->place);
        free($1); free($3);
    }

| E LE E 
    {
        $$ = emit_relational($1->place, "<=", $3->place);
        free($1); free($3);
    }

| E GE E 
    {
        $$ = emit_relational($1->place, ">=", $3->place);
        free($1); free($3);
    }

| E EQ E 
    {
        $$ = emit_relational($1->place, "==", $3->place);
        free($1); free($3);
    }

| E NE E 
    {
        $$ = emit_relational($1->place, "!=", $3->place);
        free($1); free($3);
    }

| B AND M B
    {
        backpatch($1->truelist, $3);
        $$ = create_expr(NULL, $4->truelist, mergelist($1->falselist, $4->falselist));
        free($1); free($4);
    }

| B OR M B 
    {
        backpatch($1->falselist, $3);
        $$ = create_expr(NULL, mergelist($1->truelist, $4->truelist), $4->falselist);
        free($1); free($4);
    }

| NOT B 
    {
        $$ = create_expr(NULL, $2->falselist, $2->truelist);
        free($2);
    }



| TRUE  { int idx = nextinstr; emit("goto ?"); $$ = create_expr(NULL, makelist(idx), NULL); }

| FALSE { int idx = nextinstr; emit("goto ?"); $$ = create_expr(NULL, NULL, makelist(idx)); }
;

%%

void yyerror(char* s) {
    printf("%s error at line number %d near %c\n", s, yylineno, (char)yychar);
}

int main() {
    yyparse();
    return 0;
}
