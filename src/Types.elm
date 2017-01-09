module Types
    exposing
        ( Port
        , Model
        , initModel
        , Msg(..)
        , initPort
        , OnScrollEvent
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
    , shouldScroll : Bool
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
    , logs = List.repeat 10 "Fake log"
    , shouldScroll = False
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
    | ChatScrolled OnScrollEvent


type alias OnScrollEvent =
    { height : Float
    , top : Float
    , clientHeight : Float
    }



-- | DomError Dom.Error
