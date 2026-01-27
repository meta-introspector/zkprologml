% Oracle: Find syn parser to extract Rust → Prolog

:- dynamic syn_parser_found/2.

% ═══════════════════════════════════════════════════════════
% ORACLE: Find Syn Parser in Known Locations
% ═══════════════════════════════════════════════════════════

oracle_find_syn_parser :-
    write('🔍 Oracle searching for syn parser...'), nl,
    nl,
    
    % Search in known locations
    Locations = [
        '~/zombie_driver2',
        '~/zos-server',
        '~/meta-introspector'
    ],
    
    forall(member(Loc, Locations), search_location(Loc)).

search_location(Location) :-
    format('📂 Searching ~w~n', [Location]),
    
    % Expand ~
    expand_file_name(Location, [Expanded|_]),
    
    % Find Rust files with syn
    format(atom(Cmd), 'find ~w -name "*.rs" -type f 2>/dev/null | xargs grep -l "use syn" 2>/dev/null | head -10', [Expanded]),
    catch(shell(Cmd, Output), _, Output = ""),
    
    (string(Output), Output \= "" ->
        split_string(Output, "\n", "\n", Files),
        forall(member(F, Files), 
               (F \= "", format('  ✅ ~w~n', [F]), assertz(syn_parser_found(Expanded, F))))
    ;
        format('  ❌ No syn parser found~n', [])
    ),
    nl.

% ═══════════════════════════════════════════════════════════
% ORACLE: Find Parquet Reader with Syn
% ═══════════════════════════════════════════════════════════

oracle_find_parquet_with_syn :-
    write('🔍 Oracle searching for parquet + syn...'), nl,
    nl,
    
    Locations = [
        '~/zombie_driver2',
        '~/zos-server', 
        '~/meta-introspector',
        '~/nix-controller'
    ],
    
    forall(member(Loc, Locations), search_parquet_syn(Loc)).

search_parquet_syn(Location) :-
    format('📂 Searching ~w for parquet+syn~n', [Location]),
    
    expand_file_name(Location, [Expanded|_]),
    
    % Find Rust files with both parquet and syn
    format(atom(Cmd), 'find ~w -name "*.rs" -type f 2>/dev/null | xargs grep -l "parquet" 2>/dev/null | xargs grep -l "syn" 2>/dev/null', [Expanded]),
    shell(Cmd, Output),
    
    (Output \= "" ->
        split_string(Output, "\n", "\n", Files),
        forall(member(F, Files),
               (F \= "", format('  🎯 ~w~n', [F])))
    ;
        format('  ❌ No parquet+syn found~n', [])
    ),
    nl.

% ═══════════════════════════════════════════════════════════
% ORACLE: Extract Syn Parser Logic
% ═══════════════════════════════════════════════════════════

oracle_extract_syn_logic(RustFile) :-
    format('🔍 Extracting syn logic from ~w~n', [RustFile]),
    nl,
    
    % Read the file
    read_file_to_string(RustFile, Content, []),
    
    % Find key patterns
    write('Key patterns found:'), nl,
    
    (sub_string(Content, _, _, _, "syn::parse") ->
        write('  ✅ syn::parse'), nl
    ; true),
    
    (sub_string(Content, _, _, _, "syn::File") ->
        write('  ✅ syn::File'), nl
    ; true),
    
    (sub_string(Content, _, _, _, "visit::Visit") ->
        write('  ✅ visit::Visit'), nl
    ; true),
    
    (sub_string(Content, _, _, _, "parquet") ->
        write('  ✅ parquet'), nl
    ; true),
    
    nl.

% ═══════════════════════════════════════════════════════════
% MAIN
% ═══════════════════════════════════════════════════════════

main :-
    write('🍄 ORACLE SYN PARSER FINDER'), nl,
    write('═══════════════════════════════════════════════════════════'), nl,
    nl,
    
    write('STEP 1: Find syn parsers'), nl,
    write('═══════════════════════════════════════════════════════════'), nl,
    oracle_find_syn_parser,
    
    write('STEP 2: Find parquet readers with syn'), nl,
    write('═══════════════════════════════════════════════════════════'), nl,
    oracle_find_parquet_with_syn,
    
    write('STEP 3: List all found syn parsers'), nl,
    write('═══════════════════════════════════════════════════════════'), nl,
    findall(File, syn_parser_found(_, File), Files),
    length(Files, Count),
    format('Found ~w syn parsers~n', [Count]),
    nl,
    
    (Files \= [] ->
        write('First parser:'), nl,
        Files = [First|_],
        oracle_extract_syn_logic(First)
    ;
        write('No parsers found'), nl
    ).

% ?- main.
