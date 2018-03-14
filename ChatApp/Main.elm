module Main exposing (..)

import Html as H exposing (Html)
import Html.Attributes as Attr
import Layout exposing (..)
import Bootstrap as BS


main : Html msg
main =
    viewLayout
        { navbar = [ login ]
        , toolbar = [ H.text "hier wird die Toolbar sein" ]
        , body = [ H.h1 [] [ H.text "hier werden die Nachrichten stehen" ] ]
        }


login : Html msg
login =
    H.form []
        [ BS.formRow []
            [ BS.col []
                [ BS.textInput
                    [ Attr.placeholder "Dein Name?" ]
                    []
                ]
            , BS.col []
                [ BS.passwordInput
                    [ Attr.placeholder "Passwort?" ]
                    []
                ]
            , BS.colAuto []
                [ BS.submit [] [ H.text "login" ]
                ]
            ]
        ]
