-- Read more about this program in the official Elm guide:
-- https://guide.elm-lang.org/architecture/user_input/buttons.html


module Main exposing (..)

import Html exposing (beginnerProgram, div, button, text)
import Html.Events exposing (onClick)


type alias Model =
    { counter : Int
    }


init : Model
init =
    { counter = 0 }


main : Program Never Model Msg
main =
    beginnerProgram { model = init, view = view, update = update }


view : Model -> Html.Html Msg
view model =
    div []
        [ button [ onClick Decrement ] [ text "-" ]
        , div [] [ text (toString model.counter) ]
        , button [ onClick Increment ] [ text "+" ]
        ]


type Msg
    = Increment
    | Decrement


update : Msg -> Model -> Model
update msg model =
    case msg of
        Increment ->
            { model | counter = model.counter + 1 }

        Decrement ->
            { model | counter = model.counter - 1 }
