module Anmeldung
    exposing
        ( UserName
        , Anmeldung
        , LoginEingabe
        , initLogin
        , initEingeloggt
        , auswerten
        , loginEingabe
        , getInfo
        , loginNameSetzen
        , loginPasswortSetzen
        )


type alias UserName =
    String


type Anmeldung info
    = Login LoginEingabe
    | Eingeloggt info


type alias LoginEingabe =
    { loginName : UserName
    , loginPasswort : String
    }


initLogin : Anmeldung info
initLogin =
    Login (LoginEingabe "" "")


initEingeloggt : info -> Anmeldung info
initEingeloggt info =
    Eingeloggt info


auswerten : (LoginEingabe -> a) -> (info -> a) -> Anmeldung info -> a
auswerten wennLogin wennEingeloggt anmeldung =
    case anmeldung of
        Login login ->
            wennLogin login

        Eingeloggt name ->
            wennEingeloggt name


loginEingabe : Anmeldung info -> Maybe LoginEingabe
loginEingabe =
    auswerten Just (always Nothing)


getInfo : Anmeldung info -> Maybe info
getInfo =
    auswerten (always Nothing) Just


loginNameSetzen : UserName -> Anmeldung info -> Anmeldung info
loginNameSetzen name anmeldung =
    anmeldung
        |> auswerten
            (\eingabe -> Login { eingabe | loginName = name })
            (always anmeldung)


loginPasswortSetzen : String -> Anmeldung info -> Anmeldung info
loginPasswortSetzen passwort anmeldung =
    anmeldung
        |> auswerten
            (\eingabe -> Login { eingabe | loginPasswort = passwort })
            (always anmeldung)
