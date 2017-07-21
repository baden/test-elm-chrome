module PortList exposing (Msg(..), Model, defaultModel, view, add_button_view, update)

-- module PortList exposing (Msg(..), Model, init, view, update)

import Html exposing (Html, div, text, button)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Port


type alias Model =
    { uid : Int
    , ports : List Port.Model
    }


defaultModel : Model
defaultModel =
    { uid = 0
    , ports = []
    }


type Msg
    = PortMessage Port.Msg
    | AddPort
    | RemovePort Int


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        _ =
            Debug.log "PortList:Update" ( msg, model )
    in
        case msg of
            PortMessage subMsg ->
                let
                    _ =
                        Debug.log "  ****=>  PortList.update:PortMessage" subMsg
                in
                    model ! []

            AddPort ->
                let
                    id =
                        model.uid

                    ( port_, subCmd ) =
                        Port.init id
                in
                    { model
                        | uid = model.uid + 1
                        , ports = model.ports ++ [ port_ ]
                    }
                        ! [ Cmd.map PortMessage subCmd ]

            -- !
            --     []
            RemovePort id ->
                { model | ports = List.filter (\t -> t.id /= id) model.ports }
                    ! []


view : Model -> Html Msg
view model =
    model.ports
        |> List.map (\c -> Html.map PortMessage (Port.view c))
        |> div [ class "port_list" ]


add_button_view : Model -> Html Msg
add_button_view model =
    button [ onClick AddPort ] [ text "➕ Добавить порт" ]
