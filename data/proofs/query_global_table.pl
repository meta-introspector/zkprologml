#!/usr/bin/env swipl
% Query global object table

:- consult('global_objects.pl').

count_by_shard :-
    format('~nOBJECTS PER SHARD~n'),
    forall(
        between(0, 70, Shard),
        (aggregate_all(count, object(_, Shard, _), Count),
         format('Shard ~w: ~D~n', [Shard, Count]))
    ).

main :-
    aggregate_all(count, object(_, _, _), Total),
    format('Total: ~D~n', [Total]),
    count_by_shard.

:- initialization(main, main).
