% C Complexity Lattice Facts
% Generated from c_complexity_lattice.pl

c_complexity(int_type, int, 2).
c_complexity(char_type, char, 2).
c_complexity(void_type, void, 2).
c_complexity(add_op, +, 3).
c_complexity(sub_op, -, 3).
c_complexity(mul_op, *, 3).
c_complexity(div_op, /, 3).
c_complexity(var_decl, 'int x;', 5).
c_complexity(var_assign, 'x = 1;', 5).
c_complexity(var_read, 'y = x;', 5).
c_complexity(if_stmt, 'if (x) { }', 7).
c_complexity(while_loop, 'while (x) { }', 7).
c_complexity(for_loop, 'for (;;) { }', 7).
c_complexity(func_decl, 'int f();', 11).
c_complexity(func_call, 'f(x);', 11).
c_complexity(return_stmt, 'return x;', 11).
c_complexity(pointer_decl, 'int *p;', 13).
c_complexity(pointer_deref, '*p', 13).
c_complexity(address_of, '&x', 13).
c_complexity(struct_decl, 'struct S { int x; };', 17).
c_complexity(struct_access, 's.x', 17).
c_complexity(struct_ptr_access, 's->x', 17).
c_complexity(array_decl, 'int a[10];', 19).
c_complexity(array_access, 'a[i]', 19).
c_complexity(array_init, 'int a[] = {1,2,3};', 19).
c_complexity(malloc_call, 'malloc(n)', 23).
c_complexity(free_call, 'free(p)', 23).
c_complexity(memcpy_call, 'memcpy(d,s,n)', 23).
c_complexity(asm_stmt, 'asm("mov %eax, %ebx")', 29).
c_complexity(volatile_asm, 'asm volatile(...)', 29).
c_complexity(include_directive, '#include <stdio.h>', 31).
c_complexity(define_macro, '#define X 1', 31).
c_complexity(ifdef_directive, '#ifdef X', 31).
c_complexity(ternary_op, 'x ? y : z', 41).
c_complexity(compound_literal, '(struct S){.x=1}', 41).
c_complexity(cast_expr, '(int)x', 41).
