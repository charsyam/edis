%%%-------------------------------------------------------------------
%%% @author Fernando Benavides <fernando.benavides@inakanetworks.com>
%%% @author Chad DePue <chad@inakanetworks.com>
%%% @copyright (C) 2011 InakaLabs SRL
%%% @doc Edis Pub/Sub supervisor
%%% @end
%%%-------------------------------------------------------------------
-module(edis_pubsub_sup).
-author('Fernando Benavides <fernando.benavides@inakanetworks.com>').
-author('Chad DePue <chad@inakanetworks.com>').

-include("edis.hrl").

-behaviour(supervisor).

-export([start_link/0, reload/0, init/1]).

%% ====================================================================
%% External functions
%% ====================================================================
%% @doc  Starts the supervisor process
-spec start_link() -> ignore | {error, term()} | {ok, pid()}.
start_link() ->
  supervisor:start_link({local, ?MODULE}, ?MODULE, []).

%% @doc  Reloads configuration. Restarts the managers
-spec reload() -> ok.
reload() ->
  true = exit(erlang:whereis(?MODULE), kill),
  ok.

%% ====================================================================
%% Server functions
%% ====================================================================
%% @hidden
-spec init([]) -> {ok, {{one_for_one, 5, 10}, [supervisor:child_spec()]}}.
init([]) ->
  ?INFO("Pub/Sub supervisor initialized~n", []),
  ChannelMgr = {edis_pubsub_channel, {edis_pubsub, start_link, [edis_pubsub_channel]},
                permanent, brutal_kill, worker, [edis_pubsub]},
  PatternMgr = {edis_pubsub_pattern, {edis_pubsub, start_link, [edis_pubsub_pattern]},
                permanent, brutal_kill, worker, [edis_pubsub]},
  {ok, {{one_for_one, 5, 1}, [ChannelMgr, PatternMgr]}}.