module Update exposing (init, update)

import Task exposing (Task)
import Serial
import Types
    exposing
        ( Port
        , initPort
        , initModel
        , Model
        , Msg(..)
        )
import Dom.Scroll


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


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        AddPort ->
            let
                port_ =
                    initPort model.uid
            in
                { model
                    | uid = model.uid + 1
                    , ports = model.ports ++ [ port_ ]
                }
                    ! []

        AddLabel ->
            let
                new_logs =
                    "Label" :: model.logs
            in
                { model | logs = new_logs }
                    ! [ scrollToBottom ]

        RemovePort id ->
            { model | ports = List.filter (\t -> t.id /= id) model.ports }
                ! []

        Tick newTime ->
            ( { model | time = newTime }, Cmd.none )

        SetSerialDevices ports ->
            ( { model | portList = ports }, Cmd.none )

        NoOp ->
            model ! []



-- DomError err ->
--     let
--         _ =
--             Debug.log "DOM error" (toString err)
--     in
--         ( model, Cmd.none )


getSerialDevices : Cmd Msg
getSerialDevices =
    -- Time.now
    Serial.getDevices
        |> Task.perform
            SetSerialDevices
