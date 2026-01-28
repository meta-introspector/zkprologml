
% parallel_queries.pl - Parallel query execution

:- use_module(library(thread)).

parallel_query(Goals, Results) :-
    length(Goals, N),
    format('🔀 Executing ~w queries in parallel~n', [N]),
    
    % Create threads
    maplist(create_thread, Goals, Threads),
    
    % Wait for all
    maplist(thread_join, Threads, Results).

create_thread(Goal, Thread) :-
    thread_create(call(Goal), Thread, []).

% Example usage:
% ?- parallel_query([monster_prime(X), emoji_prime(Y, E)], Results).
