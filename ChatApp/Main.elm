module Main exposing (..)

import Html as H exposing (Html)
import Html.Attributes as Attr
import Html.Events as Ev
import Layout exposing (..)
import Bootstrap as BS
import Anmeldung as Anm exposing (UserName)
import Http
import Api exposing (BenutzerId, BenutzerInfo)


baseUrl : String
baseUrl =
    -- "http://localhost:8081"
    "https://yiherfva.cloud.dropstack.run/"


type alias Model =
    { anmeldung : Anm.Anmeldung BenutzerInfo
    , fehler : Maybe String
    }


type Msg
    = LoginNameGeändert String
    | LoginPasswortGeändert String
    | Login
    | Logout
    | LoginResult (Result Http.Error BenutzerInfo)
    | LogoutResult (Result Http.Error ())
    | DismissError


init : ( Model, Cmd Msg )
init =
    ( { anmeldung = Anm.initLogin
      , fehler = Nothing
      }
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
        DismissError ->
            ( { model | fehler = Nothing }, Cmd.none )

        LoginNameGeändert name ->
            ( { model | anmeldung = Anm.loginNameSetzen name model.anmeldung }, Cmd.none )

        LoginPasswortGeändert passwort ->
            ( { model | anmeldung = Anm.loginPasswortSetzen passwort model.anmeldung }, Cmd.none )

        Login ->
            ( { model | fehler = Nothing }
            , model.anmeldung
                |> Anm.auswerten
                    (\eingabe -> Api.login baseUrl LoginResult eingabe.loginName eingabe.loginPasswort)
                    (always Cmd.none)
            )

        Logout ->
            ( model
            , model.anmeldung
                |> Anm.auswerten (always Cmd.none) (\info -> Api.logout baseUrl LogoutResult info.id)
            )

        LoginResult (Ok info) ->
            ( { model
                | fehler = Nothing
                , anmeldung = Anm.initEingeloggt info
              }
            , Cmd.none
            )

        LoginResult (Err err) ->
            ( { model | fehler = Just (toString err) }, Cmd.none )

        LogoutResult (Ok ()) ->
            ( { model
                | fehler = Nothing
                , anmeldung = Anm.initLogin
              }
            , Cmd.none
            )

        LogoutResult (Err err) ->
            ( { model | fehler = Just (toString err) }, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


view : Model -> Html Msg
view model =
    viewLayout
        { navbar = Anm.auswerten viewLogin viewEingeloggt model.anmeldung
        , toolbar = [ H.text "hier wird die Toolbar sein" ]
        , body =
            [ viewError model.fehler
            , H.h1 [] [ H.text "hier werden die Nachrichten stehen" ]
            ]
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


viewEingeloggt : BenutzerInfo -> List (Html Msg)
viewEingeloggt info =
    [ H.span [ Attr.class "navbar-text" ] [ H.text "Hallo, ", H.strong [] [ H.text info.name ] ]
    , H.form
        [ Attr.class "form-inline"
        , Ev.onSubmit Logout
        ]
        [ BS.submit [] [ H.text "logout" ]
        ]
    ]


viewError : Maybe String -> Html Msg
viewError err =
    case err of
        Nothing ->
            H.text ""

        Just text ->
            H.div
                [ Attr.class "alert alert-danger", Attr.attribute "role" "alert", Ev.onClick DismissError ]
                [ H.p [] [ H.strong [] [ H.text "error: " ], H.text text ] ]
