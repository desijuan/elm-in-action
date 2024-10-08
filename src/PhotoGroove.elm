module PhotoGroove exposing (main)

import Array exposing (Array)
import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Random

type ThumbnailSize
    = Small
    | Medium
    | Large

type Msg
    = ClickedPhoto String
    | GotSelectedIndex Int
    | ClickedSize ThumbnailSize
    | ClickedSurpriseMe

type alias Photo = { url : String }

type alias Model =
    { photos : List Photo
    , selectedUrl : String
    , chosenSize : ThumbnailSize
    }

urlPrefix : String
urlPrefix =
    "http://elm-in-action.com/"

view : Model -> Html Msg
view model =
    div [ class "content" ]
        [ h1 [] [ text "Photo Groove" ]
        , button
            [ onClick ClickedSurpriseMe ]
            [ text "surprise me!"]
        , h3 [] [ text "Thumbnail Size:" ]
        , div [ id "choose-size" ]
            (List.map (viewSizeChooser model.chosenSize) [ Small, Medium, Large ])
        , div [ id "thumbnails", class (sizeToClass model.chosenSize) ]
            (List.map (viewThumbnail model.selectedUrl) model.photos)
        , img
            [ class "large"
            , src (urlPrefix ++ "large/" ++ model.selectedUrl )
            ]
            []
        ]

viewThumbnail : String -> Photo -> Html Msg
viewThumbnail selectedUrl thumb =
        img
            [ src (urlPrefix ++ thumb.url)
            , classList [ ( "selected", selectedUrl == thumb.url ) ]
            , onClick (ClickedPhoto thumb.url)
            ]
            []

viewSizeChooser : ThumbnailSize -> ThumbnailSize -> Html Msg
viewSizeChooser chosenSize size =
    label []
        [ input
            [ type_ "radio"
            , name "size"
            , checked (size == chosenSize)
            , onClick (ClickedSize size)
            ]
            []
        , text (sizeToLabel size)
        ]

sizeToLabel : ThumbnailSize -> String
sizeToLabel size =
    case size of
        Small -> "small"
        Medium -> "medium"
        Large -> "large"

sizeToClass : ThumbnailSize -> String
sizeToClass size =
    case size of
        Small -> "small"
        Medium -> "med"
        Large -> "large"

initialModel : Model
initialModel =
    { photos =
        [ { url = "1.jpeg" }
        , { url = "2.jpeg" }
        , { url = "3.jpeg" }
        ]
    , selectedUrl = "1.jpeg"
    , chosenSize = Medium
    }

photoArray : Array Photo
photoArray =
    Array.fromList initialModel.photos

getPhotoUrl : Int -> String
getPhotoUrl index =
    case Array.get index photoArray of
        Just photo -> photo.url
        Nothing -> ""

randomPhotoPicker : Random.Generator Int
randomPhotoPicker =
    Random.int 0 (Array.length photoArray - 1)

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotSelectedIndex index ->
            ( { model | selectedUrl = getPhotoUrl index }, Cmd.none )

        ClickedPhoto url ->
            ( { model | selectedUrl = url }, Cmd.none )

        ClickedSize size ->
            ( { model | chosenSize = size }, Cmd.none )

        ClickedSurpriseMe ->
            ( model , Random.generate GotSelectedIndex randomPhotoPicker )

main : Program () Model Msg
main =
    Browser.element
        { init = \flags -> ( initialModel, Cmd.none )
        , view = view
        , update = update
        , subscriptions = \model -> Sub.none
        }
