-module(sc_sup).
-behaviour(supervisor).
-export([start_link/0, start_child/2]).
-export([init/1]).

-define(SERVER, ?MODULE).

start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

start_child(Value, LaseTime) -> 
  supervisor:start_child(?SERVER, [Value, LaseTime]).

init([]) ->
  Element = {sc_element, {sc_element, start_link, []},
             temporary, brutal_kill, worker, [sc_element]},
  % child_spec - https://www.erlang.org/doc/man/supervisor.html#type-child_spec
  Children = [Element],

  % supervisor flags - https://www.erlang.org/doc/man/supervisor.html#type-sup_flags
  RestartStrategy = {simple_one_for_one, 0, 1},
  {ok, {RestartStrategy, Children}}.
