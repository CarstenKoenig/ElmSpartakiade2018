module Main exposing (..)

import Html as H exposing (Html)
import Html.Attributes as Attr
import Html.Events as Ev
import Layout exposing (..)
import Bootstrap as BS
import Anmeldung as Anm exposing (UserName)


type alias Model =
    { anmeldung : Anm.Anmeldung
    }


type Msg
    = LoginNameGeändert String
    | LoginPasswortGeändert String
    | Login
    | Logout


init : ( Model, Cmd Msg )
init =
    ( { anmeldung = Anm.initLogin }
    , Cmd.none
    )


kannEinloggen : Anm.LoginEingabe -> Bool
kannEinloggen model =
    String.length model.loginName >= 4 && String.length model.loginPasswort > 0


main : Program Never Model Msg
main =
    H.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LoginNameGeändert name ->
            ( { model | anmeldung = Anm.loginNameSetzen name model.anmeldung }, Cmd.none )

        LoginPasswortGeändert passwort ->
            ( { model | anmeldung = Anm.loginPasswortSetzen passwort model.anmeldung }, Cmd.none )

        Login ->
            ( Anm.loginEingabe model.anmeldung
                |> Maybe.map (\eingabe -> { model | anmeldung = Anm.initEingeloggt eingabe.loginName })
                |> Maybe.withDefault model
            , Cmd.none
            )

        Logout ->
            ( { model | anmeldung = Anm.initLogin }, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


view : Model -> Html Msg
view model =
    viewLayout
        { navbar = Anm.auswerten viewLogin viewEingeloggt model.anmeldung
        , toolbar = [ H.text "hier wird die Toolbar sein" ]
        , body = [ H.h1 [] [ H.text "hier werden die Nachrichten stehen" ] ]
        }


viewLogin : Anm.LoginEingabe -> List (Html Msg)
viewLogin model =
    [ H.form [ Ev.onSubmit Login ]
        [ BS.formRow []
            [ BS.col []
                [ BS.textInput
                    [ Attr.placeholder "Dein Name?"
                    , Attr.value model.loginName
                    , Ev.onInput LoginNameGeändert
                    ]
                    []
                ]
            , BS.col []
                [ BS.passwordInput
                    [ Attr.placeholder "Passwort?"
                    , Attr.value model.loginPasswort
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
    ]


viewEingeloggt : UserName -> List (Html Msg)
viewEingeloggt userName =
    [ H.span [ Attr.class "navbar-text" ] [ H.text "Hallo, ", H.strong [] [ H.text userName ] ]
    , H.form
        [ Attr.class "form-inline"
        , Ev.onSubmit Logout
        ]
        [ BS.submit [] [ H.text "logout" ]
        ]
    ]
