-- Read more about this program in the official Elm guide:
-- https://guide.elm-lang.org/architecture/user_input/buttons.html


module Main exposing (..)

import Html exposing (Html, div, button, text, select, option)
import Html.Attributes exposing (class, value)
import Html.Events exposing (onClick)
import Serial
import Time exposing (Time, second)
import Task exposing (Task)


type alias Port =
    { id : Int }


type alias Model =
    { uid : Int
    , portList : List Serial.Port
    , ports : List Port
    , time : Time
    , debug : String
    }


initModel : Model
initModel =
    { uid = 0
    , portList = []
    , ports = []
    , time = 0
    , debug = ""
    }


type Msg
    = AddPort
    | AddLabel
    | RemovePort Int
    | Tick Time
    | SetSerialDevices (List Serial.Port)



-- | Noop


init : ( Model, Cmd Msg )
init =
    ( initModel, Cmd.batch [ getSerialDevices ] )


main : Program Never Model Msg
main =
    Html.program { init = init, view = view, update = update, subscriptions = subscriptions }


initPort : Int -> Port
initPort id =
    { id = id
    }


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
            model ! []

        RemovePort id ->
            { model | ports = List.filter (\t -> t.id /= id) model.ports }
                ! []

        Tick newTime ->
            ( { model | time = newTime }, Cmd.none )

        SetSerialDevices ports ->
            ( { model | portList = ports }, Cmd.none )


control_view : Model -> Html Msg
control_view model =
    div [ class "control" ]
        [ button [ onClick AddPort ] [ text "Добавить порт" ]
        , button [ onClick AddLabel ] [ text "Поставить метку" ]
        ]


toSelectOption : String -> Html a
toSelectOption x =
    option [] [ text x ]


listToHtmlSelectOptions : List String -> List (Html a)
listToHtmlSelectOptions list =
    list
        |> List.map toSelectOption


portOption : Serial.Port -> Html a
portOption p =
    option [ value (toString p.path) ]
        [ text (p.path ++ ":" ++ p.displayName) ]


listPorts : List Serial.Port -> List (Html a)
listPorts list =
    list
        |> List.map portOption


fakeSpeedList : List String
fakeSpeedList =
    [ "Выберите скорость:"
    , "1200"
    , "2400"
    , "4800"
    , "9600"
    , "19200"
    , "38400"
    , "57600"
    , "115200"
    , "230400"
    , "460800"
    , "125000"
    , "166667"
    , "250000"
    , "500000"
    ]


port_view : Model -> Port -> Html Msg
port_view model port_ =
    div [ class "port" ]
        [ select [] (listPorts model.portList)
        , select [] (listToHtmlSelectOptions fakeSpeedList)
        , button
            []
            [ text "Подключить" ]
        , button [ onClick (RemovePort port_.id) ] [ text "Удалить" ]
        , text (toString port_)
        , text " / "
        , text (toString (Serial.loadTime))
        , text " / "
        , text (toString (Serial.addOne port_.id))
        ]


ports_view : Model -> List Port -> Html Msg
ports_view model ports =
    ports
        |> List.map (\c -> port_view model c)
        |> div [ class "port_list" ]



-- resetFavicon : Cmd Msg
-- resetFavicon =
--     Cmd.map (always Noop)
--         << Task.perform Err Ok
--     <|
--         (Serial.set ("/public/images/favicon.png"))


getSerialDevices : Cmd Msg
getSerialDevices =
    -- Time.now
    Serial.getDevices
        |> Task.perform
            SetSerialDevices


view : Model -> Html Msg
view model =
    div []
        [ ports_view model model.ports
        , control_view model
        , div [] [ text (toString model) ]
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    -- Time.every second Tick
    Sub.none
