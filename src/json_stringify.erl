-module(json_stringify).

-export([from_term/1]).

from_term(false) ->
  <<"false">>;
from_term(true) ->
  <<"true">>;
from_term(null) ->
  <<"null">>;
from_term(Atom) when is_atom(Atom) ->
  [<<"\"">>, atom_to_binary(Atom, utf8), <<"\"">>];
from_term(Binary) when is_binary(Binary) ->
  [<<"\"">>, escape(Binary), <<"\"">>];
from_term(Int) when is_integer(Int) ->
  integer_to_binary(Int);
from_term(Float) when is_float(Float) ->
  float_to_binary(Float, [{decimals, 20}, compact]);
from_term(Map) when is_map(Map) ->
  Values = maps:fold(fun obj_fold/3, [], Map),
  [<<"{">>, join(Values, <<",">>, []), <<"}">>];
from_term([{_K, _V}|_] = Obj) ->
  Values = lists:foldl(fun obj_fold/3, [], Obj),
  [<<"{">>, join(Values, <<",">>, []), <<"}">>];
from_term(List) when is_list(List) ->
  Values = [from_term(Value) || Value <- List],
  [<<"[">>, join(Values, <<",">>, []), <<"]">>].

obj_fold(_, undefined, Acc) ->
  Acc;
obj_fold(K, V, Acc) ->
  [[from_term(K), $:, from_term(V)]|Acc].

join([], _, Acc) ->
  Acc;
join([Val], _, Acc) ->
  lists:reverse([Val|Acc]);
join([Val|Rest], Char, Acc) ->
  join(Rest, Char, [Char, Val|Acc]).

escape(Bin) ->
  << <<(escape_char(Char))/binary>> || <<Char/utf8>> <= Bin >>.

escape_char($\b) ->
  <<"\\\b">>;
escape_char($\t) ->
  <<"\\\bt">>;
escape_char($\n) ->
  <<"\\\n">>;
escape_char($\f) ->
  <<"\\\f">>;
escape_char($\r) ->
  <<"\\\r">>;
escape_char($\\) ->
  <<"\\\\">>;
escape_char($") ->
  <<"\\\"">>;
escape_char(Char) ->
  <<Char/utf8>>.