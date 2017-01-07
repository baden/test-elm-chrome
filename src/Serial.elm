module Serial exposing (loadTime, addOne, set, getDevices, Port)

import Native.Serial
import Task exposing (Task)


-- this will be our function which returns a number plus one
-- addOne a =
--     a + 1


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
