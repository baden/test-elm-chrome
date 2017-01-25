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
    , portList = []
    , ports = []
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
