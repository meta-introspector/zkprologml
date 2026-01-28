#!/usr/bin/env python3
"""Load all 8M files into global object table"""

import pandas as pd

def main():
    print("\nLOADING 8M FILES INTO GLOBAL OBJECT TABLE")
    print("=" * 80)
    
    # Read parquet
    print("\nReading parquet...")
    df = pd.read_parquet('indexed_files_natural_classes.parquet')
    print(f"Loaded {len(df):,} files")
    
    # Generate Prolog facts
    print("\nGenerating Prolog facts...")
    
    with open('global_objects.pl', 'w') as f:
        f.write("% Global object table - 8M files\n")
        f.write("% object(godel, path, shard, type, meaning, usage, class)\n\n")
        f.write(":- dynamic object/7.\n\n")
        
        for idx, row in df.iterrows():
            godel = row['godel']
            shard = row['shard']
            path = row['compressed'].replace("'", "\\'")
            ext = row['extension'] if pd.notna(row['extension']) else 'unknown'
            meaning = row['meaning']
            usage = row['usage']
            cls = row['natural_class']
            
            f.write(f"object({godel}, '{path}', {shard}, '{ext}', '{meaning}', '{usage}', '{cls}').\n")
            
            if (idx + 1) % 100000 == 0:
                print(f"  Written {idx+1:,} objects...")
    
    print(f"\n✅ Generated global_objects.pl with {len(df):,} facts")
    
    # Generate query file
    print("\nGenerating query interface...")
    
    with open('query_global_table.pl', 'w') as f:
        f.write("""#!/usr/bin/env swipl
% query_global_table.pl - Query the global object table

:- consult('global_objects.pl').

% Query by shard
by_shard(Shard, Objects) :-
    findall(object(G, P, S, T, M, U, C),
            object(G, P, S, T, M, U, C),
            AllObjects),
    include(has_shard(Shard), AllObjects, Objects).

has_shard(Shard, object(_, _, Shard, _, _, _, _)).

% Query by class
by_class(Class, Objects) :-
    findall(object(G, P, S, T, M, U, C),
            object(G, P, S, T, M, U, C),
            AllObjects),
    include(has_class(Class), AllObjects, Objects).

has_class(Class, object(_, _, _, _, _, _, Class)).

% Count by shard
count_by_shard :-
    format('~nOBJECTS PER SHARD~n'),
    format('~`=t~60|~n'),
    forall(
        between(0, 70, Shard),
        (
            aggregate_all(count, object(_, _, Shard, _, _, _, _), Count),
            (Count > 0 -> format('Shard ~w: ~D objects~n', [Shard, Count]) ; true)
        )
    ).

% Count by class
count_by_class :-
    format('~nOBJECTS PER CLASS~n'),
    format('~`=t~60|~n'),
    forall(
        member(Class, [very_low, low, medium, high, very_high]),
        (
            aggregate_all(count, object(_, _, _, _, _, _, Class), Count),
            format('~w: ~D objects~n', [Class, Count])
        )
    ).

% Sample from shard
sample_shard(Shard, N) :-
    format('~nSAMPLE FROM SHARD ~w~n', [Shard]),
    format('~`-t~60|~n'),
    aggregate_all(count, object(_, _, Shard, _, _, _, _), Total),
    format('Total in shard: ~D~n~n', [Total]),
    forall(
        (object(G, P, Shard, T, M, U, C), between(1, N, _)),
        format('~w: ~w (~w, ~w)~n', [G, P, M, C])
    ).

% Main
main :-
    format('~nGLOBAL OBJECT TABLE QUERY~n'),
    format('~`=t~60|~n'),
    
    aggregate_all(count, object(_, _, _, _, _, _, _), Total),
    format('~nTotal objects: ~D~n', [Total]),
    
    count_by_shard,
    count_by_class,
    sample_shard(58, 5),
    
    format('~n~`=t~60|~n'),
    format('QED: Query complete!~n'),
    format('~`=t~60|~n').

:- initialization(main, main).
""")
    
    print("✅ Generated query_global_table.pl")
    
    # Statistics
    print("\n\nSTATISTICS")
    print("=" * 80)
    print(f"Total objects: {len(df):,}")
    print(f"Unique shards: {df['shard'].nunique()}")
    print(f"Unique Gödel numbers: {df['godel'].nunique()}")
    print(f"\nObjects per shard (mean): {len(df) / df['shard'].nunique():.0f}")
    print(f"Objects per Gödel (mean): {len(df) / df['godel'].nunique():.0f}")
    
    print("\n\n" + "=" * 80)
    print("QED: Global object table ready!")
    print("=" * 80)
    print("\nTo query:")
    print("  swipl -g main -t halt query_global_table.pl")

if __name__ == '__main__':
    main()
