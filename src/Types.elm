module Types
    exposing
        ( Model
        , initModel
        , Msg(..)
        )

-- import Date
-- import Array exposing (Array)

import Time
import Log
import PortList


type alias Model =
    { uid : Int
    , ports : PortList.Model
    , log : Log.Model
    , time : Time.Posix
    , debug :
        String
        -- , hint : String
    }


initModel : Model
initModel =
    { uid = 0
    , ports = PortList.defaultModel
    , log = Log.initModel
    , time = Time.millisToPosix 0
    , debug =
        ""
        -- , hint = "Бульк"
    }


type Msg
    = PortListMessage PortList.Msg
    | LogMessage Log.Msg
    | OnPortGeted Int
    | OnPortConnected Int -- SLL.Event
    | OnPortReceive String -- SLL.Event
    | OnPortReceiveError String -- SLL.Event
    | Tick Time.Posix
    | NoOp



-- | DomError Dom.Error
