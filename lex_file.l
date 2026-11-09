%option noyywrap yylineno

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "y.tab.h"
%}

ws [ \t\n]
letter [A-Za-z]
digit [0-9]
identifier {letter}({letter}|{digit})*

%%
{ws} { /* Ignore whitespaces */ }
"!" { return NOT;}
";" { return ';';}
"+" { return '+';}
"-" { return '-';}
"*" { return '*';}
"/" { return '/';}
"=" { return '=';}
"(" { return '(';}
")" { return ')';}
">" { return GT;}
">=" { return GE;}
"<" { return LT;}
"<=" { return LE;}
"==" { return EQ;}
"||" { return OR;}
"&&" { return AND;}
"!=" { return NE;}
"true" { return TRUE;}
"false" {return FALSE;}
{digit}+ { yylval.val = atoi(yytext); return NUM;}
{digit}+"."{digit}+ { yylval.val = atof(yytext); return NUM;}
{identifier} { yylval.name = strdup(yytext); return ID;}
. { printf("Invalid symbol %s\n", yytext);}
%%
