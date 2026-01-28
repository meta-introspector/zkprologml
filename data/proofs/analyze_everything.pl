:- dynamic pattern/4.
:- dynamic file_type/2.

main :-
    write('🔍 ANALYZING EVERYTHING: Rust, Lean4, Nix, MiniZinc, Shell, TOML...\n\n'),
    
    Repos = [
        '/mnt/data1/nix/vendor/rust/github',
        '~/zombie_driver2',
        '~/zos-server', 
        '~/meta-introspector'
    ],
    
    % Find all files by type
    Extensions = [
        ('*.rs', rust),
        ('*.lean', lean4),
        ('*.nix', nix),
        ('*.mzn', minizinc),
        ('*.sh', shell),
        ('*.toml', toml),
        ('*.pl', prolog)
    ],
    
    forall(
        (member(R, Repos), member((Ext, Type), Extensions)),
        (
            format(string(Cmd), 'find ~w -name "~w" -type f 2>/dev/null | wc -l', [R, Ext]),
            shell(Cmd, _)
        )
    ),
    
    % Collect all
    shell('find /mnt/data1/nix/vendor/rust/github ~/zombie_driver2 ~/zos-server ~/meta-introspector -type f \\( -name "*.rs" -o -name "*.lean" -o -name "*.nix" -o -name "*.mzn" -o -name "*.sh" -o -name "*.toml" -o -name "*.pl" \\) 2>/dev/null > all_files.txt', _),
    
    open('all_files.txt', read, S),
    read_string(S, _, Content),
    close(S),
    split_string(Content, "\n", " ", Files),
    
    length(Files, Total),
    format('\n✅ Found ~w files total\n\n', [Total]),
    
    % Analyze each
    forall(
        (member(F, Files), F \= ""),
        analyze_file(F)
    ),
    
    % Report by type
    report_by_type,
    
    % Report patterns
    report_patterns.

analyze_file(File) :-
    file_extension(File, Ext),
    file_type_from_ext(Ext, Type),
    assertz(file_type(File, Type)),
    catch(
        (open(File, read, S),
         read_string(S, _, C),
         close(S),
         check_patterns(File, Type, C)),
        _, true).

file_extension(File, Ext) :-
    atom_string(FileAtom, File),
    file_name_extension(_, Ext, FileAtom).

file_type_from_ext('rs', rust).
file_type_from_ext('lean', lean4).
file_type_from_ext('nix', nix).
file_type_from_ext('mzn', minizinc).
file_type_from_ext('sh', shell).
file_type_from_ext('toml', toml).
file_type_from_ext('pl', prolog).
file_type_from_ext(_, unknown).

check_patterns(F, T, C) :-
    (sub_string(C, _, _, _, "monster") -> assertz(pattern(F, T, monster, 1)) ; true),
    (sub_string(C, _, _, _, "prime") -> assertz(pattern(F, T, prime, 1)) ; true),
    (sub_string(C, _, _, _, "complexity") -> assertz(pattern(F, T, complexity, 1)) ; true),
    (sub_string(C, _, _, _, "lattice") -> assertz(pattern(F, T, lattice, 1)) ; true),
    (sub_string(C, _, _, _, "perf") -> assertz(pattern(F, T, perf, 1)) ; true),
    (sub_string(C, _, _, _, "goblin") -> assertz(pattern(F, T, goblin, 1)) ; true),
    (sub_string(C, _, _, _, "oracle") -> assertz(pattern(F, T, oracle, 1)) ; true),
    (sub_string(C, _, _, _, "parquet") -> assertz(pattern(F, T, parquet, 1)) ; true),
    (sub_string(C, _, _, _, "lean") -> assertz(pattern(F, T, lean_export, 1)) ; true),
    (sub_string(C, _, _, _, "bott") -> assertz(pattern(F, T, bott, 1)) ; true).

report_by_type :-
    write('📊 FILES BY TYPE:\n\n'),
    Types = [rust, lean4, nix, minizinc, shell, toml, prolog],
    forall(
        member(T, Types),
        (
            findall(F, file_type(F, T), Files),
            length(Files, N),
            (N > 0 -> format('  ~w: ~w files\n', [T, N]) ; true)
        )
    ),
    nl.

report_patterns :-
    write('🔱 PATTERNS ACROSS ALL LANGUAGES:\n\n'),
    Patterns = [monster, prime, complexity, lattice, perf, goblin, oracle, parquet, lean_export, bott],
    forall(
        member(P, Patterns),
        (
            findall((F,T), pattern(F, T, P, _), Matches),
            length(Matches, N),
            (N > 5 ->
                (
                    format('📋 ~w: ~w files\n', [P, N]),
                    findall(T, pattern(_, T, P, _), Types),
                    list_to_set(Types, UniqueTypes),
                    format('   Languages: ~w\n', [UniqueTypes]),
                    forall(
                        (member((File, Type), Matches), nth1(I, Matches, (File, Type)), I =< 3),
                        format('   - [~w] ~w\n', [Type, File])
                    ),
                    (N > 3 -> format('   ... and ~w more\n\n', [N-3]) ; nl)
                )
            ; true)
        )
    ).
