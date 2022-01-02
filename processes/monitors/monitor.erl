-module(monitor).
-export([start_child/0, start_linked_child/0, loop/0, on_exit/2]).

start_child() ->
  spawn_monitor(monitored, start, []).

start_linked_child() ->
  spawn_link(monitored, start, []).

on_exit(Pid, Fn) ->
  spawn(fun() ->
          monitor(process, Pid),
          receive
            Msg ->
              io:write("Received in on_exit: ~p~n", [Msg]),
              Fn(why)
          end
        end).

loop() ->
  io:format("Waiting for news"),
  receive
    Message ->
      io:format("Received ~p~n", [Message]),
      loop()
  end.
