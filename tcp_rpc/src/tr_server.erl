%%%-------------------------------------------------------------------
%%% @author Martin & Eric <erlware-dev@googlegroups.com>
%%%  [http://www.erlware.org]
%%% @copyright 2008 Erlware
%%% @doc RPC over TCP server. This module defines a server process that
%%%      listens for incoming TCP connections and allows the user to
%%%      execute RPC commands via that TCP stream.
%%% @end
%%%-------------------------------------------------------------------

-module(tr_server).
-behaviour(gen_server).

%% API
-export([
  start_link/1,
  start_link/0,
  get_count/0,
  stop/0
]).

%% gen_server callbacks
-export([
         init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3
]).


-define(SERVER, ?MODULE).
-define(DEFAULT_PORT, 1055).

-record(state, {port, lsock, request_count = 0}).


start_link(Port) -> 
    gen_server:start_link({local, ?SERVER}, ?MODULE, [Port], []).

start_link() -> start_link(?DEFAULT_PORT).

get_count() ->
    gen_server:call(?SERVER, get_count).

stop() -> gen_server:cast(?SERVER, stop).

%% gen_server callbacks below
init([Port]) -> 
  {ok, LSock} = gen_tcp:listen(Port, [{active, true}]),
  {ok,  #state{port = Port, lsock = LSock}, 0}.

handle_call(get_count, _From, State) -> 
  io:format("handling get_cunt"),
  {reply, {State#state.request_count}, State}.

handle_cast(stop, State) -> 
  {stop, normal, State}.

handle_info({tcp, Socket, RawData}, State) ->
  io:format("handle_info -- ~p // ~p~n", [Socket, RawData]),
  do_rpc(Socket, RawData),
  RequestCount = State#state.request_count,
  {noreply, State#state{request_count = RequestCount + 1}};
handle_info(timeout, #state{lsock = LSock} = State) ->
    {ok, _Sock} = gen_tcp:accept(LSock),
    {noreply, State}.

terminate(_Reason, _State) -> ok.

code_change(_OldVan, State, _Extra) -> {ok, State}.

% INTERNAL FUNCTIONS BELOW

% do_rpc(Socket, RawData) -> 
%   MFA = re:replace(RawData, "\r\n$", "", [{return, list}]),
%   io:format("MFA: ~p~n", [MFA]),
%   gen_tcp:send(Socket, io_lib:fwrite("do_rpc()~n", [])).

do_rpc(Socket, RawData) -> 
  try
    {M, F, A} = split_out_mfa(RawData),
    io:format("MODULE: ~p / Fuction: ~p / Args: ~p~n", [M, F, A]),
    Result = apply(M, F, A),
    gen_tcp:send(Socket, io_lib:fwrite("~p~n", [Result]))
  catch
    Class:Err ->
      io:format("Erro ao processar a requisição // class: ~p~n", [Class]),
        gen_tcp:send(Socket, io_lib:fwrite("~p~n", [Err]))
  end.

split_out_mfa(RawData) ->
    MFA = re:replace(RawData, "\r\n$", "", [{return, list}]),
    io:format("MFA: ~p~n", [MFA]),
    {match, [M, F, A]} = re:run(MFA,
                                "(.*):(.*)\s*\\((.*)\s*\\)\s*.\s*$",
                                [{capture, [1,2,3], list}, ungreedy]),
    {list_to_atom(M), list_to_atom(F), args_to_terms(A)}.

args_to_terms(RawArgs) ->
    {ok, Toks, _Line} = erl_scan:string("[" ++ RawArgs ++ "]. ", 1),
    {ok, Args} = erl_parse:parse_term(Toks),
    Args.
                               
