#ifndef __SUPPORT_FUNC_H
#define __SUPPORT_FUNC_H

#include <string.h>
#include <stdio.h>
#include <stdlib.h>

static int label = 1, temp = 1;

char* genlabel(char* lab) {
    sprintf(lab, "%d", label);  
    label++;
    return lab;
}

char* gentemp(char* t) {
    sprintf(t, "t%d", temp); 
    temp++;
    return t;
}


void gencode(char* labno, char* tempvar, char* opr1, char* op, char* opr2) {
    printf("%s: %s = %s %s %s\n",
    labno, tempvar, opr1, op, opr2);

    if(strlen(opr1) > 0) free(opr1);
    if(strlen(opr2) > 0) free(opr2);
}


#endif

