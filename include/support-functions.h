#ifndef __SUPPORT_FUNC_H
#define __SUPPORT_FUNC_H

#include <string.h>
#include <stdio.h>
#include <stdlib.h>

static int label = 1, temp = 1;
static char label_buf[32], temp_buf[32];

#define MAX_INSTRUCTIONS 1000
#define MAX_INSTRSIZE 256
static int nextinstr = 1;

typedef struct {
    int label;
    char code[MAX_INSTRSIZE];
} Instruction;

static Instruction TAC[MAX_INSTRUCTIONS];

static char* gentemp() {
    sprintf(temp_buf, "t%d", temp); 
    char* newtemp = (char*)malloc(strlen(temp_buf) + 1);
    strcpy(newtemp, temp_buf);
    temp++;
    return newtemp;
}


int emit(char* instruction) {
    TAC[nextinstr].label = nextinstr;
    strcpy(TAC[nextinstr].code, instruction);
    return nextinstr++;
}


void print_TAC() {
    for(int i = 1; i<nextinstr; i++) {
        printf("%d: %s\n", TAC[i].label, TAC[i].code);
    }
}


void emit_assignment(char* opr1, char* op, char* opr2) {
    char *newtemp = gentemp();
    char instruction[MAX_INSTRSIZE];

    snprintf(instruction, sizeof(instruction),
             "%s = %s %s %s", newtemp, opr1, op, opr2);

    emit(instruction);

    free(newtemp);
    free(opr1);
    free(opr2);
}

static void emit_relational(char* lhs, char* relop, char* rhs) { 
    char *tempvar = gentemp();
    char instruction[MAX_INSTRSIZE];

    snprintf(instruction, MAX_INSTRSIZE, "if %s %s %s goto %s",
    lhs, relop, rhs, "___");
    emit(instruction);
    snprintf(instruction, MAX_INSTRSIZE, "%s = 0", tempvar);
    emit(instruction);
    snprintf(instruction, MAX_INSTRSIZE, "goto %s", "___");
    emit(instruction);
    snprintf(instruction, MAX_INSTRSIZE, "%s = 1", tempvar);
    emit(instruction);
 
    free(tempvar);

    if(strlen(lhs) > 0) free(lhs);
    if(strlen(rhs) > 0) free(rhs);
}


#endif

