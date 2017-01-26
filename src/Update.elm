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
import Helpers


-- import Process
-- import Date
-- import Html.Attributes
-- import Dom
-- import Time
-- import Process


init : ( Model, Cmd Msg )
init =
    ( initModel, Cmd.batch [ getSerialDevices ] )


scrollToBottom : Bool -> Cmd Msg
scrollToBottom scroll =
    -- Task.perform DomError (always NoOp) (toBottom id)
    case scroll of
        True ->
            Dom.Scroll.toBottom "log"
                |> Task.attempt (always NoOp)

        False ->
            Cmd.none


scrollToLine : Int -> Cmd Msg
scrollToLine line =
    Dom.Scroll.toY "log" (toFloat (line * 25))
        --logLineHeight
        |>
            Task.attempt (always NoOp)


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
                    Types.Port id "" "" " " 0 (getColor id) False
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
                ( { model
                    | last_labelid = id
                    , labels = model.labels |> Array.push (Array.length model.logs)
                  }
                , onClickAddLabel labelType id
                )

        ToNextLabel ->
            let
                active_label =
                    model.active_label + 1

                line =
                    case Array.get (active_label - 1) model.labels of
                        Just value ->
                            value

                        _ ->
                            0

                -- _ =
                --     Debug.log "to line" line
            in
                { model | active_label = active_label } ! [ scrollToLine line ]

        ToPrevLabel ->
            let
                active_label =
                    model.active_label - 1

                line =
                    case Array.get (active_label - 1) model.labels of
                        Just value ->
                            value

                        _ ->
                            0

                -- _ =
                --     Debug.log "to line" line
            in
                { model | active_label = active_label } ! [ scrollToLine line ]

        AddLogLine logLine ->
            let
                -- _ =
                --     Debug.log "AddLogLine" logLine
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
                case model.findIndex of
                    0 ->
                        { model
                            | logs = new_logs
                            , last_timestamp = logLine.timestamp
                        }
                            ! [ scrollToBottom model.autoscroll ]

                    _ ->
                        let
                            index =
                                (Array.length new_logs) - 1

                            text =
                                model.findText |> Maybe.withDefault ""

                            findResults =
                                if String.contains text logLine.data then
                                    Array.push index model.findResults
                                else
                                    model.findResults
                        in
                            { model
                                | logs = new_logs
                                , last_timestamp = logLine.timestamp
                                , findResults = findResults
                            }
                                ! [ scrollToBottom model.autoscroll ]

        ClearLog ->
            { model
                | logs = Array.empty
                , labels = Array.empty
                , active_label = 0
                , last_labelid = 0
                , findResults = Array.empty
                , findIndex = 0
                , hint = "Очищено"
            }
                ! [ scrollToBottom True ]

        ConnectPort port_ ->
            let
                _ =
                    Debug.log "Connect" port_
            in
                model
                    ! [ Serial.connect
                            ( port_.path
                            , String.toInt port_.boudrate |> Result.withDefault 19200
                            )
                            PortConnected
                      ]

        DisconnectPort port_ ->
            let
                _ =
                    Debug.log "Disconnect" port_
            in
                model ! [ Serial.disconnect port_.cid PortDisconnected ]

        PortConnected ( path, cid ) ->
            { model | ports = patchPort model.ports .path path (\p -> { p | connected = True, cid = cid }) } ! []

        PortDisconnected ( cid, result ) ->
            { model
                | ports = patchPort model.ports .cid cid (\p -> { p | connected = False, cid = 0 })
            }
                ! []

        OnChangeColorEvent cid value ->
            { model
                | ports = patchPort model.ports .cid cid (\p -> { p | logColor = value })
            }
                ! []

        OnChangePortPath port_id value ->
            { model
                | ports = patchPort model.ports .id port_id (\p -> { p | path = value })
            }
                ! []

        OnChangePortBoudrate port_id value ->
            { model | ports = patchPort model.ports .id port_id (\p -> { p | boudrate = value }) } ! []

        OnPortReceive ev_line ->
            -- let
            --     _ =
            --         Debug.log "On port message" ev_line
            -- in
            model ! [ addPortMsg ev_line.id ev_line.data ]

        OnPortReceiveError ev_line ->
            -- let
            --     _ =
            --         Debug.log "On port error message" ev_line
            -- in
            model ! [ addPortMsg ev_line.id ev_line.data ]

        RemovePort id ->
            { model | ports = List.filter (\t -> t.id /= id) model.ports }
                ! []

        Tick newTime ->
            ( { model | time = newTime }, Cmd.none )

        EnableScroll scroll ->
            let
                scroll_before =
                    model.autoscroll

                action =
                    if scroll_before == False && scroll == True then
                        Cmd.batch [ scrollToBottom True ]
                    else
                        Cmd.none
            in
                ( { model | autoscroll = scroll }, action )

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

        SaveLogToFile ->
            let
                _ =
                    Debug.log "save" 0
            in
                model ! [ saveLogToFile model.logs ]

        SaveLogDone _ ->
            model ! []

        EnterFindText text ->
            { model | findText = Just text, findIndex = 0 } ! []

        PressKeyOnFind key ->
            if key == 13 then
                if model.findIndex == 0 then
                    let
                        text =
                            model.findText |> Maybe.withDefault ""

                        f : LogLine -> ( Int, Array Int ) -> ( Int, Array Int )
                        f =
                            \d ( index, acc ) ->
                                if String.contains text d.data then
                                    ( index + 1, Array.push index acc )
                                else
                                    ( index + 1, acc )

                        ( _, results ) =
                            model.logs
                                |> Array.foldl f ( 0, Array.empty )
                    in
                        if Array.length results > 0 then
                            { model | findResults = results, findIndex = 0 } |> update NextFindResult
                            -- let
                            --     line =
                            --         results
                            --             |> Array.get 0
                            --             |> Maybe.withDefault 0
                            -- in
                            --     { model | findResults = results, findIndex = 1 } ! [ scrollToLine line ]
                        else
                            { model | findResults = results, findIndex = 0 } ! []
                else if model.findIndex < Array.length model.findResults then
                    model |> update NextFindResult
                else
                    model ! []
            else
                { model | findResults = Array.empty, findIndex = 0 } ! []

        NextFindResult ->
            let
                index =
                    model.findIndex + 1

                line =
                    case Array.get (index - 1) model.findResults of
                        Just value ->
                            value

                        _ ->
                            0
            in
                { model | findIndex = index } ! [ scrollToLine line ]

        PrevFindResult ->
            let
                index =
                    model.findIndex - 1

                line =
                    case Array.get (index - 1) model.findResults of
                        Just value ->
                            value

                        _ ->
                            0
            in
                { model | findIndex = index } ! [ scrollToLine line ]

        NoOp ->
            model ! []


patchPort : List a -> (a -> b) -> b -> (a -> a) -> List a
patchPort ports cond value fun =
    ports
        |> List.map
            (\p ->
                if (cond p) == value then
                    fun p
                else
                    p
            )


saveLogToFile : Array LogLine -> Cmd Msg
saveLogToFile logs =
    let
        logs_as_list =
            logs
                |> Array.foldr
                    (\l acc ->
                        ((Helpers.dateToTime l.timestamp)
                            ++ "\t"
                            ++ (Helpers.deltaAsString l.delta)
                            ++ "\t"
                            ++ l.data
                        )
                            :: acc
                    )
                    []
    in
        Serial.save logs_as_list SaveLogDone



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
                                "✅"

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
