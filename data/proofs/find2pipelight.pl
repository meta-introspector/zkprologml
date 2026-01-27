% Find2Pipelight - Convert plocate results to pipelight pipelines
% Use plocate to find files, generate parquets, create pipelines

:- dynamic plocate_result/3.
:- dynamic parquet_generated/2.
:- dynamic pipeline_created/2.

% ═══════════════════════════════════════════════════════════
% PLOCATE → PARQUET
% ═══════════════════════════════════════════════════════════

plocate_to_parquet(Term) :-
    format('🔍 Running plocate for: ~w~n', [Term]),
    
    % Run Rust plocate_to_parquet
    format(atom(Cmd), 'cargo run --manifest-path Cargo_plocate.toml -- ~w', [Term]),
    shell(Cmd, Result),
    
    format(atom(ParquetFile), 'plocate_~w.parquet', [Term]),
    assertz(parquet_generated(Term, ParquetFile)),
    
    format('✅ Generated: ~w~n', [ParquetFile]).

% ═══════════════════════════════════════════════════════════
% PARQUET → PIPELIGHT
% ═══════════════════════════════════════════════════════════

parquet_to_pipelight(Term) :-
    parquet_generated(Term, ParquetFile),
    format('📝 Creating pipelight pipeline for: ~w~n', [Term]),
    
    % Generate pipelight config
    format(atom(PipeFile), 'pipelight_~w.toml', [Term]),
    open(PipeFile, write, Stream),
    
    format(Stream, '[[pipelines]]~n', []),
    format(Stream, 'name = "process_~w"~n', [Term]),
    format(Stream, 'description = "Process ~w from plocate"~n~n', [Term]),
    
    format(Stream, '[[pipelines.steps]]~n', []),
    format(Stream, 'name = "load_parquet"~n', []),
    format(Stream, 'commands = [~n', []),
    format(Stream, '  "echo Loading ~w...",~n', [ParquetFile]),
    format(Stream, '  "cargo run --bin prove_lattice_indexes ~w"~n', [ParquetFile]),
    format(Stream, ']~n~n', []),
    
    format(Stream, '[[pipelines.steps]]~n', []),
    format(Stream, 'name = "prove_novelty"~n', []),
    format(Stream, 'commands = [~n', []),
    format(Stream, '  "swipl -g main -t halt data/proofs/perf_novelty_proof.pl"~n', []),
    format(Stream, ']~n', []),
    
    close(Stream),
    
    assertz(pipeline_created(Term, PipeFile)),
    format('✅ Created: ~w~n', [PipeFile]).

% ═══════════════════════════════════════════════════════════
% FIND2PIPELIGHT PIPELINE
% ═══════════════════════════════════════════════════════════

find2pipelight(Terms) :-
    format('🚀 FIND2PIPELIGHT: ~w terms~n~n', [Terms]),
    
    % Process each term
    maplist(process_term, Terms),
    
    % Combine all pipelines
    combine_pipelines(Terms).

process_term(Term) :-
    plocate_to_parquet(Term),
    parquet_to_pipelight(Term).

combine_pipelines(Terms) :-
    format('🔗 Combining ~w pipelines...~n', [Terms]),
    
    open('pipelight_combined.toml', write, Stream),
    
    format(Stream, '# Combined pipelight pipelines from find2pipelight~n~n', []),
    
    % Write each pipeline
    forall(
        pipeline_created(Term, PipeFile),
        (
            open(PipeFile, read, In),
            copy_stream_data(In, Stream),
            close(In),
            format(Stream, '~n', [])
        )
    ),
    
    close(Stream),
    
    format('✅ Combined pipeline: pipelight_combined.toml~n', []).

% ═══════════════════════════════════════════════════════════
% MAIN
% ═══════════════════════════════════════════════════════════

main :-
    write('🔍 FIND2PIPELIGHT'), nl,
    write('═══════════════════════════════════════════════════════════'), nl,
    nl,
    
    % Terms to search
    Terms = [github, search, index, crawler, scraper, prolog, rust, parquet],
    
    find2pipelight(Terms),
    
    nl,
    write('✅ FIND2PIPELIGHT COMPLETE'), nl,
    
    % Show results
    findall(P, parquet_generated(_, P), Parquets),
    length(Parquets, Count),
    format('~n🎯 Generated ~w parquets~n', [Count]).

% ?- main.
