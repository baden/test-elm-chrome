module Icons exposing (..)

import Html exposing (Html, i, text)
import Html.Attributes exposing (class)


mi : String -> Html msg
mi t =
    i [ class "material-icons" ] [ text t ]


mi_plus : Html msg
mi_plus =
    mi "playlist_add"


mi_play : Html msg
mi_play =
    mi "play_arrow"


mi_stop : Html msg
mi_stop =
    mi "stop"


mi_close : Html msg
mi_close =
    mi "close"


mi_label : Html msg
mi_label =
    mi "grade"


mi_goodlabel : Html msg
mi_goodlabel =
    mi "thumb_up"


mi_badlabel : Html msg
mi_badlabel =
    mi "thumb_down"


mi_timer : Html msg
mi_timer =
    mi "timer"


mi_prev : Html msg
mi_prev =
    mi "skip_previous"


mi_next : Html msg
mi_next =
    mi "skip_next"


mi_clear : Html msg
mi_clear =
    mi "delete_sweep"


mi_search : Html msg
mi_search =
    mi "search"


mi_save : Html msg
mi_save =
    mi "save"
