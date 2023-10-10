module Port exposing (
    Msg, Model, ParentMgs(..), init, view, update
    )

import Html exposing (Html, div, button, option, text, select, input)
import Html.Attributes exposing (class, value, title, disabled, type_, placeholder, selected)
import Html.Events exposing (onClick, onInput)
import Array exposing (Array)
import Task exposing (Task)
import Serial
import Icons exposing (..)


type alias Model =
    { id : Int
    , boudrate : String
    , name : String
    , logColor : String
    , connected : Bool
    -- , portList :
    --     List Serial.Port

    -- TODO: Заменить на Dict id Port
    -- TODO: Нужно подумать над размещением в глобальной области видимости.
    --       Или не стоит.
    }


type Msg
    =
    OnChangePortBoudrate String
    | OnChangeColorEvent String
    | ConnectPort
    | DisconnectPort
    | PortConnected Int
    | PortDisconnected Int
    -- | SetSerialDevices (List Serial.Port)
    | RemovePort


type ParentMgs
    = Remove



-- init : Int -> ( Model, Cmd Msg )
-- init id =
--     ( defaultModel id, Cmd.none )


init : Int -> ( Model, Cmd Msg )
init id =
    ( defaultModel id, Cmd.none )


defaultModel : Int -> Model
defaultModel id =
    { id = id
    , boudrate = "115200"
    , name = " "
    , logColor = (getColor id)
    , connected = False
    }


update : Msg -> Model -> ( Model, Cmd Msg, Maybe ParentMgs )
update msg model =
    -- let
    --     _ =
    --         Debug.log "Port.update" ( msg, model )
    -- in
    case msg of
        OnChangePortBoudrate value ->
            ( { model | boudrate = value }
            , Cmd.none
            , Nothing
            )

        OnChangeColorEvent value ->
            ( { model | logColor = value }
            , Cmd.none
            , Nothing
            )

        ConnectPort ->
            ( model
            , Cmd.batch
                [ Serial.connect
                    model.id
                    (String.toInt model.boudrate |> Maybe.withDefault 19200)
                    -- PortConnected
                ]
            , Nothing
            )

        DisconnectPort ->
            ( model
            , Cmd.batch
                [ Serial.disconnect
                    model.id
                    --PortDisconnected
                ]
            , Nothing
            )

        PortConnected id ->
            ( { model | connected = True }
            , Cmd.none
            , Nothing
            )

        PortDisconnected id  ->
            ( { model | connected = False
            -- , id = 0
            }
            , Cmd.none
            , Nothing
            )

        -- SetSerialDevices ports ->
        --     ( { model | portList = ports }
        --     , Cmd.none
        --     , Nothing
        --     )

        -- TODO: Dirty hack
        RemovePort ->
            ( model
            , Cmd.none
            , Just Remove
            )


toSelectOption : String -> String -> Html a
toSelectOption active x =
    if active == x then
        option [ value x, selected True ] [ text x ]
    else
        option [ value x ] [ text x ]


listToHtmlSelectOptions : List String -> String -> List (Html a)
listToHtmlSelectOptions list active =
    option [ value "" ] [ text "Скорость" ]
        :: (list
                |> List.map (toSelectOption active)
           )


portLabel : String -> String -> String
portLabel path name =
    case name of
        "" ->
            path

        _ ->
            path ++ " : " ++ name


-- portOption : String -> Serial.Port -> Html a
-- portOption active p =
--     let
--         options =
--             if p.path == active then
--                 [ value p.path, selected True ]
--             else
--                 [ value p.path ]
--     in
--         option options
--             [ text (portLabel p.path p.displayName) ]


-- listPorts : List Serial.Port -> String -> List (Html a)
-- listPorts list selected =
--     (option [ value "" ] [ text "Порт" ]) :: (list |> List.map (portOption selected))


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


view : Model -> Html Msg
view model =
    div [ class "port" ]
        [
        select
            [ disabled (model.connected)
            , onInput <| OnChangePortBoudrate
            ]
            (listToHtmlSelectOptions fakeSpeedList model.boudrate)
        , gr
            [ button
                [ title "Подключить порт и начать запись лога"
                , class
                    ("record"
                        ++ (if not model.connected then
                                ""
                            else
                                " active"
                           )
                    )
                , disabled ((model.boudrate == "") || (model.connected))
                , onClick ConnectPort
                ]
                [ mi_play ]
            , button
                [ title "Остановить запись лога и отключить порт"
                , disabled (not model.connected)
                , class
                    (if model.connected then
                        ""
                     else
                        "active"
                    )

                -- TODO: restore
                , onClick DisconnectPort
                ]
                [ mi_stop ]
            ]
        , button
            [ class "colorpicker"
            , title "Цвет текста лога"
            ]
            [ text "W"
            , input
                [ type_ "color"
                , value model.logColor
                , onInput <| OnChangeColorEvent
                ]
                []
            ]
        , div [ class "label", title "Используется как подпись строк при сохранении в файл" ]
            [ text "L"
            , input [ type_ "input", placeholder "Метка" ] []
            ]
        , button
            [ title "Удалить"
            , disabled (model.connected)

            -- TODO: restore
            , onClick RemovePort
            ]
            [ mi_close ]

        -- 🞩
        -- , text (toString model)
        -- , text " / "
        --   , text (toString (Serial.loadTime))
        --   , text " / "
        -- , text (toString (port_.id))
        -- , text " / "
        -- , text (toString (getColor port_.id))
        ]


getColor : Int -> String
getColor i =
    Array.get (i |> modBy (Array.length portColors)) portColors
        |> Maybe.withDefault "black"


portColors : Array String
portColors =
    Array.fromList
        [ "#9F0000"
        , "#00009F"
        , "#9F009F"
        , "#9F9F00"
        ]


-- getSerialDevices : Int -> Cmd Msg
-- getSerialDevices id =
--     -- Time.now
--     Serial.getDevices
--         -- |> Task.andThen
--         --     (\b ->
--         --         let
--         --             _ =
--         --                 Debug.log "getSerialDevices->then" b
--         --         in
--         --             Task.succeed ( id, b )
--         --     )
--         |> Task.perform SetSerialDevices

-- getPort : Int -> Cmd Msg
-- getPort id =
--     Serial.getPort id
--         -- |> Task.perform (Cmd.none)
