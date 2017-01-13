effect module Serial
    where { command = MyCmd, subscription = MySub }
    exposing
        ( loadTime
        , addOne
        , set
        , getDevices
        , Port
          -- , open
        , messages
        )

-- import Native.Serial

import Task exposing (Task)
import Serial.LowLevel as SLL
import Process


-- this will be our function which returns a number plus one
-- addOne a =
--     a + 1
-- COMMANDS


type MyCmd msg
    = Send String String


cmdMap : (a -> b) -> MyCmd a -> MyCmd b
cmdMap _ (Send url msg) =
    Send url msg


type alias Port =
    { displayName : String
    , path : String
    }


addOne : Int -> Int
addOne =
    Native.Serial.addOne


loadTime : Float
loadTime =
    Native.Serial.loadTime


set : String -> Task x ()
set =
    Native.Serial.set


getDevices : Task x (List Port)
getDevices =
    Native.Serial.getDevices


type MySub msg
    = Message (SLL.Event -> msg)



-- open :
--     String
--     -> Platform.Router msg Msg
--     -> Task SLL.BadOpen SLL.Serial
-- open path router =
--     SLL.open path
--         { onMessage = \_ msg -> Platform.sendToSelf router (Receive path msg)
--         }
-- open : String -> (String -> msg) -> Task x SLL.Serial
-- open =
--     SLL.open


messages : (SLL.Event -> msg) -> Sub msg
messages tagger =
    subscription (Message tagger)



-- SLL.l


type alias Event =
    {}



-- SUBSCRIPTIONS


subMap : (a -> b) -> MySub a -> MySub b
subMap func (Message tagger) =
    let
        _ =
            Debug.log "Serial:subMap" ( func, tagger )
    in
        -- case sub of
        --     Message tagger ->
        Message (tagger >> func)



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
                            send (Message tagger) =
                                Platform.sendToApp router (tagger event)
                        in
                            Task.sequence (List.map send subs)
                                |> Task.andThen (\_ -> Task.succeed state)


onEffects :
    Platform.Router msg Msg
    -> List (MyCmd msg)
    -> List (MySub msg)
    -> State msg
    -> Task Never (State msg)
onEffects router cmds subs state =
    case state of
        Nothing ->
            let
                _ =
                    Debug.log
                        ("Serial:onEffects"
                            ++ "\n     router"
                            ++ toString (router)
                            ++ "\n     cmds"
                            ++ toString (cmds)
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


waiter : Platform.Router msg Msg -> Task x SLL.Serial
waiter router =
    SLL.waitMessage
        (\msg ->
            let
                _ =
                    Debug.log "waiter Msg: " msg
            in
                Platform.sendToSelf router (Receive msg)
        )
