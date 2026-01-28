#!/usr/bin/env swipl
% label_3m_files.pl - Label all 3M files from locate_digest.parquet

:- use_module(library(csv)).
:- use_module(library(lists)).

% Label categories
label_category(git_repo).
label_category(git_object).
label_category(author).
label_category(file_type).
label_category(processing_tool).
label_category(edit_history).
label_category(intent).
label_category(documentation).
label_category(chat).
label_category(emoji).
label_category(math).
label_category(security).
label_category(database).
label_category(ui).
label_category(transport).
label_category(compression).
label_category(usage).

% Extract labels from path
extract_labels(Path, Labels) :-
    findall(Label, (
        label_rule(Path, Label)
    ), Labels).

% File type labels
label_rule(Path, label(file_type, rust)) :- sub_string(Path, _, _, 0, ".rs").
label_rule(Path, label(file_type, prolog)) :- sub_string(Path, _, _, 0, ".pl").
label_rule(Path, label(file_type, lean4)) :- sub_string(Path, _, _, 0, ".lean").
label_rule(Path, label(file_type, coq)) :- sub_string(Path, _, _, 0, ".v").
label_rule(Path, label(file_type, c)) :- sub_string(Path, _, _, 0, ".c").
label_rule(Path, label(file_type, cpp)) :- sub_string(Path, _, _, 0, ".cpp").
label_rule(Path, label(file_type, llvm)) :- sub_string(Path, _, _, 0, ".ll").
label_rule(Path, label(file_type, scheme)) :- sub_string(Path, _, _, 0, ".scm").
label_rule(Path, label(file_type, ocaml)) :- sub_string(Path, _, _, 0, ".ml").
label_rule(Path, label(file_type, parquet)) :- sub_string(Path, _, _, 0, ".parquet").

% Git labels
label_rule(Path, label(git_repo, Repo)) :- 
    sub_string(Path, _, _, _, ".git/"),
    extract_repo_name(Path, Repo).
label_rule(Path, label(git_object, commit)) :- sub_string(Path, _, _, _, "/objects/").
label_rule(Path, label(git_object, blob)) :- sub_string(Path, _, _, _, "/objects/").

% Processing tools
label_rule(Path, label(processing_tool, rustc)) :- sub_string(Path, _, _, _, "rustc").
label_rule(Path, label(processing_tool, gcc)) :- sub_string(Path, _, _, _, "gcc").
label_rule(Path, label(processing_tool, llvm)) :- sub_string(Path, _, _, _, "llvm").
label_rule(Path, label(processing_tool, swipl)) :- sub_string(Path, _, _, _, "swipl").
label_rule(Path, label(processing_tool, lean)) :- sub_string(Path, _, _, _, "lean").

% Math labels
label_rule(Path, label(math, prime)) :- sub_string(Path, _, _, _, "prime").
label_rule(Path, label(math, godel)) :- sub_string(Path, _, _, _, "godel").
label_rule(Path, label(math, hecke)) :- sub_string(Path, _, _, _, "hecke").
label_rule(Path, label(math, monster)) :- sub_string(Path, _, _, _, "monster").
label_rule(Path, label(math, galois)) :- sub_string(Path, _, _, _, "galois").

% Security labels
label_rule(Path, label(security, zk)) :- sub_string(Path, _, _, _, "zk").
label_rule(Path, label(security, proof)) :- sub_string(Path, _, _, _, "proof").
label_rule(Path, label(security, verify)) :- sub_string(Path, _, _, _, "verify").

% Database labels
label_rule(Path, label(database, postgres)) :- sub_string(Path, _, _, _, "postgres").
label_rule(Path, label(database, sqlite)) :- sub_string(Path, _, _, _, "sqlite").
label_rule(Path, label(database, parquet)) :- sub_string(Path, _, _, _, "parquet").

% UI labels
label_rule(Path, label(ui, web)) :- sub_string(Path, _, _, _, "html").
label_rule(Path, label(ui, cli)) :- sub_string(Path, _, _, _, "cli").

% Transport labels
label_rule(Path, label(transport, http)) :- sub_string(Path, _, _, _, "http").
label_rule(Path, label(transport, grpc)) :- sub_string(Path, _, _, _, "grpc").

% Compression labels
label_rule(Path, label(compression, gzip)) :- sub_string(Path, _, _, _, ".gz").
label_rule(Path, label(compression, zstd)) :- sub_string(Path, _, _, _, ".zst").
label_rule(Path, label(compression, parquet)) :- sub_string(Path, _, _, _, ".parquet").

% Documentation labels
label_rule(Path, label(documentation, readme)) :- sub_string(Path, _, _, _, "README").
label_rule(Path, label(documentation, doc)) :- sub_string(Path, _, _, _, "/doc/").

% Extract repo name from path
extract_repo_name(Path, Repo) :-
    split_string(Path, "/", "", Parts),
    member(Repo, Parts),
    Repo \= "".

% Assign Gödel number based on labels
assign_godel(Labels, Godel) :-
    maplist(label_prime, Labels, Primes),
    foldl(mult, Primes, 1, Product),
    Godel is Product mod 71.

label_prime(label(file_type, _), 2).
label_prime(label(git_repo, _), 3).
label_prime(label(processing_tool, _), 5).
label_prime(label(math, _), 7).
label_prime(label(security, _), 11).
label_prime(label(database, _), 13).
label_prime(label(ui, _), 17).
label_prime(label(transport, _), 19).
label_prime(label(compression, _), 23).
label_prime(label(documentation, _), 29).
label_prime(_, 31).  % default

mult(X, Acc, Result) :- Result is X * Acc.

% Label a single file
label_file(Path, labeled_file(Path, Labels, Godel, Shard)) :-
    extract_labels(Path, Labels),
    assign_godel(Labels, Godel),
    Shard is Godel mod 71.

% Process all files from locate_digest
process_all_files :-
    format('~nLabeling all 3M files...~n'),
    % Read from locate_digest.parquet (via CSV export)
    % For now, test with sample paths
    test_paths(Paths),
    maplist(label_and_print, Paths),
    format('~nDone!~n').

test_paths([
    'data/proofs/godel_planner.rs',
    'data/proofs/monster_decidability.pl',
    'data/proofs/prove_all_databases_monster.lean',
    '/mnt/data1/time2/time/2023/07/30/meta-meme/plocate_witness/locate_digest.parquet',
    '/nix/store/abc123-rustc-1.75.0/bin/rustc',
    '/usr/lib/gcc/x86_64-linux-gnu/11/cc1'
]).

label_and_print(Path) :-
    label_file(Path, LabeledFile),
    LabeledFile = labeled_file(P, Labels, Godel, Shard),
    format('~nFile: ~w~n', [P]),
    format('  Gödel: ~w, Shard: ~w~n', [Godel, Shard]),
    format('  Labels: ~w~n', [Labels]).

% Statistics
count_by_label(Category, Count) :-
    findall(1, (
        test_paths(Paths),
        member(Path, Paths),
        label_file(Path, labeled_file(_, Labels, _, _)),
        member(label(Category, _), Labels)
    ), Matches),
    length(Matches, Count).

print_statistics :-
    format('~nLabel Statistics:~n'),
    findall(Category-Count, (
        label_category(Category),
        count_by_label(Category, Count),
        Count > 0
    ), Stats),
    maplist(print_stat, Stats).

print_stat(Category-Count) :-
    format('  ~w: ~w~n', [Category, Count]).

main :-
    process_all_files,
    print_statistics.

:- initialization(main, main).
