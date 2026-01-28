% zkllm_monad.pl - LLM interfaces as monads

:- module(zkllm_monad, [
    llm_bind/3,
    llm_return/1,
    llm_query/2,
    gemini/2
]).

% LLM Monad: M a = IO (Either Error a)
% bind :: M a -> (a -> M b) -> M b
llm_bind(Action, Continuation, Result) :-
    call(Action, Value),
    (   Value = error(E) -> Result = error(E)
    ;   call(Continuation, Value, Result)
    ).

% return :: a -> M a
llm_return(Value) :- Value.

% Query LLM with prompt
llm_query(Prompt, Response) :-
    gemini(Prompt, Response).

% Gemini CLI interface
gemini(Prompt, Response) :-
    % Get gemini CLI path
    getenv('GEMINI_CLI', GeminiPath),
    
    % Create temp file for prompt
    tmp_file_stream(text, TmpFile, Stream),
    write(Stream, Prompt),
    close(Stream),
    
    % Call gemini CLI
    format(atom(Cmd), '~w < ~w', [GeminiPath, TmpFile]),
    setup_call_cleanup(
        open(pipe(Cmd), read, PipeStream),
        read_string(PipeStream, _, Response),
        close(PipeStream)
    ),
    
    % Cleanup
    delete_file(TmpFile).

% Monadic composition
% (>=>) :: (a -> M b) -> (b -> M c) -> (a -> M c)
compose_llm(F, G, Input, Output) :-
    llm_bind(call(F, Input), G, Output).

% Example: Chain LLM queries
chain_queries(Prompts, Responses) :-
    foldl(llm_bind_fold, Prompts, [], Responses).

llm_bind_fold(Prompt, Acc, [Response|Acc]) :-
    llm_query(Prompt, Response).

% Lift pure function into monad
llm_lift(F, Input, Output) :-
    call(F, Input, Result),
    llm_return(Result, Output).

% Example usage:
% ?- llm_query("What is 2+2?", R).
% ?- llm_bind(llm_query("Explain primes"), 
%             llm_query("Now explain Gödel encoding"), 
%             R).
