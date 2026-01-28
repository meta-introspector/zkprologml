:- dynamic pattern/3.

main :-
    write('🔍 Analyzing all Prolog files for similar patterns...\n\n'),
    
    % Get all .pl files
    shell('ls *.pl > files.txt', _),
    open('files.txt', read, S),
    read_string(S, _, Content),
    close(S),
    split_string(Content, "\n", " ", Files),
    
    % Analyze each
    forall(
        (member(F, Files), F \= ""),
        analyze_file(F)
    ),
    
    % Report
    findall(P, pattern(_, P, _), Patterns),
    list_to_set(Patterns, Unique),
    length(Unique, Count),
    format('\n✅ Found ~w unique patterns\n\n', [Count]),
    
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
    (sub_string(C, _, _, _, "oracle") -> assertz(pattern(F, oracle, 1)) ; true).

show_pattern(P) :-
    findall(F, pattern(F, P, _), Files),
    length(Files, N),
    (N > 3 ->
        (format('📋 ~w: ~w files\n', [P, N]),
         forall((member(F, Files), nth1(I, Files, F), I =< 5),
                format('  - ~w\n', [F])),
         (N > 5 -> format('  ... and ~w more\n', [N-5]) ; true),
         nl)
    ; true).
