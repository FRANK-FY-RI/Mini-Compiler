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

typedef struct ListNode {
    int label;
    struct ListNode* next;
} ListNode;

typedef struct ExprAttr {
    char *place;
    ListNode *truelist, *falselist;
} ExprAttr;

static Instruction TAC[MAX_INSTRUCTIONS + 1];

static char* gentemp() {
    sprintf(temp_buf, "t%d", temp++);  
    return strdup(temp_buf);
}


static int emit(char* instruction) {
    if(nextinstr > MAX_INSTRUCTIONS) {
        printf("emit buffer full\n");
        exit(EXIT_FAILURE);
    }
    TAC[nextinstr].label = nextinstr;
    strcpy(TAC[nextinstr].code, instruction);
    return nextinstr++;
}


static ListNode* makelist(int index) {
    ListNode *head = (ListNode*)malloc(sizeof(ListNode));
    head->label = index;
    head->next = NULL;
    return head;
}


static ListNode* mergelist(ListNode *l1, ListNode *l2) {
    if(!l1) return l2;
    if(!l2) return l1;
    ListNode *temp = l1;
    while(temp->next != NULL) {
        temp = temp->next;
    }
    temp->next = l2;
    return l1;
}


static void backpatch(ListNode *l, int index) {
    ListNode *temp = l;
    while(temp != NULL) {
        char *q = strchr(TAC[temp->label].code, '?'); 
        if(q != NULL) {
            sprintf(q, "%d", index);
        }
        ListNode *curr = temp;
        temp = temp->next;
        free(curr);
    }
}


static void print_TAC() {
    for(int i = 1; i<nextinstr; i++) {
        printf("%d: %s\n", TAC[i].label, TAC[i].code);
    }
}


static ExprAttr* create_expr(char* place, ListNode *tl, ListNode *fl) {
    ExprAttr *expr = (ExprAttr*)malloc(sizeof(ExprAttr));
    expr->place = place;
    expr->truelist = tl;
    expr->falselist = fl;
    return expr;
}


static void emit_assignment(char* opr1, char* op, char* opr2) {
    char *newtemp = gentemp();
    char instruction[MAX_INSTRSIZE];

    snprintf(instruction, sizeof(instruction),
             "%s = %s %s %s", newtemp, opr1, op, opr2);

    emit(instruction);

    free(newtemp);
    if(opr1) free(opr1);
    if(opr2) free(opr2);
}

static ExprAttr* emit_relational(char* lhs, char* relop, char* rhs) { 
    char instruction[MAX_INSTRSIZE];

    int true_label = nextinstr;
    snprintf(instruction, MAX_INSTRSIZE, "if %s %s %s goto %s",
    lhs, relop, rhs, "?");
    emit(instruction); 
    int false_label = nextinstr;
    snprintf(instruction, MAX_INSTRSIZE, "goto %s", "?");
    emit(instruction); 

    if(lhs) free(lhs);
    if(rhs) free(rhs);

    return create_expr(NULL, makelist(true_label), makelist(false_label));
 
}


#endif

