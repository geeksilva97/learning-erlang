% https://stackoverflow.com/questions/14515480/processes-exiting-normally
% To run it do:
% 1. erl
% 2. spawn(fun() -> test:start() end). 
-module(test).
-export([start/0,test/0]).

start() ->
     io:format("Parent (~p): started!\n",[self()]),
     P = spawn_link(?MODULE,test,[]),
     io:format(
        "Parent (~p): child ~p spawned. Waiting for 5 seconds\n",[self(),P]),
     timer:sleep(5000),
     % P2 = spawn_link(?MODULE,test,[]),
     % io:format(
     %    "Parent (~p): child ~p spawned. Waiting for 10 seconds\n",[self(),P2]),
     % timer:sleep(10000),
     io:format("Parent (~p): dies out of boredom\n",[self()]),
     ok. 

test() ->
     io:format("Child (~p): I'm... alive!\n",[self()]),
     process_flag(trap_exit, true),
     loop().

loop() ->
     receive
          Q = {'EXIT',_,_} ->
                io:format("Child process died together with parent (~p)\n",[Q]);
          Q ->
                io:format("Something else happened... (~p)\n",[Q])
     after
          2000 -> io:format("Child (~p): still alive after a timeout...\n", [self()]), loop()
     end.
