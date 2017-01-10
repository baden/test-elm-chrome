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
        )

import Serial
import Date
import Array exposing (Array)
import Time


-- import Time exposing (Time)
-- import Time exposing (Time)
-- import Dom


type alias Model =
    { uid : Int
    , portList : List Serial.Port
    , ports : List Port
    , time : Time.Time
    , debug : String
    , logs : Array LogLine
    , shouldScroll : Bool
    , scrollEvent : OnScrollEvent
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
        -- , logs = Array.fromList (List.repeat 10000 "Fake log with tons of text. Yeap, realy, lot of helpful text. Not kidding, each word is most important. Ok, enough. I sad STOP!")
    , logs =
        -- List.range 1 999999
        List.range 1 10
            |> List.map
                (\c ->
                    fakeLog
                        (c % 4)
                        (Date.fromTime 0)
                        ("Fake log #"
                            ++ (toString c)
                            ++ " with tons of text. Yeap, realy, lot of helpful text. Not kidding, each word is most important. Ok, enough. I sad STOP!"
                        )
                )
            |> Array.fromList
    , shouldScroll = False
    , scrollEvent = OnScrollEvent 0 0 0
    }



-- "Fake log #"
--     ++ (toString c)
--     ++ " with tons of text. Yeap, realy, lot of helpful text. Not kidding, each word is most important. Ok, enough. I sad STOP!"


type alias Port =
    { id : Int
    , logColor : String
    }



-- initPort : Int -> Port
-- initPort id =
--     { id = id
--     }


type Msg
    = AddPort
    | RemovePort Int
    | Tick Time.Time
    | SetSerialDevices (List Serial.Port)
    | AddLabel
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
    , sender : Sender
    }


fakeLog : Int -> Date.Date -> String -> LogLine
fakeLog id timestamp data =
    LogLine
        data
        timestamp
        (PortId id)



-- | DomError Dom.Error
