effect module Serial
    where { subscription = MySub }
    exposing
        ( getDevices
        , Port
        , connect
        , messages
        )

import Task exposing (Task)
import Serial.LowLevel as SLL
import Process


type alias Port =
    { displayName : String
    , path : String
    }


getDevices : Task x (List Port)
getDevices =
    Native.Serial.getDevices


type MySub msg
    = Message (SLL.Event -> msg) (SLL.Event -> msg)


messages : (SLL.Event -> msg) -> (SLL.Event -> msg) -> Sub msg
messages taggerOk taggerError =
    subscription (Message taggerOk taggerError)



-- type alias Event =
--     {}
-- SUBSCRIPTIONS


subMap : (a -> b) -> MySub a -> MySub b
subMap func (Message taggerOk taggerError) =
    -- let
    --     _ =
    --         Debug.log "Serial:subMap" ( func, taggerOk, taggerError )
    -- in
    --     -- case sub of
    --     --     Message tagger ->
    Message (taggerOk >> func) (taggerError >> func)



-- EFFECT MANAGER


type alias State msg =
    Maybe
        { subs : List (MySub msg)
        , listener : Process.Id
        }


init : Task Never (State msg)
init =
    -- let
    --     _ =
    --         Debug.log "Serial:init" 0
    -- in
    Task.succeed Nothing


onSelfMsg :
    Platform.Router msg Msg
    -> Msg
    -> State msg
    -> Task Never (State msg)
onSelfMsg router selfMsg state =
    let
        _ =
            Debug.log
                ("Serial:onSelfMsg"
                    ++ "\n  router"
                    ++ toString (router)
                    ++ "\n  selfMsg"
                    ++ toString (selfMsg)
                    ++ "\n  state"
                    ++ toString (state)
                )
                0
    in
        case selfMsg of
            Receive event ->
                case state of
                    Nothing ->
                        Task.succeed Nothing

                    Just { subs } ->
                        let
                            send (Message taggerOk _) =
                                Platform.sendToApp router (taggerOk event)
                        in
                            Task.sequence (List.map send subs)
                                |> Task.andThen (\_ -> Task.succeed state)

            ReceiveError event ->
                case state of
                    Nothing ->
                        Task.succeed Nothing

                    Just { subs } ->
                        let
                            send (Message _ taggerError) =
                                Platform.sendToApp router (taggerError event)
                        in
                            Task.sequence (List.map send subs)
                                |> Task.andThen (\_ -> Task.succeed state)


onEffects :
    Platform.Router msg Msg
    -> List (MySub msg)
    -> State msg
    -> Task Never (State msg)
onEffects router subs state =
    case state of
        Nothing ->
            let
                _ =
                    Debug.log
                        ("Serial:onEffects"
                            ++ "\n     router"
                            ++ toString (router)
                            ++ "\n     subs"
                            ++ toString (subs)
                            ++ "\n     state"
                            ++ toString (state)
                        )
                        0
            in
                case subs of
                    [] ->
                        Task.succeed state

                    _ ->
                        Process.spawn (waiter router)
                            |> Task.andThen
                                (\listener ->
                                    Task.succeed (Just { subs = subs, listener = listener })
                                )

        Just { subs, listener } ->
            Task.succeed state


type Msg
    = Receive SLL.Event
    | ReceiveError SLL.Event


waiter : Platform.Router msg Msg -> Task x SLL.Serial
waiter router =
    SLL.waitMessage
        { onReceive =
            (\msg ->
                let
                    _ =
                        Debug.log "waiter Receive Msg: " msg
                in
                    Platform.sendToSelf router (Receive msg)
            )
        , onReceiveError =
            (\msg ->
                let
                    _ =
                        Debug.log "waiter ReceiveError Msg: " msg
                in
                    Platform.sendToSelf router (ReceiveError msg)
            )
        }



-- connect : String -> Task x Int
-- connect =
--     SLL.connect
-- connect : String -> Task x Int
-- connect path =
--     Native.Serial.connect


connect : String -> (Int -> msg) -> Cmd msg
connect path target =
    -- Task.succeed 42
    -- Process.sleep 3000
    SLL.connect path
        -- -- Serial.connect path
        -- |>
        --     Task.andThen
        --         (\b ->
        --             let
        --                 _ =
        --                     Debug.log "then" b
        --             in
        --                 Task.succeed 7
        --         )
        |>
            Task.perform target
