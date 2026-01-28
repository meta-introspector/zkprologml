% count_all_indexed.pl - Count all indexed rows across all systems

:- use_module(library(csv)).

count_csv(File, Count) :-
    catch(
        (csv_read_file(File, Rows, []),
         length(Rows, Total),
         Count is Total - 1),  % Subtract header
        _,
        Count = 0
    ).

main :-
    format('🔍 Counting all indexed rows...~n~n', []),
    
    % Gödel lattice
    count_csv('generated/godel_lattice.csv', GodelCount),
    format('Gödel lattice: ~w entities~n', [GodelCount]),
    
    % Hecke shards
    count_csv('generated/hecke_shards_rust.csv', HeckeCount),
    format('Hecke shards: ~w entities~n', [HeckeCount]),
    
    % ZK RDFa URLs
    count_csv('generated/zk_rdfa_urls.csv', ZkCount),
    format('ZK RDFa URLs: ~w entities~n', [ZkCount]),
    
    % Labeled parquets
    count_csv('generated/godel_lattice.labeled.csv', L1),
    count_csv('generated/audio_features.labeled.csv', L2),
    count_csv('generated/71_shards.labeled.csv', L3),
    count_csv('generated/godel_lattice_with_urls.labeled.csv', L4),
    LabeledTotal is L1 + L2 + L3 + L4,
    format('Labeled rows: ~w rows~n', [LabeledTotal]),
    
    % Tool index
    count_csv('generated/tool_index.csv', ToolCount),
    format('Tool index: ~w tools~n', [ToolCount]),
    
    % Prime harmonics
    count_csv('generated/prime_harmonics.csv', HarmonicCount),
    format('Prime harmonics: ~w code snippets~n', [HarmonicCount]),
    
    % Total
    Total is GodelCount + HeckeCount + ZkCount + LabeledTotal + ToolCount + HarmonicCount,
    
    format('~n═══════════════════════════════════════════════════════════~n', []),
    format('TOTAL INDEXED: ~w rows~n', [Total]),
    format('═══════════════════════════════════════════════════════════~n', []),
    
    % Timing
    statistics(cputime, Time),
    format('~nCPU time: ~3f seconds~n', [Time]).
