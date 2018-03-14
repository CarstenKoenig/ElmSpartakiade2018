# Einführung

## Start
Einfach in ein Verzeichnis und dann

    elm make
    
damit wird eine `elm.package.json` mit ein paar
Standard-Modulen angelegt.

Jetzt kann eine (z.B. `Main.elm`) Elm Datei angelegt werden.

Die Datei sieht in der Regel ungefähr so aus:

```elm
module Main exposing (..)

import Html


main =
    Html.text "Hallo Elm"
```

der Name des Moduls sollte dem der Datei entsprechen (darüber findet
Elm die Module im Dateisystem)

Wird ein `main` angegeben, dann muss es eines der Typen:

- `Html` (`import Html` nicht vergessen): HTML Dokument
- `Svg` ein Bild
- `Program` (das ist die Regel) für eine Applikation

Der `main` Wert wird benötigt, wenn das Modul der Einstiegspunkt
für eine Applikation ist oder wenn man den *elm reactor* verwenden
möchte (sonst zeigt dieser nur eine leere Seite).

Diese wird kompiliert mit

- `elm make main.elm` erzeugt eine einfache `index.html` mit der gesamten Anwendung
- in der Regel aber nützlicher: `elm make --yes Main.elm --output elm.js`

Einbetten kann man das dann in Html mit:

```html
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Elm eingebettet</title>
</head>

<body>
<div id="main"></div>
<script src="elm.js"></script>
<script>
  var node = document.getElementById('main');
  var app = Elm.Main.embed(node);
</script>
</body>

</html>
```

Dabei ist natürlich die `src` etc. zu ersetzen.



## die Repl
über 

    elm repl
    
jetzt kann man mit `import Main` das Modul importieren und *benutzen*

Einmal importiert, reicht es übrigens, die Datei zu speichern, beim auswerten
einer Expression wird die Datei in der *REPL* neu geladen.


## der Reactor

aufruf mit

    elm repl
    
danach Seite [localhost:8000](http://localhost:8000)

von dort kann man Elm-Dateien automatisch kompilieren/anzeigen lassen.

Der *Reactor* kann auch `.html` Dateien verwenden - besonders nützlich dabei:
Wenn Du als URL `_compile/Main.elm` also eine `.elm` Datei angibst wird
die vom *Reactor* automatisch kompiliert.

Leider fallen dabei eventuelle Fehlermeldungen weg.

---

# Chat-App

ein Template sollte direkt im `Chat-0` Branch vorhanden sein.    

Starten mit:

```elm
module Main exposing (..)

import Html exposing (Html)


main : Html msg
main =
    Html.text "Chat ..."
```

`Html msg` heißt: die Rückgabe ist eine `Html` Darstellung
deren Aktionen (später) eine Nachricht vom *generischen* Typ
`msg` zurückgebenkönnen (für den Moment bitte ignorieren)

## Login
sagen wir ein `<h1>` Element:

```elm
import Html as H exposing (Html)

main : Html msg
main =
    login


login : Html msg
login =
    H.h1 [] [ H.text "Login hier" ]
```

Vielleicht als Form?

```elm
import Html.Attributes as Attr


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
```

Um das Layout so zu bekommen bitte 

   git checkout Chat-1

```elm
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
        [ BS.formRow
            []
            [ BS.col
                []
                [ BS.textInput
                    [ Attr.placeholder "Dein Name?" ]
                    []
                ]
            , BS.col
                []
                [ BS.passwordInput
                    [ Attr.placeholder "Passwort?" ]
                    []
                ]
            , BS.colAuto
                []
                [ BS.submit [] [ H.text "login" ]
                ]
            ]
        ]        
```

---

## Elm Architektur

    git checkout beginnerTEA

### Model-View-Update

- **Model**: der komplette Zustand den Du brauchst um Deine Applikation darzustellen, etc.
- **View**: eine Funktion, die den Zustand in eine HTML-Darstellung transformiert
- **Messages**: werden von Ereignissen in der View ausgelöst und stellen eine Aufforderung zum Ändern des Zustands dar
- **Update**: nimmt den aktuellen Zustand und eine *Message* und erstellt daraus einen *Nachfolgezustand*

Übergang zu `Program`

    mkdir TEA
    cp Starter/* TEA/
    cd TEA
    elm make --yes


```elm
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
```

> Aktueller Stand:

    git checkout beginnerTEA

---

### Übung:
Füge einen zweiten Knopf hinzu, der den Wert wieder runterzählt

#### Lösung (`beginnerTEA-2`)

```elm
type alias Model =
    { zähler : Int }


type Msg
    = Zählen Int


view : Model -> Html Msg
view model =
    H.div
        []
        [ H.h3 [] [ H.text (toString model.zähler) ]
        , H.button [ Ev.onClick (Zählen 1) ] [ H.text "+1" ]
        , H.button [ Ev.onClick (Zählen -1) ] [ H.text "-1" ]
        ]


update : Msg -> Model -> Model
update msg model =
    case msg of
        Zählen inkrement ->
            { zähler = model.zähler + inkrement }
```
---

Jetzt soll der inkrement über eine Textbox eingegeben werden können.

Dafür muss das Model erweitert werden und dann ein `String` in einen `Int`
geparst werden.

```elm
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
```            

> aktueller Stand

    git checkout beginnerTEA-3

---

Jetzt wollen wir das Login so einbauen, dass der Login-Button nur aktiviert ist, wenn ein
Name von mindestens 4 Zeichen und ein nicht-leeres Passwort eingegeben wurde

### das Model   

```elm
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
```

> aktueller Stand:

    git checkout Chat-2

> **Diskussion:** wie soll eingeloggt von nicht-eingeloggt unterschieden werden?

### Vorschlag

```elm
type alias Model =
    { anmeldung : Anmeldung
    }


type alias UserName =
    String


type Anmeldung
    = Login LoginEingabe
    | Eingeloggt UserName


type alias LoginEingabe =
    { loginName : UserName
    , loginPasswort : String
    }
```

aber wir machen aus den Anmelde-Datentyp ein eigenes Modul:

```elm
module Anmeldung
    exposing
        ( UserName
        , Anmeldung
        , LoginEingabe
        , initLogin
        , initEingeloggt
        , auswerten
        , loginEingabe
        , eingeloggterBenutzer
        , loginNameSetzen
        , loginPasswortSetzen
        )


type alias UserName =
    String


type Anmeldung
    = Login LoginEingabe
    | Eingeloggt UserName


type alias LoginEingabe =
    { loginName : UserName
    , loginPasswort : String
    }


initLogin : Anmeldung
initLogin =
    Login (LoginEingabe "" "")


initEingeloggt : UserName -> Anmeldung
initEingeloggt userName =
    Eingeloggt userName


auswerten : (LoginEingabe -> a) -> (UserName -> a) -> Anmeldung -> a
auswerten wennLogin wennEingeloggt anmeldung =
    case anmeldung of
        Login login ->
            wennLogin login

        Eingeloggt name ->
            wennEingeloggt name


loginEingabe : Anmeldung -> Maybe LoginEingabe
loginEingabe =
    auswerten Just (always Nothing)


eingeloggterBenutzer : Anmeldung -> Maybe UserName
eingeloggterBenutzer =
    auswerten (always Nothing) Just


loginNameSetzen : UserName -> Anmeldung -> Anmeldung
loginNameSetzen name anmeldung =
    anmeldung
        |> auswerten
            (\eingabe -> Login { eingabe | loginName = name })
            (always anmeldung)


loginPasswortSetzen : String -> Anmeldung -> Anmeldung
loginPasswortSetzen passwort anmeldung =
    anmeldung
        |> auswerten
            (\eingabe -> Login { eingabe | loginPasswort = passwort })
            (always anmeldung)
```

Main ändert sich dann so:

```elm 
type alias Model =
    { anmeldung : Anm.Anmeldung
    }

...

init : Model
init =
    { anmeldung = Anm.initLogin
    }


kannEinloggen : Anm.LoginEingabe -> Bool
...

update : Msg -> Model -> Model
update msg model =
    case msg of
        LoginNameGeändert name ->
            { model | anmeldung = Anm.loginNameSetzen name model.anmeldung }

        LoginPasswortGeändert passwort ->
            { model | anmeldung = Anm.loginPasswortSetzen passwort model.anmeldung }


view : Model -> Html Msg
view model =
    viewLayout
        { navbar = Anm.auswerten viewLogin viewEingeloggt model.anmeldung
        ...
        }


viewLogin : Anm.LoginEingabe -> List (Html Msg)
...

viewEingeloggt : UserName -> List (Html msg)
viewEingeloggt userName =
    [ H.span [ Attr.class "navbar-text" ] [ H.text "Hallo, ", H.strong [] [ H.text userName ] ]
    , H.form
        [ Attr.class "form-inline" ]
        [ BS.submit [] [ H.text "logout" ]
        ]
    ]

```

### Login/Logout

```elm
type Msg
    = LoginNameGeändert String
    | LoginPasswortGeändert String
    | Login
    | Logout

...

update : Msg -> Model -> Model
update msg model =
    case msg of
        LoginNameGeändert name ->
            { model | anmeldung = Anm.loginNameSetzen name model.anmeldung }

        LoginPasswortGeändert passwort ->
            { model | anmeldung = Anm.loginPasswortSetzen passwort model.anmeldung }

        Login ->
            Anm.loginEingabe model.anmeldung
                |> Maybe.map (\eingabe -> { model | anmeldung = Anm.initEingeloggt eingabe.loginName })
                |> Maybe.withDefault model

        Logout ->
            { model | anmeldung = Anm.initLogin }

...

    [ H.form [ Ev.onSubmit Login ]
```

> **aktueller Stand**

    git checkout Chat-3


---

## TEA - the next Level

Bisher wurde die Messages immer nur über Ereignisse aus der Ansicht ausgelöst
und außer dem Neuzeichnen kann Elm scheinbar auch keine Seiteneffekte auslösen.

Was aber, wenn Du jetzt eine Anfrage an den Server schicken willst (zum Beispiel einloggen)?

Elm erweitert hierfür die Architektur - es kommen *Kommandos* und *Subscriptions* hinzu.

### Kommandos
Wenn Du ein Kommando aus `init` oder `update` zurück gibst, wird die Runtime das Kommando
ausführen und danach das Ergebnis als Message zurück ans `update` schicken.

### Subscription
Damit kannst Du Interesse an Ereignissen außerhalb HTML bekunden - Du abonierst ein
entsprechendes `Sub` Objekt in `subscriptions` (wann Du das machen willst, kannst Du über Deinen
aktuellen Zustand bestimmen - hier findet also ein Refresh ähnlich Msg -> Update -> View statt)
und immer wenn ein externes Ereignis eintritt bekommst Du wieder eine Message für `update`

Dafür müssen wir zum `H.programm` wechseln:

```elm
main : Program Never Model Msg
main =
    H.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


init : ( Model, Cmd Msg )
init =
    ( { anmeldung = Anm.initLogin }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LoginNameGeändert name ->
            ( { model | anmeldung = Anm.loginNameSetzen name model.anmeldung }, Cmd.none )
        ...

subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
```

## Kommunikationmit dem Server (AJAX/JSON Decoder)

> Serveradresse für den Moment: https://yiherfva.cloud.dropstack.run/

wir brauchen ein zusätzliches Packet:

    elm package install elm-lang/http

### Logout / Login

```elm
import Http
import Json.Decode as Json
import Json.Encode as Enc


type BenutzerId
    = BenutzerId String


type alias BenutzerInfo =
    { id : BenutzerId
    , name : String
    , isOnline : Bool
    }


loginRequest : String -> String -> String -> Http.Request BenutzerId
loginRequest baseUrl name passwort =
    let
        loginBody =
            Enc.object
                [ ( "loginName", Enc.string name )
                , ( "loginPassword", Enc.string passwort )
                ]
    in
        Http.post
            (baseUrl ++ "/users/login")
            (Http.jsonBody loginBody)
            (Json.map BenutzerId Json.string)


logoutRequest : String -> BenutzerId -> Http.Request ()
logoutRequest baseUrl (BenutzerId id) =
    let
        logoutBody =
            Enc.object
                [ ( "userId", Enc.string id ) ]
    in
        Http.request
            { method = "POST"
            , headers = []
            , url = baseUrl ++ "/users/logout"
            , body = Http.jsonBody logoutBody
            , expect = Http.expectStringResponse (always <| Ok ())
            , timeout = Nothing
            , withCredentials = False
            }


benutzerInfoRequest : String -> BenutzerId -> Http.Request BenutzerInfo
benutzerInfoRequest baseUrl (BenutzerId id) =
    let
        userDecoder =
            Json.map2 (BenutzerInfo (BenutzerId id))
                (Json.field "username" Json.string)
                (Json.field "isonline" Json.bool)
    in
        Http.get (baseUrl ++ "/users/" ++ id) userDecoder
```

aus einem `Request a` kannst Du ein `Cmd msg` machen, wenn Du weißt, wie
Du aus einem `Result Http.Error a` ein `msg` machst:

```elm
-- Api.elm

logout : String -> (Result Http.Error () -> msg) -> BenutzerId -> Cmd msg
logout baseUrl inMsg benutzerId =
    logoutRequest baseUrl benutzerId
        |> Http.send inMsg

```        

Für das *Login* haben wir noch einen Schritt - erst bekommen wir vom
Server hoffentlich die Id und dann wollen wir gleich noch Infos abfragen.

Dafür benutzen wir `Task`s:

```elm
login : String -> (Result Http.Error BenutzerInfo -> msg) -> String -> String -> Cmd msg
login baseUrl inMsg name passwort =
    loginRequest baseUrl name passwort
        |> Http.toTask
        |> Task.andThen (benutzerInfoRequest baseUrl >> Http.toTask)
        |> Task.attempt inMsg
```

Am einfachsten gibst Du einen `Msg` Datenkonstruktor mit dem `Result` an:

```elm
-- Main.elm

type Msg
    = LoginNameGeändert String
    ...
    | LoginResult (Result Http.Error BenutzerInfo)
    | LogoutResult (Result Http.Error ())
```

außerdem brauchen wir einen optionalen Fehler im Model:

```elm
type alias Model =
    { anmeldung : Anm.Anmeldung
    , fehler : Maybe String
    }
```

Update ändert sich auf:

```elm
        LoginResult (Ok benutzer) ->
            ( { model | fehler = Nothing }, Cmd.none )

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
```

und wir sollten den Fehler eventuell anzeigen lassen:

```elm
viewError : Maybe String -> Html Msg
viewError err =
    case err of
        Nothing ->
            H.text ""

        Just text ->
            H.div
                [ Attr.class "alert alert-danger", Attr.attribute "role" "alert", Ev.onClick DismissError ]
                [ H.p [] [ H.strong [] [ H.text "error: " ], H.text text ] ]
```

Wo aber jetzt die Benutzerinfo speichern, und wo herbekommen? ~> wie in der Anmeldung!

> aktueller Stand

    git checkout Chat-4

## Messages abrufen

Bespielnachrichten sind in [Mesasges.json](./ChatApp/Messages.json)

```elm
-- Api.elm

type alias MessageId =
    Int


type alias Message =
    { messageId : MessageId
    , time : Date
    , body : MessageBody
    }


type alias ChatNachricht =
    { sender : String
    , isPrivate : Bool
    , htmlBody : String
    , textBody : String
    }


type alias SystemNachricht =
    { htmlBody : String
    }


type MessageBody
    = Nachricht ChatNachricht
    | System SystemNachricht
```    

der Dekoder:

```elm
messageDecoder : Json.Decoder Message
messageDecoder =
    let
        decodeDate =
            Json.string
                |> Json.andThen
                    (\dateStr ->
                        case Date.fromString dateStr of
                            Ok date ->
                                Json.succeed date

                            Err err ->
                                Json.fail err
                    )

        decodeData =
            Json.oneOf
                [ Json.map
                    SystemNachricht
                    (Json.field "_sysBody" Json.string)
                    |> Json.map System
                , Json.map4
                    ChatNachricht
                    (Json.field "_msgSender" Json.string)
                    (Json.field "_msgPrivate" Json.bool)
                    (Json.field "_msgHtmlBody" Json.string)
                    (Json.field "_msgText" Json.string)
                    |> Json.map Chat
                ]
    in
        Json.map3 Message
            (Json.field "_msgId" Json.int)
            (Json.field "_msgTime" decodeDate)
            (Json.field "_msgData" decodeData)
```

der Request:

```elm
getMessagesRequest : String -> Maybe BenutzerId -> Maybe Int -> Http.Request (List Message)
getMessagesRequest baseUrl userOpt fromMsgNo =
    let
        query =
            Maybe.map (\no -> "?fromid=" ++ toString no) fromMsgNo
                |> Maybe.withDefault ""

        uri =
            case userOpt of
                Just (BenutzerId id) ->
                    baseUrl ++ "/messages/" ++ id ++ query

                Nothing ->
                    baseUrl ++ "/messages/public" ++ query
    in
        Http.get uri (Json.list messageDecoder)
```

### Nachrichten im Zustand

die Nachrichten schreiben wir in ein `Dict`ionary:

```elm
    , nachrichten : Dict MessageId Message
```

Update:

```elm
        NachrichtenResult (Ok msgs) ->
            let
                mapMsg msg =
                    ( msg.messageId, msg )

                neueNachrichten =
                    Dict.union (Dict.fromList <| List.map mapMsg msgs) model.nachrichten
            in
                ( { model | nachrichten = neueNachrichten }, Cmd.none )

        NachrichtenResult (Err err) ->
            ( { model
                | fehler = Just (toString err)
                , nachrichten = Dict.empty
              }
            , Cmd.none
            )
```

für die Anzeige brauchen wir `evancz/elm-markdown` weil wir raw-Html
*reinschmuggeln* müssen!

    elm package install evancz/markdown

> aktueller Stand

    git checkout Chat-5

## Subscriptions

Für die Anzeige der abgelaufenen Zeit brauchen wir die aktuelle.
Die bekommen wir aber nicht (wäre ja ein Seiteneffekt).

Wir könnten die über ein `Cmd` laden lassen, aber wir werden hier statt dessen
jede Sekunde eine Message über ein `Sub` erzeugen, das uns die Zeit liefert:

```elm
subscriptions : Model -> Sub Msg
subscriptions model =
    let
        clockSub =
            Time.every Time.second UpdateTime
    in
        clockSub
```

was folgende Änderungen benötigt:

```elm
type alias Model =
    { anmeldung : Anm.Anmeldung BenutzerInfo
    , fehler : Maybe String
    , nachrichten : Dict MessageId Message
    , aktuelleZeit : Maybe Time
    }


type Msg
    = LoginNameGeändert String
    ...
    | UpdateTime Time


init : ( Model, Cmd Msg )
init =
    ( { anmeldung = Anm.initLogin
      , fehler = Nothing
      , nachrichten = Dict.empty
      , aktuelleZeit = Nothing
      }
    , Api.getNachrichten baseUrl NachrichtenResult Nothing Nothing
    )

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateTime now ->
            ( { model | aktuelleZeit = Just now }, Cmd.none )


view : Model -> Html Msg
view model =
    viewLayout
        { navbar = Anm.auswerten viewLogin viewEingeloggt model.anmeldung
        , toolbar = [ H.text "hier wird die Toolbar sein" ]
        , body =
            (viewError model.fehler
                :: (model.anmeldung
                        |> Anm.auswerten
                            (always <| viewMessages Nothing model.aktuelleZeit model.nachrichten)
                            (\info -> viewMessages (Just info.name) model.aktuelleZeit model.nachrichten)
                   )
            )
        }
    
```

### Websockets

Der Chat-Server bietet eine Websocketverbindung an um Nachrichten direkt auf die
Clients zu verteilen.

Um das zu benutzen brauchen wir zunächst ein weiteres Package:

    elm package install elm-lang/websocket

mit dieser Vorbereitung können wir eine Subscription einrichten:

```elm
-- Api.elm
import WebSocket as WS

webSocketSubscription : String -> (Result String Message -> msg) -> Maybe BenutzerId -> Sub msg
webSocketSubscription baseUrl inMsg userOpt =
    let
        decode =
            Json.decodeString messageDecoder >> inMsg
    in
        case userOpt of
            Just (BenutzerId id) ->
                WS.listen (baseUrl ++ "/messages/stream/" ++ id) decode

            Nothing ->
                WS.listen (baseUrl ++ "/messages/stream/public") decode

```

Dabei ist zu beachten, dass die Subscription grundsätzlich `String` liefert,
der Server verschickt die Nachrichten aber in *JSON* (in der Tat die gleichen)
Objekte, die auch `getNachrichten` verwendet.

Deshalb wird hier `Json.decodeString` genutzt um die Nachricht zu dekodieren.

Damit können wir die Subscription jetzt automatisch mit verbinden:

```elm
subscriptions : Model -> Sub Msg
subscriptions model =
    let
        clockSub =
            Time.every Time.second UpdateTime

        inMsg =
            Result.map List.singleton
                >> Result.mapError (always Http.NetworkError)
                >> NachrichtenResult

        webSub =
            model.anmeldung
                |> Anm.auswerten
                    (always <| Api.webSocketSubscription wsUrl inMsg Nothing)
                    (\info -> Api.webSocketSubscription wsUrl inMsg (Just info.id))
    in
        Sub.batch [ clockSub, webSub ]
```

----

Bisher fehlt noch jede Möglichkeit eine Nachricht zu verschicken ... das wird die nächste

> aktueller Stand

    git checkout Chat-6

## Übung
Implementiere das Verschicken von Nachrichten

Der Server erwartet hier einen `POST` auf `/messages` mit einem JSON-Body:

```json
{ 
    "_sendSender": "ID-von-Login",
    "_sendText": "Text der gesendet werden soll"
}
```

der Server wird nur einen 200-Status zurücksenden, deswegen solltest Du Dich
für den `Request` an `logoutRequest` orientieren.

Die Nachricht wird Dir über den Websocket gleich mit zurückgeschickt, d.h.
für das Anzeigen muss Du dich nicht kümmern.

Es bleibt nur die Eingabe in der `toolbar`

---

### Lösung

#### Nachricht senden

```elm
-- Api.elm

nachrichtSchicken : String -> (Result Http.Error () -> msg) -> BenutzerId -> String -> Cmd msg
nachrichtSchicken baseUrl inMsg senderId nachricht =
    postMessageRequest baseUrl senderId nachricht
        |> Http.send inMsg


postMessageRequest : String -> BenutzerId -> String -> Http.Request ()
postMessageRequest baseUrl (BenutzerId id) message =
    let
        msg =
            Enc.object
                [ ( "_sendSender", Enc.string id )
                , ( "_sendText", Enc.string message )
                ]
    in
        Http.request
            { method = "POST"
            , headers = []
            , url = baseUrl ++ "/messages"
            , body = Http.jsonBody msg
            , expect = Http.expectStringResponse (always <| Ok ())
            , timeout = Nothing
            , withCredentials = False
            }
```

#### Eingabe

```elm

type alias Model =
    { anmeldung : Anm.Anmeldung BenutzerInfo
    , fehler : Maybe String
    , nachrichten : Dict MessageId Message
    , aktuelleZeit : Maybe Time
    , nachrichtText : String
    , nachrichtTextFocused : Bool
    , nachrichtTextMouseOver : Bool
    }


init : ( Model, Cmd Msg )
init =
    ( { anmeldung = Anm.initLogin
      , fehler = Nothing
      , nachrichten = Dict.empty
      , aktuelleZeit = Nothing
      , nachrichtText = ""
      , nachrichtTextFocused = False
      , nachrichtTextMouseOver = False
      }
    , Api.getNachrichten baseUrl NachrichtenResult Nothing Nothing
    )


type Msg
    = LoginNameGeändert String
    ...
    | NachrichtSchicken
    | NachrichtSchickenResult (Result Http.Error ())
    | NachrichtTextGeändert String
    | NachrichtTextOver Bool
    | NachrichtTextFocus Bool


update ...
    case msg of
        ... 

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


view : Model -> Html Msg
view model =
    viewLayout
        { ...
        , toolbar = [ viewInput model ]
        , ...
        }


viewInput : Model -> Html Msg
viewInput model =
    let
        isDisabled =
            model.anmeldung
                |> Anm.auswerten (always True) (always False)

        textRows =
            if model.nachrichtTextFocused || model.nachrichtTextMouseOver then
                5
            else
                1
    in
        H.form
            (if isDisabled then
                [ Attr.class "w-100" ]
             else
                [ Attr.class "w-100", Ev.onSubmit NachrichtSchicken ]
            )
            [ BS.formRow []
                [ BS.col []
                    [ BS.textArea textRows
                        [ Attr.placeholder "Nachricht..."
                        , Attr.value model.nachrichtText
                        , Attr.disabled isDisabled
                        , Ev.onInput NachrichtTextGeändert
                        , Ev.onMouseOver (NachrichtTextOver True)
                        , Ev.onMouseOut (NachrichtTextOver False)
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
                        , Attr.disabled (isDisabled || model.nachrichtText == "")
                        ]
                        [ H.text "schicken" ]
                    ]
                ]
            ]            
``` 
> aktueller Stand

    git checkout Chat-7

---

## Bonus: Notifications mit Ports

```elm
port module Ports.Notifications exposing (..)


type alias Notification =
    { title : String
    , body : String
    }


port showNotification : Notification -> Cmd msg
```

in JS

```js
app.ports.showNotification.subscribe(function (notif) {
    // Let's check if the browser supports notifications
    if (!("Notification" in window)) {
        alert("This browser does not support desktop notification");
    }

    // Let's check whether notification permissions have alredy been granted
    else if (Notification.permission === "granted") {
        // If it's okay let's create a notification
        var notification = new Notification(notif.title, { "body": notif.body });
    }

    // Otherwise, we need to ask the user for permission
    else if (Notification.permission !== 'denied') {
        Notification.requestPermission(function (permission) {
            // If the user accepts, let's create a notification
            if (permission === "granted") {
                var notification = new Notification(notif.title, { "body": notif.body });

            }
        });
    }
});
```
> aktueller Stand

    git checkout Chat-8