module Update
    exposing
        ( init
        , update
        , subscriptions
        , onScroll
        , onResize
        )

import Task exposing (Task)
import Serial
import Types
    exposing
        ( Port
          -- , initPort
        , initModel
        , Model
        , Msg(..)
        , OnScrollEvent
        , LogLine
        , Sender(..)
        , LabelType(..)
        )
import Dom.Scroll
import Json.Decode
import Html
import Html.Events
import Array exposing (Array)
import Task
import Date


-- import Process
-- import Date
-- import Html.Attributes
-- import Dom
-- import Time
-- import Process


init : ( Model, Cmd Msg )
init =
    ( initModel, Cmd.batch [ getSerialDevices ] )


scrollToBottom : Cmd Msg
scrollToBottom =
    -- Task.perform DomError (always NoOp) (toBottom id)
    Dom.Scroll.toBottom "log"
        |> Task.attempt (always NoOp)


onScroll : (OnScrollEvent -> msg) -> Html.Attribute msg
onScroll tagger =
    Json.Decode.map tagger onScrollJsonParser
        |> Html.Events.on "scroll"


onResize : (OnScrollEvent -> msg) -> Html.Attribute msg
onResize tagger =
    Json.Decode.map tagger onScrollJsonParser
        |> Html.Events.on "resize"


onScrollJsonParser : Json.Decode.Decoder OnScrollEvent
onScrollJsonParser =
    Json.Decode.map3 OnScrollEvent
        (Json.Decode.at [ "target", "scrollHeight" ] Json.Decode.float)
        (Json.Decode.at [ "target", "scrollTop" ] Json.Decode.float)
        (Json.Decode.at [ "target", "clientHeight" ] Json.Decode.float)



-- onChangeColor port_id =
--     Json.Decode.map (OnChangeColorEvent port_id) (onChangeColorParser port_id)
--         |> Html.Events.on "input"
--
--
-- onChangeColorParser =
--     Json.Decode.map OnChangeColorEvent
--         (Json.Decode.at [ "target", "value" ] Json.Decode.float)
-- scrollToBottom : Cmd Msg
-- scrollToBottom =
--     Process.sleep (1 * Time.second)
--         |> Task.andThen (\x -> (Dom.Scroll.toBottom "log"))
--         |> Task.attempt handleScrollResult
--
--
-- handleScrollResult : Result Dom.Error () -> Msg
-- handleScrollResult result =
--     let
--         _ =
--             Debug.log "result" result
--     in
--         case result of
--             Ok _ ->
--                 NoOp
--
--             Err _ ->
--                 NoOp
-- fakeLog : Time -> String -> Types.LogLine
-- fakeLog timestamp data =
--     Types.LogLine
--         data
--         timestamp
--         (Types.LabelId 0)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        AddPort ->
            let
                id =
                    model.uid

                port_ =
                    Types.Port id "" " " (getColor id)
            in
                { model
                    | uid = model.uid + 1
                    , ports = model.ports ++ [ port_ ]
                }
                    ! []

        AddLabel labelType ->
            let
                id =
                    model.last_labelid + 1
            in
                ( { model | last_labelid = id }, onClickAddLabel labelType id )

        AddLogLine logLine ->
            let
                _ =
                    Debug.log "AddLogLine" logLine

                prev_timestamp =
                    dateToUnixtime model.last_timestamp

                log_timestamp =
                    dateToUnixtime logLine.timestamp

                delta =
                    log_timestamp - prev_timestamp

                new_logs =
                    Array.push
                        { logLine
                            | delta = delta
                        }
                        model.logs
            in
                { model
                    | logs = new_logs
                    , last_timestamp = logLine.timestamp
                }
                    ! [ scrollToBottom ]

        ClearLog ->
            { model | logs = Array.empty }
                ! [ scrollToBottom ]

        ConnectPort port_ ->
            let
                _ =
                    Debug.log "Connect" port_

                -- s =
                --     Debug.log "Open"
                --         (Serial.open "my_path" OnPortMessage)
            in
                model ! [ Serial.connect port_.path PortConnected ]

        PortConnected id ->
            let
                _ =
                    Debug.log "Port connected" id
            in
                model ! []

        OnChangeColorEvent port_id value ->
            let
                -- Не самое элегантное решение. Нужно ports сделать : Dict id Port
                -- Как-то совсем не функциональный подход
                new_ports =
                    model.ports
                        |> List.map
                            (\p ->
                                if p.id == port_id then
                                    { p | logColor = value }
                                else
                                    p
                            )
            in
                { model | ports = new_ports } ! []

        OnChangePortPath port_id value ->
            let
                -- Не самое элегантное решение. Нужно ports сделать : Dict id Port
                -- Как-то совсем не функциональный подход
                new_ports =
                    model.ports
                        |> List.map
                            (\p ->
                                if p.id == port_id then
                                    { p | path = value }
                                else
                                    p
                            )
            in
                { model | ports = new_ports } ! []

        OnPortReceive ev_line ->
            let
                _ =
                    Debug.log "On port message" ev_line
            in
                model ! [ addPortMsg ev_line.id ev_line.data ]

        OnPortReceiveError ev_line ->
            let
                _ =
                    Debug.log "On port error message" ev_line
            in
                model ! [ addPortMsg ev_line.id ev_line.data ]

        RemovePort id ->
            { model | ports = List.filter (\t -> t.id /= id) model.ports }
                ! []

        Tick newTime ->
            ( { model | time = newTime }, Cmd.none )

        SetSerialDevices ports ->
            let
                _ =
                    Debug.log "SetSerialDevices" ports
            in
                ( { model | portList = ports }, Cmd.none )

        ChatScrolled event ->
            { model
                | shouldScroll = event.top < (event.height * 0.99 - event.clientHeight)
                , scrollEvent = event
            }
                ! []

        NoOp ->
            model ! []



-- Native.Scheduler.spawn (Serial.connect path PortConnected)
-- Serial.connect path
--     |> Task.perform PortConnected
-- DomError err ->
--     let
--         _ =
--             Debug.log "DOM error" (toString err)
--     in
--         ( model, Cmd.none )


dateToUnixtime : Date.Date -> Float
dateToUnixtime date =
    (Date.toTime date) / 1000


getSerialDevices : Cmd Msg
getSerialDevices =
    -- Time.now
    Serial.getDevices
        |> Task.perform
            SetSerialDevices


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


onClickAddLabel : LabelType -> Int -> Cmd Msg
onClickAddLabel labelType id =
    Date.now
        |> Task.andThen
            (\now ->
                let
                    labelChar =
                        case labelType of
                            LabelRegular ->
                                "🖈"

                            LabelGood ->
                                "🙂"

                            LabelBad ->
                                "🙁"

                    fakeLogLine =
                        LogLine
                            ("Метка " ++ labelChar ++ (toString id))
                            now
                            0
                            (LabelId 0)
                in
                    Task.succeed fakeLogLine
            )
        |> Task.perform AddLogLine



-- TODO: Тут можно будет сразу передавать таймштамп


addPortMsg : Int -> String -> Cmd Msg
addPortMsg id text =
    Date.now
        |> Task.andThen
            (\now ->
                let
                    fakeLogLine =
                        LogLine
                            text
                            now
                            0
                            (PortId id)
                in
                    Task.succeed fakeLogLine
            )
        |> Task.perform AddLogLine



--
--     |> Task.perform AddLogLine
-- Cmd.batch [  ]


subscriptions : Model -> Sub Msg
subscriptions model =
    -- let
    --     _ =
    --         Debug.log "subscriptions" model.debug
    -- in
    Serial.messages OnPortReceive OnPortReceiveError



-- Sub.none
