module PortList
    exposing
        ( Msg(..)
        , Model
        , defaultModel
        , update
        , view
        , add_button_view
        , stylesheet
        )

-- module PortList exposing (Msg(..), Model, init, view, update)

import Html exposing (Html, div, text, button, node)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Port
import Serial
import Icons exposing (..)
-- import Platform exposing (Task)
import Task

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
    | GetPort
    | AddPort ID
    | PortMessage ID Port.Msg


-- getPort : Int -> Cmd Msg
-- getPort id =
--     Serial.getPort id
--         |> Task.perform AddPort

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            (model, Cmd.none)

        GetPort ->
            let
                id =
                    model.uid + 1
            in
                ( { model | uid = id }
                , Serial.getPort id --|> Task.perform (AddPort id)
                )

        AddPort id ->
            let
                ( port_, subCmd ) =
                    Port.init id
            in
                -- TODO: Возможно стоит сделать обратный порядок?
                ({ model
                    | ports = model.ports ++ [ ( id, port_ ) ]
                }
                , Cmd.map (PortMessage id) subCmd
                )

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

                                -- _ =
                                --     Debug.log "==**== parentCmd" parentCmd
                                --
                                -- _ =
                                --     Debug.log "  ==**== subCmd" subCmd
                            in
                                case parentCmd of
                                    Nothing ->
                                        ( ( portId, newPort ) :: ports, Cmd.map (PortMessage id) subCmd :: cmds )

                                    Just Port.Remove ->
                                        ( ports, cmds )
                        else
                            ( ( portId, portModel ) :: ports, cmds )

                ( newPorts, newCmds ) =
                    model.ports
                        |> List.foldr f ( [], [] )

                -- _ =
                --     Debug.log "  ****=>  PortList.update:PortMessage" ( id, subMsg, cmds )
            in
                -- { model | ports = newPorts } ! [ Cmd.map (PortMessage id) cmds ]
                -- TODO: TBD
                ({ model | ports = newPorts }, Cmd.batch newCmds)



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
    button [ onClick GetPort ] [ mi_plus, text "Добавить порт" ]


stylesheet : Model -> Html Msg
stylesheet model =
    let
        -- tag =
        --     "link"
        --
        -- attrs =
        --     [ attribute "rel" "stylesheet"
        --     , attribute "property" "stylesheet"
        --     , attribute "href" "css.css"
        --     ]
        tag =
            "style"

        attrs =
            []

        rule p =
            "pre.log p[class^=\"port_"
                ++ (String.fromInt p.cid)
                ++ "\"] {"
                ++ "color: "
                ++ p.logColor
                ++ ";}\n"

        rules =
            model.ports
                |> List.map (\( _, p ) -> rule p)
                |> String.concat
    in
        node tag
            attrs
            [ text rules ]
