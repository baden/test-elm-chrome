module View exposing (view)

import Html exposing (Html, div, button, text, select, option, p, pre, a, input, span)
import Html.Attributes exposing (class, value, id, title, disabled, type_, placeholder)
import Html.Events exposing (onClick)
import Types
    exposing
        ( Port
        , Model
        , initModel
        , Msg(..)
        )
import Serial
import Update exposing (onScroll)


control_view : Model -> Html Msg
control_view model =
    div [ class "control" ]
        [ button [ onClick AddPort ] [ text "🞢 Добавить порт" ]
        , button [ title "Поставить метку", onClick AddLabel ] [ text "🖈" ]
        , button [ title "Пометить как хорошее", class "good" ] [ text "🙂" ]
        , button [ title "Пометить как плохое", class "bad" ] [ text "🙁" ]
        , button [ title "К предыдущей метке" ] [ text "⏮" ]
        , button [ title "К следующей метке" ] [ text "⏭" ]
        , button [ title "Запустить секундомер" ] [ text "⏱" ]
        , button [ title "Отключить автопрокрутку" ] [ text "⏸" ]
        , button [ title "Включить автопрокрутку", disabled True, class "active" ] [ text "⏵" ]
        , button [ title "Запись в облако" ] [ text "🌍" ]
        , span [ class "find" ]
            [ text "🔍"
            , input [ type_ "input", placeholder "Поиск" ] []
            , span [ title "Назад" ] [ text "⏶" ]
            , span [ title "Далее" ] [ text "⏷" ]
            ]
        , button [ title "Заметка" ] [ text "🗩" ]
        , button [ title "Сохранить в файл" ] [ text "💾" ]
          -- , button [ title "Обнимашки" ] [ text "\x1F917" ]
        , button [ title "Настройки" ] [ text "🛠" ]
        ]


toSelectOption : String -> Html a
toSelectOption x =
    option [] [ text x ]


listToHtmlSelectOptions : List String -> List (Html a)
listToHtmlSelectOptions list =
    list
        |> List.map toSelectOption


portLabel : String -> String -> String
portLabel path name =
    case name of
        "" ->
            path

        _ ->
            path ++ " : " ++ name


portOption : Serial.Port -> Html a
portOption p =
    option [ value (toString p.path) ]
        [ text (portLabel p.path p.displayName) ]


listPorts : List Serial.Port -> List (Html a)
listPorts list =
    ((Serial.Port "" "Порт") :: list)
        |> List.map portOption


fakeSpeedList : List String
fakeSpeedList =
    [ "Скорость"
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
        , button [] [ text "⏺ Подключить" ]
        , button [] [ text "⏹ Отключить" ]
        , button [ title "Цвет текста" ] [ text "⏹" ]
        , button [ onClick (RemovePort port_.id) ] [ text "🚮 Удалить" ]
          -- 🞩
          -- , text (toString port_)
          -- , text " / "
          -- , text (toString (Serial.loadTime))
          -- , text " / "
          -- , text (toString (Serial.addOne port_.id))
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
    div [ class "log", id "log", onScroll ChatScrolled, onScroll ChatScrolled ]
        [ model.logs
            |> List.foldl (\d acc -> log_row d :: acc) []
            |> pre [ class "log" ]
        ]


logLineHeight : Float
logLineHeight =
    25


debug_scroll_view : Types.OnScrollEvent -> Html msg
debug_scroll_view e =
    case e.clientHeight of
        0 ->
            text "No data yet"

        clientHeight ->
            let
                lines =
                    clientHeight / logLineHeight + 1

                startLine =
                    e.top / logLineHeight

                start =
                    round startLine

                stop =
                    round (startLine + lines)
            in
                text
                    ("Lines from "
                        ++ (toString start)
                        ++ " to "
                        ++ (toString stop)
                    )


debug_view : Model -> Html Msg
debug_view model =
    div [ class "debug" ]
        [ debug_scroll_view model.scrollEvent
        , p [] [ text (toString model) ]
        ]


view : Model -> Html Msg
view model =
    div [ class "workspace" ]
        [ div [ class "vertical" ]
            [ -- div [ class "header" ] [ text "Логер 3" ]
              div [ class "toolbox" ]
                [ control_view model
                , ports_view model model.ports
                ]
            , log_view model
            ]
        , debug_view model
        ]
