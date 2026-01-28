#!/usr/bin/env swipl
% prolog_to_nix.pl - Convert Prolog facts to Nix expressions

:- use_module(library(lists)).

% Convert Prolog term to Nix expression
term_to_nix(Term, Nix) :-
    atom(Term),
    !,
    format(atom(Nix), '"~w"', [Term]).

term_to_nix(Term, Nix) :-
    number(Term),
    !,
    format(atom(Nix), '~w', [Term]).

term_to_nix(Term, Nix) :-
    is_list(Term),
    !,
    maplist(term_to_nix, Term, NixTerms),
    atomic_list_concat(NixTerms, ' ', NixList),
    format(atom(Nix), '[ ~w ]', [NixList]).

term_to_nix(Term, Nix) :-
    compound(Term),
    !,
    Term =.. [Functor|Args],
    maplist(term_to_nix, Args, NixArgs),
    atomic_list_concat(NixArgs, ' ', NixArgList),
    format(atom(Nix), '{ _type = "~w"; args = [ ~w ]; }', [Functor, NixArgList]).

% Convert object/3 fact to Nix attribute set
object_to_nix(object(Godel, Shard, Type), Nix) :-
    format(atom(Nix), '  "~w" = { godel = ~w; shard = ~w; type = "~w"; };',
           [Godel, Godel, Shard, Type]).

% Convert object/7 fact to Nix attribute set
object_to_nix(object(Godel, Path, Shard, Type, Meaning, Usage, Class), Nix) :-
    format(atom(Nix), '  "obj_~w" = {\n    godel = ~w;\n    path = "~w";\n    shard = ~w;\n    type = "~w";\n    meaning = "~w";\n    usage = "~w";\n    class = "~w";\n  };',
           [Godel, Godel, Path, Shard, Type, Meaning, Usage, Class]).

% Generate Nix file from Prolog facts
generate_nix_file(NixFile) :-
    format('~nGenerating ~w...~n', [NixFile]),
    
    % Objects should already be loaded
    findall(_, object(_, _, _, _, _), Objects),
    length(Objects, Count),
    format('Found ~w objects in memory~n', [Count]),
    
    % Open Nix output file
    open(NixFile, write, Stream),
    
    % Write Nix header
    format(Stream, '# Generated from global_object_table.pl~n', []),
    format(Stream, '# Prolog facts converted to Nix attribute sets~n~n', []),
    format(Stream, '{~n', []),
    
    % Convert all object/5 facts
    findall(_, object(_, _, _, _, _), Objects),
    length(Objects, Count),
    format('Writing ~w objects~n', [Count]),
    
    (   Count > 0
    ->  format(Stream, '  # object(godel, path, shard, type, uses) facts~n', []),
        format(Stream, '  objects = {~n', []),
        forall(
            object(G, P, S, T, U),
            format(Stream, '    "obj_~w" = { godel = ~w; path = "~w"; shard = ~w; type = "~w"; uses = ~w; };~n',
                   [G, G, P, S, T, U])
        ),
        format(Stream, '  };~n~n', [])
    ;   format(Stream, '  objects = {};~n~n', [])
    ),
    
    % Convert all object/7 facts - remove this section
    % (Not used in global_object_table.pl)
    
    % Write metadata
    format(Stream, '  # Metadata~n', []),
    format(Stream, '  meta = {~n', []),
    format(Stream, '    source = "global_object_table.pl";~n', []),
    format(Stream, '    objectCount = ~w;~n', [Count]),
    format(Stream, '    monsterMod = 71;~n', []),
    format(Stream, '    shardCount = 71;~n', []),
    format(Stream, '  };~n', []),
    
    format(Stream, '}~n', []),
    close(Stream),
    
    format('✅ Generated ~w~n', [NixFile]).

% Generate Nix from global object table
generate_global_objects_nix :-
    format('~nGENERATING NIX FROM GLOBAL OBJECT TABLE~n'),
    format('~`=t~80|~n'),
    
    % Generate from loaded facts
    generate_nix_file('global_objects.nix'),
    
    format('~n✅ Nix file generated~n').

% Generate Nix module for importing
generate_nix_module :-
    format('~nGENERATING NIX MODULE~n'),
    format('~`=t~80|~n'),
    
    open('zkprologml-data.nix', write, Stream),
    
    format(Stream, '# zkPrologML Data Module~n', []),
    format(Stream, '# Import Prolog facts as Nix attribute sets~n~n', []),
    
    format(Stream, '{ pkgs ? import <nixpkgs> {} }:~n~n', []),
    
    format(Stream, 'let~n', []),
    format(Stream, '  # Import generated data~n', []),
    format(Stream, '  globalObjects = import ./global_objects.nix;~n~n', []),
    
    format(Stream, '  # Helper functions~n', []),
    format(Stream, '  getObjectByShard = shard:~n', []),
    format(Stream, '    builtins.filter (obj: obj.shard == shard)~n', []),
    format(Stream, '      (builtins.attrValues globalObjects.objects);~n~n', []),
    
    format(Stream, '  getObjectByGodel = godel:~n', []),
    format(Stream, '    builtins.filter (obj: obj.godel == godel)~n', []),
    format(Stream, '      (builtins.attrValues globalObjects.objects);~n~n', []),
    
    format(Stream, '  countByShard = shard:~n', []),
    format(Stream, '    builtins.length (getObjectByShard shard);~n~n', []),
    
    format(Stream, 'in {~n', []),
    format(Stream, '  inherit globalObjects;~n', []),
    format(Stream, '  inherit getObjectByShard getObjectByGodel countByShard;~n~n', []),
    
    format(Stream, '  # Metadata~n', []),
    format(Stream, '  meta = globalObjects.meta // {~n', []),
    format(Stream, '    description = "zkPrologML Monster Group Data";~n', []),
    format(Stream, '    version = "0.1.0";~n', []),
    format(Stream, '  };~n', []),
    format(Stream, '}~n', []),
    
    close(Stream),
    
    format('✅ Generated zkprologml-data.nix~n').

% Main
main :-
    format('~nPROLOG TO NIX TRANSPILER~n'),
    format('~`=t~80|~n'),
    
    % First load test objects
    consult('test_objects.pl'),
    
    % Then generate Nix
    generate_global_objects_nix,
    generate_nix_module,
    
    format('~n~n~`=t~80|~n'),
    format('QED: Prolog facts converted to Nix!~n'),
    format('~`=t~80|~n'),
    
    format('~nUsage in Nix:~n'),
    format('  let data = import ./zkprologml-data.nix {};~n'),
    format('  in data.getObjectByShard 58~n').

:- initialization(main, main).
