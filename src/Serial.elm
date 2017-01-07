module Serial exposing (loadTime, addOne, set, get)

import Native.Serial
import Task exposing (Task)


-- this will be our function which returns a number plus one
-- addOne a =
--     a + 1


addOne : Int -> Int
addOne =
    Native.Serial.addOne


loadTime : Float
loadTime =
    Native.Serial.loadTime


set : String -> Task x ()
set =
    Native.Serial.set


get : Task x Int
get =
    Native.Serial.get
