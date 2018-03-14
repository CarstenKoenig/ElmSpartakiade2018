module Bootstrap exposing (..)

import Html as H exposing (Html, Attribute)
import Html.Attributes as Attr


input : List (Attribute msg) -> List (Html msg) -> Html msg
input attrs children =
    H.input
        (Attr.class "form-control mb-2" :: attrs)
        children


textInput : List (Attribute msg) -> List (Html msg) -> Html msg
textInput attrs children =
    input
        (Attr.type_ "text" :: attrs)
        []


passwordInput : List (Attribute msg) -> List (Html msg) -> Html msg
passwordInput attrs children =
    input
        (Attr.type_ "password" :: attrs)
        []


button : String -> List (Attribute msg) -> List (Html msg) -> Html msg
button btnClass attrs children =
    H.button
        (Attr.class ("btn " ++ btnClass) :: attrs)
        children


submit : List (Attribute msg) -> List (Html msg) -> Html msg
submit attrs children =
    button
        "btn-outline-success mb-2"
        (Attr.type_ "submit" :: attrs)
        children


col : List (Attribute msg) -> List (Html msg) -> Html msg
col attrs children =
    H.div
        (Attr.class "col" :: attrs)
        children


colMd : Int -> List (Attribute msg) -> List (Html msg) -> Html msg
colMd size attrs children =
    H.div
        (Attr.class ("col-md-" ++ toString size) :: attrs)
        children


colAuto : List (Attribute msg) -> List (Html msg) -> Html msg
colAuto attrs children =
    H.div
        (Attr.class "col-auto" :: attrs)
        children


formRow : List (Attribute msg) -> List (Html msg) -> Html msg
formRow attrs children =
    H.div
        (Attr.class "form-row align-items-center" :: attrs)
        children


card : String -> List (Attribute msg) -> List (Html msg) -> List (Html msg) -> Html msg
card classes attrs header body =
    H.div
        (Attr.class ("card " ++ classes) :: attrs)
        [ H.div
            [ Attr.class "card-header" ]
            header
        , H.div
            [ Attr.class "card-body" ]
            body
        ]
