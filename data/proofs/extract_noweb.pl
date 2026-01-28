#!/usr/bin/env swipl
% Extract code from noweb literate document

:- use_module(library(readutil)).
:- use_module(library(pcre)).

% Extract all code chunks from noweb file
extract_chunks(File, Chunks) :-
    read_file_to_string(File, Content, []),
    re_matchsub('<<([^>]+)>>=\\n(.*?)\\n@'/ms, Content, Match, []),
    findall(Name-Code, (
        re_foldl(extract_chunk, '<<([^>]+)>>=\\n(.*?)\\n@'/ms, Content, [], Pairs, []),
        member(Name-Code, Pairs)
    ), Chunks).

extract_chunk(Match, Acc, [Name-Code|Acc]) :-
    get_dict(1, Match, NameStr),
    get_dict(2, Match, Code),
    atom_string(Name, NameStr).

% Extract main program or concatenate all
extract_code(File, Code) :-
    read_file_to_string(File, Content, []),
    findall(ChunkCode, (
        re_matchsub('<<([^>]+)>>=\\n(.*?)\\n@'/ms, Content, Match, [global(true)]),
        get_dict(2, Match, ChunkCode)
    ), Codes),
    atomic_list_concat(Codes, '\n\n', Code).

% Simpler: just extract everything between <<...>>= and @
extract_all_code(File, Code) :-
    read_file_to_string(File, Content, []),
    split_string(Content, "\n", "", Lines),
    extract_code_lines(Lines, [], CodeLines),
    reverse(CodeLines, RevCode),
    atomic_list_concat(RevCode, '\n', Code).

extract_code_lines([], Acc, Acc).
extract_code_lines([Line|Rest], Acc, Result) :-
    (sub_string(Line, _, _, _, "<<") ->
        extract_code_lines(Rest, Acc, Result) ;
     sub_string(Line, 0, 1, _, "@") ->
        extract_code_lines(Rest, Acc, Result) ;
     sub_string(Line, 0, 1, _, "\\") ->
        extract_code_lines(Rest, Acc, Result) ;
     sub_string(Line, 0, 1, _, "%") ->
        (sub_string(Line, 1, 1, _, " ") ->
            extract_code_lines(Rest, [Line|Acc], Result) ;
            extract_code_lines(Rest, Acc, Result)) ;
        extract_code_lines(Rest, [Line|Acc], Result)).

main :-
    current_prolog_flag(argv, Argv),
    (Argv = [File|_] ->
        (extract_all_code(File, Code),
         writeln(Code)) ;
        (format('Usage: extract_noweb.pl <file.nw>~n', []),
         halt(1))).

:- initialization(main, main).
