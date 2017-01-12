module Main exposing (..)

import Html exposing (Html)
import Types exposing (Model, Msg)
import Update exposing (init, update, subscriptions)
import View exposing (view)


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
