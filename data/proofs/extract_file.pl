#!/usr/bin/env swipl
% Extract specific file from v3 literate document

:- use_module(library(readutil)).

extract_file(LiterateDoc, FileName, Code) :-
    read_file_to_string(LiterateDoc, Content, []),
    format(string(Pattern), '<<~w>>=', [FileName]),
    split_string(Content, "\n", "", Lines),
    extract_chunk(Lines, Pattern, [], CodeLines),
    reverse(CodeLines, RevCode),
    atomic_list_concat(RevCode, '\n', Code).

extract_chunk([], _, Acc, Acc).
extract_chunk([Line|Rest], Pattern, Acc, Result) :-
    (sub_string(Line, _, _, _, Pattern) ->
        extract_until_at(Rest, [], Result1),
        append(Result1, Acc, NewAcc),
        extract_chunk(Rest, Pattern, NewAcc, Result) ;
        extract_chunk(Rest, Pattern, Acc, Result)).

extract_until_at([], Acc, Acc).
extract_until_at([Line|Rest], Acc, Result) :-
    (sub_string(Line, 0, 1, _, "@") ->
        Result = Acc ;
     sub_string(Line, 0, 2, _, "<<") ->
        Result = Acc ;
        extract_until_at(Rest, [Line|Acc], Result)).

main :-
    current_prolog_flag(argv, Argv),
    (Argv = [Doc, File|_] ->
        (extract_file(Doc, File, Code),
         writeln(Code)) ;
        (format('Usage: extract_file.pl <literate.nw> <filename>~n', []),
         halt(1))).

:- initialization(main, main).
