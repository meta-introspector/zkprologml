% Core Prolog and Orbits - Self-Labeling System
% Identify core predicates and their orbits, label them in Prolog itself

:- dynamic core_predicate/3.
:- dynamic orbit/4.
:- dynamic orbit_label/2.

% ═══════════════════════════════════════════════════════════
% PART 1: Core Prolog (Minimal Set)
% ═══════════════════════════════════════════════════════════

% Core predicates with complexity
identify_core_prolog :-
    % Unification (complexity 0)
    assertz(core_predicate(unify, 0, 'X = Y')),
    
    % Conjunction (complexity 1)
    assertz(core_predicate(conjunction, 1, 'A, B')),
    
    % Disjunction (complexity 2)
    assertz(core_predicate(disjunction, 2, 'A ; B')),
    
    % Negation (complexity 3)
    assertz(core_predicate(negation, 3, '\\+ A')),
    
    % Call (complexity 3)
    assertz(core_predicate(call, 3, 'call(Goal)')),
    
    % Assert (complexity 7)
    assertz(core_predicate(assert, 7, 'assertz(Fact)')),
    
    % Retract (complexity 7)
    assertz(core_predicate(retract, 7, 'retract(Fact)')),
    
    % Findall (complexity 11)
    assertz(core_predicate(findall, 11, 'findall(X, Goal, List)')),
    
    % Arithmetic (complexity 2)
    assertz(core_predicate(arithmetic, 2, 'X is Expr')),
    
    % Comparison (complexity 2)
    assertz(core_predicate(comparison, 2, 'X < Y')),
    
    write('✅ Core Prolog identified: 10 predicates'), nl.

% ═══════════════════════════════════════════════════════════
% PART 2: Orbits (Equivalence Classes)
% ═══════════════════════════════════════════════════════════

% orbit(OrbitID, Complexity, Members, Label)
identify_orbits :-
    % Orbit 0: Identity (unification)
    assertz(orbit(orbit_0, 0, [unify, '='], 'Identity')),
    
    % Orbit 1: Unit (conjunction)
    assertz(orbit(orbit_1, 1, [conjunction, ','], 'Unit')),
    
    % Orbit 2: Binary (disjunction, arithmetic, comparison)
    assertz(orbit(orbit_2, 2, [disjunction, arithmetic, comparison, ';', 'is', '<', '>'], 'Binary')),
    
    % Orbit 3: Control (negation, call, cut)
    assertz(orbit(orbit_3, 3, [negation, call, cut, '\\+', '!'], 'Control')),
    
    % Orbit 7: Mutation (assert, retract)
    assertz(orbit(orbit_7, 7, [assert, retract, assertz, retractz], 'Mutation')),
    
    % Orbit 11: Collection (findall, bagof, setof)
    assertz(orbit(orbit_11, 11, [findall, bagof, setof], 'Collection')),
    
    % Orbit 13: Meta (functor, arg, =..)
    assertz(orbit(orbit_13, 13, [functor, arg, univ], 'Meta')),
    
    % Orbit 17: I/O (read, write, open, close)
    assertz(orbit(orbit_17, 17, [read, write, open, close], 'IO')),
    
    write('✅ Orbits identified: 8 orbits'), nl.

% ═══════════════════════════════════════════════════════════
% PART 3: Self-Labeling
% ═══════════════════════════════════════════════════════════

% Label predicates by analyzing their definitions
self_label_predicates :-
    write('🏷️  Self-labeling predicates...'), nl,
    
    % Get all user predicates
    findall(Name/Arity, 
            (current_predicate(Name/Arity),
             \+ predicate_property(Name/Arity, built_in)),
            UserPreds),
    
    % Label each
    maplist(label_predicate, UserPreds),
    
    length(UserPreds, Count),
    format('✅ Labeled ~w predicates~n', [Count]).

label_predicate(Name/Arity) :-
    % Analyze predicate to determine orbit
    functor(Head, Name, Arity),
    (catch(clause(Head, Body), _, fail) ->
        (analyze_body(Body, Complexity),
         find_orbit(Complexity, OrbitID),
         assertz(orbit_label(Name/Arity, OrbitID))) ;
        assertz(orbit_label(Name/Arity, orbit_0))).

% Analyze clause body to determine complexity
analyze_body(true, 0) :- !.
analyze_body((A, B), C) :- !,
    analyze_body(A, C1),
    analyze_body(B, C2),
    C is max(C1, C2) + 1.
analyze_body((A ; B), C) :- !,
    analyze_body(A, C1),
    analyze_body(B, C2),
    C is max(C1, C2) + 2.
analyze_body(\+ _, 3) :- !.
analyze_body(call(_), 3) :- !.
analyze_body(assertz(_), 7) :- !.
analyze_body(retract(_), 7) :- !.
analyze_body(findall(_,_,_), 11) :- !.
analyze_body(_ is _, 2) :- !.
analyze_body(_, 1).

% Find orbit for complexity
find_orbit(C, OrbitID) :-
    orbit(OrbitID, OC, _, _),
    abs(C - OC) < 2, !.
find_orbit(_, orbit_0).

% ═══════════════════════════════════════════════════════════
% PART 4: Orbit Membership
% ═══════════════════════════════════════════════════════════

% Check if predicate is in orbit
in_orbit(Pred, OrbitID) :-
    orbit_label(Pred, OrbitID).

% Get all predicates in orbit
orbit_members(OrbitID, Members) :-
    findall(Pred, orbit_label(Pred, OrbitID), Members).

% Get orbit info
orbit_info(OrbitID) :-
    orbit(OrbitID, Complexity, CoreMembers, Label),
    orbit_members(OrbitID, UserMembers),
    length(UserMembers, Count),
    
    format('Orbit: ~w~n', [OrbitID]),
    format('  Label: ~w~n', [Label]),
    format('  Complexity: ~w~n', [Complexity]),
    format('  Core members: ~w~n', [CoreMembers]),
    format('  User predicates: ~w (~w total)~n', [Count, UserMembers]).

% ═══════════════════════════════════════════════════════════
% PART 5: Self-Reflection
% ═══════════════════════════════════════════════════════════

% Prolog reflects on itself
self_reflect :-
    write('═══════════════════════════════════════════════════════════'), nl,
    write('🔍 PROLOG SELF-REFLECTION'), nl,
    write('═══════════════════════════════════════════════════════════'), nl,
    nl,
    
    write('Core Prolog:'), nl,
    forall(core_predicate(Name, C, Syntax),
           format('  ~w (complexity ~w): ~w~n', [Name, C, Syntax])),
    nl,
    
    write('Orbits:'), nl,
    forall(orbit(ID, C, Members, Label),
           format('  ~w: ~w (complexity ~w) - ~w~n', [ID, Label, C, Members])),
    nl,
    
    write('Self-labeled predicates:'), nl,
    forall(orbit_label(Pred, Orbit),
           format('  ~w → ~w~n', [Pred, Orbit])),
    nl,
    
    write('═══════════════════════════════════════════════════════════'), nl.

% ═══════════════════════════════════════════════════════════
% PART 6: Orbit Equivalence
% ═══════════════════════════════════════════════════════════

% Predicates in same orbit are equivalent
orbit_equivalent(Pred1, Pred2) :-
    orbit_label(Pred1, Orbit),
    orbit_label(Pred2, Orbit),
    Pred1 \= Pred2.

% Find all equivalent predicates
find_equivalents(Pred, Equivalents) :-
    orbit_label(Pred, Orbit),
    findall(P, (orbit_label(P, Orbit), P \= Pred), Equivalents).

% ═══════════════════════════════════════════════════════════
% PART 7: Orbit Diagram
% ═══════════════════════════════════════════════════════════

show_orbit_diagram :-
    write('═══════════════════════════════════════════════════════════'), nl,
    write('🌀 PROLOG ORBIT DIAGRAM'), nl,
    write('═══════════════════════════════════════════════════════════'), nl,
    nl,
    write('                    Core Prolog'), nl,
    write('                         |'), nl,
    write('         ┌───────────────┼───────────────┐'), nl,
    write('         |               |               |'), nl,
    write('    Orbit 0          Orbit 1         Orbit 2'), nl,
    write('   (Identity)        (Unit)         (Binary)'), nl,
    write('      unify            ,              ; is <'), nl,
    write('         |               |               |'), nl,
    write('         └───────────────┼───────────────┘'), nl,
    write('                         |'), nl,
    write('         ┌───────────────┼───────────────┐'), nl,
    write('         |               |               |'), nl,
    write('    Orbit 3          Orbit 7        Orbit 11'), nl,
    write('   (Control)       (Mutation)    (Collection)'), nl,
    write('    \\+ call !      assert retract  findall'), nl,
    write('         |               |               |'), nl,
    write('         └───────────────┼───────────────┘'), nl,
    write('                         |'), nl,
    write('                   Orbit 13-17'), nl,
    write('                  (Meta, I/O)'), nl,
    nl,
    write('═══════════════════════════════════════════════════════════'), nl.

% ═══════════════════════════════════════════════════════════
% PART 8: Complete System
% ═══════════════════════════════════════════════════════════

initialize_orbit_system :-
    write('🚀 Initializing Prolog Orbit System...'), nl,
    nl,
    
    identify_core_prolog,
    identify_orbits,
    self_label_predicates,
    nl,
    
    write('✅ Orbit system initialized'), nl.

% ═══════════════════════════════════════════════════════════
% MAIN
% ═══════════════════════════════════════════════════════════

main :-
    initialize_orbit_system,
    nl,
    self_reflect,
    nl,
    show_orbit_diagram.

% ?- main.
% ?- orbit_info(orbit_7).
% ?- find_equivalents(assertz/1, Equiv).
% ?- orbit_equivalent(assertz/1, retract/1).
