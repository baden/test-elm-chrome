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
    { --onOpen : Serial -> Task Never ()
      --,
      onMessage :
        Serial -> String -> Task Never ()
        -- , onError : () -> Task Never ()
        -- , onClose : { code : Int, reason : String, wasClean : Bool } -> Task Never ()
    }



-- type BadOpen
--     = BadSecurity
--     | BadArgs
-- open : String -> (String -> msg) -> Task x Serial


waitMessage :
    (Event -> Task Never ())
    -> (a -> Task Never ())
    -> Task x Serial
waitMessage =
    Native.Serial.waitMessage
