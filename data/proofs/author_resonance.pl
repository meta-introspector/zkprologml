% Author Resonance: Discover and honor important but underappreciated work
% Find authors whose contributions resonate with our ontology

:- module(author_resonance, [
    analyze_all_authors/0,
    register_important_author/3,
    compute_author_resonance/2,
    find_underappreciated_authors/1,
    analyze_author_commits/2
]).

:- use_module(bootstrap, [model_unknown_terms/1]).
:- use_module(libp2p_trust, [trust_score/3]).

% ============================================================================
% IMPORTANT AUTHORS (Dynamic Discovery)
% ============================================================================

% author(Name, Reason, Status)
:- dynamic important_author/3.

% Seed authors we know are important
seed_important_authors :-
    register_important_author('meta-introspector', 'Project creator', alive),
    register_important_author('Vladimir Voevodsky', 'HoTT founder, needs more attention', deceased),
    register_important_author('Daniel Biss', 'K-theory, Bott periodicity', unknown),
    register_important_author('John Adams', 'Stable homotopy theory', unknown).

register_important_author(Name, Reason, Status) :-
    (important_author(Name, _, _) ->
        true  % Already registered
    ;
        assertz(important_author(Name, Reason, Status)),
        format('📌 Registered: ~w (~w)~n', [Name, Reason])
    ).

% ============================================================================
% DISCOVER AUTHORS FROM REPOSITORIES
% ============================================================================

% Scan all discovered repos and find authors
discover_authors_from_repos :-
    format('🔍 Discovering authors from repositories...~n', []),
    findall(Repo, (
        exists_directory('discovered_repos'),
        directory_files('discovered_repos', Entries),
        member(Repo, Entries),
        Repo \= '.',
        Repo \= '..'
    ), Repos),
    maplist(analyze_repo_authors, Repos).

analyze_repo_authors(Repo) :-
    format(atom(RepoPath), 'discovered_repos/~w', [Repo]),
    (exists_directory(RepoPath) ->
        format(atom(Cmd), 'cd ~w && git log --all --format="%an|%ae" 2>/dev/null | sort -u', [RepoPath]),
        setup_call_cleanup(
            open(pipe(Cmd), read, Stream),
            read_authors(Stream, Repo),
            close(Stream)
        )
    ;
        true
    ).

:- dynamic discovered_author/3.  % author(Name, Email, Repos)

read_authors(Stream, Repo) :-
    read_line_to_string(Stream, Line),
    (Line == end_of_file ->
        true
    ;
        split_string(Line, "|", "", [Name, Email]),
        store_author(Name, Email, Repo),
        read_authors(Stream, Repo)
    ).

store_author(Name, Email, Repo) :-
    (discovered_author(Name, Email, Repos) ->
        retract(discovered_author(Name, Email, Repos)),
        assertz(discovered_author(Name, Email, [Repo|Repos]))
    ;
        assertz(discovered_author(Name, Email, [Repo]))
    ).

% ============================================================================
% COMPUTE AUTHOR RESONANCE
% ============================================================================

% Resonance = how aligned is this author with our ontology?
compute_author_resonance(Author, Resonance) :-
    discovered_author(Author, _, Repos),
    % Compute based on:
    % 1. Number of repos (breadth)
    length(Repos, RepoCount),
    % 2. Commit frequency analysis
    author_commit_primes(Author, Primes),
    length(Primes, CommitCount),
    % 3. Ontological alignment (shared concepts)
    author_concepts(Author, Concepts),
    our_concepts(OurConcepts),
    intersection(Concepts, OurConcepts, Shared),
    length(Shared, SharedCount),
    length(OurConcepts, OurCount),
    % Compute resonance score
    Breadth is min(RepoCount / 10.0, 1.0),
    Activity is min(CommitCount / 100.0, 1.0),
    Alignment is SharedCount / OurCount,
    Resonance is 0.3 * Breadth + 0.3 * Activity + 0.4 * Alignment.

our_concepts([
    topology, manifold, zkproof, prolog, lean,
    hott, monster_group, prime_lattice, galois,
    phase_transition, conformal_map, resonance,
    trust_network, libp2p, shard, ontology
]).

% Extract concepts from author's commit messages
author_concepts(Author, Concepts) :-
    findall(Concept, (
        author_commit(Author, _, Message),
        extract_concepts_from_text(Message, MessageConcepts),
        member(Concept, MessageConcepts)
    ), AllConcepts),
    sort(AllConcepts, Concepts).

extract_concepts_from_text(Text, Concepts) :-
    downcase_atom(Text, Lower),
    atom_codes(Lower, Codes),
    our_concepts(OurConcepts),
    include(concept_in_text(Codes), OurConcepts, Concepts).

concept_in_text(TextCodes, Concept) :-
    atom_codes(Concept, ConceptCodes),
    sublist(ConceptCodes, TextCodes).

sublist([], _).
sublist([H|T], [H|Rest]) :- sublist(T, Rest).
sublist(Sub, [_|Rest]) :- sublist(Sub, Rest).

% ============================================================================
% FIND UNDERAPPRECIATED AUTHORS
% ============================================================================

find_underappreciated_authors(Authors) :-
    format('🔎 Finding underappreciated authors...~n', []),
    discover_authors_from_repos,
    findall(Author-Resonance-Status, (
        discovered_author(Author, _, _),
        compute_author_resonance(Author, Resonance),
        Resonance > 0.3,  % Significant resonance
        author_status(Author, Status),
        Status \= well_known
    ), Candidates),
    sort(2, @>=, Candidates, Sorted),  % Sort by resonance descending
    length(Sorted, Count),
    format('  Found ~w underappreciated authors~n', [Count]),
    Sorted = Authors.

author_status(Author, Status) :-
    (important_author(Author, _, deceased) ->
        Status = needs_attention
    ; important_author(Author, _, _) ->
        Status = known
    ; discovered_author(Author, _, Repos), length(Repos, Count), Count > 5 ->
        Status = prolific
    ;
        Status = unknown
    ).

% ============================================================================
% ANALYZE AUTHOR COMMITS (Cryptographic Message)
% ============================================================================

:- dynamic author_commit/3.  % commit(Author, Hash, Message)

analyze_author_commits(Author, Analysis) :-
    format('🔮 Analyzing ~w\'s commits as cryptographic message...~n', [Author]),
    % Get all commits by this author
    findall(Hash-Message, (
        discovered_author(Author, _, Repos),
        member(Repo, Repos),
        format(atom(RepoPath), 'discovered_repos/~w', [Repo]),
        format(atom(Cmd), 'cd ~w && git log --all --format="%H|%s" --author="~w"', [RepoPath, Author]),
        setup_call_cleanup(
            open(pipe(Cmd), read, Stream),
            read_author_commits(Stream, Author),
            close(Stream)
        )
    ), _),
    % Convert to prime sequence
    author_commit_primes(Author, Primes),
    % Analyze
    length(Primes, Count),
    compute_entropy(Primes, Entropy),
    most_frequent_prime(Primes, Dominant, DomFreq),
    Analysis = analysis(
        author(Author),
        commit_count(Count),
        entropy(Entropy),
        dominant_frequency(Dominant, DomFreq),
        prime_sequence(Primes)
    ),
    format('  📊 ~w commits, entropy: ~2f, dominant: ~w~n', [Count, Entropy, Dominant]).

read_author_commits(Stream, Author) :-
    read_line_to_string(Stream, Line),
    (Line == end_of_file ->
        true
    ;
        split_string(Line, "|", "", [Hash, Message]),
        assertz(author_commit(Author, Hash, Message)),
        read_author_commits(Stream, Author)
    ).

author_commit_primes(Author, Primes) :-
    findall(Prime, (
        author_commit(Author, Hash, Message),
        commit_to_prime(Hash-Message, Prime)
    ), Primes).

commit_to_prime(Hash-Message, Prime) :-
    atom_codes(Hash, HashCodes),
    atom_codes(Message, MsgCodes),
    append(HashCodes, MsgCodes, AllCodes),
    sum_list(AllCodes, Sum),
    PrimeIndex is Sum mod 20,
    nth_prime(PrimeIndex, Prime).

nth_prime(N, Prime) :-
    Primes = [2,3,5,7,11,13,17,19,23,29,31,37,41,43,47,53,59,61,67,71],
    nth0(N, Primes, Prime).

compute_entropy(Primes, Entropy) :-
    length(Primes, Total),
    (Total > 0 ->
        setof(P, member(P, Primes), Unique),
        maplist(prime_entropy_term(Primes, Total), Unique, Terms),
        sum_list(Terms, Entropy)
    ;
        Entropy = 0
    ).

prime_entropy_term(Primes, Total, Prime, Term) :-
    include(=(Prime), Primes, Occurrences),
    length(Occurrences, Count),
    Prob is Count / Total,
    (Prob > 0 ->
        Term is -Prob * log(Prob) / log(2)
    ;
        Term = 0
    ).

most_frequent_prime(Primes, Prime, Count) :-
    setof(P, member(P, Primes), Unique),
    maplist(count_prime(Primes), Unique, Counts),
    max_member(Count, Counts),
    nth0(Index, Counts, Count),
    nth0(Index, Unique, Prime).

count_prime(Primes, Prime, Count) :-
    include(=(Prime), Primes, Occurrences),
    length(Occurrences, Count).

% ============================================================================
% MAIN ANALYSIS
% ============================================================================

analyze_all_authors :-
    format('~n═══════════════════════════════════════════════════════~n', []),
    format('  AUTHOR RESONANCE ANALYSIS~n', []),
    format('  Discovering important but underappreciated work~n', []),
    format('═══════════════════════════════════════════════════════~n~n', []),
    
    seed_important_authors,
    find_underappreciated_authors(Authors),
    
    format('~n🌟 Top underappreciated authors:~n', []),
    forall(
        member(Author-Resonance-Status, Authors),
        (format('  ~w (resonance: ~2f, status: ~w)~n', [Author, Resonance, Status]),
         analyze_author_commits(Author, _))
    ),
    
    export_author_analysis(Authors).

% ============================================================================
% EXPORT
% ============================================================================

export_author_analysis(Authors) :-
    open('data/parquets/author_resonance.parquet.py', write, S),
    write(S, 'import pandas as pd\nimport pyarrow.parquet as pq\n\n'),
    write(S, 'data = {"author": [], "resonance": [], "status": []}\n'),
    forall(
        member(Author-Resonance-Status, Authors),
        format(S, 'data["author"].append(~q)~ndata["resonance"].append(~w)~ndata["status"].append(~q)~n', 
               [Author, Resonance, Status])
    ),
    write(S, 'df = pd.DataFrame(data)\n'),
    write(S, 'pq.write_table(pa.Table.from_pandas(df), "data/parquets/author_resonance.parquet")\n'),
    write(S, 'print("✅ Author resonance analysis complete")\n'),
    close(S),
    shell('python3 data/parquets/author_resonance.parquet.py'),
    format('~n📊 Exported to data/parquets/author_resonance.parquet~n', []).
