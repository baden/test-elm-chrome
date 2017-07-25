module Types
    exposing
        ( Model
        , initModel
        , Msg(..)
        )

-- import Date
-- import Array exposing (Array)

import Time
import Serial.LowLevel as SLL
import PortList
import Log


-- import Time exposing (Time)
-- import Time exposing (Time)
-- import Dom


type alias Model =
    { uid : Int
    , ports : PortList.Model
    , log : Log.Model
    , time : Time.Time
    , debug :
        String
        -- , hint : String
    }


initModel : Model
initModel =
    { uid = 0
    , ports = PortList.defaultModel
    , log = Log.initModel
    , time = 0
    , debug =
        ""
        -- , hint = "Бульк"
    }


type Msg
    = PortListMessage PortList.Msg
      -- | AddPort
    | LogMessage Log.Msg
    | OnPortReceive SLL.Event
    | OnPortReceiveError SLL.Event
    | Tick Time.Time
    | NoOp



-- | DomError Dom.Error
