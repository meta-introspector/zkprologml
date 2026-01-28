% audit_constants.pl - Audit ALL hardcoded data in current directory

:- use_module(library(process)).

% ═══════════════════════════════════════════════════════════
% EXTRACT CONSTANTS FROM CODE
% ═══════════════════════════════════════════════════════════

:- dynamic constant_data/4.  % file, type, name, value

% Extract Rust constants
extract_rust_constants(File) :-
    format(atom(Cmd), 'grep -n "^const " ~w 2>/dev/null', [File]),
    catch(
        setup_call_cleanup(
            open(pipe(Cmd), read, S),
            (
                read_string(S, _, Content),
                split_string(Content, "\n", "", Lines),
                forall(member(Line, Lines), (
                    Line \= "",
                    split_string(Line, ":", "", [LineNum, Code]),
                    assertz(constant_data(File, rust_const, LineNum, Code))
                ))
            ),
            close(S)
        ),
        _,
        true
    ).

% Extract Prolog facts (hardcoded data)
extract_prolog_facts(File) :-
    format(atom(Cmd), 'grep -n "^[a-z_]*(" ~w 2>/dev/null | grep -v ":-" | head -100', [File]),
    catch(
        setup_call_cleanup(
            open(pipe(Cmd), read, S),
            (
                read_string(S, _, Content),
                split_string(Content, "\n", "", Lines),
                forall(member(Line, Lines), (
                    Line \= "",
                    split_string(Line, ":", "", [LineNum, Code]),
                    assertz(constant_data(File, prolog_fact, LineNum, Code))
                ))
            ),
            close(S)
        ),
        _,
        true
    ).

% Extract Lean4 defs (constants)
extract_lean_constants(File) :-
    format(atom(Cmd), 'grep -n "^def.*:=.*[0-9]" ~w 2>/dev/null', [File]),
    catch(
        setup_call_cleanup(
            open(pipe(Cmd), read, S),
            (
                read_string(S, _, Content),
                split_string(Content, "\n", "", Lines),
                forall(member(Line, Lines), (
                    Line \= "",
                    split_string(Line, ":", "", [LineNum, Code]),
                    assertz(constant_data(File, lean_const, LineNum, Code))
                ))
            ),
            close(S)
        ),
        _,
        true
    ).

% ═══════════════════════════════════════════════════════════
% AUDIT ALL FILES
% ═══════════════════════════════════════════════════════════

audit_directory :-
    format('🔍 Auditing current directory for constants...~n~n', []),
    
    % Find all code files
    setup_call_cleanup(
        open(pipe('find . -name "*.rs" -o -name "*.pl" -o -name "*.lean" | head -1000'), read, S),
        read_string(S, _, Output),
        close(S)
    ),
    split_string(Output, "\n", " ", Lines),
    exclude(=(""), Lines, FileLines),
    maplist(atom_string, Files, FileLines),
    length(Files, FileCount),
    format('Found ~w code files~n~n', [FileCount]),
    
    % Extract constants from each
    forall(member(File, Files), (
        (   sub_atom(File, _, _, _, '.rs') -> extract_rust_constants(File)
        ;   sub_atom(File, _, _, _, '.pl') -> extract_prolog_facts(File)
        ;   sub_atom(File, _, _, _, '.lean') -> extract_lean_constants(File)
        ;   true
        )
    )).

% ═══════════════════════════════════════════════════════════
% FIND DUPLICATES
% ═══════════════════════════════════════════════════════════

find_duplicates(Duplicates) :-
    findall(Value-Files, (
        constant_data(_, _, _, Value),
        findall(F, constant_data(F, _, _, Value), Files),
        length(Files, Count),
        Count > 1
    ), Pairs),
    list_to_set(Pairs, Duplicates).

% ═══════════════════════════════════════════════════════════
% MERGE CONSTANTS
% ═══════════════════════════════════════════════════════════

merge_all_constants :-
    format('~n🔧 Merging all constants...~n', []),
    
    findall(constant(F, T, L, V), constant_data(F, T, L, V), Constants),
    length(Constants, Count),
    format('  Total constants: ~w~n', [Count]),
    
    % Group by value to find duplicates
    find_duplicates(Dups),
    length(Dups, DupCount),
    format('  Duplicates: ~w~n', [DupCount]),
    
    % Save all constants
    open('generated/all_constants.csv', write, S),
    write(S, 'file,type,line,value\n'),
    forall(constant_data(F, T, L, V), 
        format(S, '~w,~w,~w,~q~n', [F, T, L, V])),
    close(S),
    format('  ✅ Saved to generated/all_constants.csv~n', []),
    
    % Save deduplicated
    findall(V, constant_data(_, _, _, V), AllValues),
    list_to_set(AllValues, UniqueValues),
    length(UniqueValues, UniqueCount),
    
    open('generated/unique_constants.pl', write, S2),
    write(S2, '% Deduplicated constants from all files\n\n'),
    forall(member(Val, UniqueValues),
        format(S2, 'unique_constant(~q).~n', [Val])),
    close(S2),
    format('  ✅ Saved ~w unique constants to generated/unique_constants.pl~n', [UniqueCount]).

% ═══════════════════════════════════════════════════════════
% STATISTICS
% ═══════════════════════════════════════════════════════════

show_stats :-
    format('~n📊 AUDIT STATISTICS~n', []),
    format('═══════════════════════════════════════════════════════════~n', []),
    
    aggregate_all(count, constant_data(_, _, _, _), Total),
    format('  Total constants: ~w~n', [Total]),
    
    aggregate_all(count, constant_data(_, rust_const, _, _), RustCount),
    format('  Rust constants: ~w~n', [RustCount]),
    
    aggregate_all(count, constant_data(_, prolog_fact, _, _), PrologCount),
    format('  Prolog facts: ~w~n', [PrologCount]),
    
    aggregate_all(count, constant_data(_, lean_const, _, _), LeanCount),
    format('  Lean4 constants: ~w~n', [LeanCount]),
    
    find_duplicates(Dups),
    length(Dups, DupCount),
    format('  Duplicate values: ~w~n', [DupCount]),
    
    findall(V, constant_data(_, _, _, V), AllValues),
    list_to_set(AllValues, UniqueValues),
    length(UniqueValues, UniqueCount),
    Savings is Total - UniqueCount,
    format('  Unique values: ~w~n', [UniqueCount]),
    format('  Savings: ~w (~2f%)~n', [Savings, Savings * 100.0 / Total]).

% ═══════════════════════════════════════════════════════════
% MAIN
% ═══════════════════════════════════════════════════════════

main :-
    format('~n🧹 AUDIT: Remove duplicate hardcoded data~n', []),
    format('═══════════════════════════════════════════════════════════~n~n', []),
    
    audit_directory,
    merge_all_constants,
    show_stats,
    
    format('~n✅ AUDIT COMPLETE~n', []),
    format('~nNext: Replace duplicates with references to unique_constants.pl~n', []).
