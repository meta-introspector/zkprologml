{ pkgs ? import <nixpkgs> {} }:

let
  # Clone all translators
  coq-of-rust = pkgs.fetchFromGitHub {
    owner = "formal-land";
    repo = "coq-of-rust";
    rev = "main";
    sha256 = pkgs.lib.fakeSha256;
  };

  coq-of-ocaml = pkgs.fetchFromGitHub {
    owner = "formal-land";
    repo = "coq-of-ocaml";
    rev = "main";
    sha256 = pkgs.lib.fakeSha256;
  };

  coq-of-ts = pkgs.fetchFromGitHub {
    owner = "formal-land";
    repo = "coq-of-ts";
    rev = "main";
    sha256 = pkgs.lib.fakeSha256;
  };

  compcert = pkgs.compcert;

in pkgs.mkShell {
  name = "universal-coq-consumer";

  buildInputs = with pkgs; [
    # Coq ecosystem
    coq
    coqPackages.metacoq
    
    # CompCert for C → Coq
    compcert
    
    # Rust toolchain for coq-of-rust
    rustc
    cargo
    
    # OCaml for coq-of-ocaml
    ocaml
    dune_3
    
    # TypeScript for coq-of-ts
    nodejs
    typescript
    
    # Prolog
    swiProlog
    
    # Build tools
    git
    gnumake
    
    # Our tools
    gcc
    clang
    perf-tools
  ];

  shellHook = ''
    echo "🌟 Universal Coq Consumer Environment"
    echo "======================================"
    echo ""
    echo "Available translators:"
    echo "  ✅ Rust → Coq (coq-of-rust)"
    echo "  ✅ OCaml → Coq (coq-of-ocaml)"
    echo "  ✅ TypeScript → Coq (coq-of-ts)"
    echo "  ✅ C → Coq (CompCert)"
    echo "  ✅ Prolog → Coq (self-hosting)"
    echo ""
    echo "Run: swipl -g main -t halt universal_coq_consumer.pl"
    echo ""
    
    # Set up paths
    export COQ_OF_RUST="${coq-of-rust}"
    export COQ_OF_OCAML="${coq-of-ocaml}"
    export COQ_OF_TS="${coq-of-ts}"
    export COMPCERT="${compcert}"
    
    # Build coq-of-rust if needed
    if [ ! -f "$COQ_OF_RUST/target/release/coq-of-rust" ]; then
      echo "Building coq-of-rust..."
      cd "$COQ_OF_RUST" && cargo build --release
    fi
  '';
}
