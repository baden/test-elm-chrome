module Serial.LowLevel
    exposing
        ( Serial
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
        { id : Int, data : String } -> Task Never ()
    , onReceiveError :
        { id : Int, data : String } -> Task Never ()
    }



-- type BadOpen
--     = BadSecurity
--     | BadArgs
-- open : String -> (String -> msg) -> Task x Serial


waitMessage :
    (Event -> Task Never ())
    -> Task x Serial
waitMessage =
    Native.Serial.waitMessage
