module Types
    exposing
        ( Port
        , Model
        , initModel
        , Msg(..)
          -- , initPort
        , OnScrollEvent
          -- , fakeLog
        , LogLine
        , Sender(..)
        , LabelType(..)
        )

import Serial
import Date
import Array exposing (Array)
import Time
import Serial.LowLevel as SLL


-- import Time exposing (Time)
-- import Time exposing (Time)
-- import Dom


type alias Model =
    { uid : Int
    , portList :
        List Serial.Port
        -- TODO: Заменить на Dict id Port
    , ports : List Port
    , time : Time.Time
    , debug : String
    , logs : Array LogLine
    , last_timestamp : Date.Date
    , last_labelid : Int
    , shouldScroll : Bool
    , scrollEvent : OnScrollEvent
    }


initModel : Model
initModel =
    { uid = 0
    , portList = []
    , ports = []
    , time = 0
    , debug = ""
    , logs = Array.empty
    , last_timestamp = Date.fromTime 0
    , last_labelid = 0
    , shouldScroll = False
    , scrollEvent = OnScrollEvent 0 0 0
    }


type alias Port =
    { id : Int
    , path : String
    , boudrate : String
    , name : String
    , cid : Int
    , logColor : String
    , connected : Bool
    }


type Msg
    = AddPort
    | RemovePort Int
    | ConnectPort Port
    | DisconnectPort Port
    | PortConnected ( String, Int )
    | PortDisconnected ( Int, Bool )
    | OnChangePortPath Int String
    | OnChangePortBoudrate Int String
    | OnChangeColorEvent Int String
    | OnPortReceive SLL.Event
    | OnPortReceiveError SLL.Event
    | Tick Time.Time
    | SetSerialDevices (List Serial.Port)
    | AddLabel LabelType
    | AddLogLine LogLine
    | ClearLog
    | NoOp
    | ChatScrolled OnScrollEvent


type alias OnScrollEvent =
    { height : Float
    , top : Float
    , clientHeight : Float
    }


type Sender
    = PortId Int
    | LabelId Int


type alias LogLine =
    { data : String
    , timestamp : Date.Date
    , delta : Float
    , sender : Sender
    }


type LabelType
    = LabelRegular
    | LabelGood
    | LabelBad


fakeLog : Int -> Date.Date -> String -> LogLine
fakeLog id timestamp data =
    LogLine
        data
        timestamp
        0
        (PortId id)



-- | DomError Dom.Error
