module Main exposing (..)

import Html as H exposing (Html)
import Html.Attributes as Attr
import Html.Events as Ev


main : Program Never Model Msg
main =
    H.beginnerProgram
        { model = { zähler = 0, inkrementText = "5" }
        , view = view
        , update = update
        }


type alias Model =
    { zähler : Int
    , inkrementText : String
    }


type Msg
    = Zählen Int
    | InkrementTextSetzen String
    | InkrementVerwenden


view : Model -> Html Msg
view model =
    H.div
        []
        [ H.h3 [] [ H.text (toString model.zähler) ]
        , H.button [ Ev.onClick (Zählen 1) ] [ H.text "+1" ]
        , H.button [ Ev.onClick (Zählen -1) ] [ H.text "-1" ]
        , H.input [ Attr.type_ "number", Attr.value model.inkrementText, Ev.onInput InkrementTextSetzen ] []
        , H.button [ Ev.onClick InkrementVerwenden ] [ H.text "do" ]
        ]


update : Msg -> Model -> Model
update msg model =
    case msg of
        Zählen inkrement ->
            { model | zähler = model.zähler + inkrement }

        InkrementTextSetzen text ->
            { model | inkrementText = text }

        InkrementVerwenden ->
            String.toInt model.inkrementText
                |> Result.map
                    (\inkrement ->
                        { model | zähler = model.zähler + inkrement }
                    )
                |> Result.withDefault
                    { model | inkrementText = "5" }
