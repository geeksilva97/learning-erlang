-module(run_forever).

-export([start/0, start/1, loop/0, start_child/0, kill/1]).


start_child() ->
  Pid = spawn_link(?MODULE, start, []),
  ProcessInfo = process_info(Pid),
  io:format("Process INFO: ~p~n", [ProcessInfo]),
  Pid.

kill(Pid) ->
  exit(Pid, kill),
  receive
    Res ->
      io:format("~p~n", [Res])
  after 5000 ->
        timeout
  end.

start() ->
  io:format("Running forever"),
  process_flag(trap_exit, true),
  loop().
start(Timeout) ->
  io:format("Runnig for ~p~n", [Timeout]),
  loop().

loop() ->
  receive 
    Message ->
      io:format("Received a message: ~p~n",[Message]),
      loop()
  end.
