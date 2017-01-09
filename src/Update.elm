module Update
    exposing
        ( init
        , update
        , onScroll
        , onResize
        )

import Task exposing (Task)
import Serial
import Types
    exposing
        ( Port
        , initPort
        , initModel
        , Model
        , Msg(..)
        , OnScrollEvent
        )
import Dom.Scroll
import Json.Decode
import Html
import Html.Events
import Array exposing (Array)


-- import Html.Attributes
-- import Dom
-- import Time
-- import Process


init : ( Model, Cmd Msg )
init =
    ( initModel, Cmd.batch [ getSerialDevices ] )


scrollToBottom : Cmd Msg
scrollToBottom =
    -- Task.perform DomError (always NoOp) (toBottom id)
    Dom.Scroll.toBottom "log"
        |> Task.attempt (always NoOp)


onScroll : (OnScrollEvent -> msg) -> Html.Attribute msg
onScroll tagger =
    Json.Decode.map tagger onScrollJsonParser
        |> Html.Events.on "scroll"


onResize : (OnScrollEvent -> msg) -> Html.Attribute msg
onResize tagger =
    Json.Decode.map tagger onScrollJsonParser
        |> Html.Events.on "resize"


onScrollJsonParser : Json.Decode.Decoder OnScrollEvent
onScrollJsonParser =
    Json.Decode.map3 OnScrollEvent
        (Json.Decode.at [ "target", "scrollHeight" ] Json.Decode.float)
        (Json.Decode.at [ "target", "scrollTop" ] Json.Decode.float)
        (Json.Decode.at [ "target", "clientHeight" ] Json.Decode.float)



-- scrollToBottom : Cmd Msg
-- scrollToBottom =
--     Process.sleep (1 * Time.second)
--         |> Task.andThen (\x -> (Dom.Scroll.toBottom "log"))
--         |> Task.attempt handleScrollResult
--
--
-- handleScrollResult : Result Dom.Error () -> Msg
-- handleScrollResult result =
--     let
--         _ =
--             Debug.log "result" result
--     in
--         case result of
--             Ok _ ->
--                 NoOp
--
--             Err _ ->
--                 NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        AddPort ->
            let
                port_ =
                    initPort model.uid
            in
                { model
                    | uid = model.uid + 1
                    , ports = model.ports ++ [ port_ ]
                }
                    ! []

        AddLabel ->
            let
                new_logs =
                    -- "Label" :: model.logs
                    Array.push "Label" model.logs
            in
                { model | logs = new_logs }
                    ! [ scrollToBottom ]

        ClearLog ->
            { model | logs = Array.empty }
                ! [ scrollToBottom ]

        RemovePort id ->
            { model | ports = List.filter (\t -> t.id /= id) model.ports }
                ! []

        Tick newTime ->
            ( { model | time = newTime }, Cmd.none )

        SetSerialDevices ports ->
            ( { model | portList = ports }, Cmd.none )

        ChatScrolled event ->
            { model
                | shouldScroll = event.top < (event.height * 0.99 - event.clientHeight)
                , scrollEvent = event
            }
                ! []

        NoOp ->
            model ! []



-- DomError err ->
--     let
--         _ =
--             Debug.log "DOM error" (toString err)
--     in
--         ( model, Cmd.none )


getSerialDevices : Cmd Msg
getSerialDevices =
    -- Time.now
    Serial.getDevices
        |> Task.perform
            SetSerialDevices
