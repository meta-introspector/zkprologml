:- dynamic pattern/3.
:- dynamic repo/1.

main :-
    write('🔍 Analyzing ALL repos for similar patterns...\n\n'),
    
    % Define repos
    Repos = [
        '/mnt/data1/nix/vendor/rust/github',
        '~/zombie_driver2',
        '~/zos-server', 
        '~/meta-introspector'
    ],
    
    forall(member(R, Repos), assertz(repo(R))),
    
    % Find all Prolog files in all repos
    forall(
        repo(R),
        (
            format('📂 Scanning ~w...\n', [R]),
            format(string(Cmd), 'find ~w -name "*.pl" -type f 2>/dev/null', [R]),
            shell(Cmd, _)
        )
    ),
    
    % Collect all files
    shell('find ~/zombie_driver2 ~/zos-server ~/meta-introspector /mnt/data1/nix/vendor/rust/github -name "*.pl" -type f 2>/dev/null > all_pl_files.txt', _),
    
    open('all_pl_files.txt', read, S),
    read_string(S, _, Content),
    close(S),
    split_string(Content, "\n", " ", Files),
    
    length(Files, Total),
    format('\n✅ Found ~w Prolog files across all repos\n\n', [Total]),
    
    % Analyze each
    forall(
        (member(F, Files), F \= ""),
        analyze_file(F)
    ),
    
    % Report
    findall(P, pattern(_, P, _), Patterns),
    list_to_set(Patterns, Unique),
    length(Unique, Count),
    format('\n🎯 Found ~w unique patterns\n\n', [Count]),
    
    % Show duplicates
    forall(
        member(P, Unique),
        show_pattern(P)
    ).

analyze_file(File) :-
    catch(
        (open(File, read, S),
         read_string(S, _, C),
         close(S),
         check_patterns(File, C)),
        _, true).

check_patterns(F, C) :-
    (sub_string(C, _, _, _, "plocate") -> assertz(pattern(F, plocate, 1)) ; true),
    (sub_string(C, _, _, _, "shell(") -> assertz(pattern(F, shell, 1)) ; true),
    (sub_string(C, _, _, _, "complexity") -> assertz(pattern(F, complexity, 1)) ; true),
    (sub_string(C, _, _, _, "monster") -> assertz(pattern(F, monster, 1)) ; true),
    (sub_string(C, _, _, _, "prime") -> assertz(pattern(F, prime, 1)) ; true),
    (sub_string(C, _, _, _, "lean") -> assertz(pattern(F, lean, 1)) ; true),
    (sub_string(C, _, _, _, "oracle") -> assertz(pattern(F, oracle, 1)) ; true),
    (sub_string(C, _, _, _, "perf") -> assertz(pattern(F, perf, 1)) ; true),
    (sub_string(C, _, _, _, "parquet") -> assertz(pattern(F, parquet, 1)) ; true),
    (sub_string(C, _, _, _, "lattice") -> assertz(pattern(F, lattice, 1)) ; true).

show_pattern(P) :-
    findall(F, pattern(F, P, _), Files),
    length(Files, N),
    (N > 3 ->
        (format('📋 ~w: ~w files\n', [P, N]),
         forall((member(F, Files), nth1(I, Files, F), I =< 5),
                format('  - ~w\n', [F])),
         (N > 5 -> format('  ... and ~w more\n\n', [N-5]) ; nl))
    ; true).
