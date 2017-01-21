module View exposing (view)

import Html exposing (Html, div, button, text, p, node, input)
import Html.Attributes exposing (class, title, type_, placeholder, disabled)
import Html.Events exposing (onClick, onInput)
import Types
    exposing
        ( Port
        , Model
        , Msg(..)
        , LabelType(..)
        )
import Port.View
import Log.View
import Array exposing (Array)


-- import Time


gr : List (Html msg) -> Html msg
gr =
    div [ class "button-group" ]


control_view : Model -> Html Msg
control_view model =
    div [ class "control" ]
        [ button [ onClick AddPort ] [ text "➕ Добавить порт" ]
        , gr
            [ button [ title "Поставить метку", onClick (AddLabel LabelRegular) ] [ text "✅" ]
            , button [ title "Пометить как хорошее", class "good", onClick (AddLabel LabelGood) ] [ text "🙂" ]
            , button [ title "Пометить как плохое", class "bad", onClick (AddLabel LabelBad) ] [ text "🙁" ]
            ]
        , gr
            [ button [ title "К предыдущей метке", onClick ToPrevLabel, disabled (model.active_label <= 1) ] [ text "⏮" ]
            , button [ title "К следующей метке", onClick ToNextLabel, disabled (model.active_label == Array.length model.labels) ] [ text "⏭" ]
            ]
        , button [ title "Запустить секундомер" ] [ text "⏱" ]
        , gr
            [ button
                [ title "Отключить автопрокрутку окна лога"
                , onClick (EnableScroll False)
                , class
                    (if model.autoscroll then
                        ""
                     else
                        "active"
                    )
                ]
                [ text "⏸" ]
            , button
                [ title "Включить автопрокрутку окна лога"
                , onClick (EnableScroll True)
                , class
                    (if model.autoscroll then
                        "active"
                     else
                        ""
                    )
                ]
                [ text "▶️" ]
            ]
        , button [ title "Очистить окно лога", onClick ClearLog ] [ text "🚮" ]
        , button [ title "Детектор данных для трекера" ] [ text "🛰" ]
        , button [ title "Запись лога в облако" ] [ text "🌍" ]
        , div [ class "find" ]
            [ text "🔍"
            , input [ type_ "input", placeholder "Поиск" ] []
            , button [ title "Назад" ] [ text "🔼" ]
            , button [ title "Далее" ] [ text "🔽" ]
            ]
        , button [ title "Заметка" ] [ text "ℹ️" ]
        , button [ title "Сохранить в файл", onClick SaveLogToFile ] [ text "💾" ]
          -- , button [ title "Обнимашки" ] [ text "\x1F917" ]
        , button [ title "Настройки" ] [ text "🛠" ]
        ]




-- resetFavicon : Cmd Msg
-- resetFavicon =
--     Cmd.map (always Noop)
--         << Task.perform Err Ok
--     <|
--         (Serial.set ("/public/images/favicon.png"))
-- fakeLog : List String
-- fakeLog =
--     List.repeat 10000 "Log"





-- log_view : Model -> Html Msg
-- log_view model =
--     div [ class "log", id "log", onScroll ChatScrolled, onScroll ChatScrolled ]
--         [ model.logs
--             |> List.foldl (\d acc -> log_row d :: acc) []
--             |> pre [ class "log" ]
--         ]




-- |> Array.toList
-- |> List.map f






debug_view : Model -> Html Msg
debug_view model =
    div [ class "debug" ]
        [ p [] [ text (toString model.ports) ]
        , p [] [ text (toString model.labels) ]
        ]


view : Model -> Html Msg
view model =
    div [ class "workspace" ]
        [ div [ class "vertical" ]
            [ -- div [ class "header" ] [ text "Логер 3" ]
              div [ class "toolbox" ]
                [ control_view model
                , Port.View.ports_view model model.ports
                ]
            , Log.View.log_view model
            , statusbar_view model
            ]
        , hint_view model.hint
        , debug_view model
        , stylesheet model
        ]

statusbar_view : Model -> Html Msg
statusbar_view model =
    div [ class "statusbar" ]
        [ div
            [class "horizontal"] [
                div [] [text ("Log lines: " ++ (toString (Array.length model.logs)))]
                , div [] [text ("Labels: " ++ (toString model.active_label) ++ "/" ++ (toString (Array.length model.labels)))]
                , div [class "fill"] [text "Main"]
                , div [] [text "End"]
            ]
        ]

hint_view : String -> Html Msg
hint_view hint =
    div [ class "hint" ]
    [ text hint ]


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
