module View exposing (view)

import Html exposing (Html, div, button, text, select, option, p, pre, a)
import Html.Attributes exposing (class, value)
import Html.Events exposing (onClick)
import Types
    exposing
        ( Port
        , Model
        , initModel
        , Msg(..)
        )
import Serial


control_view : Model -> Html Msg
control_view model =
    div [ class "control" ]
        [ button [ onClick AddPort ] [ text "Добавить порт" ]
        , button [ onClick AddLabel ] [ text "Поставить метку" ]
        ]


toSelectOption : String -> Html a
toSelectOption x =
    option [] [ text x ]


listToHtmlSelectOptions : List String -> List (Html a)
listToHtmlSelectOptions list =
    list
        |> List.map toSelectOption


portOption : Serial.Port -> Html a
portOption p =
    option [ value (toString p.path) ]
        [ text (p.path ++ " : " ++ p.displayName) ]


listPorts : List Serial.Port -> List (Html a)
listPorts list =
    list
        |> List.map portOption


fakeSpeedList : List String
fakeSpeedList =
    [ "Выберите скорость:"
    , "1200"
    , "2400"
    , "4800"
    , "9600"
    , "19200"
    , "38400"
    , "57600"
    , "115200"
    , "230400"
    , "460800"
    , "125000"
    , "166667"
    , "250000"
    , "500000"
    ]


port_view : Model -> Port -> Html Msg
port_view model port_ =
    div [ class "port" ]
        [ select [] (listPorts model.portList)
        , select [] (listToHtmlSelectOptions fakeSpeedList)
        , button
            []
            [ text "Подключить" ]
        , button [ onClick (RemovePort port_.id) ] [ text "Удалить" ]
        , text (toString port_)
        , text " / "
        , text (toString (Serial.loadTime))
        , text " / "
        , text (toString (Serial.addOne port_.id))
        ]


ports_view : Model -> List Port -> Html Msg
ports_view model ports =
    ports
        |> List.map (\c -> port_view model c)
        |> div [ class "port_list" ]



-- resetFavicon : Cmd Msg
-- resetFavicon =
--     Cmd.map (always Noop)
--         << Task.perform Err Ok
--     <|
--         (Serial.set ("/public/images/favicon.png"))
-- fakeLog : List String
-- fakeLog =
--     List.repeat 10000 "Log"


log_row : String -> Html Msg
log_row data =
    p []
        [ a [] []
        , text data
        ]


log_view : Model -> Html Msg
log_view model =
    div [ class "log" ]
        [ model.logs
            |> List.map (\d -> log_row d)
            |> pre [ class "log" ]
        ]


debug_view : Model -> Html Msg
debug_view model =
    div [ class "debug" ]
        [ p [] [ text (toString model) ]
        ]


view : Model -> Html Msg
view model =
    div [ class "workspace" ]
        [ div [ class "vertical" ]
            [ -- div [ class "header" ] [ text "Логер 3" ]
              div [ class "toolbox" ]
                [ ports_view model model.ports
                , control_view model
                ]
            , log_view model
            ]
        , debug_view model
        ]
