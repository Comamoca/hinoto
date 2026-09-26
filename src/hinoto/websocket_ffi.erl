-module(websocket_ffi).
-export([send_text/2, send_binary/2, close/1, unsafe_coerce/1]).

%% @doc Sends a text frame over the WebSocket.
send_text(Conn, Text) ->
    case mist:send_text_frame(Conn, Text) of
        ok -> nil;
        {ok, _} -> nil;
        _ -> nil
    end.

%% @doc Sends a binary frame over the WebSocket.
send_binary(Conn, Bits) ->
    case mist:send_binary_frame(Conn, Bits) of
        ok -> nil;
        {ok, _} -> nil;
        _ -> nil
    end.

%% @doc Mist does not expose a public close function for WebSocket connections.
%% Closing is handled by returning `mist:stop()' from the message handler.
close(_Conn) ->
    nil.

%% @doc Unsafe cast for Erlang/Dynamic values. Erlang is dynamically typed,
%% so this is a no-op at runtime.
unsafe_coerce(Value) -> Value.
