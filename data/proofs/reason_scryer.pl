% reason_scryer.pl - Reason about parquet in native Rust Prolog (Scryer)

% ═══════════════════════════════════════════════════════════
% PARQUET AS NATIVE FACTS
% ═══════════════════════════════════════════════════════════

:- use_module(library(pio)).
:- use_module(library(dcgs)).
:- use_module(library(lists)).

% Read CSV line by line
read_csv_file(File, Rows) :-
    phrase_from_file(csv_rows(Rows), File).

csv_rows([Row|Rows]) --> csv_row(Row), !, csv_rows(Rows).
csv_rows([]) --> [].

csv_row(Row) --> csv_fields(Row), "\n".
csv_row(Row) --> csv_fields(Row), eos.

csv_fields([Field|Fields]) --> csv_field(Field), ",", !, csv_fields(Fields).
csv_fields([Field]) --> csv_field(Field).

csv_field(Field) --> "\"", string(Codes), "\"", { atom_codes(Field, Codes) }.
csv_field(Field) --> string(Codes), { Codes \= [], atom_codes(Field, Codes) }.

% Load entities
entity(Godel, Type, Path, Primes) :-
    read_csv_file('generated/godel_lattice.csv', [_Header|Rows]),
    member([GodelAtom, Type, Path, Primes], Rows),
    atom_number(GodelAtom, Godel).

% Load shards
hecke_shard(Godel, Shard, Eigensum) :-
    read_csv_file('generated/hecke_shards_rust.csv', [_Header|Rows]),
    member([GodelAtom, _, _, _, ShardAtom, EigensumAtom], Rows),
    atom_number(GodelAtom, Godel),
    atom_number(ShardAtom, Shard),
    atom_number(EigensumAtom, Eigensum).

% ═══════════════════════════════════════════════════════════
% REASONING
% ═══════════════════════════════════════════════════════════

% Find entity
find_entity(71, Type, Path, Primes) :-
    entity(71, Type, Path, Primes).

% Entity in shard
entity_in_shard(Godel, Shard) :-
    hecke_shard(Godel, Shard, _).

% Explain
explain(Godel) :-
    entity(Godel, Type, Path, Primes),
    hecke_shard(Godel, Shard, Eigensum),
    format("Entity ~w: ~w at ~w~n", [Godel, Type, Path]),
    format("  Primes: ~w~n", [Primes]),
    format("  Shard: ~w (eigensum=~w)~n", [Shard, Eigensum]).

% Demo
demo :-
    format("🧠 Native Rust Prolog reasoning...~n~n"),
    explain(71).

:- initialization(demo).
