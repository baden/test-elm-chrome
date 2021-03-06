module Serial.LowLevel
    exposing
        ( Serial
        , connect
        , disconnect
        , save
        , waitMessage
        , Event
          -- , BadOpen(..)
        )

import Native.Serial
import Task exposing (Task)


-- open : String -> (String -> msg) -> Sub msg
-- open : String -> (String -> msg) -> Sub msg


type Serial
    = Serial


type alias Event =
    { id : Int
    , data : String
    }


type alias Settings =
    { onReceive :
        Event -> Task Never ()
    , onReceiveError :
        Event -> Task Never ()
    }



-- type BadOpen
--     = BadSecurity
--     | BadArgs
-- open : String -> (String -> msg) -> Task x Serial


connect : String -> Int -> Task x Int
connect =
    Native.Serial.connect


disconnect : Int -> Task x Bool
disconnect =
    Native.Serial.disconnect


waitMessage :
    Settings
    -> Task x Serial
waitMessage =
    Native.Serial.waitMessage


save : List String -> Task x Bool
save =
    Native.Serial.save
