#!/usr/bin/env swipl
% index_all_files.pl - Index all 3M files and compress filesystem with semantic regex

:- use_module(library(process)).
:- use_module(library(lists)).
:- use_module(library(aggregate)).
:- use_module(library(pcre)).

% Semantic filesystem levels
% Level 0: Root (/)
% Level 1: System (/nix, /usr, /home, /mnt)
% Level 2: Category (/nix/store, /usr/lib, /home/user)
% Level 3: Package (/nix/store/hash-name-version)
% Level 4: Type (/bin, /lib, /share, /src)
% Level 5: File (actual files)

% Semantic regex patterns for each level
level_pattern(0, '^/$').
level_pattern(1, '^/(nix|usr|home|mnt|var|etc|opt|tmp)').
level_pattern(2, '^/nix/store|^/usr/(lib|bin|share)|^/home/[^/]+|^/mnt/[^/]+').
level_pattern(3, '^/nix/store/[^/]+-[^/]+-[0-9.]+').
level_pattern(4, '/(bin|lib|share|src|include|doc|man)(/|$)').
level_pattern(5, '\\.[a-z0-9]+$').  % File extension

% Compress path to semantic representation
compress_path(Path, Compressed) :-
    split_string(Path, "/", "", Parts),
    maplist(compress_part, Parts, CompressedParts),
    atomic_list_concat(CompressedParts, '/', Compressed).

% Compress individual path parts
compress_part("", "").
compress_part(Part, Compressed) :-
    string(Part),
    (   % Nix store hash
        sub_string(Part, 0, 32, _, _),
        sub_string(Part, 32, 1, _, "-")
    ->  sub_string(Part, 0, 8, _, Hash),
        string_concat(Hash, "...", Compressed)
    ;   % Version numbers
        sub_string(Part, _, _, _, "-")
    ->  split_string(Part, "-", "", [Name|_]),
        string_concat(Name, "-V", Compressed)
    ;   % Long names
        string_length(Part, Len),
        Len > 20
    ->  sub_string(Part, 0, 17, _, Short),
        string_concat(Short, "...", Compressed)
    ;   Compressed = Part
    ).

% Extract semantic features from path
semantic_features(Path, Features) :-
    path_level(Path, Level),
    path_system(Path, System),
    path_category(Path, Category),
    path_package(Path, Package),
    path_type(Path, Type),
    path_extension(Path, Ext),
    path_depth(Path, Depth),
    Features = [Level, System, Category, Package, Type, Ext, Depth].

path_level(Path, Level) :-
    (   Path = "/" -> Level = 0
    ;   sub_string(Path, _, _, _, "/nix/store/") -> Level = 3
    ;   sub_string(Path, _, _, _, "/bin/") -> Level = 4
    ;   Level = 5
    ).

path_system(Path, System) :-
    (   sub_string(Path, 0, 4, _, "/nix") -> System = nix
    ;   sub_string(Path, 0, 4, _, "/usr") -> System = usr
    ;   sub_string(Path, 0, 5, _, "/home") -> System = home
    ;   sub_string(Path, 0, 4, _, "/mnt") -> System = mnt
    ;   System = other
    ).

path_category(Path, Category) :-
    (   sub_string(Path, _, _, _, "/store/") -> Category = store
    ;   sub_string(Path, _, _, _, "/lib/") -> Category = lib
    ;   sub_string(Path, _, _, _, "/bin/") -> Category = bin
    ;   sub_string(Path, _, _, _, "/share/") -> Category = share
    ;   sub_string(Path, _, _, _, "/src/") -> Category = src
    ;   Category = other
    ).

path_package(Path, Package) :-
    split_string(Path, "/", "", Parts),
    (   member(Part, Parts),
        sub_string(Part, _, _, _, "-"),
        \+ sub_string(Part, 0, 1, _, ".")
    ->  Package = Part
    ;   Package = none
    ).

path_type(Path, Type) :-
    (   sub_string(Path, _, _, _, "/bin/") -> Type = executable
    ;   sub_string(Path, _, _, _, "/lib/") -> Type = library
    ;   sub_string(Path, _, _, _, "/share/") -> Type = data
    ;   sub_string(Path, _, _, _, "/src/") -> Type = source
    ;   Type = unknown
    ).

path_extension(Path, Ext) :-
    split_string(Path, ".", "", Parts),
    (   Parts = [_|Rest],
        Rest \= []
    ->  last(Rest, Ext)
    ;   Ext = none
    ).

path_depth(Path, Depth) :-
    split_string(Path, "/", "", Parts),
    length(Parts, Depth).

% Index all files from plocate
index_all_files(OutputFile) :-
    format('~nIndexing all files from plocate...~n'),
    setup_call_cleanup(
        open(OutputFile, write, Stream),
        index_files_stream(Stream),
        close(Stream)
    ),
    format('~nIndexed all files to: ~w~n', [OutputFile]).

index_files_stream(Stream) :-
    process_create(path(plocate), [''], [stdout(pipe(In))]),
    format(Stream, 'path,compressed,level,system,category,type,extension,depth,godel,shard~n', []),
    index_lines(In, Stream, 0),
    close(In).

index_lines(In, Out, Count) :-
    read_line_to_string(In, Line),
    (   Line == end_of_file
    ->  format('~nTotal files indexed: ~w~n', [Count])
    ;   index_line(Line, Out),
        Count1 is Count + 1,
        (   Count1 mod 10000 =:= 0
        ->  format('Indexed: ~w files~n', [Count1])
        ;   true
        ),
        index_lines(In, Out, Count1)
    ).

index_line(Path, Stream) :-
    compress_path(Path, Compressed),
    semantic_features(Path, [Level, System, Category, Package, Type, Ext, Depth]),
    assign_godel(Path, Godel),
    Shard is Godel mod 71,
    format(Stream, '"~w","~w",~w,~w,~w,~w,~w,~w,~w,~w,~w~n',
        [Path, Compressed, Level, System, Category, Package, Type, Ext, Depth, Godel, Shard]).

% Assign Gödel number based on path (optimized)
assign_godel(Path, Godel) :-
    atom_codes(Path, Codes),
    hash_codes(Codes, 0, Hash),
    Godel is Hash mod 71.

hash_codes([], Hash, Hash).
hash_codes([C|Cs], Acc, Hash) :-
    Acc1 is (Acc * 31 + C) mod 1000000007,
    hash_codes(Cs, Acc1, Hash).

% Generate semantic regex for entire filesystem
generate_filesystem_regex(Regex) :-
    Regex = "^/(nix/store/[a-z0-9]{8}\\.\\.\\.-[^/]+-V|usr/(lib|bin|share)|home/[^/]+|mnt/[^/]+)(/[^/]+)*/[^/]+\\.[a-z0-9]+$".

% Test compression
test_compression :-
    TestPaths = [
        "/nix/store/abc123def456-rustc-1.75.0/bin/rustc",
        "/usr/lib/gcc/x86_64-linux-gnu/11/cc1",
        "/home/user/projects/zkprologml/data/proofs/monster_decidability.pl",
        "/mnt/data1/time2/time/2023/07/30/meta-meme/plocate_witness/locate_digest.parquet"
    ],
    format('~nTesting path compression:~n'),
    maplist(test_compress, TestPaths).

test_compress(Path) :-
    compress_path(Path, Compressed),
    semantic_features(Path, [Level, System, Category, Package, Type, Ext, Depth]),
    assign_godel(Path, Godel),
    format('~nOriginal: ~w~n', [Path]),
    format('Compressed: ~w~n', [Compressed]),
    format('Features: level=~w system=~w category=~w type=~w ext=~w depth=~w~n', 
        [Level, System, Category, Type, Ext, Depth]),
    format('Gödel: ~w, Shard: ~w~n', [Godel, Godel mod 71]).

main :-
    test_compression,
    format('~n~nStarting full indexing...~n'),
    index_all_files('indexed_files.csv'),
    generate_filesystem_regex(Regex),
    format('~nFilesystem regex: ~w~n', [Regex]).

:- initialization(main, main).
