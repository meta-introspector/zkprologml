% Test objects for Nix conversion
:- dynamic object/5.

object(12, '/usr/bin/rustc', 12, executable, ['/usr/lib/libstd.so']).
object(8, '/usr/lib/libstd.so', 8, library, []).
object(42, 'eigenvector_matrix.rs', 42, source, ['/usr/bin/rustc']).
object(53, 'prove_eigenvector.lean', 53, proof, []).
