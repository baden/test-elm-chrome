module Types
    exposing
        ( Port
        , Model
        , initModel
        , Msg(..)
        , initPort
        )

import Serial
import Time exposing (Time)


-- import Dom


type alias Model =
    { uid : Int
    , portList : List Serial.Port
    , ports : List Port
    , time : Time
    , debug : String
    , logs : List String
    }


initModel : Model
initModel =
    { uid = 0
    , portList = []
    , ports = []
    , time = 0
    , debug =
        ""
        -- , logs = []
    , logs = List.repeat 100 "Fake log"
    }


type alias Port =
    { id : Int }


initPort : Int -> Port
initPort id =
    { id = id
    }


type Msg
    = AddPort
    | AddLabel
    | RemovePort Int
    | Tick Time
    | SetSerialDevices (List Serial.Port)
    | NoOp



-- | DomError Dom.Error
