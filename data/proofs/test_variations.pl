% Generate 2^n variations per prime for better sampling
% Variations guided by lattice structure

:- dynamic variation/4.
:- dynamic compilation_trace/5.

% ═══════════════════════════════════════════════════════════
% GENERATE VARIATIONS FOR EACH PRIME
% ═══════════════════════════════════════════════════════════

% Prime 2: Types (2^2 = 4 variations)
variation(2, 1, 'int only', '
int main() { int x = 2; return x; }
').

variation(2, 2, 'char only', '
int main() { char c = 2; return c; }
').

variation(2, 3, 'int + char', '
int main() { int x = 2; char c = x; return c; }
').

variation(2, 4, 'multiple types', '
int main() { int x = 2; char c = 1; float f = 1.0; return x; }
').

% Prime 3: Operators (2^3 = 8 variations)
variation(3, 1, 'add only', '
int main() { return 1 + 2; }
').

variation(3, 2, 'multiply only', '
int main() { return 2 * 3; }
').

variation(3, 3, 'add + multiply', '
int main() { return 1 + 2 * 3; }
').

variation(3, 4, 'subtract', '
int main() { return 5 - 2; }
').

variation(3, 5, 'divide', '
int main() { return 6 / 2; }
').

variation(3, 6, 'add + subtract', '
int main() { return 5 + 3 - 2; }
').

variation(3, 7, 'multiply + divide', '
int main() { return 6 * 2 / 3; }
').

variation(3, 8, 'all operators', '
int main() { return (5 + 3) * 2 - 6 / 2; }
').

% Prime 5: Variables (2^2 = 4 variations)
variation(5, 1, 'single var', '
int main() { int x = 5; return x; }
').

variation(5, 2, 'two vars', '
int main() { int x = 5; int y = x; return y; }
').

variation(5, 3, 'chain assignment', '
int main() { int x = 5; int y = x; int z = y; return z; }
').

variation(5, 4, 'multiple assign', '
int main() { int x = 5; x = x + 1; x = x * 2; return x; }
').

% Prime 7: Control (2^3 = 8 variations)
variation(7, 1, 'if only', '
int main() { if (1) return 7; return 0; }
').

variation(7, 2, 'if-else', '
int main() { if (0) return 1; else return 7; }
').

variation(7, 3, 'nested if', '
int main() { if (1) { if (1) return 7; } return 0; }
').

variation(7, 4, 'while loop', '
int main() { int x = 0; while (x < 7) x++; return x; }
').

variation(7, 5, 'for loop', '
int main() { int x; for (x = 0; x < 7; x++); return x; }
').

variation(7, 6, 'if + while', '
int main() { int x = 0; if (1) while (x < 7) x++; return x; }
').

variation(7, 7, 'nested loops', '
int main() { int x = 0; for (int i = 0; i < 7; i++) x++; return x; }
').

variation(7, 8, 'complex control', '
int main() { int x = 0; if (x < 7) { while (x < 7) x++; } return x; }
').

% Prime 11: Functions (2^2 = 4 variations)
variation(11, 1, 'simple call', '
int f() { return 11; }
int main() { return f(); }
').

variation(11, 2, 'with param', '
int f(int x) { return x; }
int main() { return f(11); }
').

variation(11, 3, 'multiple params', '
int f(int x, int y) { return x + y; }
int main() { return f(5, 6); }
').

variation(11, 4, 'recursive', '
int f(int n) { if (n <= 0) return 1; return n + f(n-1); }
int main() { return f(5); }
').

% ═══════════════════════════════════════════════════════════
% COMPILE AND TRACE ALL VARIATIONS
% ═══════════════════════════════════════════════════════════

test_all_variations :-
    write('🔬 TESTING 2^N VARIATIONS PER PRIME\n'),
    write('═══════════════════════════════════════════════════════════\n\n'),
    
    shell('mkdir -p generated/variations', _),
    
    findall((Prime, N), variation(Prime, N, _, _), Variations),
    
    forall(
        member((Prime, N), Variations),
        test_variation(Prime, N)
    ).

test_variation(Prime, N) :-
    variation(Prime, N, Desc, Code),
    
    emoji_prime(Prime, E),
    format('~w Prime ~w, variation ~w: ~w\n', [E, Prime, N, Desc]),
    
    % Write C file
    format(atom(CFile), 'generated/variations/test_~w_~w.c', [Prime, N]),
    open(CFile, write, S),
    write(S, '#include <stdio.h>\n'),
    write(S, Code),
    close(S),
    
    % Compile with perf
    format(atom(Binary), 'generated/variations/test_~w_~w', [Prime, N]),
    format(atom(PerfData), 'generated/variations/perf_~w_~w.data', [Prime, N]),
    format(atom(CompileCmd), 'perf record -e cycles -o ~w gcc ~w -o ~w 2>&1 >/dev/null', 
           [PerfData, CFile, Binary]),
    
    catch(
        (
            shell(CompileCmd, Status),
            (Status = 0 ->
                (
                    % Extract perf stats
                    format(atom(PerfCmd), 'perf report -i ~w --stdio 2>&1 | grep "Event count" | head -1', [PerfData]),
                    catch(
                        setup_call_cleanup(
                            open(pipe(PerfCmd), read, PS),
                            read_line_to_string(PS, PerfLine),
                            close(PS)
                        ),
                        _,
                        PerfLine = ""
                    ),
                    
                    % Count opcodes
                    format(atom(ObjCmd), 'objdump -d ~w 2>/dev/null | grep -E "^\\s+[0-9a-f]+:" | wc -l', [Binary]),
                    catch(
                        setup_call_cleanup(
                            open(pipe(ObjCmd), read, OS),
                            read_line_to_string(OS, OpcodeStr),
                            close(OS)
                        ),
                        _,
                        OpcodeStr = "0"
                    ),
                    (OpcodeStr \= end_of_file, OpcodeStr \= "" ->
                        atom_string(OpcodeAtom, OpcodeStr),
                        atom_number(OpcodeAtom, Opcodes)
                    ;
                        Opcodes = 0
                    ),
                    
                    format('  ✅ ~w opcodes\n', [Opcodes]),
                    assertz(compilation_trace(Prime, N, Opcodes, PerfLine, success))
                )
            ;
                (
                    format('  ❌ failed\n', []),
                    assertz(compilation_trace(Prime, N, 0, "", failed))
                )
            )
        ),
        _,
        format('  ⚠️  error\n', [])
    ).

% ═══════════════════════════════════════════════════════════
% ANALYZE VARIATION PATTERNS
% ═══════════════════════════════════════════════════════════

analyze_variations :-
    write('\n📊 ANALYZING VARIATION PATTERNS\n'),
    write('═══════════════════════════════════════════════════════════\n\n'),
    
    Primes = [2, 3, 5, 7, 11],
    
    forall(
        member(Prime, Primes),
        analyze_prime_variations(Prime)
    ).

analyze_prime_variations(Prime) :-
    findall((N, Opcodes), compilation_trace(Prime, N, Opcodes, _, success), Results),
    
    (Results = [] ->
        true
    ;
        (
            emoji_prime(Prime, E),
            format('~w Prime ~w:\n', [E, Prime]),
            
            length(Results, Count),
            findall(O, member((_, O), Results), AllOpcodes),
            sum_list(AllOpcodes, Total),
            Avg is Total / Count,
            
            % Calculate variance
            findall(Diff, (member((_, O), Results), Diff is (O - Avg) * (O - Avg)), Diffs),
            sum_list(Diffs, SumSq),
            Variance is sqrt(SumSq / Count),
            
            format('  Variations: ~w\n', [Count]),
            format('  Avg opcodes: ~2f\n', [Avg]),
            format('  Std dev: ~2f\n', [Variance]),
            
            % Show distribution
            format('  Distribution: ', []),
            forall(
                member((N, O), Results),
                format('~w:~w ', [N, O])
            ),
            nl, nl
        )
    ).

% ═══════════════════════════════════════════════════════════
% GENERATE SUMMARY MATRIX
% ═══════════════════════════════════════════════════════════

generate_summary :-
    write('📈 VARIATION SUMMARY MATRIX\n'),
    write('═══════════════════════════════════════════════════════════\n\n'),
    
    write('Prime | Variations | Min | Max | Avg | StdDev\n'),
    write('------|------------|-----|-----|-----|-------\n'),
    
    Primes = [2, 3, 5, 7, 11],
    
    forall(
        member(Prime, Primes),
        (
            findall(O, compilation_trace(Prime, _, O, _, success), Opcodes),
            (Opcodes = [] ->
                format('~5d | ~10d | ~3d | ~3d | ~3d | ~6.2f\n', [Prime, 0, 0, 0, 0, 0.0])
            ;
                (
                    length(Opcodes, Count),
                    min_list(Opcodes, Min),
                    max_list(Opcodes, Max),
                    sum_list(Opcodes, Total),
                    Avg is Total / Count,
                    findall(D, (member(O, Opcodes), D is (O - Avg) * (O - Avg)), Diffs),
                    sum_list(Diffs, SumSq),
                    StdDev is sqrt(SumSq / Count),
                    format('~5d | ~10d | ~3d | ~3d | ~3w | ~6w\n', 
                           [Prime, Count, Min, Max, Avg, StdDev])
                )
            )
        )
    ),
    
    nl.

% ═══════════════════════════════════════════════════════════
% MAIN
% ═══════════════════════════════════════════════════════════

main :-
    write('═══════════════════════════════════════════════════════════\n'),
    write('  2^N VARIATIONS PER PRIME\n'),
    write('  Better sampling guided by lattice structure\n'),
    write('═══════════════════════════════════════════════════════════\n\n'),
    
    % Test all variations
    test_all_variations,
    
    % Analyze patterns
    analyze_variations,
    
    % Generate summary
    generate_summary,
    
    write('═══════════════════════════════════════════════════════════\n'),
    write('  QED ✓\n'),
    write('═══════════════════════════════════════════════════════════\n').

emoji_prime(2, '🔴'). emoji_prime(3, '🟠'). emoji_prime(5, '🟡').
emoji_prime(7, '🟢'). emoji_prime(11, '🔵'). emoji_prime(13, '🟣').

% ?- main.
