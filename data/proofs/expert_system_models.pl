% Expert System - Sample parquets, build models per concept
% For each concept: sample data → evaluate → build model

:- dynamic concept/1.
:- dynamic sample/3.
:- dynamic model/3.
:- dynamic evaluation/4.

% ═══════════════════════════════════════════════════════════
% CONCEPTS (from parquet names)
% ═══════════════════════════════════════════════════════════

concept(monster).
concept(godel).
concept(kurt).
concept(umberto).
concept(athena).
concept(urania).
concept(platonic).
concept(pnm_lattice).
concept(keywords).

% ═══════════════════════════════════════════════════════════
% SAMPLE DATA from Parquet
% ═══════════════════════════════════════════════════════════

sample_parquet(Concept) :-
    format('📊 Sampling ~w parquet...~n', [Concept]),
    
    % Call Rust to sample parquet
    format(atom(ParquetFile), 'data/parquets/~w_search.parquet', [Concept]),
    format(atom(Cmd), 'cargo run --bin sample_parquet -- ~w 100', [ParquetFile]),
    shell(Cmd, _),
    
    % Read sample results
    format(atom(SampleFile), 'sample_~w.txt', [Concept]),
    (exists_file(SampleFile) ->
        read_file_to_string(SampleFile, Data, []),
        split_string(Data, "\n", "", Lines),
        length(Lines, Count),
        assertz(sample(Concept, Count, Lines))
    ;
        assertz(sample(Concept, 0, []))
    ),
    
    format('✅ Sampled ~w: ~w rows~n', [Concept, Count]).

% ═══════════════════════════════════════════════════════════
% EVALUATE with Expert System Rules
% ═══════════════════════════════════════════════════════════

evaluate_concept(Concept) :-
    sample(Concept, Count, Lines),
    format('🔬 Evaluating ~w (~w samples)...~n', [Concept, Count]),
    
    % Expert system rules
    (Count > 50 -> Confidence = high ; Confidence = low),
    
    % Analyze patterns
    analyze_patterns(Lines, Patterns),
    
    % Complexity score
    complexity_score(Concept, Lines, Score),
    
    assertz(evaluation(Concept, Confidence, Patterns, Score)),
    format('✅ Evaluated ~w: confidence=~w, score=~w~n', [Concept, Confidence, Score]).

analyze_patterns(Lines, Patterns) :-
    length(Lines, Total),
    include(contains_rust, Lines, RustLines),
    length(RustLines, RustCount),
    include(contains_prolog, Lines, PrologLines),
    length(PrologLines, PrologCount),
    Patterns = [rust(RustCount), prolog(PrologCount), total(Total)].

contains_rust(Line) :- sub_string(Line, _, _, _, ".rs").
contains_prolog(Line) :- sub_string(Line, _, _, _, ".pl").

complexity_score(Concept, Lines, Score) :-
    length(Lines, N),
    atom_length(Concept, L),
    Score is N * L.

% ═══════════════════════════════════════════════════════════
% BUILD MODEL
% ═══════════════════════════════════════════════════════════

build_model(Concept) :-
    evaluation(Concept, Confidence, Patterns, Score),
    format('🏗️  Building model for ~w...~n', [Concept]),
    
    % Model structure: concept → features → prediction
    Model = model(
        concept(Concept),
        features([
            confidence(Confidence),
            patterns(Patterns),
            complexity(Score)
        ]),
        prediction(prime_complexity(Score))
    ),
    
    assertz(model(Concept, Model, Score)),
    
    % Export model to Lean4
    export_model_lean(Concept, Model),
    
    format('✅ Built model for ~w~n', [Concept]).

% ═══════════════════════════════════════════════════════════
% EXPORT MODEL to Lean4
% ═══════════════════════════════════════════════════════════

export_model_lean(Concept, Model) :-
    format(atom(File), 'data/proofs/model_~w.lean', [Concept]),
    open(File, write, Stream),
    
    format(Stream, '-- Expert system model: ~w~n', [Concept]),
    format(Stream, 'structure Model_~w where~n', [Concept]),
    format(Stream, '  concept : String~n', []),
    format(Stream, '  confidence : String~n', []),
    format(Stream, '  complexity : Nat~n~n', []),
    
    model(Concept, _, Score),
    evaluation(Concept, Confidence, _, _),
    
    format(Stream, 'def model_~w : Model_~w := {~n', [Concept, Concept]),
    format(Stream, '  concept := "~w",~n', [Concept]),
    format(Stream, '  confidence := "~w",~n', [Confidence]),
    format(Stream, '  complexity := ~w~n', [Score]),
    format(Stream, '}~n', []),
    
    close(Stream),
    format('📝 Exported: ~w~n', [File]).

% ═══════════════════════════════════════════════════════════
% PIPELINE: Sample → Evaluate → Model
% ═══════════════════════════════════════════════════════════

process_concept(Concept) :-
    sample_parquet(Concept),
    evaluate_concept(Concept),
    build_model(Concept).

process_all_concepts :-
    findall(C, concept(C), Concepts),
    format('🎯 Processing ~w concepts~n~n', [Concepts]),
    maplist(process_concept, Concepts).

% ═══════════════════════════════════════════════════════════
% MAIN
% ═══════════════════════════════════════════════════════════

main :-
    write('🧠 EXPERT SYSTEM - CONCEPT MODELING'), nl,
    write('═══════════════════════════════════════════════════════════'), nl,
    nl,
    
    process_all_concepts,
    
    nl,
    write('✅ ALL MODELS BUILT'), nl,
    
    % Show results
    findall([C, S], model(C, _, S), Models),
    format('~n🎯 Models: ~w~n', [Models]).

% ?- main.
