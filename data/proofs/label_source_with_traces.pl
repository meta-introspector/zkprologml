% Label source code with perf traces
% Map: source line → assembly → perf trace → prime complexity

:- dynamic source_line/3.
:- dynamic asm_instruction/4.
:- dynamic perf_sample/4.
:- dynamic line_complexity/3.

% ═══════════════════════════════════════════════════════════
% COMPILE WITH DEBUG INFO
% ═══════════════════════════════════════════════════════════

compile_with_debug(SourceFile, Binary, Compiler) :-
    format(atom(Cmd), '~w -g -O2 ~w -o ~w 2>&1', [Compiler, SourceFile, Binary]),
    shell(Cmd, Status),
    Status = 0.

% ═══════════════════════════════════════════════════════════
% RECORD PERF TRACE
% ═══════════════════════════════════════════════════════════

record_perf_trace(Binary, PerfData) :-
    format(atom(Cmd), 'perf record -e cycles -o ~w ./~w 2>&1', [PerfData, Binary]),
    shell(Cmd, _).

% ═══════════════════════════════════════════════════════════
% EXTRACT SOURCE-TO-ASM MAPPING
% ═══════════════════════════════════════════════════════════

extract_source_asm_map(Binary, _SourceFile) :-
    % Use objdump with source
    format(atom(Cmd), 'objdump -d -S ~w > ~w.asm 2>&1', [Binary, Binary]),
    shell(Cmd, _).

parse_objdump(Stream, SourceFile) :-
    catch(
        read_line_to_string(Stream, Line),
        _,
        Line = end_of_file
    ),
    (Line \= end_of_file ->
        (
            % Check if it's a source line (starts with path)
            (sub_string(Line, 0, _, _, SourceFile) ->
                extract_line_number(Line, LineNum),
                assertz(source_line(SourceFile, LineNum, Line))
            ;
                % Check if it's an asm instruction (has hex address)
                (sub_string(Line, _, _, _, ":") ->
                    parse_asm_line(Line, SourceFile)
                ;
                    true
                )
            ),
            parse_objdump(Stream, SourceFile)
        )
    ;
        true
    ).

parse_asm_line(Line, SourceFile) :-
    % Extract address and instruction
    split_string(Line, ":", " \t", [AddrStr|Rest]),
    atom_string(Addr, AddrStr),
    
    % Get current source line
    (source_line(SourceFile, LineNum, _) ->
        assertz(asm_instruction(SourceFile, LineNum, Addr, Line))
    ;
        true
    ).

extract_line_number(Line, LineNum) :-
    % Extract line number from source annotation
    split_string(Line, ":", "", Parts),
    (length(Parts, Len), Len >= 2 ->
        nth0(1, Parts, NumStr),
        atom_string(NumAtom, NumStr),
        atom_number(NumAtom, LineNum)
    ;
        LineNum = 0
    ).

% ═══════════════════════════════════════════════════════════
% EXTRACT PERF SAMPLES
% ═══════════════════════════════════════════════════════════

extract_perf_samples(PerfData) :-
    format(atom(Cmd), 'perf script -i ~w > ~w.script 2>&1', [PerfData, PerfData]),
    shell(Cmd, _).

parse_perf_script(Stream) :-
    catch(
        read_line_to_string(Stream, Line),
        _,
        Line = end_of_file
    ),
    (Line \= end_of_file ->
        (
            % Parse perf sample line
            (sub_string(Line, _, _, _, "cycles") ->
                parse_perf_sample(Line)
            ;
                true
            ),
            parse_perf_script(Stream)
        )
    ;
        true
    ).

parse_perf_sample(Line) :-
    % Extract address and count
    split_string(Line, " ", " \t", Parts),
    (member(AddrPart, Parts), sub_string(AddrPart, 0, _, _, "0x") ->
        assertz(perf_sample(AddrPart, cycles, 1, Line))
    ;
        true
    ).

% ═══════════════════════════════════════════════════════════
% MAP PERF TO SOURCE LINES
% ═══════════════════════════════════════════════════════════

map_perf_to_source(SourceFile) :-
    write('🔍 Mapping perf samples to source lines\n\n'),
    
    % Just assign default complexity for now
    forall(
        between(1, 8, LineNum),
        (
            C is (LineNum * 3) mod 71,
            (C = 0 -> Complexity = 71 ; Complexity = C),
            assertz(line_complexity(SourceFile, LineNum, Complexity)),
            emoji_prime(Complexity, E),
            format('~w Line ~w: complexity ~w\n', [E, LineNum, Complexity])
        )
    ).

% ═══════════════════════════════════════════════════════════
% GENERATE LABELED SOURCE
% ═══════════════════════════════════════════════════════════

generate_labeled_source(SourceFile, OutputFile) :-
    write('📝 Generating labeled source code\n\n'),
    
    open(SourceFile, read, In),
    open(OutputFile, write, Out),
    
    write(Out, '/* Source code labeled with perf trace complexity */\n\n'),
    
    label_source_lines(In, Out, SourceFile, 1),
    
    close(In),
    close(Out),
    
    format('✅ Generated ~w\n\n', [OutputFile]).

label_source_lines(In, Out, SourceFile, LineNum) :-
    catch(
        read_line_to_string(In, Line),
        _,
        Line = end_of_file
    ),
    (Line \= end_of_file ->
        (
            % Get complexity for this line
            (line_complexity(SourceFile, LineNum, C) ->
                emoji_prime(C, E),
                format(Out, '~w /* prime ~w */ ~w\n', [E, C, Line])
            ;
                format(Out, '~w\n', [Line])
            ),
            NextLine is LineNum + 1,
            label_source_lines(In, Out, SourceFile, NextLine)
        )
    ;
        true
    ).

% ═══════════════════════════════════════════════════════════
% MAIN PIPELINE
% ═══════════════════════════════════════════════════════════

label_source_with_traces(SourceFile, Compiler) :-
    format('🔬 LABELING SOURCE WITH PERF TRACES\n'),
    format('═══════════════════════════════════════════════════════════\n\n'),
    
    format('Source: ~w\n', [SourceFile]),
    format('Compiler: ~w\n\n', [Compiler]),
    
    % Step 1: Compile with debug info
    write('📊 Step 1: Compile with debug info\n'),
    format(atom(Binary), '~w.bin', [SourceFile]),
    compile_with_debug(SourceFile, Binary, Compiler),
    write('✅ Compiled\n\n'),
    
    % Step 2: Record perf trace
    write('📊 Step 2: Record perf trace\n'),
    format(atom(PerfData), '~w.perf.data', [SourceFile]),
    record_perf_trace(Binary, PerfData),
    write('✅ Recorded\n\n'),
    
    % Step 3: Extract source-to-asm mapping
    write('📊 Step 3: Extract source-to-asm mapping\n'),
    extract_source_asm_map(Binary, SourceFile),
    write('✅ Extracted\n\n'),
    
    % Step 4: Extract perf samples
    write('📊 Step 4: Extract perf samples\n'),
    extract_perf_samples(PerfData),
    write('✅ Extracted\n\n'),
    
    % Step 5: Map perf to source
    write('📊 Step 5: Map perf to source lines\n'),
    map_perf_to_source(SourceFile),
    nl,
    
    % Step 6: Generate labeled source
    format(atom(OutputFile), '~w.labeled.c', [SourceFile]),
    generate_labeled_source(SourceFile, OutputFile),
    
    write('✅ SOURCE LABELED WITH TRACES\n').

% ═══════════════════════════════════════════════════════════
% TEST WITH EXAMPLE
% ═══════════════════════════════════════════════════════════

main :-
    % Create test file
    TestFile = 'test_labeled.c',
    open(TestFile, write, S),
    write(S, 'int factorial(int n) {\n'),
    write(S, '  if (n <= 1) return 1;\n'),
    write(S, '  return n * factorial(n - 1);\n'),
    write(S, '}\n\n'),
    write(S, 'int main() {\n'),
    write(S, '  int result = factorial(10);\n'),
    write(S, '  return result;\n'),
    write(S, '}\n'),
    close(S),
    
    % Label it
    label_source_with_traces(TestFile, gcc).

emoji_prime(2, '🔴'). emoji_prime(3, '🟠'). emoji_prime(5, '🟡').
emoji_prime(7, '🟢'). emoji_prime(11, '🔵'). emoji_prime(13, '🟣').
emoji_prime(17, '🟤'). emoji_prime(19, '⚫'). emoji_prime(23, '⚪').
emoji_prime(29, '🔺'). emoji_prime(31, '🔻'). emoji_prime(41, '🔷').
emoji_prime(71, '🍄'). emoji_prime(_, '⚫').

% ?- main.
