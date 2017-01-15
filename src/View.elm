module View exposing (view)

import Html exposing (Html, div, button, text, select, option, p, pre, a, input, span, node)
import Html.Attributes exposing (class, value, id, title, disabled, type_, placeholder, style, attribute)
import Html.Events exposing (onClick, onInput)
import Types
    exposing
        ( Port
        , Model
        , initModel
        , Msg(..)
        , LogLine
        , LabelType(..)
        , Sender(..)
        )
import Serial
import Update exposing (onScroll)
import Array exposing (Array)
import Date
import Date.Format


-- import Time


toLeftGroup : Html.Attribute msg
toLeftGroup =
    style [ ( "margin-left", "-1px" ) ]


gr =
    div [ class "button-group" ]


control_view : Model -> Html Msg
control_view model =
    div [ class "control" ]
        [ button [ onClick AddPort ] [ text "🞢 Добавить порт" ]
        , gr
            [ button [ title "Поставить метку", onClick (AddLabel LabelRegular) ] [ text "🖈" ]
            , button [ title "Пометить как хорошее", class "good", toLeftGroup, onClick (AddLabel LabelGood) ] [ text "🙂" ]
            , button [ title "Пометить как плохое", class "bad", toLeftGroup, onClick (AddLabel LabelBad) ] [ text "🙁" ]
            ]
        , gr
            [ button [ title "К предыдущей метке" ] [ text "⏮" ]
            , button [ title "К следующей метке", toLeftGroup ] [ text "⏭" ]
            ]
        , button [ title "Запустить секундомер" ] [ text "⏱" ]
        , gr
            [ button
                [ title "Отключить автопрокрутку окна лога"
                , class
                    (if model.autoscroll then
                        ""
                     else
                        scroll "active"
                    )
                ]
                [ text "⏸" ]
            , button
                [ title "Включить автопрокрутку окна лога"
                , disabled True
                , class
                    (if model.autoscroll then
                        scroll "active"
                     else
                        ""
                    )
                , toLeftGroup
                ]
                [ text "⏵" ]
            ]
        , button [ title "Очистить окно лога", onClick ClearLog ] [ text "🚮" ]
        , button [ title "Детектор данных для трекера" ] [ text "🛰" ]
        , button [ title "Запись лога в облако" ] [ text "🌍" ]
        , div [ class "find" ]
            [ text "🔍"
            , input [ type_ "input", placeholder "Поиск" ] []
            , button [ title "Назад" ] [ text "⏶" ]
            , button [ title "Далее" ] [ text "⏷" ]
            ]
        , button [ title "Заметка" ] [ text "🗩" ]
        , button [ title "Сохранить в файл" ] [ text "💾" ]
          -- , button [ title "Обнимашки" ] [ text "\x1F917" ]
        , button [ title "Настройки" ] [ text "🛠" ]
        ]


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
                , toLeftGroup
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



-- resetFavicon : Cmd Msg
-- resetFavicon =
--     Cmd.map (always Noop)
--         << Task.perform Err Ok
--     <|
--         (Serial.set ("/public/images/favicon.png"))
-- fakeLog : List String
-- fakeLog =
--     List.repeat 10000 "Log"


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
            , span [ class "time" ] [ text (dateToTime l.timestamp) ]
            , span [ class "delta" ] [ text (deltaAsString l.delta) ]
            , span [ class "content" ] [ text l.data ]
            ]
        ]


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


logClassName : LogLine -> String
logClassName l =
    case l.sender of
        PortId id ->
            "port_" ++ (toString id)

        LabelId id ->
            "label_" ++ (toString id)



-- log_view : Model -> Html Msg
-- log_view model =
--     div [ class "log", id "log", onScroll ChatScrolled, onScroll ChatScrolled ]
--         [ model.logs
--             |> List.foldl (\d acc -> log_row d :: acc) []
--             |> pre [ class "log" ]
--         ]


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



-- |> Array.toList
-- |> List.map f


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


logLineHeight : Float
logLineHeight =
    25


debug_scroll_view : Types.Model -> Html msg
debug_scroll_view m =
    case m.scrollEvent.clientHeight of
        0 ->
            text "No data yet"

        clientHeight ->
            let
                lines =
                    clientHeight / logLineHeight + 1

                startLine =
                    m.scrollEvent.top / logLineHeight

                start =
                    round startLine

                stop =
                    round (startLine + lines)

                logSize =
                    Array.length m.logs
            in
                text
                    ("Lines from "
                        ++ (toString start)
                        ++ " to "
                        ++ (toString stop)
                        ++ " Log size="
                        ++ (toString logSize)
                    )


debug_view : Model -> Html Msg
debug_view model =
    div [ class "debug" ]
        [ debug_scroll_view model
        , p [] [ text (toString model.ports) ]
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
        , stylesheet model
        ]


stylesheet : Model -> Html Msg
stylesheet m =
    let
        -- tag =
        --     "link"
        --
        -- attrs =
        --     [ attribute "rel" "stylesheet"
        --     , attribute "property" "stylesheet"
        --     , attribute "href" "css.css"
        --     ]
        tag =
            "style"

        attrs =
            []

        rule p =
            "pre.log p[class^=\"port_"
                ++ (toString p.cid)
                ++ "\"] {"
                ++ "color: "
                ++ p.logColor
                ++ ";}\n"

        rules =
            m.ports
                |> List.map (\p -> rule p)
                |> String.concat
    in
        node tag
            attrs
            [ text rules ]
