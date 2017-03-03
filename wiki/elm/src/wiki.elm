port module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (placeholder, autofocus, target, href, class, id)
import Html.Events exposing (..)
import Http
import Json.Decode exposing (list, string, Decoder)
import Json.Decode.Pipeline exposing (decode, required, requiredAt)


main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


port openWindow : String -> Cmd msg



--MODEL


type alias Model =
    { query : String
    , results : WikiResults
    , error : Maybe String
    }


type alias WikiResults =
    { titles : List String
    , descriptions : List String
    , links : List String
    }


init : ( Model, Cmd Msg )
init =
    ( Model "" (WikiResults [] [] []) Nothing, Cmd.none )



--UPDATE


type Msg
    = NewQuery String
    | SendQuery
    | GetWiki (Result Http.Error WikiResults)
    | OpenRandom


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NewQuery query ->
            ( { model | query = query }, Cmd.none )

        SendQuery ->
            ( model, getFromWiki model.query )

        GetWiki (Err e) ->
            ( { model | error = Just (toString e) }, Cmd.none )

        GetWiki (Ok results) ->
            ( { model | results = results }, Cmd.none )

        OpenRandom ->
            ( model, openWindow "https://en.wikipedia.org/wiki/Special:Random" )


getFromWiki : String -> Cmd Msg
getFromWiki query =
    case query of
        "" ->
            Cmd.none

        _ ->
            let
                url =
                    "https://en.wikipedia.org/w/api.php?"
                        ++ "action=opensearch&format=json&origin=*&search="
                        ++ query
            in
                Http.send GetWiki <| get url decodeWiki


get : String -> Decoder WikiResults -> Http.Request WikiResults
get url decoder =
    Http.request
        { method = "GET"
        , headers = []
        , url = url
        , body = Http.emptyBody
        , expect = Http.expectJson (decoder)
        , timeout = Nothing
        , withCredentials = False
        }


decodeWiki : Decoder WikiResults
decodeWiki =
    decode WikiResults
        |> requiredAt [ "1" ] (list string)
        |> requiredAt [ "2" ] (list string)
        |> requiredAt [ "3" ] (list string)



--VIEW


view : Model -> Html Msg
view model =
    div [ id "container" ]
        [ div [ id "search" ]
            [ Html.form [ id "query", onSubmit SendQuery ]
                [ input [ onInput NewQuery, placeholder "Search!", autofocus True ] []
                , div [ id "buttons" ]
                    [ button [ id "search-btn" ] [ text "Search" ]
                    , button
                        [ id "random-btn"
                        , onWithOptions "click" (Options True True) (Json.Decode.succeed OpenRandom)
                        ]
                        [ text "Random" ]
                    ]
                ]
            ]
        , div [ id "results" ] (List.map viewResult (zipResults model.results))
        ]


viewResult : ( String, String, String ) -> Html Msg
viewResult result =
    let
        ( title, description, link ) =
            result
    in
        div [ class "result" ]
            [ a
                [ target "_blank"
                , href link
                ]
                [ h3 [] [ text title ]
                , p [] [ text description ]
                ]
            ]


zipResults : WikiResults -> List ( String, String, String )
zipResults results =
    List.map3 (,,) results.titles results.descriptions results.links



--SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
