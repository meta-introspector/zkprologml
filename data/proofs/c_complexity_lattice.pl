% C Code Complexity Lattice
% Label every C construct with prime complexity
% Use to label CompCert internals and Coq extraction

:- dynamic c_construct/3.
:- dynamic complexity_class/2.

% ═══════════════════════════════════════════════════════════
% PRIME COMPLEXITY LATTICE FOR C
% ═══════════════════════════════════════════════════════════

% Prime 2: Basic types
c_construct(int_type, 'int', 2).
c_construct(char_type, 'char', 2).
c_construct(void_type, 'void', 2).

% Prime 3: Operators
c_construct(add_op, '+', 3).
c_construct(sub_op, '-', 3).
c_construct(mul_op, '*', 3).
c_construct(div_op, '/', 3).

% Prime 5: Variables
c_construct(var_decl, 'int x;', 5).
c_construct(var_assign, 'x = 1;', 5).
c_construct(var_read, 'y = x;', 5).

% Prime 7: Control flow
c_construct(if_stmt, 'if (x) { }', 7).
c_construct(while_loop, 'while (x) { }', 7).
c_construct(for_loop, 'for (;;) { }', 7).

% Prime 11: Functions
c_construct(func_decl, 'int f();', 11).
c_construct(func_call, 'f(x);', 11).
c_construct(return_stmt, 'return x;', 11).

% Prime 13: Pointers
c_construct(pointer_decl, 'int *p;', 13).
c_construct(pointer_deref, '*p', 13).
c_construct(address_of, '&x', 13).

% Prime 17: Structs
c_construct(struct_decl, 'struct S { int x; };', 17).
c_construct(struct_access, 's.x', 17).
c_construct(struct_ptr_access, 's->x', 17).

% Prime 19: Arrays
c_construct(array_decl, 'int a[10];', 19).
c_construct(array_access, 'a[i]', 19).
c_construct(array_init, 'int a[] = {1,2,3};', 19).

% Prime 23: Memory
c_construct(malloc_call, 'malloc(n)', 23).
c_construct(free_call, 'free(p)', 23).
c_construct(memcpy_call, 'memcpy(d,s,n)', 23).

% Prime 29: Inline assembly
c_construct(asm_stmt, 'asm("mov %eax, %ebx")', 29).
c_construct(volatile_asm, 'asm volatile(...)', 29).

% Prime 31: Preprocessor
c_construct(include_directive, '#include <stdio.h>', 31).
c_construct(define_macro, '#define X 1', 31).
c_construct(ifdef_directive, '#ifdef X', 31).

% Prime 41: Complex expressions
c_construct(ternary_op, 'x ? y : z', 41).
c_construct(compound_literal, '(struct S){.x=1}', 41).
c_construct(cast_expr, '(int)x', 41).

% ═══════════════════════════════════════════════════════════
% LABEL COMPCERT INTERNALS
% ═══════════════════════════════════════════════════════════

label_compcert_file(File, Labels) :-
    % Read C file
    read_file_to_codes(File, Codes, []),
    atom_codes(Content, Codes),
    
    % Find all constructs
    findall(
        (Construct, Prime),
        (
            c_construct(Construct, Pattern, Prime),
            sub_atom(Content, _, _, _, Pattern)
        ),
        Labels
    ).

% ═══════════════════════════════════════════════════════════
% LABEL COQ EXTRACTION
% ═══════════════════════════════════════════════════════════

label_coq_extraction(CoqFile, CFile, Mapping) :-
    % Map Coq constructs to C constructs
    % Coq type → C type (prime 2)
    % Coq function → C function (prime 11)
    % Coq match → C switch (prime 7)
    
    findall(
        (CoqConstruct, CConstruct, Prime),
        (
            coq_to_c_mapping(CoqConstruct, CConstruct, Prime)
        ),
        Mapping
    ).

coq_to_c_mapping('nat', int_type, 2).
coq_to_c_mapping('bool', int_type, 2).
coq_to_c_mapping('list', pointer_decl, 13).
coq_to_c_mapping('option', pointer_decl, 13).
coq_to_c_mapping('Definition', func_decl, 11).
coq_to_c_mapping('Fixpoint', func_decl, 11).
coq_to_c_mapping('match', if_stmt, 7).
coq_to_c_mapping('if', if_stmt, 7).

% ═══════════════════════════════════════════════════════════
% ANALYZE COMPCERT SOURCE
% ═══════════════════════════════════════════════════════════

analyze_compcert_source :-
    write('🔍 Analyzing CompCert source with complexity lattice\n\n'),
    
    % Find CompCert installation
    CompCertPath = '/mnt/data1/2023/07/06/CompCert',
    
    (exists_directory(CompCertPath) ->
        (
            write('Found CompCert at: '), write(CompCertPath), nl,
            
            % Find C files
            format('find ~w -name "*.c" -type f 2>/dev/null | head -20', [CompCertPath]),
            nl
        )
    ;
        write('CompCert not found, using example\n')
    ),
    
    nl.

% ═══════════════════════════════════════════════════════════
% GENERATE LABELED OUTPUT
% ═══════════════════════════════════════════════════════════

generate_labeled_c :-
    write('📝 Generating labeled C code examples\n\n'),
    
    open('labeled_c_examples.c', write, S),
    
    write(S, '/* C Code Complexity Lattice */\n'),
    write(S, '/* Each construct labeled with prime complexity */\n\n'),
    
    forall(
        c_construct(Construct, Code, Prime),
        (
            format(S, '/* ~w: prime ~w */\n', [Construct, Prime]),
            format(S, '~w\n\n', [Code])
        )
    ),
    
    close(S),
    
    write('✅ Generated labeled_c_examples.c\n\n').

% ═══════════════════════════════════════════════════════════
% EXPORT TO PARQUET
% ═══════════════════════════════════════════════════════════

export_lattice_to_facts :-
    write('💾 Exporting lattice to Prolog facts\n\n'),
    
    open('c_complexity_facts.pl', write, S),
    
    write(S, '% C Complexity Lattice Facts\n'),
    write(S, '% Generated from c_complexity_lattice.pl\n\n'),
    
    forall(
        c_construct(Construct, Code, Prime),
        format(S, 'c_complexity(~q, ~q, ~w).\n', [Construct, Code, Prime])
    ),
    
    close(S),
    
    write('✅ Exported to c_complexity_facts.pl\n\n').

% ═══════════════════════════════════════════════════════════
% MAIN
% ═══════════════════════════════════════════════════════════

main :-
    write('🔬 C CODE COMPLEXITY LATTICE\n'),
    write('═══════════════════════════════════════════════════════════\n\n'),
    
    % Show lattice
    write('📊 Prime Complexity Lattice:\n\n'),
    forall(
        c_construct(Construct, Code, Prime),
        (
            emoji_prime(Prime, E),
            format('~w ~w: ~w → ~q\n', [E, Prime, Construct, Code])
        )
    ),
    nl,
    
    % Generate outputs
    generate_labeled_c,
    export_lattice_to_facts,
    
    % Analyze CompCert
    analyze_compcert_source,
    
    write('✅ C complexity lattice ready for labeling CompCert/Coq\n').

emoji_prime(2, '🔴'). emoji_prime(3, '🟠'). emoji_prime(5, '🟡').
emoji_prime(7, '🟢'). emoji_prime(11, '🔵'). emoji_prime(13, '🟣').
emoji_prime(17, '🟤'). emoji_prime(19, '⚫'). emoji_prime(23, '⚪').
emoji_prime(29, '🔺'). emoji_prime(31, '🔻'). emoji_prime(41, '🔷').

% ?- main.
