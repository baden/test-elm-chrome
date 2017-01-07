-- Read more about this program in the official Elm guide:
-- https://guide.elm-lang.org/architecture/user_input/buttons.html


module Main exposing (..)

import Html exposing (beginnerProgram, node, div, button, text)
import Html.Attributes exposing (attribute)
import Html.Events exposing (onClick)


main : Program Never number Msg
main =
    beginnerProgram { model = 0, view = view, update = update }


view : a -> Html.Html Msg
view model =
    div []
        [ stylesheet
        , button [ onClick Decrement ] [ text "-" ]
        , div [] [ text (toString model) ]
        , button [ onClick Increment ] [ text "+" ]
        ]


type Msg
    = Increment
    | Decrement


update : Msg -> number -> number
update msg model =
    case msg of
        Increment ->
            model + 1

        Decrement ->
            model - 1


stylesheet : Html.Html msg
stylesheet =
    let
        attrs =
            [ attribute "rel" "stylesheet"
            , attribute "property" "stylesheet"
            , attribute "href" "../app/css/main.css"
            ]
    in
        node "link" attrs []
