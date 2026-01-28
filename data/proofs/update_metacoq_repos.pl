% Find and Pull All MetaCoq Repos
% Use plocate + Prolog to discover, reason, and update

:- dynamic metacoq_repo/2.
:- dynamic repo_fork/3.
:- dynamic repo_updated/2.

% ═══════════════════════════════════════════════════════════
% DISCOVER: Find all MetaCoq repos
% ═══════════════════════════════════════════════════════════

discover_metacoq_repos :-
    write('🔍 Discovering MetaCoq repos...'), nl,
    
    % Find all directories with metacoq
    shell('plocate -i "metacoq" | grep -E "\.git$|/metacoq$" | head -50 > metacoq_repos.txt', _),
    
    open('metacoq_repos.txt', read, Stream),
    read_string(Stream, _, Content),
    close(Stream),
    
    split_string(Content, "\n", "", Lines),
    
    forall(
        (member(Line, Lines), Line \= ""),
        (
            % Extract repo path
            (sub_string(Line, _, _, _, ".git") ->
                atom_string(Path, Line),
                file_directory_name(Path, RepoDir)
            ;
                atom_string(RepoDir, Line)
            ),
            
            assertz(metacoq_repo(RepoDir, discovered)),
            format('  Found: ~w~n', [RepoDir])
        )
    ),
    
    findall(R, metacoq_repo(R, _), Repos),
    length(Repos, Count),
    format('✅ Found ~w MetaCoq repos~n', [Count]).

% ═══════════════════════════════════════════════════════════
% CHECK: Identify forks and upstreams
% ═══════════════════════════════════════════════════════════

check_forks :-
    write('🔗 Checking for forks...'), nl,
    nl,
    
    forall(
        metacoq_repo(Repo, _),
        (
            format('Checking: ~w~n', [Repo]),
            
            % Get git remote
            format(atom(Cmd), 'cd ~w && git remote -v 2>/dev/null | head -2', [Repo]),
            shell(Cmd, Output),
            
            % Check if it's a fork
            (sub_string(Output, _, _, _, "meta-introspector") ->
                (
                    assertz(repo_fork(Repo, meta_introspector, fork)),
                    write('  → Fork of meta-introspector~n')
                )
            ; sub_string(Output, _, _, _, "metacoq") ->
                (
                    assertz(repo_fork(Repo, upstream, original)),
                    write('  → Upstream MetaCoq~n')
                )
            ;
                write('  → Unknown origin~n')
            )
        )
    ),
    nl.

% ═══════════════════════════════════════════════════════════
% UPDATE: Pull latest from all repos
% ═══════════════════════════════════════════════════════════

update_repos :-
    write('📥 Updating all repos...'), nl,
    nl,
    
    forall(
        metacoq_repo(Repo, _),
        (
            format('Updating: ~w~n', [Repo]),
            
            % Git pull
            format(atom(PullCmd), 'cd ~w && git pull 2>&1', [Repo]),
            shell(PullCmd, PullOutput),
            
            % Check result
            (sub_string(PullOutput, _, _, _, "Already up to date") ->
                (
                    assertz(repo_updated(Repo, up_to_date)),
                    write('  ✓ Already up to date~n')
                )
            ; sub_string(PullOutput, _, _, _, "Updating") ->
                (
                    assertz(repo_updated(Repo, updated)),
                    write('  ✓ Updated~n')
                )
            ;
                (
                    assertz(repo_updated(Repo, failed)),
                    write('  ✗ Failed~n')
                )
            )
        )
    ),
    nl.

% ═══════════════════════════════════════════════════════════
% FIND: Get latest commits
% ═══════════════════════════════════════════════════════════

get_latest_commits :-
    write('📝 Getting latest commits...'), nl,
    nl,
    
    forall(
        metacoq_repo(Repo, _),
        (
            format('~w:~n', [Repo]),
            
            % Get latest commit
            format(atom(LogCmd), 'cd ~w && git log -1 --oneline 2>/dev/null', [Repo]),
            shell(LogCmd, Commit),
            
            format('  ~w~n', [Commit])
        )
    ),
    nl.

% ═══════════════════════════════════════════════════════════
% EXPORT: Generate Nix flake for all repos
% ═══════════════════════════════════════════════════════════

export_nix_flake :-
    write('📝 Generating Nix flake...'), nl,
    
    open('metacoq_repos.nix', write, Stream),
    
    format(Stream, '{ pkgs ? import <nixpkgs> {} }:~n~n', []),
    format(Stream, 'let~n', []),
    format(Stream, '  # All MetaCoq repos discovered~n', []),
    format(Stream, '  metacoqRepos = [~n', []),
    
    forall(
        metacoq_repo(Repo, _),
        format(Stream, '    "~w"~n', [Repo])
    ),
    
    format(Stream, '  ];~n~n', []),
    
    format(Stream, 'in pkgs.buildEnv {~n', []),
    format(Stream, '  name = "metacoq-all-repos";~n', []),
    format(Stream, '  paths = metacoqRepos;~n', []),
    format(Stream, '}~n', []),
    
    close(Stream),
    
    write('✅ Nix flake generated: metacoq_repos.nix'), nl.

% ═══════════════════════════════════════════════════════════
% MAIN
% ═══════════════════════════════════════════════════════════

main :-
    write('🧠 METACOQ REPO DISCOVERY & UPDATE'), nl,
    write('Find → Check forks → Pull latest'), nl,
    write('═══════════════════════════════════════════════════════════'), nl,
    nl,
    
    % Discover
    discover_metacoq_repos,
    nl,
    
    % Check forks
    check_forks,
    
    % Update
    update_repos,
    
    % Get commits
    get_latest_commits,
    
    % Export Nix
    export_nix_flake,
    nl,
    
    write('✅ ALL REPOS UPDATED'), nl,
    
    % Summary
    findall(R, repo_updated(R, updated), Updated),
    findall(R, repo_updated(R, up_to_date), UpToDate),
    length(Updated, UpdatedCount),
    length(UpToDate, UpToDateCount),
    format('~n🎯 Updated: ~w, Already up to date: ~w~n', [UpdatedCount, UpToDateCount]).

% ?- main.
