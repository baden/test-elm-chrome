module Helpers exposing (..)

import Time exposing (utc, Posix)
-- import Date.Format


dateToTime : Posix -> String
dateToTime time =
    let
        hour = String.fromInt (Time.toHour utc time) |> String.padLeft 2 '0'
        minute = String.fromInt (Time.toMinute utc time) |> String.padLeft 2 '0'
        second = String.fromInt (Time.toSecond utc time) |> String.padLeft 2 '0'
    in
        hour ++ ":" ++ minute ++ ":" ++ second


deltaAsString : Float -> String
deltaAsString d =
    -- let
    --     hi =
    --         floor d

    --     lo =
    --         -- (round (d * 1000)) % 1000

    --     loStr =
    --         toString lo
    --             |> String.padLeft 3 '0'
    -- in
    --     if d > 1000000 then
    --         "+?"
    --     else
    --         "+" ++ (toString hi) ++ "." ++ loStr
    String.fromFloat d
