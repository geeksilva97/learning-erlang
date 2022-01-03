-module(naive_example_system_sup).

-export([start/1, start_multiple/1,  loop/1]).

-spec start_multiple(term()) -> [pid()].
start_multiple(Values) ->
  process_flag(trap_exit, true),
  Pids = [spawn_link(example_system, delayed_calc_sum, [self(), V]) || V <- Values],
  io:format("~p~n", [Pids]),
  loop(Pids).

start(Value) ->
  process_flag(trap_exit, true),
  Pid1 = spawn_link(example_system, delayed_calc_sum, [self(), Value]),
  Pid2 = spawn_link(example_system, delayed_calc_sum, [self(), Value*100]),
  io:format("started and linked two processes: [~p, ~p]~n", [Pid1, Pid2]).
  % loop().

loop([]) ->
  io:format("other processes finished~n"),
  ok;
  
loop([_|OtherPids] = Pids) ->
  receive
    {'EXIT', _Pid, normal} ->
      loop(OtherPids);
    Msg ->
      io:format("Received Message: ~p~n", [Msg]),
        loop(Pids)
  end.
