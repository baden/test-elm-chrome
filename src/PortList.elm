module PortList exposing (Msg(..), Model, defaultModel, view, add_button_view, update)

-- module PortList exposing (Msg(..), Model, init, view, update)

import Html exposing (Html, div, text, button)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Port


type alias ID =
    Int


type alias Model =
    { uid : ID
    , ports : List ( ID, Port.Model )
    }


init : ( Model, Cmd Msg )
init =
    ( defaultModel, Cmd.none )


defaultModel : Model
defaultModel =
    { uid = 0
    , ports = []
    }


type Msg
    = NoOp
    | AddPort
    | PortMessage ID Port.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            model ! []

        AddPort ->
            let
                id =
                    model.uid

                ( port_, subCmd ) =
                    Port.init id
            in
                -- TODO: Возможно стоит сделать обратный порядок?
                { model
                    | uid = model.uid + 1
                    , ports = model.ports ++ [ ( id, port_ ) ]
                }
                    ! [ Cmd.map (PortMessage id) subCmd ]

        -- PortMessage id (Port.RemovePort _) ->
        --     { model | ports = List.filter (\t -> t.id /= id) model.ports }
        --         ! []
        PortMessage id subMsg ->
            let
                f : ( ID, Port.Model ) -> ( List ( ID, Port.Model ), List (Cmd Msg) ) -> ( List ( ID, Port.Model ), List (Cmd Msg) )
                f =
                    \( portId, portModel ) ( ports, cmds ) ->
                        if portId == id then
                            let
                                ( newPort, subCmd, parentCmd ) =
                                    Port.update subMsg portModel

                                _ =
                                    Debug.log "==**== parentCmd" parentCmd
                            in
                                case parentCmd of
                                    Nothing ->
                                        ( ( portId, newPort ) :: ports, Cmd.map (PortMessage id) subCmd :: cmds )

                                    Just (Port.Remove) ->
                                        ( ports, cmds )
                        else
                            ( ( portId, portModel ) :: ports, [] )

                ( newPorts, cmds ) =
                    model.ports
                        |> List.foldr f ( [], [] )

                _ =
                    Debug.log "  ****=>  PortList.update:PortMessage" ( id, subMsg )
            in
                -- { model | ports = newPorts } ! [ Cmd.map (PortMessage id) cmds ]
                -- TODO: TBD
                { model | ports = newPorts } ! []



-- !
--     []
-- RemovePort id ->
--     { model | ports = List.filter (\t -> t.id /= id) model.ports }
--         ! []


view : Model -> Html Msg
view model =
    model.ports
        |> List.map
            (\( id, portModel ) ->
                Port.view portModel
                    |> Html.map (PortMessage id)
            )
        |> div [ class "port_list" ]


add_button_view : Model -> Html Msg
add_button_view model =
    button [ onClick AddPort ] [ text "➕ Добавить порт" ]
