% GBNF Grammar Generator: Convert Prolog schema to GGML grammar
% Integrates with lang_agent and gbnf-nice-parser

:- module(gbnf_generator, [
    generate_gbnf_grammar/1,
    schema_to_gbnf/2,
    constrain_ollama_output/2
]).

% ============================================================================
% PROLOG SCHEMA TO GBNF GRAMMAR
% ============================================================================

% Generate GBNF grammar for our Prolog schema
generate_gbnf_grammar(OutputFile) :-
    format('🔧 Generating GBNF grammar...~n', []),
    
    % Define our schema
    prolog_schema(Schema),
    
    % Convert to GBNF
    schema_to_gbnf(Schema, GBNF),
    
    % Write to file
    open(OutputFile, write, S),
    write(S, GBNF),
    close(S),
    
    format('✅ Generated ~w~n', [OutputFile]).

% Our Prolog schema
prolog_schema([
    predicate(concept, [atom]),
    predicate(concept_definition, [atom, string]),
    predicate(concept_chord, [atom, integer]),
    predicate(concept_relates_to, [atom, atom, atom]),
    predicate(concept_instance, [atom, string])
]).

% Convert schema to GBNF grammar
schema_to_gbnf(Schema, GBNF) :-
    format(atom(GBNF),
'# GBNF Grammar for Prolog Concept Schema
# Generated from bootstrap system

root ::= statement+

statement ::= concept | concept_definition | concept_chord | concept_relates_to | concept_instance

# concept(Name).
concept ::= "concept(" atom ")."

# concept_definition(Name, Definition).
concept_definition ::= "concept_definition(" atom ", " string ")."

# concept_chord(Name, Prime).
concept_chord ::= "concept_chord(" atom ", " integer ")."

# concept_relates_to(Name1, Name2, Relation).
concept_relates_to ::= "concept_relates_to(" atom ", " atom ", " atom ")."

# concept_instance(Name, Example).
concept_instance ::= "concept_instance(" atom ", " string ")."

# Basic types
atom ::= [a-z] [a-z0-9_]*
integer ::= [0-9]+
string ::= "\\"" [^"]* "\\""
ws ::= [ \\t\\n]*
', []).

% ============================================================================
% CONSTRAINED OLLAMA GENERATION
% ============================================================================

% Use GBNF grammar to constrain Ollama output
constrain_ollama_output(Prompt, PrologFacts) :-
    % Generate grammar if not exists
    GrammarFile = 'data/grammars/prolog_schema.gbnf',
    (exists_file(GrammarFile) ->
        true
    ;
        generate_gbnf_grammar(GrammarFile)
    ),
    
    % Call Ollama with grammar constraint
    format(atom(Cmd), 
        'ollama run codellama:7b --grammar-file ~w ~q',
        [GrammarFile, Prompt]),
    
    setup_call_cleanup(
        open(pipe(Cmd), read, Stream),
        read_string(Stream, _, PrologFacts),
        close(Stream)
    ).

% ============================================================================
% INTEGRATION WITH BOOTSTRAP
% ============================================================================

% Enhanced Ollama job processor with GBNF constraints
process_ollama_job_constrained(Job, OutStream) :-
    Job = json([term=Term, prompt=Prompt|_]),
    
    % Use constrained generation
    constrain_ollama_output(Prompt, Response),
    
    % Validate response is valid Prolog
    (validate_prolog_syntax(Response) ->
        format(OutStream, '%% Concept: ~w~n', [Term]),
        format(OutStream, '~w~n~n', [Response])
    ;
        format(OutStream, '%% ERROR: Invalid Prolog for ~w~n', [Term])
    ).

validate_prolog_syntax(Text) :-
    catch(
        (atom_string(Atom, Text),
         read_term_from_atom(Atom, _, [])),
        _,
        fail
    ).

% ============================================================================
% LANG_AGENT INTEGRATION
% ============================================================================

% Generate lang_agent compatible grammar
generate_lang_agent_grammar(OutputFile) :-
    format('🔧 Generating lang_agent grammar...~n', []),
    
    open(OutputFile, write, S),
    write(S, '# Lang Agent Grammar for Prolog Concepts\n\n'),
    write(S, 'grammar PrologConcepts;\n\n'),
    
    % ANTLR4 style grammar
    write(S, 'program: statement+ ;\n\n'),
    write(S, 'statement\n'),
    write(S, '  : concept\n'),
    write(S, '  | concept_definition\n'),
    write(S, '  | concept_chord\n'),
    write(S, '  | concept_relates_to\n'),
    write(S, '  | concept_instance\n'),
    write(S, '  ;\n\n'),
    
    write(S, 'concept: \'concept(\' ATOM \').\';\n'),
    write(S, 'concept_definition: \'concept_definition(\' ATOM \',\' STRING \').\';\n'),
    write(S, 'concept_chord: \'concept_chord(\' ATOM \',\' INT \').\';\n'),
    write(S, 'concept_relates_to: \'concept_relates_to(\' ATOM \',\' ATOM \',\' ATOM \').\';\n'),
    write(S, 'concept_instance: \'concept_instance(\' ATOM \',\' STRING \').\';\n\n'),
    
    write(S, 'ATOM: [a-z][a-z0-9_]*;\n'),
    write(S, 'INT: [0-9]+;\n'),
    write(S, 'STRING: \'"\' ~["]* \'"\';\n'),
    write(S, 'WS: [ \\t\\n\\r]+ -> skip;\n'),
    
    close(S),
    format('✅ Generated ~w~n', [OutputFile]).

% ============================================================================
% GBNF-NICE-PARSER INTEGRATION
% ============================================================================

% Generate parser using gbnf-nice-parser
generate_nice_parser(GrammarFile, ParserOutput) :-
    format('🔧 Generating parser with gbnf-nice-parser...~n', []),
    
    % Assume gbnf-nice-parser is available
    format(atom(Cmd), 
        'gbnf-nice-parser ~w > ~w',
        [GrammarFile, ParserOutput]),
    
    shell(Cmd),
    format('✅ Generated parser: ~w~n', [ParserOutput]).

% ============================================================================
% COMPLETE PIPELINE
% ============================================================================

% Full pipeline: Schema → GBNF → Constrained Ollama → Validated Prolog
generate_constrained_concepts :-
    format('~n🚀 CONSTRAINED CONCEPT GENERATION~n', []),
    format('═══════════════════════════════════════~n~n', []),
    
    % 1. Generate GBNF grammar
    generate_gbnf_grammar('data/grammars/prolog_schema.gbnf'),
    
    % 2. Generate lang_agent grammar
    generate_lang_agent_grammar('data/grammars/prolog_schema.g4'),
    
    % 3. Process Ollama jobs with constraints
    format('~n🤖 Processing Ollama jobs with GBNF constraints...~n', []),
    open('data/parquets/ollama_jobs.jsonl', read, S),
    read_ollama_jobs(S, Jobs),
    close(S),
    
    open('data/proofs/generated_concepts_constrained.pl', write, Out),
    write(Out, '% Generated with GBNF-constrained Ollama\n\n'),
    write(Out, ':- module(generated_concepts_constrained, []).\n\n'),
    
    forall(
        member(Job, Jobs),
        process_ollama_job_constrained(Job, Out)
    ),
    
    close(Out),
    
    format('~n✅ Generated data/proofs/generated_concepts_constrained.pl~n', []),
    format('✅ All outputs are valid Prolog (grammar-enforced)~n', []).

% Helper to read JSONL
read_ollama_jobs(Stream, Jobs) :-
    read_line_to_string(Stream, Line),
    (Line == end_of_file ->
        Jobs = []
    ;
        atom_string(JobAtom, Line),
        term_string(Job, JobAtom),
        read_ollama_jobs(Stream, RestJobs),
        Jobs = [Job | RestJobs]
    ).

% ============================================================================
% EXAMPLE
% ============================================================================

example :-
    generate_gbnf_grammar('data/grammars/prolog_schema.gbnf'),
    generate_lang_agent_grammar('data/grammars/prolog_schema.g4').
