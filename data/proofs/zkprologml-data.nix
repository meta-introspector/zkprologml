# zkPrologML Data Module
# Import Prolog facts as Nix attribute sets

{ pkgs ? import <nixpkgs> {} }:

let
  # Import generated data
  globalObjects = import ./global_objects.nix;

  # Helper functions
  getObjectByShard = shard:
    builtins.filter (obj: obj.shard == shard)
      (builtins.attrValues globalObjects.objects);

  getObjectByGodel = godel:
    builtins.filter (obj: obj.godel == godel)
      (builtins.attrValues globalObjects.objects);

  countByShard = shard:
    builtins.length (getObjectByShard shard);

in {
  inherit globalObjects;
  inherit getObjectByShard getObjectByGodel countByShard;

  # Metadata
  meta = globalObjects.meta // {
    description = "zkPrologML Monster Group Data";
    version = "0.1.0";
  };
}
