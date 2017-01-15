module Helpers exposing (..)

import Date
import Date.Format


dateToTime : Date.Date -> String
dateToTime date =
    Date.Format.format "%H:%M:%S" date


deltaAsString : Float -> String
deltaAsString d =
    let
        hi =
            floor d

        lo =
            (round (d * 1000)) % 1000

        loStr =
            toString lo
                |> String.padLeft 3 '0'
    in
        if d > 1000000 then
            "+?"
        else
            "+" ++ (toString hi) ++ "." ++ loStr
