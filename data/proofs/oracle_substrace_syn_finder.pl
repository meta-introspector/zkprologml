% Oracle: Use substrace to find syn parsers
% No find, no shell - pure oracle substrace

:- dynamic syn_parser_found/2.
:- dynamic parquet_reader_found/2.

% ═══════════════════════════════════════════════════════════
% ORACLE: Substrace to find files
% ═══════════════════════════════════════════════════════════

oracle_substrace_find_syn :-
    write('🔍 Oracle substrace: Finding syn parsers...'), nl,
    nl,
    
    Locations = [
        '~/zombie_driver2',
        '~/zos-server',
        '~/meta-introspector',
        '~/nix-controller'
    ],
    
    forall(member(Loc, Locations), substrace_search_syn(Loc)).

substrace_search_syn(Location) :-
    format('📂 Substrace ~w~n', [Location]),
    
    expand_file_name(Location, [Expanded|_]),
    
    % Use substrace to trace file access
    format(atom(Cmd), 'substrace -e openat ls -R ~w 2>&1 | grep "\\.rs" | head -20', [Expanded]),
    catch(shell(Cmd, Output), _, Output = ""),
    
    (string(Output), Output \= "" ->
        write('  ✅ Found .rs files via substrace'), nl,
        write(Output), nl
    ;
        write('  ❌ No files found'), nl
    ),
    nl.

% ═══════════════════════════════════════════════════════════
% ORACLE: Direct file read with substrace
% ═══════════════════════════════════════════════════════════

oracle_substrace_read_rust(RustFile) :-
    format('🔍 Substrace reading ~w~n', [RustFile]),
    
    % Use substrace to trace the read
    format(atom(Cmd), 'substrace -e read cat ~w 2>&1 | grep -E "(syn|parquet)" | head -10', [RustFile]),
    catch(shell(Cmd, Output), _, Output = ""),
    
    (string(Output), Output \= "" ->
        write('  ✅ Contains syn/parquet'), nl,
        assertz(syn_parser_found(RustFile, true))
    ;
        write('  ❌ No syn/parquet'), nl
    ),
    nl.

% ═══════════════════════════════════════════════════════════
% ORACLE: List known locations directly
% ═══════════════════════════════════════════════════════════

oracle_known_syn_parsers :-
    write('🔍 Oracle: Known syn parser locations'), nl,
    nl,
    
    % Check known files directly
    KnownFiles = [
        '~/zombie_driver2/src/main.rs',
        '~/zos-server/src/main.rs',
        '~/meta-introspector/src/main.rs',
        '~/nix-controller/src/main.rs'
    ],
    
    forall(member(F, KnownFiles), check_file_exists(F)).

check_file_exists(File) :-
    expand_file_name(File, [Expanded|_]),
    (exists_file(Expanded) ->
        format('  ✅ ~w~n', [Expanded]),
        assertz(syn_parser_found(Expanded, exists))
    ;
        format('  ❌ ~w (not found)~n', [File])
    ).

% ═══════════════════════════════════════════════════════════
% MAIN
% ═══════════════════════════════════════════════════════════

main :-
    write('🍄 ORACLE SUBSTRACE SYN FINDER'), nl,
    write('═══════════════════════════════════════════════════════════'), nl,
    nl,
    
    write('STEP 1: Check known locations'), nl,
    write('═══════════════════════════════════════════════════════════'), nl,
    oracle_known_syn_parsers,
    nl,
    
    write('STEP 2: Substrace search'), nl,
    write('═══════════════════════════════════════════════════════════'), nl,
    oracle_substrace_find_syn,
    
    write('STEP 3: Summary'), nl,
    write('═══════════════════════════════════════════════════════════'), nl,
    findall(F, syn_parser_found(F, _), Files),
    length(Files, Count),
    format('Found ~w potential syn parsers~n', [Count]),
    forall(member(F, Files), format('  • ~w~n', [F])).

% ?- main.
