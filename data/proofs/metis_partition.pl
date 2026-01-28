#!/usr/bin/env swipl
% metis_partition.pl - Partition graph along Monster Group using METIS

:- use_module(library(lists)).

% Generate METIS graph format from unified KB
generate_metis_graph(File) :-
    format('~nGENERATING METIS GRAPH~n'),
    format('~`=t~80|~n'),
    
    % Load unified KB
    consult('unified_kb.pl'),
    
    % Collect all entities with shards
    findall(Entity-Shard, (
        (code(Path, _, _, Shard), Entity = Path) ;
        (data(Path, _, _, Shard), Entity = Path) ;
        (proof(Path, _, _, Shard), Entity = Path)
    ), Entities),
    
    length(Entities, NumVertices),
    format('Found ~w vertices~n', [NumVertices]),
    
    % Build adjacency list (edges based on usage/dependencies)
    findall(From-To, (
        member(From-_, Entities),
        member(To-_, Entities),
        From \= To,
        % Add edge if related (simplified - could use actual dependencies)
        atom_concat(_, '.rs', From),
        atom_concat(_, '.lean', To)
    ), Edges),
    
    length(Edges, NumEdges),
    format('Found ~w edges~n', [NumEdges]),
    
    % Write METIS format
    open(File, write, Stream),
    
    % Header: NumVertices NumEdges [fmt] [ncon]
    % fmt=0: no weights, fmt=1: edge weights, fmt=10: vertex weights, fmt=11: both
    format(Stream, '~w ~w 10~n', [NumVertices, NumEdges]),
    
    % For each vertex: [vsize] [vweight] adjacency_list
    forall(
        member(Entity-Shard, Entities),
        (
            % Vertex weight = shard number (for Monster Group partitioning)
            format(Stream, '~w ', [Shard]),
            
            % Adjacency list (vertex IDs of neighbors)
            findall(ToIdx, (
                member(To-_, Entities),
                member(Entity-To, Edges),
                nth1(ToIdx, Entities, To-_)
            ), Neighbors),
            
            forall(member(N, Neighbors), format(Stream, '~w ', [N])),
            format(Stream, '~n', [])
        )
    ),
    
    close(Stream),
    format('✅ Generated ~w~n', [File]).

% Generate Graphviz DOT format
generate_graphviz(File) :-
    format('~nGENERATING GRAPHVIZ~n'),
    format('~`=t~80|~n'),
    
    consult('unified_kb.pl'),
    
    open(File, write, Stream),
    
    format(Stream, 'digraph MonsterGraph {~n', []),
    format(Stream, '  rankdir=LR;~n', []),
    format(Stream, '  node [shape=box, style=filled];~n~n', []),
    
    % Color by shard (71 colors)
    format(Stream, '  // Nodes colored by Monster Group shard~n', []),
    
    % Add code nodes
    forall(
        code(Path, Lang, Godel, Shard),
        (
            % Color based on shard (hue = shard/71)
            Hue is Shard / 71.0,
            format(Stream, '  "~w" [label="~w\\n~w\\nShard ~w", fillcolor="~f,0.7,0.9"];~n',
                   [Path, Path, Lang, Shard, Hue])
        )
    ),
    
    % Add data nodes
    forall(
        data(Path, Format, Godel, Shard),
        (
            Hue is Shard / 71.0,
            format(Stream, '  "~w" [label="~w\\n~w\\nShard ~w", fillcolor="~f,0.5,0.9", shape=cylinder];~n',
                   [Path, Path, Format, Shard, Hue])
        )
    ),
    
    % Add proof nodes
    forall(
        proof(Path, System, Godel, Shard),
        (
            Hue is Shard / 71.0,
            format(Stream, '  "~w" [label="~w\\n~w\\nShard ~w", fillcolor="~f,0.9,0.9", shape=diamond];~n',
                   [Path, Path, System, Shard, Hue])
        )
    ),
    
    % Add edges (simplified - based on file relationships)
    format(Stream, '~n  // Edges~n', []),
    forall(
        (code(From, rust, _, _), code(To, lean4, _, _)),
        format(Stream, '  "~w" -> "~w" [color=gray];~n', [From, To])
    ),
    
    format(Stream, '}~n', []),
    close(Stream),
    
    format('✅ Generated ~w~n', [File]).

% Generate Tulip TLP format
generate_tulip(File) :-
    format('~nGENERATING TULIP TLP~n'),
    format('~`=t~80|~n'),
    
    consult('unified_kb.pl'),
    
    open(File, write, Stream),
    
    format(Stream, '(tlp "2.3"~n', []),
    format(Stream, '(date "2026-01-28")~n', []),
    format(Stream, '(author "zkPrologML")~n~n', []),
    
    % Nodes
    format(Stream, '; Nodes~n', []),
    
    findall(Entity-Shard, (
        (code(Path, _, _, Shard), Entity = Path) ;
        (data(Path, _, _, Shard), Entity = Path) ;
        (proof(Path, _, _, Shard), Entity = Path)
    ), Entities),
    
    forall(
        nth1(Idx, Entities, Entity-Shard),
        format(Stream, '(node ~w)~n', [Idx])
    ),
    
    % Edges
    format(Stream, '~n; Edges~n', []),
    
    forall(
        (nth1(FromIdx, Entities, From-_),
         nth1(ToIdx, Entities, To-_),
         FromIdx < ToIdx,
         atom_concat(_, '.rs', From),
         atom_concat(_, '.lean', To)),
        format(Stream, '(edge ~w ~w ~w)~n', [FromIdx, FromIdx, ToIdx])
    ),
    
    % Properties
    format(Stream, '~n; Properties~n', []),
    
    % Shard property
    format(Stream, '(property 0 int "shard"~n', []),
    format(Stream, '  (default "0" "0")~n', []),
    forall(
        nth1(Idx, Entities, _-Shard),
        format(Stream, '  (node ~w "~w")~n', [Idx, Shard])
    ),
    format(Stream, ')~n', []),
    
    % Label property
    format(Stream, '(property 0 string "viewLabel"~n', []),
    format(Stream, '  (default "" "")~n', []),
    forall(
        nth1(Idx, Entities, Entity-_),
        format(Stream, '  (node ~w "~w")~n', [Idx, Entity])
    ),
    format(Stream, ')~n', []),
    
    format(Stream, ')~n', []),
    close(Stream),
    
    format('✅ Generated ~w~n', [File]).

% Generate partition script for METIS
generate_metis_script(GraphFile, NumParts) :-
    format('~nGENERATING METIS PARTITION SCRIPT~n'),
    format('~`=t~80|~n'),
    
    open('partition.sh', write, Stream),
    
    format(Stream, '#!/bin/bash~n', []),
    format(Stream, '# Partition graph using METIS along Monster Group shards~n~n', []),
    
    format(Stream, 'echo "Partitioning ~w into ~w parts..."~n', [GraphFile, NumParts]),
    format(Stream, '~n', []),
    
    % METIS command
    % gpmetis: General graph partitioning
    % -ptype=rb: Recursive bisection
    % -ufactor=1: Imbalance factor
    format(Stream, 'gpmetis -ptype=rb -ufactor=1 ~w ~w~n', [GraphFile, NumParts]),
    format(Stream, '~n', []),
    
    format(Stream, 'echo "Partition complete!"~n', []),
    format(Stream, 'echo "Output: ~w.part.~w"~n', [GraphFile, NumParts]),
    
    close(Stream),
    
    % Make executable
    shell('chmod +x partition.sh'),
    
    format('✅ Generated partition.sh~n').

% Analyze partition results
analyze_partition(GraphFile, NumParts) :-
    format('~nANALYZING PARTITION~n'),
    format('~`=t~80|~n'),
    
    % Read partition file
    format(atom(PartFile), '~w.part.~w', [GraphFile, NumParts]),
    
    (   exists_file(PartFile)
    ->  format('Reading ~w...~n', [PartFile]),
        
        % Read partition assignments
        open(PartFile, read, Stream),
        read_partition_lines(Stream, Assignments),
        close(Stream),
        
        length(Assignments, NumVertices),
        format('~nPartition statistics:~n'),
        format('  Vertices: ~w~n', [NumVertices]),
        format('  Parts: ~w~n', [NumParts]),
        
        % Count vertices per part
        forall(
            between(0, NumParts-1, Part),
            (
                include(=(Part), Assignments, PartVertices),
                length(PartVertices, Count),
                format('  Part ~w: ~w vertices~n', [Part, Count])
            )
        )
    ;   format('⚠️  Partition file not found: ~w~n', [PartFile]),
        format('   Run: ./partition.sh~n')
    ).

read_partition_lines(Stream, []) :-
    at_end_of_stream(Stream), !.
read_partition_lines(Stream, [Part|Rest]) :-
    read_line_to_string(Stream, Line),
    atom_number(Line, Part),
    read_partition_lines(Stream, Rest).

% Main
main :-
    format('~nMETIS PARTITIONING + VISUALIZATION~n'),
    format('~`=t~80|~n'),
    
    % Generate graph formats
    generate_metis_graph('monster_graph.metis'),
    generate_graphviz('monster_graph.dot'),
    generate_tulip('monster_graph.tlp'),
    
    % Generate partition script (71 parts for 71 shards)
    generate_metis_script('monster_graph.metis', 71),
    
    % Try to analyze if partition exists
    analyze_partition('monster_graph.metis', 71),
    
    format('~n~n~`=t~80|~n'),
    format('QED: Graph partitioning ready!~n'),
    format('~`=t~80|~n'),
    
    format('~nNext steps:~n'),
    format('  1. Install METIS: sudo apt install metis~n'),
    format('  2. Run partition: ./partition.sh~n'),
    format('  3. Visualize DOT: dot -Tpng monster_graph.dot -o monster_graph.png~n'),
    format('  4. Open TLP: tulip monster_graph.tlp~n').

:- initialization(main, main).
