module Log.View exposing (..)

import Html exposing (Html, div, pre, p, text, span, a)
import Html.Attributes exposing (class, id, style)
import Array exposing (Array)
import Update exposing (onScroll)
import Types exposing (Msg(..), Model, LogLine, Port, Sender(..))
import Helpers


log_view : Model -> Html Msg
log_view model =
    let
        e =
            model.scrollEvent

        logSize =
            Array.length model.logs

        lines =
            case e.clientHeight of
                0 ->
                    100

                -- Пока размер окна не определен, будем считать что у нас 100 строк
                h ->
                    h / logLineHeight + 1

        startLine =
            e.top / logLineHeight

        start =
            max 0 ((round startLine) - 10)

        stop =
            min logSize ((round (startLine + lines)) + 10)
    in
        div
            [ class "log"
            , id "log"
            , onScroll ChatScrolled
            ]
            [ sliceLog start stop model.logs
                |> pre
                    [ class "log"
                    , style [ ( "height", (toString ((toFloat logSize) * logLineHeight)) ++ "px" ) ]
                    ]
            ]


sliceLog : Int -> Int -> Array LogLine -> List (Html Msg)
sliceLog start stop logs =
    -- [ ("Show from " ++ (toString start) ++ " to " ++ (toString stop)) ]
    let
        f : LogLine -> ( Int, List (Html Msg) ) -> ( Int, List (Html Msg) )
        f =
            \d ( index, acc ) -> ( index + 1, log_row d index :: acc )
    in
        Array.slice start stop logs
            |> Array.foldl f ( start, [] )
            |> Tuple.second


logLineHeight : Float
logLineHeight =
    25

log_row : LogLine -> Int -> Html Msg
log_row l offset =
    p
        [ style [ ( "top", toString ((toFloat offset) * logLineHeight) ++ "px" ) ]
        , class (logClassName l)
          --   attribute
          --     "style"
          --     ("top: "
          --         ++ toString ((toFloat offset) * logLineHeight)
          --         ++ "px"
          --     )
        ]
        [ div [ class "horizontal" ]
            [ a [] [ text (toString (offset + 1)) ]
            , span [ class "time" ] [ text (Helpers.dateToTime l.timestamp) ]
            , span [ class "delta" ] [ text (Helpers.deltaAsString l.delta) ]
            , span [ class "content" ] [ text l.data ]
            ]
        ]


logClassName : LogLine -> String
logClassName l =
    case l.sender of
        PortId id ->
            "port_" ++ (toString id)

        LabelId id ->
            "label_" ++ (toString id)
