#!/usr/bin/env swipl
% LLM Activation Lattice - Feed programs to LLM, trace activations per complexity

:- use_module(library(process)).
:- use_module(library(readutil)).
:- use_module(library(http/json)).

% Prime lattice with complexity levels
prime_complexity(2, types, 'Types and basic data').
prime_complexity(3, operators, 'Operators and expressions').
prime_complexity(5, variables, 'Variables and assignment').
prime_complexity(7, control, 'Control flow').
prime_complexity(11, functions, 'Functions and calls').
prime_complexity(13, pointers, 'Pointers and references').
prime_complexity(17, structures, 'Structures and records').
prime_complexity(19, arrays, 'Arrays and indexing').
prime_complexity(23, memory, 'Memory management').
prime_complexity(29, optimization, 'Optimization and SSA').
prime_complexity(31, output, 'Output and statements').
prime_complexity(41, machine, 'Machine code and assembly').
prime_complexity(71, universe, 'Type universe and MetaCoq').

% Gödel numbers for programs (use existing test programs)
godel_program(2, 'generated/test_2_1.c').
godel_program(3, 'generated/variations/test_3_1.c').
godel_program(5, 'generated/variations/test_5_1.c').
godel_program(7, 'generated/variations/test_7_1.c').
godel_program(11, 'generated/variations/test_11_1.c').

% LLM prompt for program analysis
llm_prompt(Program, Prompt) :-
    format(string(Prompt), 
        'Analyze this C program and describe its computational complexity, register usage, and semantic meaning:\n\n~w\n\nProvide: 1) Complexity analysis 2) Key operations 3) Register predictions', 
        [Program]).

% Call LLM via ollama
call_llm(Prompt, Response, Trace) :-
    get_time(Start),
    setup_call_cleanup(
        process_create(path(ollama), ['run', 'qwen2.5-coder:7b', Prompt],
            [stdout(pipe(Out)), stderr(pipe(Err)), process(PID)]),
        (read_string(Out, _, Response),
         read_string(Err, _, ErrMsg)),
        (close(Out), close(Err), process_wait(PID, _))
    ),
    get_time(End),
    Duration is End - Start,
    Trace = trace{start: Start, end: End, duration: Duration, stderr: ErrMsg}.

% Extract activation patterns from response
extract_activations(Response, Activations) :-
    % Count key terms related to each complexity level
    findall(Prime-Count, (
        prime_complexity(Prime, Level, _),
        atom_string(LevelAtom, Level),
        split_string(Response, " \n\t.,;:!?", "", Tokens),
        include(contains_level(LevelAtom), Tokens, Matches),
        length(Matches, Count)
    ), Activations).

contains_level(Level, Token) :-
    downcase_atom(Level, LevelLower),
    downcase_atom(Token, TokenLower),
    sub_atom(TokenLower, _, _, _, LevelLower).

% Run single program through LLM
test_program_activation(Godel, Result) :-
    format('~n🔬 Testing Gödel program ~w~n', [Godel]),
    godel_program(Godel, Path),
    (exists_file(Path) ->
        read_file_to_string(Path, Program, []),
        llm_prompt(Program, Prompt),
        format('📤 Sending to LLM (~w chars)~n', [string_length(Prompt)]),
        call_llm(Prompt, Response, Trace),
        extract_activations(Response, Activations),
        Result = result{
            godel: Godel,
            path: Path,
            trace: Trace,
            activations: Activations,
            response_length: string_length(Response),
            timestamp: Trace.start
        },
        format('✅ Completed in ~2f seconds~n', [Trace.duration]),
        format('📊 Activations: ~w~n', [Activations])
    ;
        format('❌ File not found: ~w~n', [Path]),
        fail
    ).

% Run all programs in background
test_all_activations :-
    findall(Godel, godel_program(Godel, _), Godels),
    format('~n🚀 Starting LLM activation lattice test~n'),
    format('Programs: ~w~n', [Godels]),
    get_time(StartTime),
    findall(Result, (
        member(G, Godels),
        test_program_activation(G, Result)
    ), Results),
    get_time(EndTime),
    TotalTime is EndTime - StartTime,
    
    % Save results
    format(atom(ResultFile), 'generated/llm_activations_~w.pl', [StartTime]),
    open(ResultFile, write, Stream),
    format(Stream, '%% LLM Activation Results~n', []),
    format(Stream, 'timestamp(~w).~n', [StartTime]),
    format(Stream, 'total_duration(~2f).~n', [TotalTime]),
    forall(member(R, Results), (
        format(Stream, 'result(~w, ~w, ~w, ~w).~n', 
            [R.godel, R.trace.duration, R.response_length, R.activations])
    )),
    close(Stream),
    
    % Generate activation matrix
    generate_activation_matrix(Results),
    
    format('~n✨ Complete! Total time: ~2f seconds~n', [TotalTime]),
    format('📁 Results: ~w~n', [ResultFile]).

% Generate activation matrix (Gödel × Prime)
generate_activation_matrix(Results) :-
    open('generated/activation_matrix.csv', write, Stream),
    
    % Header
    findall(Prime, prime_complexity(Prime, _, _), Primes),
    format(Stream, 'Godel,~w~n', [Primes]),
    
    % Data rows
    forall(member(Result, Results), (
        Godel = Result.godel,
        Activations = Result.activations,
        findall(Count, (
            member(Prime, Primes),
            (member(Prime-Count, Activations) -> true ; Count = 0)
        ), Counts),
        format(Stream, '~w,~w~n', [Godel, Counts])
    )),
    
    close(Stream),
    format('📊 Matrix: generated/activation_matrix.csv~n').

% Background runner with perf trace
run_background :-
    format('~n🌙 Starting background LLM activation test~n'),
    setup_call_cleanup(
        process_create(path(perf), 
            ['record', '-e', 'cycles,instructions', '-o', 'generated/perf_llm_activation.data', '--', 
             'swipl', '-g', 'test_all_activations', '-t', 'halt', 
             'llm_activation_lattice.pl'],
            [process(PID), detached(true)]),
        format('🔄 Background process: ~w~n', [PID]),
        format('📝 Perf trace: generated/perf_llm_activation.data~n')
    ).

% Main entry
main :-
    test_all_activations.

:- initialization(main, main).
