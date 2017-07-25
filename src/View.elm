module View exposing (view)

import Html exposing (Html, div, button, text, p, node, input)
import Html.Attributes exposing (class, title, type_, placeholder, disabled)


-- import Html.Events exposing (onClick, onInput)

import Types
    exposing
        ( Model
        , Msg(..)
        )
import PortList
import Log


-- import Array exposing (Array)
-- import Json.Decode
-- import Time


gr : List (Html msg) -> Html msg
gr =
    div [ class "button-group" ]


control_view : Model -> Html Msg
control_view model =
    div [ class "control" ]
        -- [ button [ onClick AddPort ] [ text "➕ Добавить порт" ]
        -- TODO: восстановить в первую очередь
        -- [ button [] [ text "➕ Добавить порт" ]
        [ PortList.add_button_view model.ports |> Html.map PortListMessage
          --   TODO: Можно вынести всю панель управления логом в компонент Log
        , gr
            [ Log.view_addLabel model.log |> Html.map LogMessage
            , Log.view_markAsGood model.log |> Html.map LogMessage
            , Log.view_markAsBad model.log |> Html.map LogMessage
            ]
        , gr
            [ Log.view_toPrevLabel model.log |> Html.map LogMessage
            , Log.view_toNextLabel model.log |> Html.map LogMessage
            ]
        , Log.view_startTimer model.log |> Html.map LogMessage
        , gr
            [ Log.view_stopAutoScroll model.log |> Html.map LogMessage
            , Log.view_startAutoScroll model.log |> Html.map LogMessage
            ]
        , Log.view_clearLog model.log |> Html.map LogMessage
        , button [ title "Детектор данных для трекера" ] [ text "🛰" ]
        , button [ title "Запись лога в облако" ] [ text "🌍" ]
        , Log.view_find model.log |> Html.map LogMessage
        , button [ title "Заметка" ] [ text "ℹ️" ]
        , Log.view_save model.log |> Html.map LogMessage
          -- , button [ title "Обнимашки" ] [ text "\x1F917" ]
        , button [ title "Настройки" ] [ text "🛠" ]
        ]



-- debug_view : Model -> Html Msg
-- debug_view model =
--     div [ class "debug" ]
--         [ p [] [ text (toString model.ports) ]
--         , p [] [ text (toString model.labels) ]
--         , p [] [ text (toString model.findText) ]
--         , p [] [ text (toString model.findIndex) ]
--         , p [] [ text (toString model.findResults) ]
--         ]


view : Model -> Html Msg
view model =
    div [ class "workspace" ]
        [ div [ class "vertical" ]
            [ -- div [ class "header" ] [ text "Логер 3" ]
              div [ class "toolbox" ]
                [ control_view model
                , PortList.view model.ports
                    |> Html.map PortListMessage
                ]
            , Log.view model.log |> Html.map LogMessage
            , Log.statusbar_view model.log |> Html.map LogMessage
            ]
          -- , hint_view model.hint
          -- , debug_view model
        , stylesheet model
        ]



-- hint_view : String -> Html Msg
-- hint_view hint =
--     div [ class "hint" ]
--         [ text hint ]


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
            m.ports.ports
                |> List.map (\( _, p ) -> rule p)
                |> String.concat
    in
        node tag
            attrs
            [ text rules ]
