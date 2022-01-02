-module(request_count_gen_server).
-behaviour(gen_server).
-compile(export_all).

-define(SERVER, ?MODULE).

ping() ->
 gen_server:call(?SERVER, ping).

reset_counter() ->
  gen_server:cast(?SERVER, reset_counter).

get_count() ->
  gen_server:call(?SERVER, get_count).

get_count_async() ->
  gen_server:cast(?SERVER, get_count_async).

get_count_with_no_increment() ->
  gen_server:call(?SERVER, get_count_with_no_increment).

timeout_break() ->
  gen_server:call(?SERVER, timeout_break).

init(Args) ->
  io:format("initializing with args: ~p~n", [Args]),
  {ok, 0}.


% ======================================================= 
%                 GEN_SERVER TRIGGERS
% ======================================================= 
start_link() ->
  gen_server:start_link({local, ?SERVER}, ?SERVER, [], []).


handle_call(ping, _From, State) ->
  {reply, "PONG", State + 1};
handle_call(get_count_with_no_increment, _From, State) ->
  {reply, State, State};

handle_call(timeout_break, _From, State) ->
  timer:sleep(6000),
  NewState = State + 1,
  {reply, NewState, NewState};


handle_call(get_count, _From, State) ->
  NewState = State + 1,
  {reply, NewState, NewState};
handle_call(Request, From, State) ->
  io:format("handle_call()~n~nRequest: ~p~nFrom: ~p~nState: ~p~n", [Request, From, State]),
  {reply, State, State+1}.

handle_cast(get_count_async, State) ->
  {stop, normal, State};
handle_cast(reset_counter, _State) ->
  {noreply, 0}.

handle_info(timeout, State) ->
  {noreply, State};
handle_info(Info, State) ->
  io:format("Info: ~p // State: ~p~n", [Info, State]),
  {noreply, State}.
