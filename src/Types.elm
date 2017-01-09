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
import Array exposing (Array)


-- import Dom


type alias Model =
    { uid : Int
    , portList : List Serial.Port
    , ports : List Port
    , time : Time
    , debug : String
    , logs : Array String
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
        List.range 1 1000
            |> List.map
                (\c ->
                    "Fake log #"
                        ++ (toString c)
                        ++ " with tons of text. Yeap, realy, lot of helpful text. Not kidding, each word is most important. Ok, enough. I sad STOP!"
                )
            |> Array.fromList
    , shouldScroll = False
    , scrollEvent = OnScrollEvent 0 0 0
    }


type alias Port =
    { id : Int }


initPort : Int -> Port
initPort id =
    { id = id
    }


type Msg
    = AddPort
    | RemovePort Int
    | Tick Time
    | SetSerialDevices (List Serial.Port)
    | AddLabel
    | ClearLog
    | NoOp
    | ChatScrolled OnScrollEvent


type alias OnScrollEvent =
    { height : Float
    , top : Float
    , clientHeight : Float
    }


type alias LogLine =
    { data : String
    }



-- | DomError Dom.Error
