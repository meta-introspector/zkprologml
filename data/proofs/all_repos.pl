🔍 Consuming repos with Rust + Oracle Busybox
% Generated from 0 repos
:- dynamic repo_predicate/5.
:- dynamic repo_info/3.


% Find equivalent predicates across repos
equivalent(R1, P1, R2, P2) :-
    repo_predicate(R1, P1, _, C, _),
    repo_predicate(R2, P2, _, C, _),
    R1 \= R2.

% Universal call via prime complexity
universal_call(SourceRepo, TargetRepo, Pred, Args) :-
    repo_predicate(SourceRepo, Pred, _, C, _),
    repo_predicate(TargetRepo, TargetPred, _, C, _),
    format('~w.~w -> ~w.~w (complexity: ~w)~n', [SourceRepo, Pred, TargetRepo, TargetPred, C]).
