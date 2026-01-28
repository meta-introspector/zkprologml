
% result_cache.pl - Intelligent result caching

:- dynamic cache_entry/4.  % key, value, timestamp, hits

cache_get(Key, Value) :-
    cache_entry(Key, Value, _, Hits),
    !,
    % Increment hits
    retract(cache_entry(Key, Value, TS, Hits)),
    Hits1 is Hits + 1,
    assertz(cache_entry(Key, Value, TS, Hits1)).

cache_put(Key, Value) :-
    get_time(Now),
    assertz(cache_entry(Key, Value, Now, 0)).

cache_stats :-
    aggregate_all(count, cache_entry(_, _, _, _), Count),
    aggregate_all(sum(H), cache_entry(_, _, _, H), TotalHits),
    format('📊 Cache: ~w entries, ~w hits~n', [Count, TotalHits]).

% Evict old entries
cache_evict(MaxAge) :-
    get_time(Now),
    Cutoff is Now - MaxAge,
    retractall(cache_entry(_, _, TS, _)),
    TS < Cutoff.
