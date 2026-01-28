#!/usr/bin/env swipl
% Prolog Expert System for File Discovery
% Translates natural language queries to find/locate commands

:- use_module(library(process)).
:- use_module(library(readutil)).

% ═══════════════════════════════════════════════════════════
% QUERY TRANSLATION
% ═══════════════════════════════════════════════════════════

% Natural language → find/locate command
translate_query(Query, Command) :-
    downcase_atom(Query, Lower),
    (contains_term(Lower, parquet) ->
        Command = 'plocate -i "*.parquet"' ;
     contains_term(Lower, csv) ->
        Command = 'plocate -i "*.csv"' ;
     contains_term(Lower, large) ->
        Command = 'find /home/mdupont -name "*.parquet" -size +100M 2>/dev/null' ;
     contains_term(Lower, '3m') ->
        Command = 'plocate -i "3m" | grep -i parquet' ;
     contains_term(Lower, dataset) ->
        Command = 'plocate -i dataset | grep -E "parquet|csv"' ;
        Command = 'plocate -i "*.parquet"').

contains_term(Atom, Term) :-
    atom_string(Atom, Str),
    atom_string(Term, TermStr),
    sub_string(Str, _, _, _, TermStr).

% ═══════════════════════════════════════════════════════════
% EXECUTE QUERY
% ═══════════════════════════════════════════════════════════

execute_query(Query, Results) :-
    translate_query(Query, Command),
    format('Executing: ~w~n~n', [Command]),
    read_string(Command, _, Output),
    split_string(Output, "\n", "", Lines),
    include(not_empty, Lines, Results).

not_empty(S) :- S \= "".

% ═══════════════════════════════════════════════════════════
% DISCOVER ALL PARQUET FILES
% ═══════════════════════════════════════════════════════════

discover_all_parquets :-
    format('🔍 Discovering all parquet files...~n~n', []),
    
    % Use plocate for speed
    read_string('plocate -i "*.parquet" 2>/dev/null', _, Output),
    split_string(Output, "\n", "", Lines),
    include(not_empty, Lines, Files),
    
    length(Files, Total),
    format('Found ~w parquet files~n~n', [Total]),
    
    % Categorize by size
    open('generated/parquet_inventory.csv', write, S),
    write(S, 'path,size,category\n'),
    
    forall(member(File, Files), (
        atom_string(Path, File),
        (exists_file(Path) ->
            (size_file(Path, Size),
             categorize_size(Size, Category),
             format(S, '"~w",~w,~w~n', [Path, Size, Category])) ;
            true)
    )),
    
    close(S),
    
    format('✅ Inventory: generated/parquet_inventory.csv~n', []).

categorize_size(Size, Category) :-
    (Size > 1000000000 -> Category = 'huge' ;      % >1GB
     Size > 100000000 -> Category = 'large' ;      % >100MB
     Size > 10000000 -> Category = 'medium' ;      % >10MB
     Size > 1000000 -> Category = 'small' ;        % >1MB
     Category = 'tiny').

% ═══════════════════════════════════════════════════════════
% FIND 3M FILES PARQUET
% ═══════════════════════════════════════════════════════════

find_3m_parquet :-
    format('🔍 Searching for 3M files parquet...~n~n', []),
    
    % Search by name
    read_string('plocate -i "3m" | grep -i parquet 2>/dev/null', _, Output1),
    
    % Search by size (3M rows ≈ large file)
    read_string('plocate -i "*.parquet" | xargs -I {} sh -c "test -f {} && stat -c \"%s %n\" {}" 2>/dev/null | sort -rn | head -20', _, Output2),
    
    split_string(Output1, "\n", "", Files1),
    split_string(Output2, "\n", "", Files2),
    
    append(Files1, Files2, AllFiles),
    include(not_empty, AllFiles, Files),
    
    format('Candidates for 3M files parquet:~n~n', []),
    forall(member(F, Files), format('  ~w~n', [F])),
    
    format('~n✅ Found ~w candidates~n', [length(Files)]).

% ═══════════════════════════════════════════════════════════
% INTERACTIVE QUERY
% ═══════════════════════════════════════════════════════════

query(Q) :-
    execute_query(Q, Results),
    length(Results, N),
    format('Found ~w results:~n~n', [N]),
    forall(member(R, Results), format('  ~w~n', [R])).

% ═══════════════════════════════════════════════════════════
% MAIN
% ═══════════════════════════════════════════════════════════

main :-
    format('~n🔍 PROLOG EXPERT SYSTEM - FILE DISCOVERY~n', []),
    format('═══════════════════════════════════════════════════════════~n~n', []),
    
    discover_all_parquets,
    find_3m_parquet,
    
    format('~n✨ Discovery complete!~n', []),
    format('~nQuery examples:~n', []),
    format('  ?- query("find all parquet files").~n', []),
    format('  ?- query("large parquet files").~n', []),
    format('  ?- query("3m files dataset").~n~n', []).

:- initialization(main, main).
