effect module Serial
    where { command = MyCmd, subscription = MySub }
    exposing
        ( loadTime
        , addOne
        , set
        , getDevices
        , Port
        , open
        , listen
        )

-- import Native.Serial

import Task exposing (Task)
import Serial.LowLevel as SLL


-- import Process
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
    = Listen String (String -> msg)


open :
    String
    -> Platform.Router msg Msg
    -> Task SLL.BadOpen SLL.Serial
open path router =
    SLL.open path
        { onMessage = \_ msg -> Platform.sendToSelf router (Receive path msg)
        }



-- open : String -> (String -> msg) -> Task x SLL.Serial
-- open =
--     SLL.open


listen : String -> (String -> msg) -> Sub msg
listen path tagger =
    subscription (Listen path tagger)



-- SLL.l


type alias Event =
    {}



-- SUBSCRIPTIONS


subMap : (a -> b) -> MySub a -> MySub b
subMap func sub =
    let
        _ =
            Debug.log "Serial:subMap" ( func, sub )
    in
        case sub of
            Listen path tagger ->
                Listen path (tagger >> func)



-- EFFECT MANAGER


type alias State msg =
    Maybe
        { subs : List (MySub msg)
        }


init : Task Never (State msg)
init =
    let
        _ =
            Debug.log "Serial:init" 0
    in
        Task.succeed Nothing


onSelfMsg :
    Platform.Router msg Msg
    -> Msg
    -> State msg
    -> Task Never (State msg)
onSelfMsg router selfMsg state =
    let
        _ =
            Debug.log "Serial:onSelfMsg" ( router, selfMsg, state )
    in
        Task.succeed state


onEffects :
    Platform.Router msg Msg
    -> List (MyCmd msg)
    -> List (MySub msg)
    -> State msg
    -> Task Never (State msg)
onEffects router cmds subs state =
    let
        _ =
            Debug.log "Serial:onEffects" ( router, cmds, subs, state )
    in
        Task.succeed Nothing
