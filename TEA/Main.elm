module Main exposing (..)

import Html as H exposing (Html)
import Html.Events as Ev


main : Program Never Model Msg
main =
    H.beginnerProgram
        { model = { zähler = 0 }
        , view = view
        , update = update
        }


type alias Model =
    { zähler : Int }


type Msg
    = Hochzählen


view : Model -> Html Msg
view model =
    H.div
        []
        [ H.h3 [] [ H.text (toString model.zähler) ]
        , H.button [ Ev.onClick Hochzählen ] [ H.text "+1" ]
        ]


update : Msg -> Model -> Model
update msg model =
    case msg of
        Hochzählen ->
            { zähler = model.zähler + 1 }
