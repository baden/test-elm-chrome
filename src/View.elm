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


control_view : Model -> Html Msg
control_view model =
    div [ class "control" ]
        -- [ button [ onClick AddPort ] [ text "➕ Добавить порт" ]
        -- TODO: восстановить в первую очередь
        -- [ button [] [ text "➕ Добавить порт" ]
        [ PortList.add_button_view model.ports |> Html.map PortListMessage
          --   TODO: Можно вынести всю панель управления логом в компонент Log
        , Log.view_control_panel model.log |> Html.map LogMessage
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
        , PortList.stylesheet model.ports
            |> Html.map PortListMessage
        ]



-- hint_view : String -> Html Msg
-- hint_view hint =
--     div [ class "hint" ]
--         [ text hint ]
