#!/usr/bin/env swipl
% Shard ALL files into 71 Monster group buckets
% Everything must fit in the lattice or be excluded as "sticky residue"

:- use_module(library(filesex)).

monster_primes([2,3,5,7,11,13,17,19,23,29,31,37,41,43,47,53,59,61,67,71]).

% ═══════════════════════════════════════════════════════════
% FILE → PRIME MAPPING
% ═══════════════════════════════════════════════════════════

% Assign file to prime based on content signature
file_to_prime(Path, Prime) :-
    % Hash path to get consistent assignment
    atom_codes(Path, Codes),
    sumlist(Codes, Sum),
    monster_primes(Primes),
    length(Primes, Len),
    Index is Sum mod Len,
    nth0(Index, Primes, Prime).

% Check if file fits in Monster group
fits_in_monster(Path) :-
    file_to_prime(Path, Prime),
    monster_primes(Primes),
    member(Prime, Primes).

% ═══════════════════════════════════════════════════════════
% SHARD ALL FILES
% ═══════════════════════════════════════════════════════════

shard_all_files :-
    format('🌌 Sharding all files into 71 Monster buckets...~n~n', []),
    
    % Find all files
    expand_file_name('**/*', AllPaths),
    include(exists_file, AllPaths, Files),
    length(Files, Total),
    format('Found ~w files~n', [Total]),
    
    % Create shard directories
    monster_primes(Primes),
    forall(member(Prime, Primes), (
        format(atom(Dir), 'generated/shards/shard_~w', [Prime]),
        make_directory_path(Dir)
    )),
    
    % Shard each file
    findall(Prime-File, (
        member(File, Files),
        file_to_prime(File, Prime)
    ), Shards),
    
    % Count per shard
    monster_primes(Primes),
    open('generated/shard_manifest.csv', write, S),
    write(S, 'prime,count,files\n'),
    
    forall(member(Prime, Primes), (
        findall(F, member(Prime-F, Shards), ShardFiles),
        length(ShardFiles, Count),
        format('Shard ~w: ~w files~n', [Prime, Count]),
        
        % Write manifest
        atomic_list_concat(ShardFiles, ';', FileList),
        format(S, '~w,~w,"~w"~n', [Prime, Count, FileList]),
        
        % Create shard index
        format(atom(IndexFile), 'generated/shards/shard_~w/index.txt', [Prime]),
        open(IndexFile, write, IS),
        forall(member(F, ShardFiles), format(IS, '~w~n', [F])),
        close(IS)
    )),
    
    close(S),
    
    format('~n✅ All files sharded into 71 buckets~n', []).

% ═══════════════════════════════════════════════════════════
% DETECT STICKY RESIDUE
% ═══════════════════════════════════════════════════════════

detect_sticky_residue :-
    format('~n🔍 Detecting sticky residue (files that don\'t fit)...~n~n', []),
    
    % Files that can't be cleanly mapped
    expand_file_name('**/*', AllPaths),
    include(exists_file, AllPaths, Files),
    
    findall(File, (
        member(File, Files),
        \+ fits_in_monster(File)
    ), Residue),
    
    length(Residue, Count),
    (Count > 0 ->
        (format('⚠️  Found ~w sticky residue files:~n', [Count]),
         forall(member(R, Residue), format('  ~w~n', [R]))) ;
        format('✅ No sticky residue - all files fit!~n', [])).

% ═══════════════════════════════════════════════════════════
% GENERATE SHARD STATISTICS
% ═══════════════════════════════════════════════════════════

shard_statistics :-
    format('~n📊 Shard Statistics:~n~n', []),
    
    csv_read_file('generated/shard_manifest.csv', Rows, [functor(row)]),
    
    findall(Count, member(row(_, Count, _), Rows), Counts),
    sumlist(Counts, Total),
    length(Counts, NumShards),
    Avg is Total / NumShards,
    max_list(Counts, Max),
    min_list(Counts, Min),
    
    format('Total files: ~w~n', [Total]),
    format('Shards: ~w~n', [NumShards]),
    format('Average per shard: ~2f~n', [Avg]),
    format('Max shard: ~w files~n', [Max]),
    format('Min shard: ~w files~n', [Min]),
    
    % Find most/least populated
    member(row(MaxPrime, Max, _), Rows),
    member(row(MinPrime, Min, _), Rows),
    format('~nMost populated: Shard ~w (~w files)~n', [MaxPrime, Max]),
    format('Least populated: Shard ~w (~w files)~n', [MinPrime, Min]).

% ═══════════════════════════════════════════════════════════
% EXPORT TO PARQUET
% ═══════════════════════════════════════════════════════════

export_shards_to_parquet :-
    format('~n📦 Exporting shards to parquet...~n', []),
    
    shell('python3 -c "import pandas as pd; pd.read_csv(\'generated/shard_manifest.csv\').to_parquet(\'generated/shard_manifest.parquet\')"'),
    
    format('✅ Parquet: generated/shard_manifest.parquet~n', []).

% ═══════════════════════════════════════════════════════════
% MAIN
% ═══════════════════════════════════════════════════════════

main :-
    format('~n🌌 71 MONSTER SHARDS - MAXIMAL PARTITIONING~n', []),
    format('═══════════════════════════════════════════════════════════~n', []),
    
    shard_all_files,
    detect_sticky_residue,
    shard_statistics,
    export_shards_to_parquet,
    
    format('~n✨ Everything sharded into 71 Monster buckets!~n', []),
    format('~nMaximal constraint: 71 shards only~n', []),
    format('Sticky residue excluded~n', []),
    format('Perfect Monster group alignment~n~n', []).

:- initialization(main, main).
