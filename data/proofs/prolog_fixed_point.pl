% Fixed Point of Prolog in Prolog
% Self-referential model: Prolog reasoning about its own instruction pointer

:- module(prolog_fixed_point, [
    instruction_pointer/3,
    expected_next/2,
    is_complete/1,
    advance_ip/3,
    fixed_point_reached/1,
    model_sampling/3
]).

% ============================================================================
% INSTRUCTION POINTER STATE
% ============================================================================

% instruction_pointer(Buffer, Position, StatementType)
:- dynamic instruction_pointer/3.
:- dynamic expected_tokens/1.

% Initialize IP
init_ip :-
    retractall(instruction_pointer(_, _, _)),
    retractall(expected_tokens(_)),
    assertz(instruction_pointer("", 0, unknown)),
    assertz(expected_tokens(["concept", "concept_definition", "concept_chord"])).

% ============================================================================
% EXPECTED NEXT TOKENS (Fixed Point Computation)
% ============================================================================

% Compute expected tokens based on current buffer
expected_next(Buffer, Expected) :-
    (atom_codes(Buffer, Codes), Codes = [] ->
        Expected = ["concept", "concept_definition", "concept_chord"]
    ; sub_atom(Buffer, 0, _, _, 'concept('), \+ sub_atom(Buffer, _, _, _, ')') ->
        Expected = [")"]
    ; sub_atom(Buffer, _, _, _, ')'), \+ sub_atom(Buffer, _, _, 0, '.') ->
        Expected = ["."]
    ; sub_atom(Buffer, 0, _, _, 'concept_definition('), \+ sub_atom(Buffer, _, _, _, ',') ->
        Expected = [","]
    ; sub_atom(Buffer, _, _, _, ','), \+ sub_atom(Buffer, _, _, _, ')') ->
        Expected = [")"]
    ;
        Expected = []
    ).

% Check if statement is complete
is_complete(Buffer) :-
    expected_next(Buffer, Expected),
    Expected = [].

% ============================================================================
% ADVANCE INSTRUCTION POINTER
% ============================================================================

% advance_ip(CurrentBuffer, Token, NewBuffer)
advance_ip(Buffer, Token, NewBuffer) :-
    atom_concat(Buffer, Token, NewBuffer),
    atom_length(NewBuffer, NewPos),
    retractall(instruction_pointer(_, _, _)),
    detect_statement_type(NewBuffer, Type),
    assertz(instruction_pointer(NewBuffer, NewPos, Type)),
    expected_next(NewBuffer, Expected),
    retractall(expected_tokens(_)),
    assertz(expected_tokens(Expected)).

% Detect statement type from buffer
detect_statement_type(Buffer, Type) :-
    (sub_atom(Buffer, 0, _, _, 'concept_definition(') ->
        Type = definition
    ; sub_atom(Buffer, 0, _, _, 'concept_chord(') ->
        Type = chord
    ; sub_atom(Buffer, 0, _, _, 'concept_relates_to(') ->
        Type = relates_to
    ; sub_atom(Buffer, 0, _, _, 'concept_instance(') ->
        Type = instance
    ; sub_atom(Buffer, 0, _, _, 'concept(') ->
        Type = concept
    ;
        Type = unknown
    ).

% ============================================================================
% FIXED POINT DETECTION
% ============================================================================

% Fixed point reached when IP converges (no more expected tokens)
fixed_point_reached(Buffer) :-
    is_complete(Buffer),
    instruction_pointer(Buffer, _, Type),
    Type \= unknown.

% ============================================================================
% MODEL SAMPLING (Prolog models LLM sampling)
% ============================================================================

% model_sampling(Candidates, Buffer, BestToken)
% Models how LLM should sample given current IP state
model_sampling(Candidates, Buffer, BestToken) :-
    expected_next(Buffer, Expected),
    findall(Score-Token, (
        member(Token, Candidates),
        score_token(Token, Expected, Buffer, Score)
    ), ScoredTokens),
    sort(1, @>=, ScoredTokens, [_-BestToken|_]).

% Score token based on IP guidance
score_token(Token, Expected, Buffer, Score) :-
    % Base score
    BaseScore = 1.0,
    
    % IP bonus (fixed point guidance)
    (member(Token, Expected) ->
        IPBonus = 20.0
    ;
        IPBonus = 0.0
    ),
    
    % Validity check
    atom_concat(Buffer, Token, TestBuffer),
    (is_valid_prolog_fragment(TestBuffer) ->
        ValidityBonus = 5.0
    ;
        ValidityBonus = -10.0
    ),
    
    Score is BaseScore + IPBonus + ValidityBonus.

% Check if buffer is valid Prolog fragment
is_valid_prolog_fragment(Buffer) :-
    atom_codes(Buffer, Codes),
    count_char(Codes, 40, OpenParen),   % (
    count_char(Codes, 41, CloseParen),  % )
    CloseParen =< OpenParen.

count_char([], _, 0).
count_char([C|Rest], C, Count) :-
    !,
    count_char(Rest, C, RestCount),
    Count is RestCount + 1.
count_char([_|Rest], C, Count) :-
    count_char(Rest, C, Count).

% ============================================================================
% SELF-REFERENTIAL FIXED POINT
% ============================================================================

% Prolog models itself modeling the IP
self_model(Buffer, Model) :-
    instruction_pointer(Buffer, Pos, Type),
    expected_next(Buffer, Expected),
    Model = model(
        buffer(Buffer),
        position(Pos),
        type(Type),
        expected(Expected),
        complete(is_complete(Buffer))
    ).

% Fixed point equation: IP(Buffer) = Expected(IP(Buffer))
% The IP is a fixed point when it predicts itself
fixed_point_equation(Buffer) :-
    expected_next(Buffer, Expected),
    % If Expected = [], then IP has converged
    (Expected = [] ->
        format('✅ Fixed point: IP(~w) = []~n', [Buffer])
    ;
        format('⏳ Not fixed point: IP(~w) = ~w~n', [Buffer, Expected])
    ).

% ============================================================================
% ITERATIVE CONVERGENCE TO FIXED POINT
% ============================================================================

% Simulate token-by-token generation until fixed point
converge_to_fixed_point(InitialBuffer, Candidates, FinalBuffer) :-
    converge_loop(InitialBuffer, Candidates, FinalBuffer, 0, 100).

converge_loop(Buffer, _, Buffer, Iter, _) :-
    fixed_point_reached(Buffer),
    !,
    format('✅ Converged at iteration ~w: ~w~n', [Iter, Buffer]).

converge_loop(Buffer, Candidates, FinalBuffer, Iter, MaxIter) :-
    Iter < MaxIter,
    !,
    model_sampling(Candidates, Buffer, BestToken),
    advance_ip(Buffer, BestToken, NewBuffer),
    format('  [~w] ~w + ~w = ~w~n', [Iter, Buffer, BestToken, NewBuffer]),
    NextIter is Iter + 1,
    converge_loop(NewBuffer, Candidates, FinalBuffer, NextIter, MaxIter).

converge_loop(Buffer, _, Buffer, Iter, MaxIter) :-
    Iter >= MaxIter,
    format('⚠️  Max iterations reached: ~w~n', [Buffer]).

% ============================================================================
% EXPORT TO RUST
% ============================================================================

% Generate Rust code that implements this fixed point model
export_fixed_point_to_rust(OutputFile) :-
    open(OutputFile, write, S),
    write(S, '// Generated from prolog_fixed_point.pl\n\n'),
    write(S, 'pub fn expected_next(buffer: &str) -> Vec<String> {\n'),
    write(S, '    if buffer.is_empty() {\n'),
    write(S, '        vec!["concept".to_string()]\n'),
    write(S, '    } else if buffer.starts_with("concept(") && !buffer.contains(\')\') {\n'),
    write(S, '        vec![")".to_string()]\n'),
    write(S, '    } else if buffer.contains(\')\') && !buffer.ends_with(\'.\') {\n'),
    write(S, '        vec![".".to_string()]\n'),
    write(S, '    } else {\n'),
    write(S, '        vec![]\n'),
    write(S, '    }\n'),
    write(S, '}\n'),
    close(S),
    format('✅ Exported to ~w~n', [OutputFile]).

% ============================================================================
% EXAMPLE
% ============================================================================

example :-
    init_ip,
    
    % Simulate convergence
    Candidates = ["concept", "(", "topology", ")", "."],
    converge_to_fixed_point("", Candidates, Final),
    
    % Show fixed point equation
    fixed_point_equation(Final).

% Example with definition
example_definition :-
    init_ip,
    Candidates = ["concept_definition", "(", "topology", ",", "\"study of shape\"", ")", "."],
    converge_to_fixed_point("", Candidates, Final),
    fixed_point_equation(Final).
