% load_datafusion.pl - Load DataFusion optimizer into Prolog

:- consult('generated/merged_constants.pl').
:- consult('find_optimizers.pl').

% ═══════════════════════════════════════════════════════════
% LOAD DATAFUSION OPTIMIZER
% ═══════════════════════════════════════════════════════════

:- dynamic optimizer_function/5.  % name, file, lines, godel, cost

load_datafusion :-
    format('⚡ Loading DataFusion optimizer...~n', []),
    
    % Get optimizer files using shell
    setup_call_cleanup(
        open(pipe('plocate datafusion | grep "optimizer.*\\.rs$" | head -10'), read, S),
        read_string(S, _, Output),
        close(S)
    ),
    
    split_string(Output, "\n", " ", Lines),
    exclude(=(""), Lines, Files),
    length(Files, Count),
    format('  Found ~w files~n', [Count]),
    
    % Load each file
    forall(member(File, Files), load_rust_file(File)).

load_rust_file(File) :-
    atom_string(FileAtom, File),
    exists_file(FileAtom),
    !,
    format('  📄 ~w~n', [File]),
    
    % Count lines
    format(atom(Cmd), 'wc -l "~w" 2>/dev/null | cut -d" " -f1', [File]),
    catch(
        setup_call_cleanup(
            open(pipe(Cmd), read, S),
            (read_line_to_string(S, LinesStr), atom_number(LinesStr, Lines)),
            close(S)
        ),
        _,
        Lines = 0
    ),
    
    % Extract function names
    format(atom(GrepCmd), 'grep -n "^pub fn\\|^fn " "~w" 2>/dev/null | head -20', [File]),
    catch(
        setup_call_cleanup(
            open(pipe(GrepCmd), read, S2),
            read_string(S2, _, Output),
            close(S2)
        ),
        _,
        Output = ""
    ),
    
    split_string(Output, "\n", "", FuncLines),
    forall((member(FuncLine, FuncLines), FuncLine \= ""), 
        extract_function(FuncLine, File, Lines)).

load_rust_file(File) :-
    format('  ⚠️  Skipped: ~w~n', [File]).

extract_function(Line, File, FileLines) :-
    split_string(Line, ":", "", [LineNumStr, Code]),
    atom_number(LineNumStr, LineNum),
    
    % Extract function name
    (   sub_string(Code, _, _, _, "pub fn ") ->
        split_string(Code, " (", "", Parts),
        nth0(2, Parts, Name)
    ;   sub_string(Code, _, _, _, "fn ") ->
        split_string(Code, " (", "", Parts),
        nth0(1, Parts, Name)
    ;   Name = "unknown"
    ),
    
    % Calculate Gödel number
    atom_codes(Name, Codes),
    encode_codes(Codes, Godel),
    
    % Calculate cost (lines * position)
    Cost is FileLines * LineNum,
    
    assertz(optimizer_function(Name, File, LineNum, Godel, Cost)).

encode_codes([], 1).
encode_codes([C|Cs], G) :-
    encode_codes(Cs, G0),
    monster_primes(Primes),
    Idx is C mod 20,
    nth0(Idx, Primes, P),
    G is G0 * P.

% ═══════════════════════════════════════════════════════════
% QUERY OPTIMIZER FUNCTIONS
% ═══════════════════════════════════════════════════════════

show_functions :-
    format('~n📊 OPTIMIZER FUNCTIONS~n', []),
    format('═══════════════════════════════════════════════════════════~n', []),
    
    aggregate_all(count, optimizer_function(_, _, _, _, _), Count),
    format('  Total functions: ~w~n', [Count]),
    
    aggregate_all(sum(C), optimizer_function(_, _, _, _, C), TotalCost),
    format('  Total cost: ~w~n', [TotalCost]),
    
    format('~n🔥 Top 10 functions:~n', []),
    findall(Cost-Name-File, optimizer_function(Name, File, _, _, Cost), Funcs),
    sort(0, @>=, Funcs, Sorted),
    length(Prefix, 10),
    append(Prefix, _, Sorted),
    forall(member(C-N-F, Prefix),
        format('  ~w (~w): ~w~n', [N, C, F])).

% ═══════════════════════════════════════════════════════════
% MAIN
% ═══════════════════════════════════════════════════════════

main :-
    format('~n⚡ LOAD DATAFUSION - Query optimizer in Prolog~n', []),
    format('═══════════════════════════════════════════════════════════~n~n', []),
    
    load_datafusion,
    show_functions,
    
    format('~n✅ COMPLETE - DataFusion loaded into Prolog~n', []).
