// Tau-Prolog facts for zkPrologML dashboard
// Load with: session.consult(tauFacts)

const tauFacts = `
% Code files
code('load_global_table.rs', rust, 42, 42).
code('update_parquet_formal.rs', rust, 43, 43).
code('eigenvector_matrix.rs', rust, 44, 44).
code('global_object_table.pl', prolog, 33, 33).
code('prolog_to_nix.pl', prolog, 34, 34).
code('power_of_2_model.pl', prolog, 35, 35).
code('prove_eigenvector.lean', lean4, 53, 53).
code('eigenvector_matrix.lean', lean4, 54, 54).
code('prove_all_databases_monster.lean', lean4, 55, 55).
code('eigenvector_matrix.mzn', minizinc, 12, 12).
code('find_eigenvector.mzn', minizinc, 13, 13).
code('deep_insights.py', python, 60, 60).
code('learn_interesting_bytes.py', python, 61, 61).
code('parse_formal_files.py', python, 62, 62).

% Data files
data('master.parquet', parquet, 70, 70).
data('global_objects.pl', prolog, 71, 0).
data('global_objects.nix', nix, 72, 1).
data('eigenvector_class_summary.csv', csv, 73, 2).
data('learned_byte_patterns.json', json, 74, 3).

% Proofs
proof('prove_eigenvector.lean', lean4, 53, 53).
proof('eigenvector_matrix.lean', lean4, 54, 54).
proof('prove_all_databases_monster.lean', lean4, 55, 55).

% Theorems
theorem(eigenvector_in_monster, lean4, true).
theorem(transform_preserves_monster, lean4, true).
theorem(eigenvector_is_automorphic, lean4, true).
theorem(classify_total, lean4, true).
theorem(classify_deterministic, lean4, true).
theorem(classes_disjoint, lean4, true).
theorem(all_godel_valid, prolog, true).
theorem(godel_equals_shard, prolog, true).
theorem(usage_graph_acyclic, prolog, true).
theorem(table_complete, prolog, true).

% Systems
system(oeis, 0, 'Online Encyclopedia of Integer Sequences').
system(lmfdb, 1, 'L-functions and Modular Forms Database').
system(zoo, 2, 'Complexity Zoo').
system(github, 3, 'Source Code Repository').
system(huggingface, 4, 'ML Models Hub').
system(wikidata, 5, 'Structured Knowledge Base').
system(uml, 6, 'Unified Modeling Language').
system(c4, 7, 'C4 Architecture Model').
system(itil, 8, 'IT Service Management').
system(monster, 9, 'Monster Group').

% Query predicates
by_shard(Shard, Path) :- code(Path, _, _, Shard).
by_shard(Shard, Path) :- data(Path, _, _, Shard).
by_shard(Shard, Path) :- proof(Path, _, _, Shard).

by_language(Lang, Path) :- code(Path, Lang, _, _).

proven_theorems(Name) :- theorem(Name, _, true).
`;
