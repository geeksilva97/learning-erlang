-module(pure_erlang_server).

% -export(compile_all).
-export([
        init/0,
        start/0,
        ping/0,
        get_count/0,
        get_count_sync/0
        ]).

start() ->
  spawn(?MODULE, init, []).

ping() ->
  ?MODULE ! {self(), "ping"},
  ok.

get_count() ->
  ?MODULE ! {self(), get_count},
  ok.

get_count_sync() ->
  ?MODULE ! {self(), get_count_sync},
  receive 
    Result ->
      Result
  end.

init() ->
  io:format("Intializing server...~n"),
  register(?MODULE, self()),
  loop(0).

loop(Count) ->
  receive
    {From, get_count_sync} ->
      From ! Count,
      loop(Count+1);
    {_From, get_count} ->
      io:format("Requests count: ~p~n", [Count]),
      loop(Count+1);
    {From, Data} ->
      io:format("From: ~p / Data: ~p~n", [From, Data]),
      loop(Count+1);
    Other ->
      io:format("unexpected message: ~p~n", [Other]),
      loop(Count+1)
  end.


