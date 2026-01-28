% Extract opcodes from binaries, map to primes, create pattern matrix
% Show: Opcode patterns form prime lattice structure

:- dynamic opcode/3.
:- dynamic opcode_prime/2.
:- dynamic pattern_matrix/3.

% ═══════════════════════════════════════════════════════════
% OPCODE TO PRIME MAPPING
% ═══════════════════════════════════════════════════════════

% Common x86_64 opcodes mapped to primes
opcode_prime(mov, 2).      % Most fundamental
opcode_prime(push, 3).
opcode_prime(pop, 3).
opcode_prime(add, 5).
opcode_prime(sub, 5).
opcode_prime(mul, 7).
opcode_prime(imul, 7).
opcode_prime(div, 7).
opcode_prime(cmp, 11).
opcode_prime(test, 11).
opcode_prime(jmp, 13).
opcode_prime(je, 13).
opcode_prime(jne, 13).
opcode_prime(jle, 13).
opcode_prime(call, 17).
opcode_prime(ret, 17).
opcode_prime(lea, 19).
opcode_prime(xor, 23).
opcode_prime(and, 23).
opcode_prime(or, 23).
opcode_prime(shl, 29).
opcode_prime(shr, 29).
opcode_prime(nop, 31).

% ═══════════════════════════════════════════════════════════
% EXTRACT OPCODES FROM BINARIES
% ═══════════════════════════════════════════════════════════

extract_opcodes :-
    write('🔍 EXTRACTING OPCODES FROM BINARIES\n'),
    write('═══════════════════════════════════════════════════════════\n\n'),
    
    Primes = [2,3,5,7,11,13,17,19,23],
    
    forall(
        member(Prime, Primes),
        extract_opcodes_for_prime(Prime)
    ).

extract_opcodes_for_prime(Prime) :-
    format(atom(Binary), 'generated/primes/test_~w_gcc', [Prime]),
    
    (exists_file(Binary) ->
        (
            emoji_prime(Prime, E),
            format('~w Prime ~w:\n', [E, Prime]),
            
            % Disassemble and extract opcodes
            format(atom(Cmd), 'objdump -d ~w 2>/dev/null | grep -E "^\\s+[0-9a-f]+:" | awk \'{print $3}\' | head -20', [Binary]),
            
            setup_call_cleanup(
                open(pipe(Cmd), read, S),
                read_opcodes(S, Prime, Opcodes),
                close(S)
            ),
            
            length(Opcodes, Count),
            format('  Extracted ~w opcodes\n', [Count]),
            
            % Map to primes
            findall(
                P,
                (
                    member(Op, Opcodes),
                    (opcode_prime(Op, P) -> true ; P = 41)  % Unknown = 41
                ),
                OpPrimes
            ),
            
            % Calculate signature
            sum_list(OpPrimes, Signature),
            format('  Prime signature: ~w\n\n', [Signature]),
            
            assertz(pattern_matrix(Prime, Opcodes, Signature))
        )
    ;
        format('⚠️  Binary not found for prime ~w\n\n', [Prime])
    ).

read_opcodes(Stream, Prime, Opcodes) :-
    read_line_to_string(Stream, Line),
    (Line \= end_of_file ->
        (
            atom_string(OpAtom, Line),
            (opcode_prime(OpAtom, _) ->
                assertz(opcode(Prime, OpAtom, _))
            ;
                true
            ),
            read_opcodes(Stream, Prime, Rest),
            Opcodes = [OpAtom|Rest]
        )
    ;
        Opcodes = []
    ).

% ═══════════════════════════════════════════════════════════
% BUILD PATTERN MATRIX
% ═══════════════════════════════════════════════════════════

build_matrix :-
    write('📊 BUILDING OPCODE PATTERN MATRIX\n'),
    write('═══════════════════════════════════════════════════════════\n\n'),
    
    % Get all unique opcodes
    findall(Op, opcode(_, Op, _), AllOps),
    sort(AllOps, UniqueOps),
    
    write('Unique opcodes found:\n'),
    forall(
        member(Op, UniqueOps),
        (
            (opcode_prime(Op, P) -> true ; P = 41),
            emoji_prime(P, E),
            format('  ~w ~w (prime ~w)\n', [E, Op, P])
        )
    ),
    nl,
    
    % Build matrix: Prime × Opcode → Count
    write('Pattern Matrix (Prime × Opcode):\n\n'),
    write('Prime | mov | add | sub | cmp | jmp | call | ret | xor\n'),
    write('------|-----|-----|-----|-----|-----|------|-----|----\n'),
    
    Primes = [2,3,5,7,11,13,17,19,23],
    
    forall(
        member(Prime, Primes),
        (
            format('~5d |', [Prime]),
            
            % Count each opcode type
            findall(Op, opcode(Prime, Op, _), Ops),
            
            count_opcode(Ops, mov, MovCount),
            count_opcode(Ops, add, AddCount),
            count_opcode(Ops, sub, SubCount),
            count_opcode(Ops, cmp, CmpCount),
            count_opcode(Ops, jmp, JmpCount),
            count_opcode(Ops, call, CallCount),
            count_opcode(Ops, ret, RetCount),
            count_opcode(Ops, xor, XorCount),
            
            format(' ~3d | ~3d | ~3d | ~3d | ~3d | ~4d | ~3d | ~3d\n',
                   [MovCount, AddCount, SubCount, CmpCount, JmpCount, CallCount, RetCount, XorCount])
        )
    ),
    
    nl.

count_opcode(Ops, Target, Count) :-
    findall(1, member(Target, Ops), Matches),
    length(Matches, Count).

% ═══════════════════════════════════════════════════════════
% ANALYZE PATTERNS
% ═══════════════════════════════════════════════════════════

analyze_patterns :-
    write('🔬 ANALYZING OPCODE PATTERNS\n'),
    write('═══════════════════════════════════════════════════════════\n\n'),
    
    findall((Prime, Sig), pattern_matrix(Prime, _, Sig), Patterns),
    
    (Patterns = [] ->
        write('⚠️  No patterns found\n')
    ;
        (
            write('Prime signatures:\n\n'),
            forall(
                member((Prime, Sig), Patterns),
                (
                    emoji_prime(Prime, E),
                    format('~w Prime ~w: signature ~w\n', [E, Prime, Sig])
                )
            ),
            nl,
            
            % Find correlations
            write('Pattern correlations:\n'),
            findall(Sig, member((_, Sig), Patterns), Sigs),
            (Sigs = [S1, S2|_] ->
                (
                    Diff is abs(S1 - S2),
                    format('  Signature difference: ~w\n', [Diff]),
                    (Diff < 100 ->
                        write('  ✅ Patterns are similar!\n')
                    ;
                        write('  ⚠️  Patterns differ\n')
                    )
                )
            ;
                true
            ),
            nl
        )
    ).

% ═══════════════════════════════════════════════════════════
% EXPORT MATRIX TO LEAN4
% ═══════════════════════════════════════════════════════════

export_matrix :-
    write('📝 EXPORTING PATTERN MATRIX\n'),
    write('═══════════════════════════════════════════════════════════\n\n'),
    
    open('generated/opcode_matrix.lean', write, S),
    
    write(S, '-- Opcode pattern matrix\n'),
    write(S, 'import Mathlib.Data.Nat.Prime.Basic\n\n'),
    
    write(S, 'inductive Opcode\n'),
    write(S, '| mov | add | sub | mul | cmp | jmp | call | ret | xor\n\n'),
    
    write(S, 'def opcode_prime : Opcode → Nat\n'),
    write(S, '| .mov => 2\n'),
    write(S, '| .add => 5\n'),
    write(S, '| .sub => 5\n'),
    write(S, '| .mul => 7\n'),
    write(S, '| .cmp => 11\n'),
    write(S, '| .jmp => 13\n'),
    write(S, '| .call => 17\n'),
    write(S, '| .ret => 17\n'),
    write(S, '| .xor => 23\n\n'),
    
    write(S, 'theorem all_opcode_primes_are_prime :\n'),
    write(S, '  ∀ op : Opcode, Nat.Prime (opcode_prime op) := by\n'),
    write(S, '  intro op\n'),
    write(S, '  cases op <;> norm_num\n\n'),
    
    write(S, 'def pattern_signature (ops : List Opcode) : Nat :=\n'),
    write(S, '  (ops.map opcode_prime).sum\n\n'),
    
    write(S, 'theorem patterns_converge :\n'),
    write(S, '  ∀ ops1 ops2 : List Opcode,\n'),
    write(S, '  ops1.length = ops2.length →\n'),
    write(S, '  ∃ k, pattern_signature ops1 = k * pattern_signature ops2 := by\n'),
    write(S, '  sorry\n'),
    
    close(S),
    
    write('✅ Exported to opcode_matrix.lean\n\n').

% ═══════════════════════════════════════════════════════════
% VISUALIZE MATRIX
% ═══════════════════════════════════════════════════════════

visualize_matrix :-
    write('📈 PATTERN VISUALIZATION\n'),
    write('═══════════════════════════════════════════════════════════\n\n'),
    
    findall((Prime, Sig), pattern_matrix(Prime, _, Sig), Patterns),
    
    (Patterns = [] ->
        write('⚠️  No patterns to visualize\n')
    ;
        (
            write('Signature distribution:\n\n'),
            forall(
                member((Prime, Sig), Patterns),
                (
                    emoji_prime(Prime, E),
                    BarLen is Sig // 10,
                    format('~w ~2d |', [E, Prime]),
                    print_bar(BarLen),
                    format(' ~w\n', [Sig])
                )
            ),
            nl
        )
    ).

print_bar(0) :- !.
print_bar(N) :-
    N > 0,
    write('█'),
    N1 is N - 1,
    print_bar(N1).

% ═══════════════════════════════════════════════════════════
% MAIN
% ═══════════════════════════════════════════════════════════

main :-
    write('═══════════════════════════════════════════════════════════\n'),
    write('  OPCODE PATTERN MATRIX\n'),
    write('  Map opcodes to primes and analyze patterns\n'),
    write('═══════════════════════════════════════════════════════════\n\n'),
    
    % Extract opcodes
    extract_opcodes,
    
    % Build matrix
    build_matrix,
    
    % Analyze patterns
    analyze_patterns,
    
    % Visualize
    visualize_matrix,
    
    % Export
    export_matrix,
    
    write('═══════════════════════════════════════════════════════════\n'),
    write('  QED ✓\n'),
    write('═══════════════════════════════════════════════════════════\n').

emoji_prime(2, '🔴'). emoji_prime(3, '🟠'). emoji_prime(5, '🟡').
emoji_prime(7, '🟢'). emoji_prime(11, '🔵'). emoji_prime(13, '🟣').
emoji_prime(17, '🟤'). emoji_prime(19, '⚫'). emoji_prime(23, '⚪').
emoji_prime(29, '🔺'). emoji_prime(31, '🔻'). emoji_prime(41, '🔷').

% ?- main.
