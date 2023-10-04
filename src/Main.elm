module Main exposing (..)
import Browser

-- import Html exposing (Html)
import Types exposing (Model, Msg)
import Update exposing (init, update, subscriptions)
import View exposing (view)


main : Program Int Model Msg
main =
  Browser.element
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }
