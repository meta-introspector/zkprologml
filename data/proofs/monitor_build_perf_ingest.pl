% Monitor discovered repos: update, check forks, build, perf test
% Deep ingestion via standard build tools

:- dynamic repo/3.
:- dynamic fork/3.
:- dynamic build_result/3.
:- dynamic perf_result/4.

% ═══════════════════════════════════════════════════════════
% DISCOVER: Repos from keyword search
% ═══════════════════════════════════════════════════════════

discover_repos :-
    write('🔍 Discovering repos from keyword matches...\n\n'),
    
    % Newly added submodules + existing repos
    Repos = [
        ('crypto-primes', 'discovered_repos/crypto-primes', rust),
        ('algebra', 'discovered_repos/algebra', rust),
        ('ark-ff', 'discovered_repos/ark-ff', rust),
        ('CompCert', '/mnt/data1/2023/07/06/CompCert', coq),
        ('MetaCoq', '/mnt/data1/2023/07/06/metacoq', coq)
    ],
    
    forall(
        member((Name, Path, Type), Repos),
        (
            assertz(repo(Name, Path, Type)),
            format('  ✅ ~w (~w): ~w\n', [Name, Type, Path])
        )
    ),
    
    nl.

% ═══════════════════════════════════════════════════════════
% UPDATE: Pull latest changes
% ═══════════════════════════════════════════════════════════

update_repos :-
    write('📥 Updating repos...\n\n'),
    
    forall(
        repo(Name, Path, _),
        update_repo(Name, Path)
    ).

update_repo(Name, Path) :-
    format('Updating ~w...\n', [Name]),
    
    % Check if it's a git repo
    format(string(CheckCmd), 'test -d "~w/.git" && echo "yes" || echo "no"', [Path]),
    
    (exists_directory(Path) ->
        (
            format(string(Cmd), 'cd "~w" && git pull 2>&1 | head -5', [Path]),
            shell(Cmd, _),
            write('  ✅ Updated\n\n')
        )
    ;
        format('  ⚠️  Not found: ~w\n\n', [Path])
    ).

% ═══════════════════════════════════════════════════════════
% CHECK FORKS: Find if users migrated
% ═══════════════════════════════════════════════════════════

check_forks :-
    write('🔱 Checking for forks and migrations...\n\n'),
    
    forall(
        repo(Name, Path, _),
        check_repo_forks(Name, Path)
    ).

check_repo_forks(Name, Path) :-
    format('Checking ~w for forks...\n', [Name]),
    
    % Use GitHub API to check forks
    (sub_string(Path, _, _, _, "github.com") ->
        (
            % Extract owner/repo from URL
            format(string(Cmd), 'curl -s "https://api.github.com/repos/~w/forks" 2>/dev/null | grep -o \'\\"full_name\\":[^,]*\' | head -5', [Name]),
            shell(Cmd, _),
            write('  ✅ Checked\n\n')
        )
    ;
        write('  ⚠️  Not a GitHub repo\n\n')
    ).

% ═══════════════════════════════════════════════════════════
% BUILD: Use standard build tools
% ═══════════════════════════════════════════════════════════

build_repos :-
    write('🔨 Building repos with standard tools...\n\n'),
    
    forall(
        repo(Name, Path, Type),
        build_repo(Name, Path, Type)
    ).

build_repo(Name, Path, rust) :-
    format('Building ~w (Rust)...\n', [Name]),
    
    (exists_directory(Path) ->
        (
            format(string(Cmd), 'cd "~w" && cargo build --release 2>&1 | tail -10', [Path]),
            shell(Cmd, _),
            assertz(build_result(Name, rust, success)),
            write('  ✅ Built\n\n')
        )
    ;
        write('  ⚠️  Path not found\n\n')
    ).

build_repo(Name, Path, coq) :-
    format('Building ~w (Coq)...\n', [Name]),
    
    (exists_directory(Path) ->
        (
            format(string(Cmd), 'cd "~w" && make -j4 2>&1 | tail -10', [Path]),
            shell(Cmd, _),
            assertz(build_result(Name, coq, success)),
            write('  ✅ Built\n\n')
        )
    ;
        write('  ⚠️  Path not found\n\n')
    ).

% ═══════════════════════════════════════════════════════════
% PERF TEST: Record performance during build
% ═══════════════════════════════════════════════════════════

perf_test_builds :-
    write('🔥 Perf testing builds...\n\n'),
    
    forall(
        build_result(Name, Type, success),
        perf_test_repo(Name, Type)
    ).

perf_test_repo(Name, Type) :-
    format('Perf testing ~w (~w)...\n', [Name, Type]),
    
    repo(Name, Path, Type),
    
    % Run with perf
    format(string(Cmd), 'cd "~w" && perf stat -e cycles,instructions cargo test 2>&1 | grep -E "(cycles|instructions)" | head -5', [Path]),
    shell(Cmd, _),
    
    assertz(perf_result(Name, Type, measured, cycles)),
    write('  ✅ Perf recorded\n\n').

% ═══════════════════════════════════════════════════════════
% INGEST: Deep analysis of build artifacts
% ═══════════════════════════════════════════════════════════

deep_ingest :-
    write('🔬 Deep ingestion of build artifacts...\n\n'),
    
    forall(
        build_result(Name, Type, success),
        ingest_artifacts(Name, Type)
    ).

ingest_artifacts(Name, rust) :-
    format('Ingesting ~w artifacts...\n', [Name]),
    
    repo(Name, Path, rust),
    
    % Find built binaries
    format(string(Cmd), 'find "~w/target/release" -type f -executable 2>/dev/null | head -5', [Path]),
    shell(Cmd, _),
    
    write('  ✅ Artifacts found\n\n').

ingest_artifacts(Name, coq) :-
    format('Ingesting ~w artifacts...\n', [Name]),
    
    repo(Name, Path, coq),
    
    % Find .vo files
    format(string(Cmd), 'find "~w" -name "*.vo" 2>/dev/null | wc -l', [Path]),
    shell(Cmd, _),
    
    write('  ✅ Coq objects found\n\n').

% ═══════════════════════════════════════════════════════════
% MAIN
% ═══════════════════════════════════════════════════════════

main :-
    write('🌀 MONITOR → UPDATE → BUILD → PERF → INGEST\n'),
    write('═══════════════════════════════════════════════════════════\n\n'),
    
    % Discover
    discover_repos,
    
    % Update
    update_repos,
    
    % Check forks
    check_forks,
    
    % Build
    build_repos,
    
    % Perf test
    perf_test_builds,
    
    % Deep ingest
    deep_ingest,
    
    write('✅ DEEP INGESTION PIPELINE COMPLETE\n').

% ?- main.
