#ifndef __SUPPORT_FUNC_H
#define __SUPPORT_FUNC_H

#include <string.h>
#include <stdio.h>
#include <stdlib.h>

static int label = 1, temp = 1;
static char label_buf[32], temp_buf[32];

char* genlabel() {
    sprintf(label_buf, "%d", label);  
    label++;
    return label_buf;
}

char* gentemp() {
    sprintf(temp_buf, "t%d", temp); 
    temp++;
    return temp_buf;
}


void emit_assignment(char* opr1, char* op, char* opr2) {
    printf("%s: %s = %s %s %s\n",
    genlabel(), gentemp(), opr1, op, opr2);

    if(strlen(opr1) > 0) free(opr1);
    if(strlen(opr2) > 0) free(opr2);
}


#endif

