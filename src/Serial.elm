port module Serial exposing (..)
-- import Types exposing (Msg(..))

import Json.Decode as D
import Json.Encode as E

port getPort : Int -> Cmd msg
port connectPort : PortData -> Cmd msg

port onPortGeted : (Int -> msg) -> Sub msg
-- port onPortConnected : Int -> Cmd msg
port onPortConnected : (Int -> msg) -> Sub msg
port onPortReceive : (PortLine -> msg) -> Sub msg
port onPortReceiveError : (String -> msg) -> Sub msg


save : List String -> Cmd msg
save log_list =
    let
        _ = Debug.log "save" log_list
    in
        Cmd.none

type alias PortData =
    { id : Int
    , baudrate : Int
    }

type alias PortLine =
    { id : Int
    -- , timestamp : Int
    , data : String
    }

portDataEncode : PortData -> E.Value
portDataEncode p =
    E.object
        [ ( "id", E.int p.id )
        , ( "baudrate", E.int p.baudrate )
        ]

connect : Int -> Int -> Cmd msg
connect id baudrate =
    let
        _ = Debug.log "connect" id
        _ = Debug.log "connect" baudrate
    in
        connectPort <| PortData id baudrate

disconnect : Int -> Cmd msg
disconnect id =
    let
        _ = Debug.log "disconnect" id
    in
        Cmd.none

