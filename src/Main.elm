-- Read more about this program in the official Elm guide:
-- https://guide.elm-lang.org/architecture/user_input/buttons.html


module Main exposing (..)

import Html exposing (Html, div, button, text, select, option)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)


type alias Port =
    { id : Int }


type alias Model =
    { uid : Int
    , ports : List Port
    }


initModel : Model
initModel =
    { uid = 0
    , ports = []
    }


type Msg
    = AddPort
    | AddLabel
    | RemovePort Int


init : ( Model, Cmd Msg )
init =
    ( initModel, Cmd.none )


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


fakePortList : List String
fakePortList =
    [ "Выберите порт:"
    , "COM1"
    , "COM2"
    , "COM3"
    ]


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


port_view : Port -> Html Msg
port_view port_ =
    div [ class "port" ]
        [ select [] (listToHtmlSelectOptions fakePortList)
        , select [] (listToHtmlSelectOptions fakeSpeedList)
        , button
            []
            [ text "Подключить" ]
        , button [ onClick (RemovePort port_.id) ] [ text "Удалить" ]
        , text (toString port_)
        ]


ports_view : List Port -> Html Msg
ports_view ports =
    ports
        |> List.map (\c -> port_view c)
        |> div [ class "port_list" ]


view : Model -> Html Msg
view model =
    div []
        [ ports_view model.ports
        , control_view model
        , div [] [ text (toString model) ]
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    -- Time.every second Tick
    Sub.none
