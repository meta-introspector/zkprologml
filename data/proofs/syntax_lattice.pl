#!/usr/bin/env swipl
% Syntax Lattice: Enums, Structs, Control Structures → Prime Lattice

% ═══════════════════════════════════════════════════════════
% PRIME LATTICE FOR SYNTAX CONSTRUCTS
% ═══════════════════════════════════════════════════════════

% Basic types
syntax_prime(int, 2).
syntax_prime(bool, 3).
syntax_prime(char, 5).

% Composite types
syntax_prime(array, 7).
syntax_prime(struct, 11).
syntax_prime(enum, 13).
syntax_prime(union, 17).
syntax_prime(pointer, 19).

% Control structures
syntax_prime(if, 23).
syntax_prime(while, 29).
syntax_prime(for, 31).
syntax_prime(switch, 37).
syntax_prime(match, 41).

% Advanced
syntax_prime(closure, 43).
syntax_prime(trait, 47).
syntax_prime(generic, 53).

% ═══════════════════════════════════════════════════════════
% ENUM IN C, SCHEME, PROLOG
% ═══════════════════════════════════════════════════════════

% C enum
c_enum(color, [red, green, blue]).

c_enum_code(color, '
typedef enum {
    RED = 0,
    GREEN = 1,
    BLUE = 2
} Color;

Color get_color(int n) {
    switch(n) {
        case 0: return RED;
        case 1: return GREEN;
        case 2: return BLUE;
        default: return RED;
    }
}
').

% Scheme enum (as symbols)
scheme_enum(color, '
(define (make-color n)
  (cond
    ((= n 0) \'red)
    ((= n 1) \'green)
    ((= n 2) \'blue)
    (else \'red)))

(define (color-value c)
  (cond
    ((eq? c \'red) 0)
    ((eq? c \'green) 1)
    ((eq? c \'blue) 2)))
').

% Prolog enum (as facts)
prolog_enum(color, [
    color(red, 0),
    color(green, 1),
    color(blue, 2)
]).

% ═══════════════════════════════════════════════════════════
% STRUCT IN C, SCHEME, PROLOG
% ═══════════════════════════════════════════════════════════

% C struct
c_struct(point, [x-int, y-int]).

c_struct_code(point, '
typedef struct {
    int x;
    int y;
} Point;

Point make_point(int x, int y) {
    Point p = {x, y};
    return p;
}

int point_distance_sq(Point p) {
    return p.x * p.x + p.y * p.y;
}
').

% Scheme struct (as list)
scheme_struct(point, '
(define (make-point x y)
  (list x y))

(define (point-x p) (car p))
(define (point-y p) (cadr p))

(define (point-distance-sq p)
  (+ (* (point-x p) (point-x p))
     (* (point-y p) (point-y p))))
').

% Prolog struct (as compound term)
prolog_struct(point, point(X, Y)) :-
    integer(X), integer(Y).

point_distance_sq(point(X, Y), D) :-
    D is X*X + Y*Y.

% ═══════════════════════════════════════════════════════════
% CONTROL STRUCTURES
% ═══════════════════════════════════════════════════════════

% IF-THEN-ELSE
control_if_c('
int max(int a, int b) {
    if (a > b) {
        return a;
    } else {
        return b;
    }
}
').

control_if_scheme('
(define (max a b)
  (if (> a b) a b))
').

control_if_prolog(max(A, B, Max)) :-
    (A > B -> Max = A ; Max = B).

% WHILE LOOP
control_while_c('
int sum_to_n(int n) {
    int sum = 0;
    int i = 0;
    while (i <= n) {
        sum += i;
        i++;
    }
    return sum;
}
').

control_while_scheme('
(define (sum-to-n n)
  (let loop ((i 0) (sum 0))
    (if (<= i n)
        (loop (+ i 1) (+ sum i))
        sum)))
').

control_while_prolog(sum_to_n(N, Sum)) :-
    sum_to_n_helper(0, N, 0, Sum).

sum_to_n_helper(I, N, Acc, Sum) :-
    (I =< N ->
        Acc1 is Acc + I,
        I1 is I + 1,
        sum_to_n_helper(I1, N, Acc1, Sum) ;
        Sum = Acc).

% FOR LOOP
control_for_c('
int product_range(int start, int end) {
    int prod = 1;
    for (int i = start; i <= end; i++) {
        prod *= i;
    }
    return prod;
}
').

control_for_scheme('
(define (product-range start end)
  (let loop ((i start) (prod 1))
    (if (<= i end)
        (loop (+ i 1) (* prod i))
        prod)))
').

control_for_prolog(product_range(Start, End, Prod)) :-
    product_range_helper(Start, End, 1, Prod).

product_range_helper(I, End, Acc, Prod) :-
    (I =< End ->
        Acc1 is Acc * I,
        I1 is I + 1,
        product_range_helper(I1, End, Acc1, Prod) ;
        Prod = Acc).

% SWITCH/MATCH
control_switch_c('
const char* day_name(int day) {
    switch(day) {
        case 0: return "Monday";
        case 1: return "Tuesday";
        case 2: return "Wednesday";
        case 3: return "Thursday";
        case 4: return "Friday";
        case 5: return "Saturday";
        case 6: return "Sunday";
        default: return "Unknown";
    }
}
').

control_switch_scheme('
(define (day-name day)
  (case day
    ((0) "Monday")
    ((1) "Tuesday")
    ((2) "Wednesday")
    ((3) "Thursday")
    ((4) "Friday")
    ((5) "Saturday")
    ((6) "Sunday")
    (else "Unknown")))
').

control_switch_prolog(day_name(0, "Monday")).
control_switch_prolog(day_name(1, "Tuesday")).
control_switch_prolog(day_name(2, "Wednesday")).
control_switch_prolog(day_name(3, "Thursday")).
control_switch_prolog(day_name(4, "Friday")).
control_switch_prolog(day_name(5, "Saturday")).
control_switch_prolog(day_name(6, "Sunday")).
control_switch_prolog(day_name(_, "Unknown")).

% ═══════════════════════════════════════════════════════════
% CALCULATE SYNTAX COMPLEXITY
% ═══════════════════════════════════════════════════════════

syntax_complexity(Code, Complexity) :-
    findall(Prime, (
        syntax_prime(Construct, Prime),
        contains_construct(Code, Construct)
    ), Primes),
    list_to_set(Primes, UniqueP),
    length(UniqueP, Complexity).

contains_construct(Code, Construct) :-
    atom_string(Code, CodeStr),
    atom_string(Construct, ConstructStr),
    sub_string(CodeStr, _, _, _, ConstructStr).

% ═══════════════════════════════════════════════════════════
% TEST ALL CONSTRUCTS
% ═══════════════════════════════════════════════════════════

test_enum :-
    format('~n🔷 ENUM TEST~n', []),
    format('═══════════════════════════════════════════════════════════~n~n', []),
    
    % Test C enum
    c_enum(color, Colors),
    format('C enum: ~w~n', [Colors]),
    
    % Test Prolog enum
    prolog_enum(color, PrologColors),
    format('Prolog enum: ~w~n', [PrologColors]),
    
    % Prime signature
    syntax_prime(enum, Prime),
    format('Prime: ~w~n~n', [Prime]).

test_struct :-
    format('🔷 STRUCT TEST~n', []),
    format('═══════════════════════════════════════════════════════════~n~n', []),
    
    % Test C struct
    c_struct(point, Fields),
    format('C struct fields: ~w~n', [Fields]),
    
    % Test Prolog struct
    Point = point(3, 4),
    point_distance_sq(Point, D),
    format('Prolog point(3,4) distance²: ~w~n', [D]),
    
    % Prime signature
    syntax_prime(struct, Prime),
    format('Prime: ~w~n~n', [Prime]).

test_control_structures :-
    format('🔷 CONTROL STRUCTURES TEST~n', []),
    format('═══════════════════════════════════════════════════════════~n~n', []),
    
    % Test if
    control_if_prolog(max(5, 3, Max1)),
    format('if: max(5,3) = ~w~n', [Max1]),
    syntax_prime(if, IfPrime),
    format('  Prime: ~w~n', [IfPrime]),
    
    % Test while
    control_while_prolog(sum_to_n(5, Sum)),
    format('while: sum_to_n(5) = ~w~n', [Sum]),
    syntax_prime(while, WhilePrime),
    format('  Prime: ~w~n', [WhilePrime]),
    
    % Test for
    control_for_prolog(product_range(1, 5, Prod)),
    format('for: product_range(1,5) = ~w~n', [Prod]),
    syntax_prime(for, ForPrime),
    format('  Prime: ~w~n', [ForPrime]),
    
    % Test switch
    control_switch_prolog(day_name(3, Day)),
    format('switch: day_name(3) = ~w~n', [Day]),
    syntax_prime(switch, SwitchPrime),
    format('  Prime: ~w~n~n', [SwitchPrime]).

% ═══════════════════════════════════════════════════════════
% EXPORT TO COQ
% ═══════════════════════════════════════════════════════════

export_syntax_lattice_coq :-
    format('📝 Exporting syntax lattice to Coq...~n', []),
    
    CoqCode = '
Require Import Coq.Lists.List.
Require Import Coq.ZArith.ZArith.

(* Syntax constructs *)
Inductive syntax_construct : Type :=
  | SInt : syntax_construct
  | SBool : syntax_construct
  | SStruct : syntax_construct
  | SEnum : syntax_construct
  | SIf : syntax_construct
  | SWhile : syntax_construct
  | SFor : syntax_construct
  | SSwitch : syntax_construct.

(* Prime lattice mapping *)
Definition syntax_prime (s : syntax_construct) : Z :=
  match s with
  | SInt => 2
  | SBool => 3
  | SStruct => 11
  | SEnum => 13
  | SIf => 23
  | SWhile => 29
  | SFor => 31
  | SSwitch => 37
  end.

(* Enum example *)
Inductive Color : Type :=
  | Red : Color
  | Green : Color
  | Blue : Color.

(* Struct example *)
Record Point : Type := {
  x : Z;
  y : Z
}.

Definition point_distance_sq (p : Point) : Z :=
  (x p) * (x p) + (y p) * (y p).

(* Theorem: All constructs map to primes *)
Theorem syntax_primes_unique :
  forall s1 s2 : syntax_construct,
  s1 <> s2 -> syntax_prime s1 <> syntax_prime s2.
Proof.
  intros s1 s2 Hneq.
  destruct s1; destruct s2; try discriminate; simpl; lia.
Qed.
',
    
    open('generated/syntax_lattice.v', write, Stream),
    write(Stream, CoqCode),
    close(Stream),
    
    format('✅ Coq: generated/syntax_lattice.v~n~n', []).

% ═══════════════════════════════════════════════════════════
% MAIN
% ═══════════════════════════════════════════════════════════

main :-
    format('~n⚡ SYNTAX LATTICE: Enums, Structs, Control Structures ⚡~n', []),
    format('═══════════════════════════════════════════════════════════~n', []),
    
    test_enum,
    test_struct,
    test_control_structures,
    export_syntax_lattice_coq,
    
    format('✨ ALL SYNTAX CONSTRUCTS MAPPED TO PRIME LATTICE!~n~n', []),
    format('Prime Lattice:~n', []),
    format('  2=int, 3=bool, 5=char~n', []),
    format('  7=array, 11=struct, 13=enum, 17=union, 19=pointer~n', []),
    format('  23=if, 29=while, 31=for, 37=switch, 41=match~n', []),
    format('  43=closure, 47=trait, 53=generic~n~n', []),
    format('All constructs unified in C, Scheme, and Prolog!~n~n', []).

:- initialization(main, main).
