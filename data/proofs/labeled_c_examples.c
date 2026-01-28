/* C Code Complexity Lattice */
/* Each construct labeled with prime complexity */

/* int_type: prime 2 */
int

/* char_type: prime 2 */
char

/* void_type: prime 2 */
void

/* add_op: prime 3 */
+

/* sub_op: prime 3 */
-

/* mul_op: prime 3 */
*

/* div_op: prime 3 */
/

/* var_decl: prime 5 */
int x;

/* var_assign: prime 5 */
x = 1;

/* var_read: prime 5 */
y = x;

/* if_stmt: prime 7 */
if (x) { }

/* while_loop: prime 7 */
while (x) { }

/* for_loop: prime 7 */
for (;;) { }

/* func_decl: prime 11 */
int f();

/* func_call: prime 11 */
f(x);

/* return_stmt: prime 11 */
return x;

/* pointer_decl: prime 13 */
int *p;

/* pointer_deref: prime 13 */
*p

/* address_of: prime 13 */
&x

/* struct_decl: prime 17 */
struct S { int x; };

/* struct_access: prime 17 */
s.x

/* struct_ptr_access: prime 17 */
s->x

/* array_decl: prime 19 */
int a[10];

/* array_access: prime 19 */
a[i]

/* array_init: prime 19 */
int a[] = {1,2,3};

/* malloc_call: prime 23 */
malloc(n)

/* free_call: prime 23 */
free(p)

/* memcpy_call: prime 23 */
memcpy(d,s,n)

/* asm_stmt: prime 29 */
asm("mov %eax, %ebx")

/* volatile_asm: prime 29 */
asm volatile(...)

/* include_directive: prime 31 */
#include <stdio.h>

/* define_macro: prime 31 */
#define X 1

/* ifdef_directive: prime 31 */
#ifdef X

/* ternary_op: prime 41 */
x ? y : z

/* compound_literal: prime 41 */
(struct S){.x=1}

/* cast_expr: prime 41 */
(int)x

