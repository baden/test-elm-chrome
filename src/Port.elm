module Port exposing (Msg(..), Model, init, view, update)

import Html exposing (Html, div, button, option, text, select, input)
import Html.Attributes exposing (class, value, title, disabled, type_, placeholder)
import Html.Events exposing (onClick, onInput)
import Array exposing (Array)
import Task exposing (Task)
import Serial


type alias Model =
    { id : Int
    , path : String
    , boudrate : String
    , name : String
    , cid : Int
    , logColor : String
    , connected : Bool
    , portList :
        List Serial.Port
        -- TODO: Заменить на Dict id Port
        -- TODO: Нужно подумать над размещением в глобальной области видимости.
        --       Или не стоит.
    }


type Msg
    = OnChangePortPath String
    | OnChangePortBoudrate String
    | OnChangeColorEvent String
    | ConnectPort
    | DisconnectPort
    | PortConnected ( String, Int )
    | PortDisconnected ( Int, Bool )
    | SetSerialDevices ( Int, List Serial.Port )



-- init : Int -> ( Model, Cmd Msg )
-- init id =
--     ( defaultModel id, Cmd.none )


init : Int -> ( Model, Cmd Msg )
init id =
    ( defaultModel id, Cmd.batch [ getSerialDevices id ] )


defaultModel : Int -> Model
defaultModel id =
    { id = id
    , path = ""
    , boudrate = ""
    , name = " "
    , cid = 0
    , logColor = (getColor id)
    , connected = False
    , portList = []
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        _ =
            Debug.log "Port.update" ( msg, model )
    in
        case msg of
            OnChangePortPath value ->
                { model | path = value } ! []

            OnChangePortBoudrate value ->
                { model | boudrate = value } ! []

            OnChangeColorEvent value ->
                { model | logColor = value } ! []

            ConnectPort ->
                let
                    _ =
                        Debug.log "Connect" model
                in
                    model
                        ! [ Serial.connect
                                ( model.path
                                , String.toInt model.boudrate |> Result.withDefault 19200
                                )
                                PortConnected
                          ]

            DisconnectPort ->
                let
                    _ =
                        Debug.log "Disconnect" model
                in
                    model ! [ Serial.disconnect model.cid PortDisconnected ]

            PortConnected ( path, cid ) ->
                -- { model | ports = patchPort model.ports .path path (\p -> { p | connected = True, cid = cid }) } ! []
                { model | connected = True, cid = cid } ! []

            PortDisconnected ( cid, result ) ->
                -- { model
                --     | ports = patchPort model.ports .cid cid (\p -> { p | connected = False, cid = 0 })
                -- }
                { model | connected = False, cid = 0 } ! []

            SetSerialDevices ( id, ports ) ->
                let
                    _ =
                        Debug.log "SetSerialDevices" ( id, ports )

                    _ =
                        Debug.log "  ID" id

                    _ =
                        Debug.log "  model" model

                    _ =
                        Debug.log "  ports" ports
                in
                    ( { model | portList = ports }, Cmd.none )


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
      -- init : ( Model, Cmd Msg )
      -- init =
      --     ( defaultModel, Cmd.none )
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
    let
        _ =
            Debug.log "Port.view " model
    in
        div [ class "port" ]
            [ select
                [ onInput <| OnChangePortPath
                ]
                (listPorts model.portList)
            , select
                [ disabled (model.path == "")
                , onInput <| OnChangePortBoudrate
                ]
                (listToHtmlSelectOptions fakeSpeedList)
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
                    , disabled ((model.path == "") || (model.boudrate == ""))
                    , onClick ConnectPort
                    ]
                    [ text "⏺" ]
                , button
                    [ title "Остановить запись лога и отключить порт"
                    , disabled (model.path == "")
                    , class
                        (if model.connected then
                            ""
                         else
                            "active"
                        )
                      -- TODO: restore
                      -- , onClick (DisconnectPort port_)
                    ]
                    [ text "⏹" ]
                ]
            , button
                [ class "colorpicker"
                , title "Цвет текста лога"
                  -- , disabled (model.path == "")
                ]
                [ text "W"
                , input
                    [ type_ "color"
                    , value model.logColor
                    , disabled (model.path == "")
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
                  -- , onClick (RemovePort port_.id)
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


getColor : Int -> String
getColor i =
    Array.get (i % Array.length portColors) portColors
        |> Maybe.withDefault "black"


portColors : Array String
portColors =
    Array.fromList
        [ "#9F0000"
        , "#00009F"
        , "#9F009F"
        , "#9F9F00"
        ]


getSerialDevices : Int -> Cmd Msg
getSerialDevices id =
    -- Time.now
    Serial.getDevices
        |> Task.andThen
            (\b ->
                let
                    _ =
                        Debug.log "getSerialDevices->then" b
                in
                    Task.succeed ( id, b )
            )
        |> Task.perform SetSerialDevices
