module Main exposing (..)

import Html as H exposing (Html)
import Html.Attributes as Attr
import Layout exposing (..)


main : Html msg
main =
    viewLayout
        { navbar = [ login ]
        , toolbar = [ H.text "hier wird die Toolbar sein" ]
        , body = [ H.h1 [] [ H.text "hier werden die Nachrichten stehen" ] ]
        }


login : Html msg
login =
    H.form
        []
        [ H.input
            [ Attr.type_ "text"
            , Attr.placeholder "Dein Name?"
            ]
            []
        , H.input
            [ Attr.type_ "password"
            , Attr.placeholder "Passwort?"
            ]
            []
        , H.button
            [ Attr.type_ "submit"
            ]
            [ H.text "login" ]
        ]
