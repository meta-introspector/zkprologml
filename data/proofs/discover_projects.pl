% discover_projects.pl - Calculate and rank projects to scan

:- use_module(library(csv)).

% ═══════════════════════════════════════════════════════════
% LOAD CURRENT KNOWLEDGE
% ═══════════════════════════════════════════════════════════

:- dynamic file_knowledge/10.
:- dynamic project/3.  % name, score, reason

load_enriched_files :-
    csv_read_file('generated/files_enriched_monster.csv', Rows, []),
    forall(
        (member(Row, Rows), 
         Row =.. [row|Fields],
         length(Fields, L), L >= 9,
         nth0(0, Fields, Path),
         atom(Path)),
        assertz(file_knowledge(Path, _, _, _, _, _, _, _, _, _))
    ),
    aggregate_all(count, file_knowledge(_, _, _, _, _, _, _, _, _, _), C),
    format('  ✅ ~w files loaded~n', [C]).

% ═══════════════════════════════════════════════════════════
% DISCOVER RELATED PROJECTS
% ═══════════════════════════════════════════════════════════

% Projects we already have
known_project('coq-of-rust', 'Coq verification of Rust').
known_project('zkprologml', 'This project').
known_project('scryer-prolog', 'Native Rust Prolog').

% Calculate related projects based on our focus
related_project('lean4', 100, 'Proof assistant - prime 61').
related_project('rocq', 95, 'Coq renamed - formal verification').
related_project('isabelle', 90, 'Proof assistant - HOL').
related_project('agda', 85, 'Dependent types - proof assistant').
related_project('idris2', 80, 'Dependent types - Rust-like').
related_project('rust-analyzer', 95, 'Rust tooling - prime 2').
related_project('rustc', 100, 'Rust compiler - foundation').
related_project('llvm', 90, 'Compiler infrastructure - prime 41').
related_project('gcc', 85, 'GNU compiler - bootstrap').
related_project('mes', 100, 'Minimal bootstrap - prime 23').
related_project('arrow-rs', 95, 'Parquet/Arrow in Rust').
related_project('polars', 90, 'Fast dataframes - Rust').
related_project('duckdb', 95, 'Analytical database - parquet').
related_project('prolog-analyzer', 80, 'Prolog tooling - prime 71').
related_project('tau-prolog', 75, 'Prolog in JavaScript').
related_project('swi-prolog', 90, 'Standard Prolog').
related_project('minizinc', 85, 'Constraint solving - prime 29').
related_project('z3', 90, 'SMT solver - verification').
related_project('cvc5', 85, 'SMT solver - verification').
related_project('vampire', 80, 'Theorem prover').

% Score projects based on our needs
score_project(Name, Score, Reason) :-
    related_project(Name, BaseScore, BaseReason),
    
    % Boost if we have related files
    (has_related_files(Name) -> 
        Boost = 10, BoostReason = ' +10 (related files)'
    ;   Boost = 0, BoostReason = ''),
    
    % Boost if matches our primes
    (matches_prime_focus(Name) ->
        PrimeBoost = 5, PrimeReason = ' +5 (prime match)'
    ;   PrimeBoost = 0, PrimeReason = ''),
    
    Score is BaseScore + Boost + PrimeBoost,
    format(atom(Reason), '~w~w~w', [BaseReason, BoostReason, PrimeReason]).

has_related_files(Name) :-
    file_knowledge(Path, _, _, _, _, _, _, _, _, _),
    atom_string(Path, PathStr),
    atom_string(Name, NameStr),
    sub_string(PathStr, _, _, _, NameStr).

matches_prime_focus('lean4').
matches_prime_focus('rust-analyzer').
matches_prime_focus('rustc').
matches_prime_focus('scryer-prolog').
matches_prime_focus('swi-prolog').
matches_prime_focus('minizinc').

% ═══════════════════════════════════════════════════════════
% RANK AND OUTPUT
% ═══════════════════════════════════════════════════════════

rank_projects :-
    format('~n🎯 RANKING PROJECTS TO SCAN~n', []),
    format('═══════════════════════════════════════════════════════════~n~n', []),
    
    findall(Score-Name-Reason, score_project(Name, Score, Reason), Projects),
    sort(Projects, Sorted),
    reverse(Sorted, Ranked),
    
    format('Top 20 projects to scan:~n~n', []),
    forall(
        (member(Score-Name-Reason, Ranked), Score >= 80),
        format('  ~w. ~w (~w)~n', [Score, Name, Reason])
    ),
    
    % Save to CSV
    open('generated/projects_to_scan.csv', write, S),
    write(S, 'rank,name,score,reason\n'),
    Rank = 1,
    forall(
        member(Score-Name-Reason, Ranked),
        (
            format(S, '~w,~w,~w,~w~n', [Rank, Name, Score, Reason]),
            Rank2 is Rank + 1
        )
    ),
    close(S),
    
    format('~n✅ Saved to generated/projects_to_scan.csv~n', []).

% Generate scan commands
generate_scan_commands :-
    format('~n📋 SCAN COMMANDS~n', []),
    format('═══════════════════════════════════════════════════════════~n~n', []),
    
    findall(Score-Name, score_project(Name, Score, _), Projects),
    sort(Projects, Sorted),
    reverse(Sorted, Ranked),
    
    open('generated/scan_commands.sh', write, S),
    write(S, '#!/bin/bash\n'),
    write(S, '# Auto-generated scan commands\n\n'),
    
    forall(
        (member(Score-Name, Ranked), Score >= 90),
        (
            format(S, 'echo "Scanning ~w..."~n', [Name]),
            format(S, 'git clone https://github.com/~w/~w || true~n', [Name, Name]),
            format(S, 'cd ~w && find . -type f | wc -l~n', [Name]),
            format(S, 'cd ..~n~n', [])
        )
    ),
    
    close(S),
    format('✅ Saved to generated/scan_commands.sh~n', []).

% Main
main :-
    format('🔍 DISCOVERING PROJECTS TO SCAN~n', []),
    format('═══════════════════════════════════════════════════════════~n~n', []),
    
    format('📦 Loading current knowledge...~n', []),
    load_enriched_files,
    
    rank_projects,
    generate_scan_commands,
    
    format('~n✨ Project discovery complete!~n', []),
    format('~nNext steps:~n', []),
    format('  1. Review generated/projects_to_scan.csv~n', []),
    format('  2. Run generated/scan_commands.sh~n', []),
    format('  3. Enrich new files with Monster numbers~n', []).
