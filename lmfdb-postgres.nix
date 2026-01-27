{ pkgs ? import <nixpkgs> {} }:

let
  lmfdb-postgres = pkgs.stdenv.mkDerivation {
    name = "lmfdb-postgres-server";
    version = "1.0.0";
    
    buildInputs = with pkgs; [
      postgresql_16
      python311
      python311Packages.psycopg2
      python311Packages.sqlalchemy
      python311Packages.pandas
      python311Packages.pyarrow
      python311Packages.huggingface-hub
      sage
      magma
      perf
    ];
    
    shellHook = ''
      export PGDATA=$PWD/postgres_data
      export PGHOST=$PWD/postgres
      export PGPORT=5433
      export DATABASE_URL="postgresql:///$USER?host=$PGHOST&port=$PGPORT"
      
      echo "🗄️  LMFDB Postgres Server"
      echo "   Data: $PGDATA"
      echo "   Port: $PGPORT"
      
      if [ ! -d "$PGDATA" ]; then
        echo "📦 Initializing database..."
        initdb -D $PGDATA
        echo "host all all 127.0.0.1/32 trust" >> $PGDATA/pg_hba.conf
      fi
      
      echo "🚀 Start server: pg_ctl -D $PGDATA -l logfile start"
      echo "🛑 Stop server: pg_ctl -D $PGDATA stop"
    '';
  };
in
lmfdb-postgres
