module Update
    exposing
        ( init
        , update
        , subscriptions
        )

import Serial
import Types
    exposing
        ( -- Port
          -- , initPort
          initModel
        , Model
        , Msg(..)
        )
import PortList
import Log


init : ( Model, Cmd Msg )
init =
    -- ( initModel, Cmd.batch [ getSerialDevices ] )
    ( initModel, Cmd.none )



-- onResize : (OnScrollEvent -> msg) -> Html.Attribute msg
-- onResize tagger =
--     Json.Decode.map tagger onScrollJsonParser
--         |> Html.Events.on "resize"
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
    -- let
    --     _ =
    --         Debug.log "Update" ( msg, model )
    -- in
    case msg of
        OnPortReceive ev_line ->
            -- let
            --     _ =
            --         Debug.log "On port message" ev_line
            -- in
            let
                logCmd =
                    Log.addPortMsg ev_line.id ev_line.data
            in
                model ! [ Cmd.map LogMessage logCmd ]

        OnPortReceiveError ev_line ->
            -- let
            --     _ =
            --         Debug.log "On port error message" ev_line
            -- in
            let
                logCmd =
                    Log.addPortMsg ev_line.id ev_line.data
            in
                model ! [ Cmd.map LogMessage logCmd ]

        PortListMessage subMsg ->
            let
                ( newPortList, subCmd ) =
                    PortList.update subMsg model.ports
            in
                { model | ports = newPortList } ! [ Cmd.map PortListMessage subCmd ]

        LogMessage subMsg ->
            let
                ( newLog, subCmd ) =
                    Log.update subMsg model.log
            in
                { model | log = newLog } ! [ Cmd.map LogMessage subCmd ]

        -- ( model, Cmd.none )
        Tick newTime ->
            ( { model | time = newTime }, Cmd.none )

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
-- TODO: Тут можно будет сразу передавать таймштамп
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
