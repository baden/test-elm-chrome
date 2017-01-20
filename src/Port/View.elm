module Port.View exposing (..)

import Html exposing (Html, div, button, option, text, select, input)
import Html.Attributes exposing (class, value, title, disabled, type_, placeholder)
import Html.Events exposing (onClick, onInput)
import Serial
import Types exposing (Port, Model, Msg(..))


toSelectOption : String -> Html a
toSelectOption x =
    option [ value x ] [ text x ]


listToHtmlSelectOptions : List String -> List (Html a)
listToHtmlSelectOptions list =
    option [ value "" ] [ text "Скорость" ]
        :: (list
                |> List.map toSelectOption
           )


portLabel : String -> String -> String
portLabel path name =
    case name of
        "" ->
            path

        _ ->
            path ++ " : " ++ name


portOption : Serial.Port -> Html a
portOption p =
    option [ value p.path ]
        [ text (portLabel p.path p.displayName) ]


listPorts : List Serial.Port -> List (Html a)
listPorts list =
    (option [ value "" ] [ text "Порт" ]) :: (list |> List.map portOption)


fakeSpeedList : List String
fakeSpeedList =
    [ "1200"
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

gr : List (Html msg) -> Html msg
gr =
    div [ class "button-group" ]


port_view : Model -> Port -> Html Msg
port_view model port_ =
    div [ class "port" ]
        [ select
            [ onInput (OnChangePortPath port_.id)
            ]
            (listPorts model.portList)
        , select
            [ disabled (port_.path == "")
            , onInput (OnChangePortBoudrate port_.id)
            ]
            (listToHtmlSelectOptions fakeSpeedList)
        , gr
            [ button
                [ title "Подключить порт и начать запись лога"
                , class
                    ("record"
                        ++ (if not port_.connected then
                                ""
                            else
                                " active"
                           )
                    )
                , disabled ((port_.path == "") || (port_.boudrate == ""))
                , onClick (ConnectPort port_)
                ]
                [ text "⏺" ]
            , button
                [ title "Остановить запись лога и отключить порт"
                , disabled (port_.path == "")
                , class
                    (if port_.connected then
                        ""
                     else
                        "active"
                    )
                , onClick (DisconnectPort port_)
                ]
                [ text "⏹" ]
            ]
        , button
            [ class "colorpicker"
            , title "Цвет текста лога"
            , disabled (port_.path == "")
            ]
            [ text "W"
            , input
                [ type_ "color"
                , value port_.logColor
                , disabled (port_.path == "")
                , onInput (OnChangeColorEvent port_.cid)
                ]
                []
            ]
        , div [ class "label", title "Используется как подпись строк при сохранении в файл" ]
            [ text "L"
            , input [ type_ "input", placeholder "Метка" ] []
            ]
        , button
            [ title "Удалить"
            , disabled (port_.connected)
            , onClick (RemovePort port_.id)
            ]
            [ text "🚮" ]
          -- 🞩
          -- , text (toString port_)
          -- , text " / "
          --   , text (toString (Serial.loadTime))
          --   , text " / "
          -- , text (toString (port_.id))
          -- , text " / "
          -- , text (toString (getColor port_.id))
        ]


ports_view : Model -> List Port -> Html Msg
ports_view model ports =
    ports
        |> List.map (\c -> port_view model c)
        |> div [ class "port_list" ]
