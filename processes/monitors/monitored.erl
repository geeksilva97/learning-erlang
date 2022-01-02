-module(monitored).
-export([start/0, die_after_timeout/1, die_after_timeout/2]).

start() ->
  io:format("Started a monitored process with PID#~p~n", [self()]),
  loop().

die_after_timeout(Timeout, Pid) ->
  link(Pid),
  die_after_timeout(Timeout).

die_after_timeout(Timeout) ->
  timer:sleep(Timeout),
  exit(kill).

loop() ->
  receive 
    _Any -> ok,
    loop()
  end.
