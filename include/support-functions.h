#ifndef __SUPPORT_FUNC_H
#define __SUPPORT_FUNC_H

#include <string.h>
#include <stdio.h>
#include <stdlib.h>

static int label = 1, temp = 1;
static char label_buf[32], temp_buf[32];

char* genlabel() {
    sprintf(label_buf, "%d", label); 
    char* newlabel = (char*)malloc(strlen(label_buf) + 1);
    strcpy(newlabel, label_buf);
    label++;
    return newlabel;
}

char* gentemp() {
    sprintf(temp_buf, "t%d", temp); 
    char* newtemp = (char*)malloc(strlen(temp_buf) + 1);
    strcpy(newtemp, temp_buf);
    temp++;
    return newtemp;
}


void emit_assignment(char* opr1, char* op, char* opr2) {
    char *newlabel = genlabel(), *newtemp = gentemp();

    printf("%s: %s = %s %s %s\n",
    newlabel, newtemp, opr1, op, opr2);

    free(newlabel);
    free(newtemp);

    if(strlen(opr1) > 0) free(opr1);
    if(strlen(opr2) > 0) free(opr2);
}


void emit_relational(char* lhs, char* relop, char* rhs) {
    char *start_label = genlabel(), *else_body = genlabel(),
         *else_goto = genlabel(), *true_body = genlabel(),
         *after = genlabel();
    label--;
    char *tempvar = gentemp();

    printf("%s: if %s %s %s goto %s\n",
    start_label, lhs, relop, rhs, true_body);
    printf("%s: %s = 0\n", else_body, tempvar);
    printf("%s: goto %s\n", else_goto, after);
    printf("%s: %s = 1\n", true_body, tempvar);

    free(start_label);
    free(else_body);
    free(else_goto);
    free(true_body);
    free(after);
    free(tempvar);

    if(strlen(lhs) > 0) free(lhs);
    if(strlen(rhs) > 0) free(rhs);
}


#endif

