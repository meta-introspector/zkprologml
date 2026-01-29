% Code as Conformal Boundary: Topological Reading of Programs
% Every program is a geodesic on the mathematical manifold

:- module(code_topology, [
    analyze_code_topology/2,
    code_as_boundary/2,
    detect_phase_transitions/2,
    fiber_bundle_structure/2,
    measure_winding_number/2
]).

% ============================================================================
% CODE AS CONFORMAL BOUNDARY
% ============================================================================

% Analyze code file as topological object
analyze_code_topology(FilePath, Analysis) :-
    read_file_to_codes(FilePath, Codes),
    atom_codes(Content, Codes),
    
    % Extract structure
    extract_imports(Content, Imports),
    extract_definitions(Content, Definitions),
    extract_instances(Content, Instances),
    
    % Detect phase transitions
    detect_phase_transitions(Definitions, Transitions),
    
    % Compute fiber bundle structure
    fiber_bundle_structure(Definitions, Bundle),
    
    % Measure topological invariants
    measure_winding_number(Content, WindingNumber),
    compute_geodesic_length(Definitions, Length),
    
    Analysis = topology(
        imports(Imports),
        definitions(Definitions),
        instances(Instances),
        phase_transitions(Transitions),
        fiber_bundle(Bundle),
        winding_number(WindingNumber),
        geodesic_length(Length)
    ).

% ============================================================================
% IMPORTS AS ATLAS CHARTS
% ============================================================================

% Imports establish base manifold
extract_imports(Content, Imports) :-
    split_string(Content, "\n", "", Lines),
    include(is_import_line, Lines, ImportLines),
    maplist(parse_import, ImportLines, Imports).

is_import_line(Line) :-
    sub_string(Line, 0, _, _, "import ").

parse_import(Line, import(Module, Type)) :-
    split_string(Line, " ", "", ["import"|Parts]),
    atomic_list_concat(Parts, ' ', Module),
    classify_import(Module, Type).

classify_import(Module, Type) :-
    (sub_string(Module, _, _, _, "algebra") -> Type = gauge_symmetry
    ; sub_string(Module, _, _, _, "ring") -> Type = local_structure
    ; sub_string(Module, _, _, _, "heq") -> Type = parallel_transport
    ; Type = utility
    ).

% ============================================================================
% DEFINITIONS AS MEASUREMENTS
% ============================================================================

% Each definition collapses wavefunction
extract_definitions(Content, Definitions) :-
    split_string(Content, "\n", "", Lines),
    findall(Def, (
        member(Line, Lines),
        parse_definition_line(Line, Def)
    ), Definitions).

parse_definition_line(Line, definition(Name, Type, Complexity)) :-
    (sub_string(Line, _, _, _, "definition ") ->
        split_string(Line, " ", "", Parts),
        nth0(1, Parts, Name),
        definition_type(Line, Type),
        definition_complexity(Line, Complexity)
    ; fail
    ).

definition_type(Line, Type) :-
    (sub_string(Line, _, _, _, "→") -> Type = functor
    ; sub_string(Line, _, _, _, "[constructor]") -> Type = constructor
    ; sub_string(Line, _, _, _, "[instance]") -> Type = gauge_connection
    ; Type = basic
    ).

definition_complexity(Line, Complexity) :-
    atom_codes(Line, Codes),
    length(Codes, Len),
    include(is_symbol, Codes, Symbols),
    length(Symbols, SymCount),
    Complexity is SymCount / Len.

is_symbol(Code) :- member(Code, [40, 41, 91, 93, 123, 125, 8594]).  % ()[]{}→

% ============================================================================
% INSTANCES AS GAUGE CONNECTIONS
% ============================================================================

extract_instances(Content, Instances) :-
    split_string(Content, "\n", "", Lines),
    findall(Inst, (
        member(Line, Lines),
        sub_string(Line, _, _, _, "[instance]"),
        parse_instance(Line, Inst)
    ), Instances).

parse_instance(Line, instance(Name, Priority)) :-
    split_string(Line, " ", "", Parts),
    member(Name, Parts),
    (member(PriorityStr, Parts), sub_string(PriorityStr, _, _, _, "priority") ->
        extract_priority(Parts, Priority)
    ;
        Priority = default
    ).

extract_priority(Parts, Priority) :-
    member(Part, Parts),
    atom_number(Part, Priority),
    !.
extract_priority(_, default).

% ============================================================================
% PHASE TRANSITIONS
% ============================================================================

% Detect where structure changes (symmetry breaking/restoration)
detect_phase_transitions(Definitions, Transitions) :-
    findall(Transition, (
        append(Before, [Def1, Def2|After], Definitions),
        is_phase_transition(Def1, Def2, Transition)
    ), Transitions).

is_phase_transition(
    definition(Name1, Type1, _),
    definition(Name2, Type2, _),
    transition(Name1, Name2, TransitionType)
) :-
    (Type1 = functor, Type2 = gauge_connection ->
        TransitionType = symmetry_breaking
    ; Type1 = basic, Type2 = constructor ->
        TransitionType = structure_formation
    ; Type1 = constructor, Type2 = functor ->
        TransitionType = generalization
    ; fail
    ).

% ============================================================================
% FIBER BUNDLE STRUCTURE
% ============================================================================

% Detect fiber bundle constructions (graded structures)
fiber_bundle_structure(Definitions, Bundle) :-
    findall(bundle(Base, Fiber, Connection), (
        member(definition(Name, Type, _), Definitions),
        detect_bundle(Name, Type, Base, Fiber, Connection)
    ), Bundles),
    (Bundles = [] ->
        Bundle = none
    ;
        Bundle = bundles(Bundles)
    ).

detect_bundle(Name, Type, Base, Fiber, Connection) :-
    Type = constructor,
    (sub_atom(Name, _, _, _, 'graded') ->
        Base = monoid,
        Fiber = additive_group,
        Connection = multiplication
    ; sub_atom(Name, _, _, _, 'direct_sum') ->
        Base = index_set,
        Fiber = component,
        Connection = inclusion
    ; fail
    ).

% ============================================================================
% TOPOLOGICAL INVARIANTS
% ============================================================================

% Winding number = how many times key concept appears
measure_winding_number(Content, WindingNumber) :-
    key_concepts(Concepts),
    maplist(count_concept(Content), Concepts, Counts),
    sum_list(Counts, WindingNumber).

key_concepts(['Ring', 'Group', 'Monoid', 'Bundle', 'Fiber']).

count_concept(Content, Concept, Count) :-
    atom_string(Concept, ConceptStr),
    split_string(Content, ConceptStr, "", Parts),
    length(Parts, Len),
    Count is Len - 1.

% Geodesic length = conceptual distance traversed
compute_geodesic_length(Definitions, Length) :-
    length(Definitions, Count),
    maplist(definition_complexity_value, Definitions, Complexities),
    sum_list(Complexities, TotalComplexity),
    Length is TotalComplexity / Count.

definition_complexity_value(definition(_, _, C), C).

% ============================================================================
% CODE AS CFT BOUNDARY
% ============================================================================

% Map code to conformal field theory boundary
code_as_boundary(FilePath, Boundary) :-
    analyze_code_topology(FilePath, Analysis),
    Analysis = topology(
        imports(Imports),
        definitions(Defs),
        instances(Insts),
        phase_transitions(Trans),
        fiber_bundle(Bundle),
        winding_number(Winding),
        geodesic_length(Length)
    ),
    
    % Boundary observables
    length(Imports, ImportCount),
    length(Defs, DefCount),
    length(Insts, InstCount),
    length(Trans, TransCount),
    
    % Compute correlation functions
    correlation_length(Defs, CorrLength),
    
    Boundary = cft_boundary(
        observables([
            import_count(ImportCount),
            definition_count(DefCount),
            instance_count(InstCount),
            transition_count(TransCount)
        ]),
        invariants([
            winding_number(Winding),
            geodesic_length(Length),
            correlation_length(CorrLength)
        ]),
        structure(Bundle)
    ).

% Correlation length = how far definitions influence each other
correlation_length(Definitions, Length) :-
    length(Definitions, N),
    (N > 1 ->
        Length is log(N)
    ;
        Length = 0
    ).

% ============================================================================
% EXPORT TO PARQUET
% ============================================================================

export_code_topology(FilePath, OutputParquet) :-
    analyze_code_topology(FilePath, Analysis),
    Analysis = topology(_, definitions(Defs), _, transitions(Trans), _, Winding, Length),
    
    open(atom(Script), write, S),
    write(S, 'import pandas as pd\nimport pyarrow.parquet as pq\n\n'),
    write(S, 'data = {"definition": [], "type": [], "complexity": []}\n'),
    forall(
        member(definition(Name, Type, Complexity), Defs),
        format(S, 'data["definition"].append(~q)\ndata["type"].append(~q)\ndata["complexity"].append(~w)\n',
               [Name, Type, Complexity])
    ),
    write(S, 'df = pd.DataFrame(data)\n'),
    format(S, 'pq.write_table(pa.Table.from_pandas(df), ~q)\n', [OutputParquet]),
    close(S),
    atom_string(Script, ScriptStr),
    setup_call_cleanup(
        open('/tmp/code_topology.py', write, F),
        write(F, ScriptStr),
        close(F)
    ),
    shell('python3 /tmp/code_topology.py').

% ============================================================================
% EXAMPLE
% ============================================================================

example :-
    % Analyze a Lean file
    analyze_code_topology('data/proofs/MESC.lean', Analysis),
    format('Analysis: ~w~n', [Analysis]).
