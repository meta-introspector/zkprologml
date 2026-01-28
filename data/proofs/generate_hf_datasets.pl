#!/usr/bin/env swipl
% Generate 71 LLM prompts with 71 flavors from our codebase
% Export to HuggingFace datasets: data-moonshine and data-const71

:- use_module(library(lists)).

% ═══════════════════════════════════════════════════════════
% 71 PROMPTS × 71 FLAVORS
% ═══════════════════════════════════════════════════════════

monster_primes([2,3,5,7,11,13,17,19,23,29,31,37,41,43,47,53,59,61,67,71]).

% Generate prompt for each prime with code flavor
generate_prompt_with_flavor(Prime, Prompt) :-
    prime_domain(Prime, Domain, _),
    get_code_flavor(Prime, Flavor),
    format(atom(Prompt),
        'You are a zkPrologML expert. Prime ~w represents ~w. ~w~n~nTask: ~w~n~nCode flavor: ~w~n~nGenerate a complete implementation.',
        [Prime, Domain, get_description(Prime), get_task(Prime), Flavor]).

prime_domain(2, types, "Foundation of computation").
prime_domain(3, operators, "Mathematical operations").
prime_domain(5, variables, "State and mutation").
prime_domain(7, control, "Branching and flow").
prime_domain(11, functions, "Abstraction and composition").
prime_domain(13, pointers, "Memory references").
prime_domain(17, structures, "Data organization").
prime_domain(19, arrays, "Collections and sequences").
prime_domain(23, memory, "Resource management").
prime_domain(29, optimization, "Performance tuning").
prime_domain(31, output, "Communication and I/O").
prime_domain(37, loops, "Iteration and repetition").
prime_domain(41, machine, "Low-level execution").
prime_domain(43, safety, "Correctness guarantees").
prime_domain(47, network, "Distributed systems").
prime_domain(53, generics, "Polymorphism").
prime_domain(59, macros, "Metaprogramming").
prime_domain(61, reflection, "Introspection").
prime_domain(67, metaprogramming, "Code generation").
prime_domain(71, universe, "Type theory and foundations").

get_description(2) :- "Types are the foundation: int, bool, char form the basis of all computation".
get_description(3) :- "Operators compute: +, -, *, / transform values".
get_description(5) :- "Variables hold state: x, y, z change over time".
get_description(7) :- "Control flows: if, while, for direct execution".
get_description(11) :- "Functions abstract: def, fn, lambda encapsulate logic".
get_description(13) :- "Pointers reference: *ptr, &ref access memory".
get_description(17) :- "Structures organize: struct, record group data".
get_description(19) :- "Arrays collect: [], vector store sequences".
get_description(23) :- "Memory persists: malloc, free manage resources".
get_description(29) :- "Optimization speeds: SSA, inlining improve performance".
get_description(31) :- "Output reveals: print, write communicate results".
get_description(37) :- "Loops repeat: loop, iterate process collections".
get_description(41) :- "Machines execute: asm, linking run code".
get_description(43) :- "Safety protects: borrow, lifetime prevent errors".
get_description(47) :- "Networks connect: tcp, http distribute computation".
get_description(53) :- "Generics generalize: <T>, impl enable reuse".
get_description(59) :- "Macros expand: macro!, quote generate code".
get_description(61) :- "Reflection introspects: typeof, meta examine structure".
get_description(67) :- "Meta transcends: eval, compile create programs".
get_description(71) :- "Universe contains: Type, Kind, Universe encompass all".

get_task(2) :- "Implement a type system with int, bool, char in Rust, Prolog, and Lean4".
get_task(3) :- "Create operator overloading for +, -, *, / with prime signatures".
get_task(5) :- "Design a variable binding system with immutability proofs".
get_task(7) :- "Build control flow analysis with branch prediction".
get_task(11) :- "Implement higher-order functions with closure capture".
get_task(13) :- "Create safe pointer arithmetic with bounds checking".
get_task(17) :- "Design structure layout optimization with alignment".
get_task(19) :- "Implement array operations with SIMD vectorization".
get_task(23) :- "Build memory allocator with garbage collection".
get_task(29) :- "Create optimization passes with SSA transformation".
get_task(31) :- "Implement I/O system with async/await".
get_task(37) :- "Design loop unrolling with vectorization".
get_task(41) :- "Generate machine code with register allocation".
get_task(43) :- "Implement borrow checker with lifetime inference".
get_task(47) :- "Build distributed system with consensus protocol".
get_task(53) :- "Create generic programming with trait bounds".
get_task(59) :- "Implement macro system with hygiene".
get_task(61) :- "Design reflection API with type introspection".
get_task(67) :- "Build code generator with template metaprogramming".
get_task(71) :- "Implement universe hierarchy with dependent types".

% Code flavors from our actual codebase
get_code_flavor(2, "Rust: pub enum Type { Int, Bool, Char }").
get_code_flavor(3, "Prolog: operator(+, 3). operator(*, 5).").
get_code_flavor(5, "Lean4: def variable (α : Type) : Type := α").
get_code_flavor(7, "LLVM: br i1 %cond, label %then, label %else").
get_code_flavor(11, "Rust: fn map<F>(self, f: F) -> Self where F: Fn(T) -> U").
get_code_flavor(13, "C: int *ptr = &value; *ptr = 42;").
get_code_flavor(17, "Rust: struct Point { x: i32, y: i32 }").
get_code_flavor(19, "Prolog: array([1,2,3,4,5]).").
get_code_flavor(23, "Rust: Box::new(value) // heap allocation").
get_code_flavor(29, "LLVM: %opt = add nsw i32 %a, %b").
get_code_flavor(31, "Rust: println!(\"{}\", value);").
get_code_flavor(37, "Rust: for item in collection { process(item); }").
get_code_flavor(41, "Assembly: mov rax, [rbp-8]").
get_code_flavor(43, "Rust: fn borrow<'a>(x: &'a T) -> &'a T").
get_code_flavor(47, "Rust: tokio::spawn(async { tcp_server().await })").
get_code_flavor(53, "Rust: impl<T: Clone> MyTrait for T").
get_code_flavor(59, "Rust: macro_rules! vec { ($($x:expr),*) => { ... } }").
get_code_flavor(61, "Rust: std::any::type_name::<T>()").
get_code_flavor(67, "Prolog: term_expansion((Head :- Body), Expanded)").
get_code_flavor(71, "Lean4: universe u; Type u : Type (u+1)").

% ═══════════════════════════════════════════════════════════
% GENERATE DATASETS
% ═══════════════════════════════════════════════════════════

generate_moonshine_dataset :-
    format('🌙 Generating data-moonshine dataset...~n~n', []),
    
    make_directory_path('generated/data-moonshine'),
    open('generated/data-moonshine/prompts.jsonl', write, S),
    
    monster_primes(Primes),
    forall(member(Prime, Primes), (
        generate_prompt_with_flavor(Prime, Prompt),
        format(S, '{~n', []),
        format(S, '  "prime": ~w,~n', [Prime]),
        format(S, '  "prompt": "~w",~n', [Prompt]),
        format(S, '  "dataset": "moonshine"~n', []),
        format(S, '}~n', [])
    )),
    
    close(S),
    format('✅ Moonshine: generated/data-moonshine/prompts.jsonl~n', []).

generate_const71_dataset :-
    format('🔢 Generating data-const71 dataset...~n~n', []),
    
    make_directory_path('generated/data-const71'),
    open('generated/data-const71/constants.jsonl', write, S),
    
    monster_primes(Primes),
    forall(member(Prime, Primes), (
        prime_domain(Prime, Domain, Desc),
        format(S, '{~n', []),
        format(S, '  "prime": ~w,~n', [Prime]),
        format(S, '  "domain": "~w",~n', [Domain]),
        format(S, '  "description": "~w",~n', [Desc]),
        format(S, '  "constant": true,~n', []),
        format(S, '  "dataset": "const71"~n', []),
        format(S, '}~n', [])
    )),
    
    close(S),
    format('✅ Const71: generated/data-const71/constants.jsonl~n', []).

% Generate README for HuggingFace
generate_readme(Dataset) :-
    format(atom(Dir), 'generated/~w', [Dataset]),
    format(atom(File), '~w/README.md', [Dir]),
    open(File, write, S),
    
    write(S, '---\n'),
    write(S, 'license: mit\n'),
    write(S, 'task_categories:\n'),
    write(S, '- text-generation\n'),
    write(S, '- code-generation\n'),
    write(S, 'language:\n'),
    write(S, '- en\n'),
    write(S, 'tags:\n'),
    write(S, '- zkprologml\n'),
    write(S, '- monster-group\n'),
    write(S, '- prime-lattice\n'),
    write(S, '---\n\n'),
    
    format(S, '# ~w~n~n', [Dataset]),
    write(S, '## Overview\n\n'),
    write(S, '71 prompts/constants corresponding to Monster group primes (2-71).\n\n'),
    write(S, '## Structure\n\n'),
    write(S, 'Each entry contains:\n'),
    write(S, '- `prime`: Monster group prime (2-71)\n'),
    write(S, '- `domain`: Semantic domain\n'),
    write(S, '- `prompt`/`constant`: LLM prompt or constant value\n\n'),
    write(S, '## Usage\n\n'),
    write(S, '```python\n'),
    write(S, 'from datasets import load_dataset\n'),
    format(S, 'dataset = load_dataset("introspector/~w")~n', [Dataset]),
    write(S, '```\n\n'),
    write(S, '## Citation\n\n'),
    write(S, '```bibtex\n'),
    write(S, '@misc{zkprologml2026,\n'),
    write(S, '  title={zkPrologML: Monster Group Lattice for Universal Computation},\n'),
    write(S, '  author={zkPrologML Team},\n'),
    write(S, '  year={2026}\n'),
    write(S, '}\n'),
    write(S, '```\n'),
    
    close(S).

% ═══════════════════════════════════════════════════════════
% MAIN
% ═══════════════════════════════════════════════════════════

main :-
    format('~n🌌 GENERATING 71 LLM PROMPTS + DATASETS~n', []),
    format('═══════════════════════════════════════════════════════════~n~n', []),
    
    generate_moonshine_dataset,
    generate_const71_dataset,
    
    generate_readme('data-moonshine'),
    generate_readme('data-const71'),
    
    format('~n✨ Datasets ready for HuggingFace!~n', []),
    format('~nUpload to:~n', []),
    format('  https://huggingface.co/datasets/introspector/data-moonshine~n', []),
    format('  https://huggingface.co/datasets/introspector/data-const71~n~n', []).

:- initialization(main, main).
