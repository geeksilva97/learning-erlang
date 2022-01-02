-module(naive_example_system_sup).

-export([start/1, loop/0]).

start(Value) ->
  process_flag(trap_exit, true),
  Pid1 = spawn_link(example_system, delayed_calc_sum, [self(), Value]),
  Pid2 = spawn_link(example_system, delayed_calc_sum, [self(), Value*100]),
  io:format("started and linked two processes: [~p, ~p]~n", [Pid1, Pid2]),
  loop().

loop() ->
  receive
    Msg ->
      io:format("~p~n", [Msg])
  end,
  loop().
