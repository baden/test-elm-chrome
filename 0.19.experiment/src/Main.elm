port module Main exposing (..)

import Browser
import Html exposing (Html, div, text, button, ul, li)
import Html.Events exposing (onClick)

type Msg
    = NoOp
    | GetPorts
    | OnPortFound String -- VendorId ?

port getPorts : String -> Cmd msg
port onPortFound : (String -> msg) -> Sub msg
port onPortConnected : (String -> msg) -> Sub msg
port onPortDisconnected : (String -> msg) -> Sub msg

type alias Model = {
    currentTime : Int
    , ports : List String
    }

init : Int -> ( Model, Cmd Msg )
init currentTime =
    ( { currentTime = currentTime, ports = [] }
    , Cmd.none
    )

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )
        GetPorts ->
            ( model, getPorts "Hello" )
        OnPortFound vendorId ->
            ( { model | ports = vendorId :: model.ports }, Cmd.none )

view : Model -> Html Msg
view model =
    div [] [
        div [] [
            text "Hello, World! Time: "
            , text (String.fromInt model.currentTime)
            , button [ onClick GetPorts ] [ text "Click me!" ]
        ]
        , div [] [ text "Ports:" ]
        , ul [] (List.map (\vendorId -> li [] [text vendorId]) model.ports)
    ]

subscriptions : Model -> Sub Msg
subscriptions _ =
  Sub.batch
    [ onPortFound OnPortFound
    , onPortConnected (always NoOp)
    , onPortDisconnected (always NoOp)
    ]

main : Program Int Model Msg
main =
  Browser.element
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }
