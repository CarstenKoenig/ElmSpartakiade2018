module Layout exposing (Items, Content, viewLayout)

import Html as H exposing (Html)
import Html.Attributes as Attr


type alias Items msg =
    List (Html msg)


type alias Content msg =
    { navbar : Items msg
    , toolbar : Items msg
    , body : Items msg
    }


viewLayout : Content msg -> Html msg
viewLayout content =
    let
        -- schaffe am Ende des Body-Content genug Platz für die Toolbar
        bottomSpace =
            H.div [ Attr.style [ ( "height", "75px" ) ] ] []
    in
        H.div
            []
            [ viewNavbar content.navbar
            , H.div
                [ Attr.class "container scrollable"
                ]
                (viewToolbar content.toolbar :: content.body ++ [ bottomSpace ])
            ]


viewNavbar : Items msg -> Html msg
viewNavbar content =
    H.nav
        [ Attr.class "navbar navbar-light bg-light sticky-top justify-content-between" ]
        ([ H.a
            [ Attr.class "navbar-brand", Attr.href "#" ]
            [ H.text "λ Chat" ]
         ]
            ++ content
        )


viewToolbar : Items msg -> Html msg
viewToolbar content =
    H.nav
        [ Attr.class "navbar navbar-light bg-light fixed-bottom justify-content-between" ]
        content
