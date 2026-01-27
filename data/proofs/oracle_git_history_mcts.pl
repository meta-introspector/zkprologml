% Oracle: Load 3 months git history with MCTS and cost planning
% Build model of files and contents

:- dynamic git_commit/5.
:- dynamic file_change/4.
:- dynamic file_content_model/3.
:- dynamic mcts_node/4.
:- dynamic cost_estimate/3.

% ═══════════════════════════════════════════════════════════
% STEP 1: Extract 3 months git history
% ═══════════════════════════════════════════════════════════

oracle_load_git_history(Repo) :-
    expand_file_name(Repo, [Expanded|_]),
    format('🔍 Loading 3 months history from ~w~n', [Expanded]),
    
    % Get commits from last 3 months
    format(atom(Cmd), 'cd ~w && git log --since="3 months ago" --pretty=format:"%H|%at|%an|%s" --name-status 2>/dev/null', [Expanded]),
    shell(Cmd, Output),
    
    (Output \= "" ->
        parse_git_log(Output, Expanded),
        findall(_, git_commit(_, _, _, _, _), Commits),
        length(Commits, Count),
        format('  ✅ Loaded ~w commits~n', [Count])
    ;
        write('  ❌ No history found'), nl
    ).

parse_git_log(Output, Repo) :-
    split_string(Output, "\n", "", Lines),
    parse_commits(Lines, Repo, none).

parse_commits([], _, _).
parse_commits([Line|Rest], Repo, CurrentCommit) :-
    (sub_string(Line, _, _, _, "|") ->
        % Commit line: hash|time|author|message
        split_string(Line, "|", "", [Hash, Time, Author, Msg]),
        atom_string(HashAtom, Hash),
        atom_number(Time, TimeNum),
        assertz(git_commit(Repo, HashAtom, TimeNum, Author, Msg)),
        parse_commits(Rest, Repo, HashAtom)
    ;
        % File change line: M/A/D filename
        (CurrentCommit \= none ->
            split_string(Line, "\t", "", [Status, File]),
            assertz(file_change(Repo, CurrentCommit, Status, File))
        ; true),
        parse_commits(Rest, Repo, CurrentCommit)
    ).

% ═══════════════════════════════════════════════════════════
% STEP 2: MCTS - Monte Carlo Tree Search for file exploration
% ═══════════════════════════════════════════════════════════

% MCTS node: mcts_node(FilePattern, Visits, Value, Children)
mcts_init :-
    % Root node: explore all file types
    assertz(mcts_node(root, 0, 0.0, ['.rs', '.pl', '.toml', '.md'])).

% UCB1 selection
mcts_select(Node, BestChild) :-
    mcts_node(Node, _, _, Children),
    findall(Score-Child,
            (member(Child, Children),
             mcts_ucb1(Node, Child, Score)),
            Scores),
    sort(1, @>=, Scores, [_-BestChild|_]).

% UCB1 formula: value + C * sqrt(ln(parent_visits) / child_visits)
mcts_ucb1(Parent, Child, Score) :-
    mcts_node(Parent, ParentVisits, _, _),
    (mcts_node(Child, ChildVisits, ChildValue, _) ->
        (ChildVisits > 0 ->
            C = 1.414,
            Score is ChildValue + C * sqrt(log(ParentVisits) / ChildVisits)
        ;
            Score = 999999  % Unvisited nodes get high priority
        )
    ;
        Score = 999999
    ).

% MCTS expansion
mcts_expand(FilePattern) :-
    % Find files matching pattern
    format(atom(Cmd), 'plocate -r ".*~w$" | head -20', [FilePattern]),
    shell(Cmd, Output),
    
    (Output \= "" ->
        split_string(Output, "\n", "\n", Files),
        length(Files, Count),
        Value is Count / 20.0,  % Normalize
        
        (mcts_node(FilePattern, Visits, OldValue, Children) ->
            retract(mcts_node(FilePattern, Visits, OldValue, Children)),
            NewVisits is Visits + 1,
            NewValue is (OldValue * Visits + Value) / NewVisits,
            assertz(mcts_node(FilePattern, NewVisits, NewValue, Children))
        ;
            assertz(mcts_node(FilePattern, 1, Value, []))
        )
    ; true).

% ═══════════════════════════════════════════════════════════
% STEP 3: Cost planning - estimate cost of reading files
% ═══════════════════════════════════════════════════════════

% Cost factors: file size, complexity, dependencies
estimate_cost(File, Cost) :-
    expand_file_name(File, [Expanded|_]),
    (exists_file(Expanded) ->
        % Get file size
        format(atom(Cmd), 'stat -c %s "~w" 2>/dev/null', [Expanded]),
        shell(Cmd, SizeStr),
        atom_number(SizeStr, Size),
        
        % Base cost = size in KB
        BaseCost is Size / 1024,
        
        % Complexity multiplier based on extension
        (sub_atom(File, _, _, 0, '.rs') -> Mult = 2.0
        ; sub_atom(File, _, _, 0, '.pl') -> Mult = 1.5
        ; Mult = 1.0
        ),
        
        Cost is BaseCost * Mult,
        assertz(cost_estimate(File, Cost, Size))
    ;
        Cost = 0
    ).

% Plan optimal file reading order (greedy by value/cost ratio)
plan_reading_order(Files, OrderedFiles) :-
    findall(Ratio-File,
            (member(File, Files),
             estimate_value(File, Value),
             estimate_cost(File, Cost),
             (Cost > 0 -> Ratio is Value / Cost ; Ratio = 0)),
            Ratios),
    sort(1, @>=, Ratios, Sorted),
    findall(F, member(_-F, Sorted), OrderedFiles).

% Estimate value based on recent changes
estimate_value(File, Value) :-
    (file_change(_, _, _, File) ->
        findall(_, file_change(_, _, _, File), Changes),
        length(Changes, Value)
    ;
        Value = 1
    ).

% ═══════════════════════════════════════════════════════════
% STEP 4: Build file content model
% ═══════════════════════════════════════════════════════════

build_file_model(File) :-
    expand_file_name(File, [Expanded|_]),
    (exists_file(Expanded) ->
        % Read first 1000 chars
        open(Expanded, read, Stream),
        read_string(Stream, 1000, Content),
        close(Stream),
        
        % Extract key patterns
        (sub_string(Content, _, _, _, "use syn") -> HasSyn = true ; HasSyn = false),
        (sub_string(Content, _, _, _, "parquet") -> HasParquet = true ; HasParquet = false),
        (sub_string(Content, _, _, _, "rustc_") -> HasRustc = true ; HasRustc = false),
        
        assertz(file_content_model(File, [syn=HasSyn, parquet=HasParquet, rustc=HasRustc], Content))
    ; true).

% ═══════════════════════════════════════════════════════════
% MAIN
% ═══════════════════════════════════════════════════════════

main :-
    write('🍄 ORACLE GIT HISTORY + MCTS + COST PLANNING'), nl,
    write('═══════════════════════════════════════════════════════════'), nl,
    nl,
    
    write('STEP 1: Load 3 months git history'), nl,
    write('═══════════════════════════════════════════════════════════'), nl,
    Repos = [
        '~/zombie_driver2',
        '~/zos-server',
        '/mnt/data1/nix/vendor/rust/github'
    ],
    forall(member(R, Repos), oracle_load_git_history(R)),
    nl,
    
    write('STEP 2: MCTS exploration'), nl,
    write('═══════════════════════════════════════════════════════════'), nl,
    mcts_init,
    forall(member(Ext, ['.rs', '.pl', '.toml']), mcts_expand(Ext)),
    nl,
    
    write('STEP 3: Cost planning'), nl,
    write('═══════════════════════════════════════════════════════════'), nl,
    findall(F, file_change(_, _, _, F), AllFiles),
    list_to_set(AllFiles, UniqueFiles),
    length(UniqueFiles, FileCount),
    format('Files changed: ~w~n', [FileCount]),
    
    % Take top 10 by value/cost
    (FileCount > 0 ->
        plan_reading_order(UniqueFiles, Ordered),
        take_n(10, Ordered, Top10),
        write('Top 10 files to read:'), nl,
        forall(member(F, Top10),
               (estimate_cost(F, C),
                estimate_value(F, V),
                format('  ~w (value=~w, cost=~w)~n', [F, V, C])))
    ; write('No files found'), nl),
    nl,
    
    write('STEP 4: Build models'), nl,
    write('═══════════════════════════════════════════════════════════'), nl,
    (FileCount > 0 ->
        forall(member(F, Top10), build_file_model(F)),
        findall(_, file_content_model(_, _, _), Models),
        length(Models, ModelCount),
        format('Built ~w file models~n', [ModelCount])
    ; write('No models built'), nl),
    nl,
    
    write('✅ COMPLETE'), nl.

take_n(0, _, []) :- !.
take_n(_, [], []) :- !.
take_n(N, [H|T], [H|R]) :- N1 is N - 1, take_n(N1, T, R).

% ?- main.
