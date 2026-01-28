# Generated from global_object_table.pl
# Prolog facts converted to Nix attribute sets

{
  # object(godel, path, shard, type, uses) facts
  objects = {
    "obj_12" = { godel = 12; path = "/usr/bin/rustc"; shard = 12; type = "executable"; uses = [/usr/lib/libstd.so]; };
    "obj_8" = { godel = 8; path = "/usr/lib/libstd.so"; shard = 8; type = "library"; uses = []; };
    "obj_42" = { godel = 42; path = "eigenvector_matrix.rs"; shard = 42; type = "source"; uses = [/usr/bin/rustc]; };
    "obj_53" = { godel = 53; path = "prove_eigenvector.lean"; shard = 53; type = "proof"; uses = []; };
  };

  # Metadata
  meta = {
    source = "global_object_table.pl";
    objectCount = 4;
    monsterMod = 71;
    shardCount = 71;
  };
}
