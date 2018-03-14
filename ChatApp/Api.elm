module Api
    exposing
        ( BenutzerId
        , BenutzerInfo
        , login
        , logout
        , MessageId
        , Message
        , MessageBody(..)
        , ChatNachricht
        , SystemNachricht
        , getNachrichten
        )

import Http
import Json.Decode as Json
import Json.Encode as Enc
import Task
import Date exposing (Date)


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
    = Chat ChatNachricht
    | System SystemNachricht


getNachrichten : String -> (Result Http.Error (List Message) -> msg) -> Maybe BenutzerId -> Maybe Int -> Cmd msg
getNachrichten baseUrl inMsg userOpt fromMsgNo =
    getMessagesRequest baseUrl userOpt fromMsgNo
        |> Http.send inMsg


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
