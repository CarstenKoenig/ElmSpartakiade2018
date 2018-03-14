module Api exposing (BenutzerId, BenutzerInfo, login, logout)

import Http
import Json.Decode as Json
import Json.Encode as Enc
import Task


type BenutzerId
    = BenutzerId String


type alias BenutzerInfo =
    { id : BenutzerId
    , name : String
    , isOnline : Bool
    }


login : String -> (Result Http.Error BenutzerInfo -> msg) -> String -> String -> Cmd msg
login baseUrl inMsg name passwort =
    loginRequest baseUrl name passwort
        |> Http.toTask
        |> Task.andThen (benutzerInfoRequest baseUrl >> Http.toTask)
        |> Task.attempt inMsg


logout : String -> (Result Http.Error () -> msg) -> BenutzerId -> Cmd msg
logout baseUrl inMsg benutzerId =
    logoutRequest baseUrl benutzerId
        |> Http.send inMsg


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
