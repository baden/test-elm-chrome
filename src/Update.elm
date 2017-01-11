module Update
    exposing
        ( init
        , update
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
        )
import Dom.Scroll
import Json.Decode
import Html
import Html.Events
import Array exposing (Array)
import Task
import Date


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
                    Types.Port id (getColor id)
            in
                { model
                    | uid = model.uid + 1
                    , ports = model.ports ++ [ port_ ]
                }
                    ! []

        AddLabel ->
            let
                id =
                    model.last_labelid + 1
            in
                ( { model | last_labelid = id }, onClickAddLabel id )

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

        RemovePort id ->
            { model | ports = List.filter (\t -> t.id /= id) model.ports }
                ! []

        Tick newTime ->
            ( { model | time = newTime }, Cmd.none )

        SetSerialDevices ports ->
            ( { model | portList = ports }, Cmd.none )

        ChatScrolled event ->
            { model
                | shouldScroll = event.top < (event.height * 0.99 - event.clientHeight)
                , scrollEvent = event
            }
                ! []

        NoOp ->
            model ! []



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


onClickAddLabel : Int -> Cmd Msg
onClickAddLabel id =
    Date.now
        |> Task.andThen
            (\now ->
                let
                    fakeLogLine =
                        LogLine
                            ("Метка 🖈" ++ (toString id))
                            now
                            0
                            (LabelId 0)
                in
                    Task.succeed fakeLogLine
            )
        |> Task.perform AddLogLine



--
--     |> Task.perform AddLogLine
-- Cmd.batch [  ]
