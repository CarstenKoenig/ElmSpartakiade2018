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
