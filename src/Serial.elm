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


type Msg
    = Receive String String


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
    -- let
    --     _ =
    --         Debug.log "Serial:subMap" ( func, tagger )
    -- in
    --     -- case sub of
    --     --     Message tagger ->
    Message (tagger >> func)



-- EFFECT MANAGER


type alias State msg =
    Maybe
        { subs : List (MySub msg)
        , listener : Process.Id
        }


init : Task Never (State msg)
init =
    let
        _ =
            Debug.log "Serial:init" 0
    in
        Task.succeed Nothing


onSelfMsg :
    Platform.Router msg SLL.Event
    -> SLL.Event
    -> State msg
    -> Task Never (State msg)
onSelfMsg router selfMsg state =
    let
        _ =
            Debug.log "Serial:onSelfMsg" 0

        _ =
            Debug.log "     router" router

        _ =
            Debug.log "    selfMsg" selfMsg

        _ =
            Debug.log "     state" state
    in
        case state of
            Nothing ->
                Task.succeed Nothing

            Just { subs } ->
                let
                    send (Message tagger) =
                        Platform.sendToApp router (tagger selfMsg)
                in
                    Task.sequence (List.map send subs)
                        |> Task.andThen (\_ -> Task.succeed state)


onEffects :
    Platform.Router msg SLL.Event
    -> List (MyCmd msg)
    -> List (MySub msg)
    -> State msg
    -> Task Never (State msg)
onEffects router cmds subs state =
    let
        _ =
            Debug.log "Serial:onEffects" 0

        _ =
            Debug.log "     router" router

        _ =
            Debug.log "     cmds" cmds

        _ =
            Debug.log "     subs" subs

        _ =
            Debug.log "     state" state
    in
        case state of
            Nothing ->
                case subs of
                    [] ->
                        Task.succeed state

                    _ ->
                        Process.spawn (SLL.waitMessage (Platform.sendToSelf router) (\_ -> Task.succeed ()))
                            |> Task.andThen
                                (\listener ->
                                    Task.succeed (Just { subs = subs, listener = listener })
                                )

            -- Process.spawn (SLL.waitMessage (Platform.sendToSelf router) (\_ -> Task.succeed ()))
            --     |> Task.andThen
            --         (\listener ->
            --             Task.succeed (Just { subs = subs, listener = listener })
            --         )
            Just { subs, listener } ->
                Task.succeed state
