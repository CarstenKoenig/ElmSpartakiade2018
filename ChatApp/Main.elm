module Main exposing (..)

import Anmeldung as Anm exposing (UserName)
import Api exposing (BenutzerId, BenutzerInfo, MessageId, Message)
import Bootstrap as BS
import Date exposing (Date)
import Dict exposing (Dict)
import Html as H exposing (Html)
import Html.Attributes as Attr
import Html.Events as Ev
import Http
import Keyboard as Kbd
import Layout exposing (..)
import Markdown as MD
import Notifications as N
import Time exposing (Time)


baseUrl : String
baseUrl =
    -- "http://localhost:8081"
    "https://yiherfva.cloud.dropstack.run/"


wsUrl : String
wsUrl =
    -- "ws://localhost:8081"
    "wss://yiherfva.cloud.dropstack.run/"


ctrlKeyCode : Kbd.KeyCode
ctrlKeyCode =
    17


enterKeyCode : Kbd.KeyCode
enterKeyCode =
    13


type alias Model =
    { anmeldung : Anm.Anmeldung BenutzerInfo
    , fehler : Maybe String
    , nachrichten : Dict MessageId Message
    , aktuelleZeit : Maybe Time
    , nachrichtText : String
    , nachrichtTextFocused : Bool
    , nachrichtTextMouseOver : Bool
    , ctrlKeyPressed : Bool
    }


type Msg
    = LoginNameGeändert String
    | LoginPasswortGeändert String
    | Login
    | Logout
    | LoginResult (Result Http.Error BenutzerInfo)
    | LogoutResult (Result Http.Error ())
    | NachrichtenResult Bool (Result Http.Error (List Message))
    | DismissError
    | UpdateTime Time
    | NachrichtSchicken
    | NachrichtSchickenResult (Result Http.Error ())
    | NachrichtTextGeändert String
    | NachrichtTextOver Bool
    | NachrichtTextFocus Bool
    | KeyDown Kbd.KeyCode
    | KeyUp Kbd.KeyCode


init : ( Model, Cmd Msg )
init =
    ( { anmeldung = Anm.initLogin
      , fehler = Nothing
      , nachrichten = Dict.empty
      , aktuelleZeit = Nothing
      , nachrichtText = ""
      , nachrichtTextFocused = False
      , nachrichtTextMouseOver = False
      , ctrlKeyPressed = False
      }
    , Api.getNachrichten baseUrl (NachrichtenResult False) Nothing Nothing
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
        UpdateTime now ->
            ( { model | aktuelleZeit = Just now }, Cmd.none )

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
            , Cmd.batch
                [ Api.getNachrichten baseUrl (NachrichtenResult False) (Just <| info.id) Nothing
                , N.showNotification (N.Notification ("Hallo " ++ info.name) "")
                ]
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

        NachrichtenResult istAktuell (Ok msgs) ->
            let
                mapMsg msg =
                    ( msg.messageId, msg )

                mapNotify msg =
                    case msg.body of
                        Api.Chat chat ->
                            if Just chat.sender /= Maybe.map (\info -> info.name) (Anm.getInfo model.anmeldung) then
                                Just (N.Notification ("Nachricht von " ++ chat.sender) chat.textBody)
                            else
                                Nothing

                        Api.System _ ->
                            Nothing

                neueNachrichten =
                    Dict.union (Dict.fromList <| List.map mapMsg msgs) model.nachrichten

                cmdNotifications =
                    if istAktuell then
                        List.filterMap mapNotify msgs
                            |> List.map N.showNotification
                            |> Cmd.batch
                    else
                        Cmd.none
            in
                ( { model | nachrichten = neueNachrichten }, cmdNotifications )

        NachrichtenResult _ (Err err) ->
            ( { model
                | fehler = Just (toString err)
                , nachrichten = Dict.empty
              }
            , Cmd.none
            )

        NachrichtSchicken ->
            nachrichtSchicken model

        NachrichtSchickenResult (Ok ()) ->
            ( model, Cmd.none )

        NachrichtSchickenResult (Err err) ->
            ( { model | fehler = Just (toString err) }, Cmd.none )

        NachrichtTextGeändert text ->
            ( { model | nachrichtText = text }, Cmd.none )

        NachrichtTextFocus focused ->
            ( { model | nachrichtTextFocused = focused }, Cmd.none )

        NachrichtTextOver over ->
            ( { model | nachrichtTextMouseOver = over }, Cmd.none )

        KeyDown keyCode ->
            if keyCode == ctrlKeyCode then
                { model | ctrlKeyPressed = True } ! []
            else if keyCode == enterKeyCode && model.ctrlKeyPressed && model.nachrichtTextFocused then
                nachrichtSchicken model
            else
                ( model, Cmd.none )

        KeyUp keyCode ->
            if keyCode == ctrlKeyCode then
                { model | ctrlKeyPressed = False } ! []
            else
                model ! []


nachrichtSchicken : Model -> ( Model, Cmd Msg )
nachrichtSchicken model =
    if model.nachrichtText == "" then
        ( model, Cmd.none )
    else
        let
            cmd =
                model.anmeldung
                    |> Anm.auswerten (always Cmd.none)
                        (\info -> Api.nachrichtSchicken baseUrl NachrichtSchickenResult info.id model.nachrichtText)
        in
            { model | nachrichtText = "" } ! [ cmd ]


subscriptions : Model -> Sub Msg
subscriptions model =
    let
        clockSub =
            Time.every Time.second UpdateTime

        inMsg =
            Result.map List.singleton
                >> Result.mapError (always Http.NetworkError)
                >> NachrichtenResult True

        webSub =
            model.anmeldung
                |> Anm.auswerten
                    (always <| Api.webSocketSubscription wsUrl inMsg Nothing)
                    (\info -> Api.webSocketSubscription wsUrl inMsg (Just info.id))

        kbdSub =
            Sub.batch [ Kbd.downs KeyDown, Kbd.ups KeyUp ]
    in
        Sub.batch [ clockSub, webSub, kbdSub ]


view : Model -> Html Msg
view model =
    viewLayout
        { navbar = Anm.auswerten viewLogin viewEingeloggt model.anmeldung
        , toolbar = [ viewInput model ]
        , body =
            (viewError model.fehler
                :: (model.anmeldung
                        |> Anm.auswerten
                            (always <| viewMessages Nothing model.aktuelleZeit model.nachrichten)
                            (\info -> viewMessages (Just info.name) model.aktuelleZeit model.nachrichten)
                   )
            )
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


viewMessages : Maybe UserName -> Maybe Time -> Dict MessageId Message -> List (Html Msg)
viewMessages angemeldet now =
    Dict.values
        >> List.reverse
        >> List.map (viewMessage angemeldet (now |> Maybe.withDefault 0))


viewMessage : Maybe UserName -> Time -> Message -> Html Msg
viewMessage angemeldet time msg =
    case msg.body of
        Api.Chat chatMsg ->
            viewChatMessage angemeldet time msg.time chatMsg

        Api.System sysMsg ->
            viewSystemMessage time msg.time sysMsg


viewChatMessage : Maybe UserName -> Time -> Date -> Api.ChatNachricht -> Html Msg
viewChatMessage angemeldet now msgTime msg =
    BS.card
        "w-75 mt-2 mb-2"
        [ Attr.classList
            [ ( "float-right", Just msg.sender /= angemeldet )
            , ( "text-white", msg.isPrivate || Just msg.sender == angemeldet )
            , ( "bg-info", Just msg.sender == angemeldet )
            , ( "bg-warning", msg.isPrivate )
            ]
        ]
        [ BS.row
            []
            [ BS.colMd 8
                []
                [ H.h5
                    [ Attr.class "card-title" ]
                    [ H.text msg.sender ]
                ]
            , BS.col
                []
                [ H.div
                    [ Attr.class "float-right" ]
                    [ H.h6
                        []
                        [ H.text (formatEllapsedTime now msgTime)
                        ]
                    ]
                ]
            ]
        ]
        [ rawHtml msg.htmlBody ]


viewSystemMessage : Time -> Date -> Api.SystemNachricht -> Html Msg
viewSystemMessage now msgTime msg =
    BS.card "w-50 mt-2 mb-2 p-0"
        []
        []
        [ BS.row
            []
            [ BS.colMd 8 [] [ rawHtml msg.htmlBody ]
            , BS.col []
                [ H.div
                    [ Attr.class "float-right" ]
                    [ H.h6 [] [ H.text (formatEllapsedTime now msgTime) ] ]
                ]
            ]
        ]


formatEllapsedTime : Time -> Date -> String
formatEllapsedTime currentTime displayDate =
    let
        timeDiff =
            currentTime - Date.toTime displayDate

        ellapsedHours =
            Time.inHours timeDiff

        ellapsedMinutes =
            Time.inMinutes timeDiff

        ellapsedSeconds =
            Time.inSeconds timeDiff
    in
        if round ellapsedHours >= 2 then
            toString (round ellapsedHours) ++ " hours ago"
        else if ellapsedHours >= 1 then
            "one hour ago"
        else if round ellapsedMinutes >= 2 then
            toString (round ellapsedMinutes) ++ " minutes ago"
        else if ellapsedMinutes >= 1 then
            "one minute ago"
        else
            "just now"


rawHtml : String -> Html msg
rawHtml =
    let
        def =
            MD.defaultOptions

        options =
            { def
                | sanitize = False
            }
    in
        MD.toHtmlWith options []


viewInput : Model -> Html Msg
viewInput model =
    let
        isDisabled =
            model.anmeldung
                |> Anm.auswerten (always True) (always False)

        textRows =
            if not isDisabled && (model.nachrichtTextFocused || model.nachrichtTextMouseOver) then
                5
            else
                1
    in
        H.form
            (if isDisabled then
                [ Attr.class "w-100" ]
             else
                [ Attr.class "w-100"
                , Ev.onSubmit NachrichtSchicken
                , Ev.onMouseOver (NachrichtTextOver True)
                , Ev.onMouseOut (NachrichtTextOver False)
                ]
            )
            [ BS.formRow []
                [ BS.col []
                    [ BS.textArea textRows
                        [ Attr.placeholder "Nachricht..."
                        , Attr.value model.nachrichtText
                        , Attr.disabled isDisabled
                        , Ev.onInput NachrichtTextGeändert
                        , Ev.onFocus (NachrichtTextFocus True)
                        , Ev.onBlur (NachrichtTextFocus False)
                        ]
                        []
                    ]
                , BS.colAuto []
                    [ BS.submit
                        [ Attr.classList
                            [ ( "btn-outline-success", not isDisabled )
                            , ( "btn-outline-warning", not isDisabled && model.nachrichtText == "" )
                            , ( "btn-outline-danger", isDisabled )
                            ]
                        , Ev.onMouseOver (NachrichtTextOver True)
                        , Ev.onMouseOut (NachrichtTextOver False)
                        , Attr.disabled (isDisabled || model.nachrichtText == "")
                        ]
                        [ H.text "schicken" ]
                    ]
                ]
            ]
