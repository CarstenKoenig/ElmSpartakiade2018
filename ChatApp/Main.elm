module Main exposing (..)

import Html as H exposing (Html)
import Html.Attributes as Attr
import Html.Events as Ev
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


kannEinloggen : Model -> Bool
kannEinloggen model =
    String.length model.loginName >= 4 && String.length model.loginPasswort > 0


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


view : Model -> Html Msg
view model =
    viewLayout
        { navbar = [ login model ]
        , toolbar = [ H.text "hier wird die Toolbar sein" ]
        , body = [ H.h1 [] [ H.text "hier werden die Nachrichten stehen" ] ]
        }


login : Model -> Html Msg
login model =
    H.form []
        [ BS.formRow []
            [ BS.col []
                [ BS.textInput
                    [ Attr.placeholder "Dein Name?"
                    , Ev.onInput LoginNameGeändert
                    ]
                    []
                ]
            , BS.col []
                [ BS.passwordInput
                    [ Attr.placeholder "Passwort?"
                    , Ev.onInput LoginPasswortGeändert
                    ]
                    []
                ]
            , BS.colAuto []
                [ BS.submit
                    [ Attr.disabled (not (kannEinloggen model)) ]
                    [ H.text "login" ]
                ]
            ]
        ]
