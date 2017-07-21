module Types
    exposing
        ( Model
        , initModel
        , Msg(..)
          -- , initPort
        , OnScrollEvent
          -- , fakeLog
        , LogLine
        , Sender(..)
        , LabelType(..)
        )

import Date
import Array exposing (Array)
import Time
import Serial.LowLevel as SLL
import PortList


-- import Time exposing (Time)
-- import Time exposing (Time)
-- import Dom


type alias Model =
    { uid : Int
    , ports : PortList.Model
    , time : Time.Time
    , debug : String
    , logs : Array LogLine
    , labels : Array Int
    , active_label : Int
    , last_timestamp : Date.Date
    , last_labelid : Int
    , shouldScroll : Bool
    , autoscroll : Bool
    , scrollEvent : OnScrollEvent
    , hint : String
    , findText : Maybe String
    , findIndex : Int
    , findResults : Array Int
    }


initModel : Model
initModel =
    { uid = 0
    , ports = PortList.defaultModel
    , time = 0
    , debug = ""
    , logs = Array.empty
    , labels = Array.empty
    , active_label = 0
    , last_timestamp = Date.fromTime 0
    , last_labelid = 0
    , shouldScroll = False
    , autoscroll = True
    , scrollEvent = OnScrollEvent 0 0 0
    , hint = "Бульк"
    , findText = Nothing
    , findIndex = 0
    , findResults = Array.empty
    }


type Msg
    = PortListMessage PortList.Msg
      -- | AddPort
    | OnPortReceive SLL.Event
    | OnPortReceiveError SLL.Event
    | Tick Time.Time
    | AddLabel LabelType
    | ToNextLabel
    | ToPrevLabel
    | AddLogLine LogLine
    | ClearLog
    | EnableScroll Bool
    | NoOp
    | SaveLogToFile
    | SaveLogDone String
    | ChatScrolled OnScrollEvent
    | EnterFindText String
    | PressKeyOnFind Int
    | NextFindResult
    | PrevFindResult


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
