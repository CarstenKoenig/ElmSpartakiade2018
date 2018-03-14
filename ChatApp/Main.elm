module Main exposing (..)

import Html as H exposing (Html)
import Html.Attributes as Attr
import Layout exposing (..)
import Bootstrap as BS


type alias Model =
    { loginName : String
    , loginPasswort : String
    }


type Msg
    = LoginNameGeändert String
    | LoginPasswortGeändert String


init : Model
init =
    { loginName = ""
    , loginPasswort = ""
    }


main : Program Never Model Msg
main =
    H.beginnerProgram
        { model = init
        , view = view
        , update = update
        }


update : Msg -> Model -> Model
update msg model =
    case msg of
        LoginNameGeändert name ->
            { model | loginName = name }

        LoginPasswortGeändert passwort ->
            { model | loginPasswort = passwort }


view : Model -> Html msg
view model =
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
