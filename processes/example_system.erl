-module(example_system).

-export([
        calc_sum/1,
        delayed_calc_sum/2
        ]).

delayed_calc_sum(Parent, N) ->
  Sum = delayed_calc_sum2(N),
  Parent ! {self(), Sum},
  exit(normal).
  
delayed_calc_sum2(1) -> 1;
delayed_calc_sum2(N) ->
 N + delayed_calc_sum2(N-1).

calc_sum(N) ->
  (N*(N+1))/2.
