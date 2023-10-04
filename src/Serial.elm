port module Serial exposing (..)
-- import Types exposing (Msg(..))

port getPort : Int -> Cmd msg
port connectPort : (Int, Int) -> Cmd msg

port onPortGeted : (Int -> msg) -> Sub msg
-- port onPortConnected : Int -> Cmd msg
port onPortConnected : (Int -> msg) -> Sub msg
port onPortReceive : (String -> msg) -> Sub msg
port onPortReceiveError : (String -> msg) -> Sub msg


save : List String -> Cmd msg
save log_list =
    let
        _ = Debug.log "save" log_list
    in
        Cmd.none

connect : Int -> Int -> Cmd msg
connect id baudrate =
    let
        _ = Debug.log "connect" id
        _ = Debug.log "connect" baudrate
    in
        connectPort (id, baudrate)

disconnect : Int -> Cmd msg
disconnect id =
    let
        _ = Debug.log "disconnect" id
    in
        Cmd.none

