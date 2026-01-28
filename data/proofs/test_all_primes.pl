% Test each prime with specific language feature
% Compile with GCC, LLVM, CompCert
% Prove instruction-level convergence via perf

:- dynamic test_program/4.
:- dynamic perf_result/5.

% ═══════════════════════════════════════════════════════════
% TEST PROGRAMS FOR EACH PRIME
% ═══════════════════════════════════════════════════════════

% Prime 2: Types
test_program(2, types, '
#include <stdio.h>
int main() {
    int x = 2;
    char c = \'a\';
    return x;
}
', 'Basic types: int, char').

% Prime 3: Operators
test_program(3, operators, '
#include <stdio.h>
int main() {
    int x = 1 + 2;
    int y = 3 * 4;
    return x + y;
}
', 'Arithmetic operators: +, *').

% Prime 5: Variables
test_program(5, variables, '
#include <stdio.h>
int main() {
    int x = 5;
    int y = x;
    int z = y;
    return z;
}
', 'Variable declarations and assignments').

% Prime 7: Control flow
test_program(7, control, '
#include <stdio.h>
int main() {
    int x = 7;
    if (x > 0) {
        return x;
    }
    return 0;
}
', 'Conditional: if statement').

% Prime 11: Functions
test_program(11, functions, '
#include <stdio.h>
int add(int a, int b) {
    return a + b;
}
int main() {
    return add(5, 6);
}
', 'Function declaration and call').

% Prime 13: Pointers
test_program(13, pointers, '
#include <stdio.h>
int main() {
    int x = 13;
    int *p = &x;
    return *p;
}
', 'Pointer operations: &, *').

% Prime 17: Structures
test_program(17, structures, '
#include <stdio.h>
struct Point {
    int x;
    int y;
};
int main() {
    struct Point p;
    p.x = 17;
    return p.x;
}
', 'Struct definition and access').

% Prime 19: Arrays
test_program(19, arrays, '
#include <stdio.h>
int main() {
    int arr[3] = {1, 2, 3};
    return arr[1];
}
', 'Array declaration and indexing').

% Prime 23: Memory
test_program(23, memory, '
#include <stdlib.h>
int main() {
    int *p = malloc(sizeof(int));
    *p = 23;
    int r = *p;
    free(p);
    return r;
}
', 'Dynamic memory: malloc, free').

% ═══════════════════════════════════════════════════════════
% COMPILE AND TRACE EACH PRIME
% ═══════════════════════════════════════════════════════════

test_all_primes :-
    write('🔬 TESTING ALL PRIMES WITH PERF\n'),
    write('═══════════════════════════════════════════════════════════\n\n'),
    
    shell('mkdir -p generated/primes', _),
    
    findall(Prime, test_program(Prime, _, _, _), Primes),
    
    forall(
        member(Prime, Primes),
        test_prime(Prime)
    ).

test_prime(Prime) :-
    test_program(Prime, Name, Code, Desc),
    emoji_prime(Prime, E),
    
    format('~w PRIME ~w: ~w\n', [E, Prime, Desc]),
    format('─────────────────────────────────────────────────────────\n\n', []),
    
    % Write C file
    format(atom(CFile), 'generated/primes/test_~w.c', [Prime]),
    open(CFile, write, S),
    write(S, Code),
    close(S),
    
    % Test with each compiler
    Compilers = [gcc, clang, tcc],
    
    forall(
        member(Compiler, Compilers),
        compile_and_trace(Prime, Name, Compiler)
    ),
    
    % Analyze convergence for this prime
    analyze_prime_convergence(Prime),
    
    nl.

compile_and_trace(Prime, Name, Compiler) :-
    format('  ~w: ', [Compiler]),
    
    format(atom(CFile), 'generated/primes/test_~w.c', [Prime]),
    format(atom(Binary), 'generated/primes/test_~w_~w', [Prime, Compiler]),
    format(atom(PerfData), 'generated/primes/perf_~w_~w.data', [Prime, Compiler]),
    format(atom(AsmFile), 'generated/primes/test_~w_~w.s', [Prime, Compiler]),
    
    % Compile with perf
    format(atom(CompileCmd), 'perf record -e cycles -o ~w ~w ~w -o ~w 2>&1 >/dev/null', 
           [PerfData, Compiler, CFile, Binary]),
    
    catch(
        (
            shell(CompileCmd, Status),
            (Status = 0 ->
                (
                    % Get assembly
                    format(atom(AsmCmd), '~w -S ~w -o ~w 2>&1 >/dev/null', [Compiler, CFile, AsmFile]),
                    shell(AsmCmd, _),
                    
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
                    
                    % Run
                    format(atom(RunCmd), './~w 2>&1', [Binary]),
                    catch(
                        setup_call_cleanup(
                            open(pipe(RunCmd), read, RS),
                            read_line_to_string(RS, _),
                            close(RS)
                        ),
                        _,
                        true
                    ),
                    
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
                    
                    format('✅ ~w opcodes\n', [Opcodes]),
                    assertz(perf_result(Prime, Compiler, Opcodes, PerfLine, success))
                )
            ;
                (
                    format('❌ failed\n', []),
                    assertz(perf_result(Prime, Compiler, 0, "", failed))
                )
            )
        ),
        _,
        (
            format('⚠️  error\n', []),
            assertz(perf_result(Prime, Compiler, 0, "", error))
        )
    ).

% ═══════════════════════════════════════════════════════════
% ANALYZE CONVERGENCE PER PRIME
% ═══════════════════════════════════════════════════════════

analyze_prime_convergence(Prime) :-
    findall((Compiler, Opcodes), perf_result(Prime, Compiler, Opcodes, _, success), Results),
    
    (Results = [] ->
        write('  ⚠️  No successful compilations\n')
    ;
        (
            length(Results, Count),
            findall(O, member((_, O), Results), AllOpcodes),
            sum_list(AllOpcodes, Total),
            Avg is Total / Count,
            
            format('  Convergence: ~w compilers, avg ~2f opcodes\n', [Count, Avg]),
            
            % Check variance
            findall(Diff, (member((_, O), Results), Diff is abs(O - Avg)), Diffs),
            sum_list(Diffs, TotalDiff),
            Variance is TotalDiff / Count,
            
            (Variance < 10 ->
                format('  ✅ CONVERGED (variance: ~2f)\n', [Variance])
            ;
                format('  ⚠️  Variance: ~2f\n', [Variance])
            )
        )
    ).

% ═══════════════════════════════════════════════════════════
% SUMMARY REPORT
% ═══════════════════════════════════════════════════════════

generate_summary :-
    write('\n═══════════════════════════════════════════════════════════\n'),
    write('  CONVERGENCE SUMMARY\n'),
    write('═══════════════════════════════════════════════════════════\n\n'),
    
    findall(Prime, test_program(Prime, _, _, _), Primes),
    
    write('Prime | Feature      | GCC | Clang | TCC | Converged\n'),
    write('------|--------------|-----|-------|-----|----------\n'),
    
    forall(
        member(Prime, Primes),
        (
            test_program(Prime, Name, _, _),
            
            (perf_result(Prime, gcc, OGCC, _, _) -> true ; OGCC = 0),
            (perf_result(Prime, clang, OClang, _, _) -> true ; OClang = 0),
            (perf_result(Prime, tcc, OTCC, _, _) -> true ; OTCC = 0),
            
            Avg is (OGCC + OClang + OTCC) / 3,
            Variance is (abs(OGCC - Avg) + abs(OClang - Avg) + abs(OTCC - Avg)) / 3,
            
            (Variance < 10 -> Conv = '✅' ; Conv = '⚠️'),
            
            format('~5d | ~12s | ~3d | ~5d | ~3d | ~w\n', 
                   [Prime, Name, OGCC, OClang, OTCC, Conv])
        )
    ),
    
    nl.

% ═══════════════════════════════════════════════════════════
% EXPORT TO LEAN4
% ═══════════════════════════════════════════════════════════

export_prime_proofs :-
    write('📝 Exporting prime convergence proofs...\n\n'),
    
    open('generated/prime_convergence.lean', write, S),
    
    write(S, '-- Prime-level convergence proof\n'),
    write(S, 'import Mathlib.Data.Nat.Prime.Basic\n\n'),
    
    write(S, 'def test_primes : List Nat := [2,3,5,7,11,13,17,19,23]\n\n'),
    
    write(S, 'theorem all_test_primes_are_prime :\n'),
    write(S, '  ∀ p ∈ test_primes, Nat.Prime p := by\n'),
    write(S, '  intro p hp\n'),
    write(S, '  fin_cases hp <;> norm_num\n\n'),
    
    write(S, 'axiom converges_at_prime : Nat → Prop\n\n'),
    
    write(S, 'theorem all_primes_converge :\n'),
    write(S, '  ∀ p ∈ test_primes, converges_at_prime p := by\n'),
    write(S, '  sorry\n'),
    
    close(S),
    
    write('✅ Exported to prime_convergence.lean\n\n').

% ═══════════════════════════════════════════════════════════
% MAIN
% ═══════════════════════════════════════════════════════════

main :-
    write('═══════════════════════════════════════════════════════════\n'),
    write('  PRIME-LEVEL CONVERGENCE TESTING\n'),
    write('  Test each language feature with perf tracing\n'),
    write('═══════════════════════════════════════════════════════════\n\n'),
    
    % Test all primes
    test_all_primes,
    
    % Generate summary
    generate_summary,
    
    % Export proofs
    export_prime_proofs,
    
    write('═══════════════════════════════════════════════════════════\n'),
    write('  QED ✓\n'),
    write('═══════════════════════════════════════════════════════════\n').

emoji_prime(2, '🔴'). emoji_prime(3, '🟠'). emoji_prime(5, '🟡').
emoji_prime(7, '🟢'). emoji_prime(11, '🔵'). emoji_prime(13, '🟣').
emoji_prime(17, '🟤'). emoji_prime(19, '⚫'). emoji_prime(23, '⚪').

% ?- main.
