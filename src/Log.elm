module Log
    exposing
        ( LogLine
        , Model
        , initModel
        , Msg(..)
        , update
        , addPortMsg
        , view
        , view_control_panel
        , statusbar_view
        )

import Date
import Html exposing (Html, div, button, pre, p, text, span, a, mark, input)
import Html.Attributes exposing (class, id, style, title, type_, placeholder, disabled)
import Html.Events exposing (onClick, onInput)
import Array exposing (Array)
import Helpers
import Task
import Dom.Scroll
import Serial
import Json.Decode
import Icons exposing (..)


type alias LogLine =
    { data : String
    , timestamp : Date.Date
    , delta : Float
    , sender : Sender
    }


type Sender
    = PortId Int
    | LabelId Int


type alias OnScrollEvent =
    { height : Float
    , top : Float
    , clientHeight : Float
    }


type LabelType
    = LabelRegular
    | LabelGood
    | LabelBad


type Msg
    = NoOp
    | ClearLog
    | AddLogLine LogLine
    | AddLabel LabelType
    | ToNextLabel
    | ToPrevLabel
    | EnableScroll Bool
    | SaveLogToFile
    | SaveLogDone String
    | ChatScrolled OnScrollEvent
    | EnterFindText String
    | PressKeyOnFind Int
    | NextFindResult
    | PrevFindResult


type alias Model =
    { logs : Array LogLine
    , autoscroll : Bool
    , scrollEvent : OnScrollEvent
    , last_labelid : Int
    , labels : Array Int
    , active_label : Int
    , last_timestamp : Date.Date
    , shouldScroll : Bool
    , findText : Maybe String
    , findIndex : Int
    , findResults : Array Int
    }


initModel : Model
initModel =
    { logs = Array.empty
    , autoscroll = True
    , scrollEvent = OnScrollEvent 0 0 0
    , last_labelid = 0
    , labels = Array.empty
    , active_label = 0
    , last_timestamp = Date.fromTime 0
    , shouldScroll = False
    , findText = Nothing
    , findIndex = 0
    , findResults = Array.empty
    }



-- API:


logs_count : Model -> Int
logs_count model =
    Array.length model.logs



-- Component's API


init : ( Model, Cmd Msg )
init =
    ( initModel, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        ClearLog ->
            { model
                | logs = Array.empty
                , labels = Array.empty
                , active_label = 0
                , last_labelid = 0
                , findResults = Array.empty
                , findIndex =
                    0

                -- , hint = "Очищено"
            }
                ! [ scrollToBottom True ]

        AddLogLine logLine ->
            let
                -- _ =
                --     Debug.log "AddLogLine" logLine
                prev_timestamp =
                    dateToUnixtime model.last_timestamp

                log_timestamp =
                    dateToUnixtime logLine.timestamp

                delta =
                    log_timestamp - prev_timestamp

                new_logs =
                    Array.push
                        { logLine
                            | delta = delta
                        }
                        model.logs
            in
                case model.findIndex of
                    0 ->
                        { model
                            | logs = new_logs
                            , last_timestamp = logLine.timestamp
                        }
                            ! [ scrollToBottom model.autoscroll ]

                    _ ->
                        let
                            index =
                                (Array.length new_logs) - 1

                            text =
                                model.findText |> Maybe.withDefault ""

                            findResults =
                                if String.contains text logLine.data then
                                    Array.push index model.findResults
                                else
                                    model.findResults
                        in
                            { model
                                | logs = new_logs
                                , last_timestamp = logLine.timestamp
                                , findResults = findResults
                            }
                                ! [ scrollToBottom model.autoscroll ]

        AddLabel labelType ->
            let
                id =
                    model.last_labelid + 1
            in
                ( { model
                    | last_labelid = id
                    , labels = model.labels |> Array.push (Array.length model.logs)
                  }
                , onClickAddLabel labelType id
                )

        ToNextLabel ->
            let
                active_label =
                    model.active_label + 1

                line =
                    case Array.get (active_label - 1) model.labels of
                        Just value ->
                            value

                        _ ->
                            0

                -- _ =
                --     Debug.log "to line" line
            in
                { model | active_label = active_label } ! [ scrollToLine line ]

        ToPrevLabel ->
            let
                active_label =
                    model.active_label - 1

                line =
                    case Array.get (active_label - 1) model.labels of
                        Just value ->
                            value

                        _ ->
                            0

                -- _ =
                --     Debug.log "to line" line
            in
                { model | active_label = active_label } ! [ scrollToLine line ]

        EnableScroll scroll ->
            let
                scroll_before =
                    model.autoscroll

                action =
                    if scroll_before == False && scroll == True then
                        Cmd.batch [ scrollToBottom True ]
                    else
                        Cmd.none
            in
                ( { model | autoscroll = scroll }, action )

        ChatScrolled event ->
            { model
                | shouldScroll = event.top < (event.height * 0.99 - event.clientHeight)
                , scrollEvent = event
            }
                ! []

        SaveLogToFile ->
            let
                _ =
                    Debug.log "save" 0
            in
                model ! [ saveLogToFile model.logs ]

        SaveLogDone _ ->
            model ! []

        EnterFindText text ->
            { model | findText = Just text, findIndex = 0 } ! []

        PressKeyOnFind key ->
            if key == 13 then
                if model.findIndex == 0 then
                    let
                        text =
                            model.findText |> Maybe.withDefault ""

                        f : LogLine -> ( Int, Array Int ) -> ( Int, Array Int )
                        f =
                            \d ( index, acc ) ->
                                if String.contains text d.data then
                                    ( index + 1, Array.push index acc )
                                else
                                    ( index + 1, acc )

                        ( _, results ) =
                            model.logs
                                |> Array.foldl f ( 0, Array.empty )
                    in
                        if Array.length results > 0 then
                            { model | findResults = results, findIndex = 0 } |> update NextFindResult
                            -- let
                            --     line =
                            --         results
                            --             |> Array.get 0
                            --             |> Maybe.withDefault 0
                            -- in
                            --     { model | findResults = results, findIndex = 1 } ! [ scrollToLine line ]
                        else
                            { model | findResults = results, findIndex = 0 } ! []
                else if model.findIndex < Array.length model.findResults then
                    model |> update NextFindResult
                else
                    model ! []
            else
                { model | findResults = Array.empty, findIndex = 0 } ! []

        NextFindResult ->
            let
                index =
                    model.findIndex + 1

                line =
                    case Array.get (index - 1) model.findResults of
                        Just value ->
                            value

                        _ ->
                            0
            in
                { model | findIndex = index } ! [ scrollToLine line ]

        PrevFindResult ->
            let
                index =
                    model.findIndex - 1

                line =
                    case Array.get (index - 1) model.findResults of
                        Just value ->
                            value

                        _ ->
                            0
            in
                { model | findIndex = index } ! [ scrollToLine line ]


scrollToBottom : Bool -> Cmd Msg
scrollToBottom scroll =
    -- Task.perform DomError (always NoOp) (toBottom id)
    case scroll of
        True ->
            Dom.Scroll.toBottom "log"
                |> Task.attempt (always NoOp)

        False ->
            Cmd.none


view : Model -> Html Msg
view model =
    let
        e =
            model.scrollEvent

        logSize =
            Array.length model.logs

        lines =
            case e.clientHeight of
                0 ->
                    100

                -- Пока размер окна не определен, будем считать что у нас 100 строк
                h ->
                    h / logLineHeight + 1

        startLine =
            e.top / logLineHeight

        start =
            max 0 ((round startLine) - 10)

        stop =
            min logSize ((round (startLine + lines)) + 10)

        hightlight =
            if model.findIndex == 0 then
                Nothing
            else
                model.findText
    in
        div
            [ class "log"
            , id "log"
            , onScroll ChatScrolled
            ]
            [ sliceLog start stop hightlight model.logs
                |> pre
                    [ class "log"
                    , style [ ( "height", (toString ((toFloat logSize) * logLineHeight)) ++ "px" ) ]
                    ]
            ]


sliceLog : Int -> Int -> Maybe String -> Array LogLine -> List (Html Msg)
sliceLog start stop hightlight logs =
    -- [ ("Show from " ++ (toString start) ++ " to " ++ (toString stop)) ]
    let
        f : LogLine -> ( Int, List (Html Msg) ) -> ( Int, List (Html Msg) )
        f =
            \d ( index, acc ) -> ( index + 1, log_row d index hightlight :: acc )
    in
        Array.slice start stop logs
            |> Array.foldl f ( start, [] )
            |> Tuple.second


logLineHeight : Float
logLineHeight =
    25


log_row : LogLine -> Int -> Maybe String -> Html Msg
log_row l offset hightlight =
    p
        [ style [ ( "top", toString ((toFloat offset) * logLineHeight) ++ "px" ) ]
        , class (logClassName l)

        --   attribute
        --     "style"
        --     ("top: "
        --         ++ toString ((toFloat offset) * logLineHeight)
        --         ++ "px"
        --     )
        ]
        [ div [ class "horizontal" ]
            [ a [] [ text (toString (offset + 1)) ]
            , span [ class "time" ] [ text (Helpers.dateToTime l.timestamp) ]
            , span [ class "delta" ] [ text (Helpers.deltaAsString l.delta) ]
            , span [ class "content" ] (maybeHiglight l.data hightlight)
            ]
        ]


maybeHiglight : String -> Maybe String -> List (Html msg)
maybeHiglight data hightlight =
    case hightlight of
        Nothing ->
            [ text data ]

        Just markit ->
            if String.contains markit data then
                let
                    parts =
                        String.split markit data
                in
                    marks markit parts
            else
                [ text data ]


marks : String -> List String -> List (Html msg)
marks markit parts =
    case parts of
        p1 :: [] ->
            [ text p1 ]

        p1 :: rest ->
            [ text p1, mark [] [ text markit ] ] ++ (marks markit rest)

        [] ->
            []


logClassName : LogLine -> String
logClassName l =
    case l.sender of
        PortId id ->
            "port_" ++ (toString id)

        LabelId id ->
            "label_" ++ (toString id)


addPortMsg : Int -> String -> Cmd Msg
addPortMsg id text =
    Date.now
        |> Task.andThen
            (\now ->
                let
                    fakeLogLine =
                        LogLine
                            text
                            now
                            0
                            (PortId id)
                in
                    Task.succeed fakeLogLine
            )
        |> Task.perform AddLogLine


fakeLog : Int -> Date.Date -> String -> LogLine
fakeLog id timestamp data =
    LogLine
        data
        timestamp
        0
        (PortId id)


onClickAddLabel : LabelType -> Int -> Cmd Msg
onClickAddLabel labelType id =
    Date.now
        |> Task.andThen
            (\now ->
                let
                    labelChar =
                        case labelType of
                            LabelRegular ->
                                "x"

                            LabelGood ->
                                "+"

                            LabelBad ->
                                "-"

                    fakeLogLine =
                        LogLine
                            ("Метка " ++ labelChar ++ (toString id))
                            now
                            0
                            (LabelId 0)
                in
                    Task.succeed fakeLogLine
            )
        |> Task.perform AddLogLine


scrollToLine : Int -> Cmd Msg
scrollToLine line =
    Dom.Scroll.toY "log" (toFloat (line * 25))
        --logLineHeight
        |> Task.attempt (always NoOp)


saveLogToFile : Array LogLine -> Cmd Msg
saveLogToFile logs =
    let
        logs_as_list =
            logs
                |> Array.foldr
                    (\l acc ->
                        ((Helpers.dateToTime l.timestamp)
                            ++ "\t"
                            ++ (Helpers.deltaAsString l.delta)
                            ++ "\t"
                            ++ l.data
                        )
                            :: acc
                    )
                    []
    in
        Serial.save logs_as_list SaveLogDone


onScroll : (OnScrollEvent -> msg) -> Html.Attribute msg
onScroll tagger =
    Json.Decode.map tagger onScrollJsonParser
        |> Html.Events.on "scroll"


onKeyDown : (Int -> msg) -> Html.Attribute msg
onKeyDown tagger =
    Json.Decode.map tagger Html.Events.keyCode
        |> Html.Events.on "keydown"


onScrollJsonParser : Json.Decode.Decoder OnScrollEvent
onScrollJsonParser =
    Json.Decode.map3 OnScrollEvent
        (Json.Decode.at [ "target", "scrollHeight" ] Json.Decode.float)
        (Json.Decode.at [ "target", "scrollTop" ] Json.Decode.float)
        (Json.Decode.at [ "target", "clientHeight" ] Json.Decode.float)


dateToUnixtime : Date.Date -> Float
dateToUnixtime date =
    (Date.toTime date) / 1000



-- View components


view_addLabel : Model -> Html Msg
view_addLabel model =
    button
        [ title "Поставить метку", onClick (AddLabel LabelRegular) ]
        [ mi_label ]


view_markAsGood : Model -> Html Msg
view_markAsGood model =
    button
        [ title "Пометить как хорошее", class "good", onClick (AddLabel LabelGood) ]
        [ mi_goodlabel ]


view_markAsBad : Model -> Html Msg
view_markAsBad model =
    button
        [ title "Пометить как плохое", class "bad", onClick (AddLabel LabelBad) ]
        [ mi_badlabel ]


view_toPrevLabel : Model -> Html Msg
view_toPrevLabel model =
    button
        [ title "К предыдущей метке"
        , onClick ToPrevLabel
        , disabled (model.active_label <= 1)
        ]
        [ mi_prev ]


view_toNextLabel : Model -> Html Msg
view_toNextLabel model =
    button
        [ title "К следующей метке"
        , onClick ToNextLabel
        , disabled (model.active_label == Array.length model.labels)
        ]
        [ mi_next ]


view_startTimer : Model -> Html Msg
view_startTimer model =
    button [ title "Запустить секундомер" ] [ mi_timer ]


view_stopAutoScroll : Model -> Html Msg
view_stopAutoScroll model =
    button
        [ title "Отключить автопрокрутку окна лога"
        , onClick (EnableScroll False)
        , class
            (if model.autoscroll then
                ""
             else
                "active"
            )
        ]
        [ mi_stop ]


view_startAutoScroll : Model -> Html Msg
view_startAutoScroll model =
    button
        [ title "Включить автопрокрутку окна лога"
        , onClick (EnableScroll True)
        , class
            (if model.autoscroll then
                "active"
             else
                ""
            )
        ]
        [ mi_play ]


view_clearLog : Model -> Html Msg
view_clearLog model =
    button [ title "Очистить окно лога", onClick ClearLog ] [ mi_clear ]


view_find : Model -> Html Msg
view_find model =
    div [ class "find" ]
        [ mi_search
        , input
            [ type_ "input"
            , placeholder "Поиск"
            , onInput EnterFindText
            , onKeyDown PressKeyOnFind
            ]
            []
        , button
            [ title "Назад"
            , onClick PrevFindResult
            , disabled (model.findIndex <= 1)
            ]
            [ mi_prev ]
        , button
            [ title "Далее"
            , onClick NextFindResult
            , disabled (model.findIndex >= Array.length model.findResults)
            ]
            [ mi_next ]
        ]


view_save : Model -> Html Msg
view_save model =
    button
        [ title "Сохранить в файл", onClick SaveLogToFile ]
        [ mi_save ]


gr : List (Html msg) -> Html msg
gr =
    div [ class "button-group" ]


view_control_panel : Model -> Html Msg
view_control_panel model =
    div [ class "log-control-panel" ]
        [ gr
            [ view_addLabel model
            , view_markAsGood model
            , view_markAsBad model
            ]
        , gr
            [ view_toPrevLabel model
            , view_toNextLabel model
            ]

        -- , view_startTimer model
        , gr
            [ view_stopAutoScroll model
            , view_startAutoScroll model
            ]
        , view_clearLog model

        -- , button [ title "Детектор данных для трекера" ] [ text "🛰" ]
        -- , button [ title "Запись лога в облако" ] [ text "🌍" ]
        , view_find model

        -- , button [ title "Заметка" ] [ text "ℹ️" ]
        , view_save model

        -- , button [ title "Обнимашки" ] [ text "\x1F917" ]
        -- , button [ title "Настройки" ] [ text "🛠" ]
        ]


statusbar_view : Model -> Html Msg
statusbar_view model =
    div [ class "statusbar" ]
        [ div
            [ class "horizontal" ]
            [ div [] [ text ("Строк лога: " ++ (toString (logs_count model))) ]
            , div [] [ text ("Метка: " ++ (toString model.active_label) ++ "/" ++ (toString (Array.length model.labels))) ]
            , div [] [ text ("Результат поиска: " ++ (toString model.findIndex) ++ "/" ++ (toString (Array.length model.findResults))) ]
            , div [ class "fill" ] [ text "Тут могла бы быть ваша реклама." ]
            , div [] [ text "©2017 Денис Батрак (baden.i.ua@gmail.com)" ]
            ]
        ]
