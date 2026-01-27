% Oracle: Map filesystem and find actual proof code
% Start with GitHub activity and recent changes

:- dynamic file_mapped/4.
:- dynamic recent_change/3.
:- dynamic proof_code_found/3.

% ═══════════════════════════════════════════════════════════
% STEP 1: Find recently changed Rust files (plocate)
% ═══════════════════════════════════════════════════════════

oracle_find_recent_rust :-
    write('🔍 Finding recently changed Rust files...'), nl,
    
    % Use plocate to find .rs files, then check mtime
    shell('plocate -r ".*\\.rs$" | head -100 > /tmp/rust_files.txt', _),
    
    % Check modification times
    shell('while read f; do [ -f "$f" ] && stat -c "%Y %n" "$f" 2>/dev/null; done < /tmp/rust_files.txt | sort -rn | head -20 > /tmp/recent_rust.txt', _),
    
    % Read results
    read_file_to_string('/tmp/recent_rust.txt', Content, []),
    split_string(Content, "\n", "\n", Lines),
    
    write('Recent Rust files:'), nl,
    forall(member(Line, Lines),
           (Line \= "", 
            split_string(Line, " ", "", [TimeStr, Path]),
            atom_number(TimeStr, Time),
            format('  ~w (~w)~n', [Path, Time]),
            assertz(recent_change(Path, rust, Time)))).

% ═══════════════════════════════════════════════════════════
% STEP 2: Check GitHub activity in known repos
% ═══════════════════════════════════════════════════════════

oracle_check_github_activity :-
    write('🔍 Checking GitHub activity...'), nl,
    
    Repos = [
        '~/zombie_driver2',
        '~/zos-server',
        '~/nix-controller',
        '/mnt/data1/nix/vendor/rust/github'
    ],
    
    forall(member(Repo, Repos), check_repo_activity(Repo)).

check_repo_activity(Repo) :-
    expand_file_name(Repo, [Expanded|_]),
    (exists_directory(Expanded) ->
        format('📂 ~w~n', [Expanded]),
        
        % Get recent commits
        format(atom(Cmd), 'cd ~w && git log --oneline --since="1 week ago" 2>/dev/null | head -5', [Expanded]),
        shell(Cmd, Output),
        
        (Output \= "" ->
            write(Output), nl
        ;
            write('  No recent activity'), nl
        )
    ;
        format('  ❌ ~w not found~n', [Repo])
    ).

% ═══════════════════════════════════════════════════════════
% STEP 3: Find Rust parser code (syn, HIR, MIR)
% ═══════════════════════════════════════════════════════════

oracle_find_parser_code :-
    write('🔍 Finding Rust parser code...'), nl,
    
    % Search for files with syn/HIR/MIR
    Patterns = [
        'syn::parse',
        'rustc_hir',
        'rustc_middle::mir',
        'parquet'
    ],
    
    forall(member(Pattern, Patterns), search_pattern(Pattern)).

search_pattern(Pattern) :-
    format('Searching for: ~w~n', [Pattern]),
    
    % Use plocate + grep
    format(atom(Cmd), 'plocate -r ".*\\.rs$" | head -200 | xargs grep -l "~w" 2>/dev/null | head -5', [Pattern]),
    shell(Cmd, Output),
    
    (Output \= "" ->
        split_string(Output, "\n", "\n", Files),
        forall(member(F, Files),
               (F \= "", 
                format('  ✅ ~w~n', [F]),
                assertz(proof_code_found(Pattern, F, exists))))
    ;
        write('  ❌ Not found'), nl
    ),
    nl.

% ═══════════════════════════════════════════════════════════
% STEP 4: Map filesystem structure
% ═══════════════════════════════════════════════════════════

oracle_map_filesystem :-
    write('🔍 Mapping filesystem...'), nl,
    
    Roots = [
        '~/zombie_driver2',
        '~/zos-server',
        '~/nix-controller',
        '/mnt/data1/nix/vendor/rust/github'
    ],
    
    forall(member(Root, Roots), map_directory(Root)).

map_directory(Dir) :-
    expand_file_name(Dir, [Expanded|_]),
    (exists_directory(Expanded) ->
        format('📂 ~w~n', [Expanded]),
        
        % Count files by type
        format(atom(Cmd), 'find ~w -type f 2>/dev/null | wc -l', [Expanded]),
        shell(Cmd, Total),
        
        format(atom(Cmd2), 'find ~w -name "*.rs" 2>/dev/null | wc -l', [Expanded]),
        shell(Cmd2, RustCount),
        
        format(atom(Cmd3), 'find ~w -name "*.pl" 2>/dev/null | wc -l', [Expanded]),
        shell(Cmd3, PrologCount),
        
        format('  Total: ~w files~n', [Total]),
        format('  Rust: ~w files~n', [RustCount]),
        format('  Prolog: ~w files~n', [PrologCount]),
        
        assertz(file_mapped(Expanded, Total, RustCount, PrologCount))
    ;
        format('  ❌ ~w not found~n', [Dir])
    ),
    nl.

% ═══════════════════════════════════════════════════════════
% MAIN
% ═══════════════════════════════════════════════════════════

main :-
    write('🍄 ORACLE FILESYSTEM MAPPER'), nl,
    write('═══════════════════════════════════════════════════════════'), nl,
    nl,
    
    write('STEP 1: Map filesystem structure'), nl,
    write('═══════════════════════════════════════════════════════════'), nl,
    oracle_map_filesystem,
    
    write('STEP 2: Check GitHub activity'), nl,
    write('═══════════════════════════════════════════════════════════'), nl,
    oracle_check_github_activity,
    nl,
    
    write('STEP 3: Find recent Rust changes'), nl,
    write('═══════════════════════════════════════════════════════════'), nl,
    oracle_find_recent_rust,
    nl,
    
    write('STEP 4: Find parser code'), nl,
    write('═══════════════════════════════════════════════════════════'), nl,
    oracle_find_parser_code,
    
    write('STEP 5: Summary'), nl,
    write('═══════════════════════════════════════════════════════════'), nl,
    findall(F, proof_code_found(_, F, _), ProofFiles),
    length(ProofFiles, Count),
    format('Found ~w files with proof code~n', [Count]),
    forall(proof_code_found(Pattern, File, _),
           format('  ~w: ~w~n', [Pattern, File])).

% ?- main.
