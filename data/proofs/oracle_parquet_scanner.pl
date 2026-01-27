% Start in Prolog - Use Oracle to scan filesystem
% plocate for large parquet files, index by name

:- dynamic parquet_file/3.
:- dynamic parquet_indexed/1.

% ═══════════════════════════════════════════════════════════
% PART 1: Oracle Scan for Parquet Files
% ═══════════════════════════════════════════════════════════

oracle_scan_parquets :-
    write('🔍 Oracle scanning for parquet files...'), nl,
    
    % Use plocate to find parquet files
    shell('plocate -l 100 .parquet', Output),
    
    % Parse output
    split_string(Output, "\n", "\n", Lines),
    
    % Process each file
    maplist(process_parquet_line, Lines),
    
    % Count
    findall(F, parquet_file(F, _, _), Files),
    length(Files, Count),
    format('✅ Found ~w parquet files~n', [Count]).

process_parquet_line(Line) :-
    string(Line),
    Line \= "",
    
    % Get file size via oracle
    format(atom(SizeCmd), 'stat -c %s "~w" 2>/dev/null', [Line]),
    shell(SizeCmd, SizeOutput),
    atom_number(SizeOutput, Size),
    
    % Extract name
    split_string(Line, "/", "", Parts),
    last(Parts, NameStr),
    atom_string(Name, NameStr),
    
    % Store
    assertz(parquet_file(Line, Name, Size)),
    
    format('  ~w (~w bytes)~n', [Name, Size]).

process_parquet_line(_).

% ═══════════════════════════════════════════════════════════
% PART 2: Index by Name
% ═══════════════════════════════════════════════════════════

index_parquets_by_name :-
    write('📇 Indexing parquets by name...'), nl,
    
    findall(Name-Path-Size, parquet_file(Path, Name, Size), Entries),
    
    % Sort by size (largest first)
    sort(3, @>=, Entries, Sorted),
    
    % Display index
    forall(member(N-P-S, Sorted),
           format('  ~w: ~w (~w bytes)~n', [N, P, S])),
    
    assertz(parquet_indexed(true)),
    write('✅ Indexed'), nl.

% ═══════════════════════════════════════════════════════════
% PART 3: Query Index
% ═══════════════════════════════════════════════════════════

% Find largest parquets
largest_parquets(N, Files) :-
    findall(Size-Name-Path, parquet_file(Path, Name, Size), All),
    sort(1, @>=, All, Sorted),
    take_n(N, Sorted, Files).

take_n(0, _, []) :- !.
take_n(_, [], []) :- !.
take_n(N, [H|T], [H|Rest]) :-
    N1 is N - 1,
    take_n(N1, T, Rest).

% Find by name pattern
find_parquet_by_name(Pattern, Files) :-
    findall(Name-Path-Size,
            (parquet_file(Path, Name, Size),
             sub_atom(Name, _, _, _, Pattern)),
            Files).

% ═══════════════════════════════════════════════════════════
% MAIN
% ═══════════════════════════════════════════════════════════

main :-
    write('🍄 ORACLE PARQUET SCANNER'), nl,
    write('═══════════════════════════════════════════════════════════'), nl,
    nl,
    
    oracle_scan_parquets,
    nl,
    
    index_parquets_by_name,
    nl,
    
    write('═══════════════════════════════════════════════════════════'), nl,
    write('Top 10 largest parquets:'), nl,
    write('═══════════════════════════════════════════════════════════'), nl,
    largest_parquets(10, Top),
    forall(member(Size-Name-Path, Top),
           format('~w MB: ~w~n  ~w~n', [Size/1048576, Name, Path])),
    nl,
    
    write('✅ Ready to consume!'), nl.

% ?- main.
% ?- largest_parquets(10, Files).
% ?- find_parquet_by_name(github, Files).
