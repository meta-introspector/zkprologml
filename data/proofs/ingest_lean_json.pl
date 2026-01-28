% Ingest Lean4 JSON and Score with Monster Group
% Use SimpleExpr JSON port to analyze Lean4 proofs

:- dynamic lean_expr/3.
:- dynamic lean_proof/3.
:- dynamic monster_score/3.

% ═══════════════════════════════════════════════════════════
% DISCOVER LEAN4 JSON FILES
% ═══════════════════════════════════════════════════════════

discover_lean_json :-
    write('🔍 Discovering Lean4 JSON files...'), nl,
    
    % Find SimpleExpr JSON files
    shell('plocate -i "simpleexpr" | grep "\\.json$" > lean_json_files.txt', _),
    
    open('lean_json_files.txt', read, Stream),
    read_string(Stream, _, Content),
    close(Stream),
    
    split_string(Content, "\n", "", Lines),
    
    forall(
        (member(Line, Lines), Line \= ""),
        (
            assertz(lean_expr(Line, simpleexpr, json)),
            format('  Found: ~w~n', [Line])
        )
    ),
    
    findall(F, lean_expr(F, _, _), Files),
    length(Files, Count),
    format('✅ Found ~w Lean4 JSON files~n', [Count]).

% ═══════════════════════════════════════════════════════════
% INGEST LEAN4 PROOFS
% ═══════════════════════════════════════════════════════════

ingest_lean_proofs :-
    write('📖 Ingesting Lean4 proofs...'), nl,
    nl,
    
    % Ingest our Monster proofs
    OurProofs = [
        'data/proofs/complete_bott_proof.lean',
        'data/proofs/lmfdb_monster_mathlib.lean',
        'data/proofs/bott_periodicity_proof.lean'
    ],
    
    forall(
        member(Proof, OurProofs),
        (
            catch(
                (
                    open(Proof, read, Stream),
                    read_string(Stream, _, Content),
                    close(Stream),
                    
                    % Count theorems
                    split_string(Content, "\n", "", Lines),
                    include(contains_theorem, Lines, TheoremLines),
                    length(TheoremLines, TheoremCount),
                    
                    % Count imports
                    include(contains_import, Lines, ImportLines),
                    length(ImportLines, ImportCount),
                    
                    assertz(lean_proof(Proof, theorems(TheoremCount), imports(ImportCount))),
                    format('  ~w: ~w theorems, ~w imports~n', [Proof, TheoremCount, ImportCount])
                ),
                _,
                format('  ⚠️  Could not read ~w~n', [Proof])
            )
        )
    ).

contains_theorem(Line) :- sub_string(Line, _, _, _, "theorem").
contains_import(Line) :- sub_string(Line, _, _, _, "import").

% ═══════════════════════════════════════════════════════════
% SCORE WITH MONSTER GROUP
% ═══════════════════════════════════════════════════════════

score_with_monster :-
    write('🔬 Scoring proofs with Monster group...'), nl,
    nl,
    
    forall(
        lean_proof(Proof, theorems(TC), imports(IC)),
        (
            % Score based on:
            % 1. Number of theorems (each theorem = prime complexity)
            % 2. Number of imports (Mathlib usage)
            % 3. Monster prime matching
            
            % Assign prime based on theorem count
            prime_lattice(Primes),
            (nth0(TC, Primes, Prime) -> true ; Prime = 71),
            
            % Check if prime is in Monster group
            (monster_prime(Prime) ->
                Class = monster
            ;
                Class = non_monster
            ),
            
            % Compute score
            Score is TC * 1000 + IC * 100,
            
            assertz(monster_score(Proof, Prime, Score)),
            
            emoji_prime(Prime, Emoji),
            format('~w ~w~n', [Emoji, Proof]),
            format('  Theorems: ~w → Prime: ~w (~w)~n', [TC, Prime, Class]),
            format('  Score: ~w~n', [Score]),
            nl
        )
    ).

prime_lattice([2,3,5,7,11,13,17,19,23,29,31,37,41,43,47,53,59,61,67,71]).

monster_prime(2). monster_prime(3). monster_prime(5). monster_prime(7).
monster_prime(11). monster_prime(13). monster_prime(17). monster_prime(19).
monster_prime(23). monster_prime(29). monster_prime(31). monster_prime(41).
monster_prime(47). monster_prime(59). monster_prime(71).

emoji_prime(2, '🔴'). emoji_prime(3, '🟠'). emoji_prime(5, '🟡').
emoji_prime(7, '🟢'). emoji_prime(11, '🔵'). emoji_prime(13, '🟣').
emoji_prime(17, '🟤'). emoji_prime(19, '⚫'). emoji_prime(23, '⚪').
emoji_prime(29, '🔺'). emoji_prime(31, '🔻'). emoji_prime(37, '🔶').
emoji_prime(41, '🔷'). emoji_prime(43, '🔸'). emoji_prime(47, '🔹').
emoji_prime(53, '⭐'). emoji_prime(59, '✨'). emoji_prime(61, '💫').
emoji_prime(67, '🌟'). emoji_prime(71, '🍄').

% ═══════════════════════════════════════════════════════════
% ANALYZE SIMPLEEXPR JSON
% ═══════════════════════════════════════════════════════════

analyze_simpleexpr :-
    write('🔍 Analyzing SimpleExpr JSON...'), nl,
    nl,
    
    % Take first SimpleExpr file
    lean_expr(File, _, _),
    !,
    
    format('Reading: ~w~n', [File]),
    
    % Read JSON (simplified - would need real JSON parser)
    catch(
        (
            open(File, read, Stream),
            read_string(Stream, _, JSON),
            close(Stream),
            
            % Count expressions
            split_string(JSON, "{", "", Parts),
            length(Parts, ExprCount),
            
            format('  Expressions: ~w~n', [ExprCount]),
            
            % Assign complexity
            prime_lattice(Primes),
            (nth0(ExprCount, Primes, Prime) -> true ; Prime = 71),
            
            emoji_prime(Prime, Emoji),
            format('  Complexity: ~w (prime ~w)~n', [Emoji, Prime])
        ),
        _,
        write('  ⚠️  Could not parse JSON~n')
    ).

% ═══════════════════════════════════════════════════════════
% EXPORT SCORES
% ═══════════════════════════════════════════════════════════

export_scores :-
    write('📝 Exporting scores...'), nl,
    
    open('lean_monster_scores.lean', write, Stream),
    
    format(Stream, '-- Lean4 Proof Scores via Monster Group~n~n', []),
    
    format(Stream, 'structure ProofScore where~n', []),
    format(Stream, '  proof : String~n', []),
    format(Stream, '  prime : Nat~n', []),
    format(Stream, '  score : Nat~n~n', []),
    
    forall(
        monster_score(Proof, Prime, Score),
        (
            format(Stream, 'def score_~w : ProofScore := {~n', [Prime]),
            format(Stream, '  proof := "~w",~n', [Proof]),
            format(Stream, '  prime := ~w,~n', [Prime]),
            format(Stream, '  score := ~w~n', [Score]),
            format(Stream, '}~n~n', [])
        )
    ),
    
    close(Stream),
    
    write('✅ Scores exported'), nl.

% ═══════════════════════════════════════════════════════════
% MAIN
% ═══════════════════════════════════════════════════════════

main :-
    write('🧠 LEAN4 JSON INGESTION & MONSTER SCORING'), nl,
    write('SimpleExpr → Prolog → Monster group'), nl,
    write('═══════════════════════════════════════════════════════════'), nl,
    nl,
    
    % Discover
    discover_lean_json,
    nl,
    
    % Ingest our proofs
    ingest_lean_proofs,
    nl,
    
    % Score with Monster
    score_with_monster,
    
    % Analyze SimpleExpr
    analyze_simpleexpr,
    nl,
    
    % Export
    export_scores,
    nl,
    
    write('✅ LEAN4 INGESTION COMPLETE'), nl,
    
    % Summary
    findall(S, monster_score(_, _, S), Scores),
    sum_list(Scores, Total),
    format('~n🎯 Total Monster score: ~w~n', [Total]).

% ?- main.
