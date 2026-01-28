#!/usr/bin/env swipl
% Register Profiling with Perf - Map to Prime Lattice
% Record registers, extract instruction values, assign prime complexity

:- use_module(library(process)).
:- use_module(library(readutil)).

% ═══════════════════════════════════════════════════════════
% PRIME LATTICE FOR REGISTERS
% ═══════════════════════════════════════════════════════════

register_prime(rax, 2).   % Return value
register_prime(rbx, 3).   % Base
register_prime(rcx, 5).   % Counter
register_prime(rdx, 7).   % Data
register_prime(rsi, 11).  % Source index
register_prime(rdi, 13).  % Destination index
register_prime(rbp, 17).  % Base pointer
register_prime(rsp, 19).  % Stack pointer
register_prime(r8, 23).
register_prime(r9, 29).
register_prime(r10, 31).
register_prime(r11, 37).
register_prime(r12, 41).
register_prime(r13, 43).
register_prime(r14, 47).
register_prime(r15, 53).

% ═══════════════════════════════════════════════════════════
% PRIME LATTICE FOR INSTRUCTIONS
% ═══════════════════════════════════════════════════════════

instruction_prime(mov, 2).    % Data movement
instruction_prime(add, 3).    % Arithmetic
instruction_prime(sub, 3).
instruction_prime(mul, 5).
instruction_prime(div, 5).
instruction_prime(cmp, 7).    % Comparison
instruction_prime(test, 7).
instruction_prime(jmp, 11).   % Control flow
instruction_prime(je, 11).
instruction_prime(jne, 11).
instruction_prime(call, 13).  % Function calls
instruction_prime(ret, 13).
instruction_prime(push, 17).  % Stack operations
instruction_prime(pop, 17).
instruction_prime(lea, 19).   % Address calculation
instruction_prime(xor, 23).   % Bitwise
instruction_prime(and, 23).
instruction_prime(or, 23).

% ═══════════════════════════════════════════════════════════
% RECORD WITH PERF: Registers + Instructions
% ═══════════════════════════════════════════════════════════

record_with_registers(Program, OutputBase) :-
    format('🎯 Recording ~w with register profiling~n', [Program]),
    
    % Perf record with register sampling
    format(atom(PerfData), '~w.perf.data', [OutputBase]),
    format(atom(PerfScript), '~w.perf.script', [OutputBase]),
    
    % Record with registers
    process_create(path(perf), [
        'record',
        '-e', 'cycles',
        '--intr-regs=AX,BX,CX,DX,SI,DI,BP,SP,R8,R9,R10,R11,R12,R13,R14,R15',
        '-o', PerfData,
        '--', Program
    ], []),
    
    % Generate script with register values
    format('⚠️  Perf script generation (register values require kernel support)~n', []),
    % process_create(path(perf), [
    %     'script',
    %     '-i', PerfData,
    %     '-F', 'ip,sym,iregs',
    %     '-o', PerfScript
    % ], []),
    
    format('✅ Recorded: ~w~n', [PerfData]).

% ═══════════════════════════════════════════════════════════
% PARSE PERF SCRIPT: Extract registers and instructions
% ═══════════════════════════════════════════════════════════

parse_perf_script(ScriptFile, Samples) :-
    read_file_to_string(ScriptFile, Content, []),
    split_string(Content, "\n", "", Lines),
    findall(Sample, (
        member(Line, Lines),
        parse_sample_line(Line, Sample)
    ), Samples).

parse_sample_line(Line, sample{ip: IP, regs: Regs}) :-
    % Parse line format: "address symbol AX:value BX:value ..."
    split_string(Line, " ", " \t", Parts),
    Parts = [IPStr | Rest],
    atom_string(IP, IPStr),
    parse_registers(Rest, Regs).

parse_registers(Parts, Regs) :-
    findall(Reg-Value, (
        member(Part, Parts),
        split_string(Part, ":", "", [RegStr, ValStr]),
        downcase_atom(RegStr, Reg),
        atom_string(ValAtom, ValStr),
        atom_number(ValAtom, Value)
    ), Regs).

% ═══════════════════════════════════════════════════════════
% CALCULATE REGISTER SIGNATURE (Gödel number)
% ═══════════════════════════════════════════════════════════

register_signature(Samples, Signature) :-
    % Count register usage
    findall(Reg, (
        member(Sample, Samples),
        member(Reg-_, Sample.regs)
    ), AllRegs),
    
    % Count occurrences
    findall(Prime^Count, (
        register_prime(Reg, Prime),
        findall(1, member(Reg, AllRegs), Occurrences),
        length(Occurrences, Count),
        Count > 0
    ), PrimeCounts),
    
    % Calculate Gödel number: ∏(prime^count)
    calculate_godel_number(PrimeCounts, Signature).

calculate_godel_number([], 1).
calculate_godel_number([Prime^Count | Rest], Signature) :-
    calculate_godel_number(Rest, RestSig),
    Signature is RestSig * (Prime ** Count).

% ═══════════════════════════════════════════════════════════
% EXTRACT INSTRUCTIONS FROM BINARY
% ═══════════════════════════════════════════════════════════

extract_instructions(Binary, Instructions) :-
    format('🔍 Extracting instructions from ~w~n', [Binary]),
    
    % Objdump disassembly
    process_create(path(objdump), ['-d', Binary], 
        [stdout(pipe(Out))]),
    read_string(Out, _, Disasm),
    close(Out),
    
    % Parse instructions
    split_string(Disasm, "\n", "", Lines),
    findall(Instr, (
        member(Line, Lines),
        parse_instruction_line(Line, Instr)
    ), Instructions),
    
    format('✅ Found ~w instructions~n', [length(Instructions)]).

parse_instruction_line(Line, Instr) :-
    % Parse: "  address: bytes  instruction operands"
    % Example: "    1040:	b8 03 00 00 00       	mov    $0x3,%eax"
    sub_string(Line, _, _, _, ":"),  % Has address
    sub_string(Line, _, _, _, "\t"),  % Has tab
    split_string(Line, "\t", "", Parts),
    length(Parts, Len), Len >= 3,
    nth0(2, Parts, InstrPart),
    split_string(InstrPart, " ", " ", [InstrStr | _]),
    InstrStr \= "",
    atom_string(Instr, InstrStr).

% ═══════════════════════════════════════════════════════════
% INSTRUCTION SIGNATURE (Gödel number)
% ═══════════════════════════════════════════════════════════

instruction_signature(Instructions, Signature) :-
    % Count instruction types
    findall(Prime^Count, (
        instruction_prime(Instr, Prime),
        findall(1, member(Instr, Instructions), Occurrences),
        length(Occurrences, Count),
        Count > 0
    ), PrimeCounts),
    
    % Calculate Gödel number
    calculate_godel_number(PrimeCounts, Signature).

% ═══════════════════════════════════════════════════════════
% COMPLETE PROFILE: Registers + Instructions → Lattice
% ═══════════════════════════════════════════════════════════

profile_program(SourceFile, Binary) :-
    format('~n📊 PROFILING: ~w~n', [Binary]),
    format('═══════════════════════════════════════════════════════════~n~n', []),
    
    % Check if binary exists, compile if needed
    (exists_file(Binary) ->
        format('✅ Using existing binary: ~w~n~n', [Binary]) ;
        (format('1️⃣  Compiling...~n', []),
         process_create(path(gcc), ['-O2', SourceFile, '-o', Binary], []),
         format('✅ Binary: ~w~n~n', [Binary]))),
    
    % Extract instructions
    format('2️⃣  Extracting instructions...~n', []),
    extract_instructions(Binary, Instructions),
    format('~n', []),
    
    % Calculate instruction signature
    format('3️⃣  Calculating instruction signature...~n', []),
    instruction_signature(Instructions, InstrSig),
    format('✅ Instruction signature (Gödel): ~w~n~n', [InstrSig]),
    
    % Show instruction breakdown
    format('4️⃣  Instruction breakdown:~n', []),
    findall(Instr-Prime, (
        instruction_prime(Instr, Prime),
        member(Instr, Instructions)
    ), InstrPrimes),
    sort(InstrPrimes, Sorted),
    forall(member(I-P, Sorted), 
        format('   ~w (prime ~w)~n', [I, P])),
    
    format('~n✨ Profile complete!~n~n', []).

% ═══════════════════════════════════════════════════════════
% PROFILE ALL GÖDEL PROGRAMS
% ═══════════════════════════════════════════════════════════

profile_all_godel_programs :-
    format('~n🎯 PROFILING ALL GÖDEL PROGRAMS~n', []),
    format('═══════════════════════════════════════════════════════════~n', []),
    
    % Find all test programs
    findall(File, (
        exists_file(File),
        atom_concat('generated/variations/test_', _, File),
        atom_concat(_, '.c', File)
    ), Programs),
    
    format('Found ~w programs~n~n', [length(Programs)]),
    
    % Profile each
    forall(member(Prog, Programs), (
        atom_concat(Prog, '.bin', Binary),
        profile_program(Prog, Binary)
    )).

% ═══════════════════════════════════════════════════════════
% EXPORT TO PARQUET
% ═══════════════════════════════════════════════════════════

export_profiles_to_parquet :-
    format('📊 Exporting profiles to parquet~n', []),
    
    % Collect all profiles
    findall(profile{
        program: Prog,
        instruction_signature: InstrSig,
        register_signature: RegSig,
        combined_signature: Combined
    }, profile_data(Prog, InstrSig, RegSig, Combined), Profiles),
    
    % Write CSV
    open('generated/register_instruction_profiles.csv', write, Stream),
    format(Stream, 'program,instruction_signature,register_signature,combined_signature~n', []),
    forall(member(P, Profiles),
        format(Stream, '~w,~w,~w,~w~n', 
            [P.program, P.instruction_signature, P.register_signature, P.combined_signature])),
    close(Stream),
    
    % Convert to parquet
    process_create(path(python3), ['-c',
        'import polars as pl; df = pl.read_csv("generated/register_instruction_profiles.csv"); df.write_parquet("generated/register_instruction_profiles.parquet")'
    ], []),
    
    format('✅ Parquet: generated/register_instruction_profiles.parquet~n', []).

:- dynamic profile_data/4.

% ═══════════════════════════════════════════════════════════
% MAIN
% ═══════════════════════════════════════════════════════════

main :-
    % Profile existing binaries
    profile_program('generated/variations/test_3_1.c', 'generated/variations/test_3_1').

:- initialization(main, main).
