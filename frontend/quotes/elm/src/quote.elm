module Main exposing (..)

import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Http
import Json.Decode as Decode


main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



--MODEL


type alias Model =
    { quote : String
    , author : String
    , error : Http.Error
    }


type alias Quote =
    { quote : String, author : String }


init : ( Model, Cmd Msg )
init =
    ( Model "Shit happens" "Anon" Http.Timeout, pullNewQuote )



--UPDATE


type Msg
    = GetQuote
    | NewQuote (Result Http.Error Quote)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GetQuote ->
            ( model, pullNewQuote )

        NewQuote (Ok data) ->
            ( { model
                | quote = data.quote
                , author = data.author
              }
            , Cmd.none
            )

        NewQuote (Err e) ->
            ( { model | error = e }, Cmd.none )


pullNewQuote : Cmd Msg
pullNewQuote =
    let
        url =
            "https://andruxnet-random-famous-quotes"
                ++ ".p.mashape.com/?cat=movies"
    in
        Http.send NewQuote <| get url decodeQuote


get : String -> Decode.Decoder Quote -> Http.Request Quote
get url decoder =
    Http.request
        { method = "GET"
        , headers =
            [ Http.header "X-Mashape-Authorization"
                "qKPbfOzWKemsh2qi30QgbOA1WufXp1ok1NsjsnAkvh6yVJfaAk"
            ]
        , url = url
        , body = Http.emptyBody
        , expect = Http.expectJson (decoder)
        , timeout = Nothing
        , withCredentials = False
        }


decodeQuote : Decode.Decoder Quote
decodeQuote =
    Decode.map2 Quote
        (Decode.at [ "quote" ] Decode.string)
        (Decode.at [ "author" ] Decode.string)



--VIEW


view : Model -> Html Msg
view model =
    div []
        [ div [ style [ ( "width", "85%" ) ] ]
            [ blockquote [] [ text model.quote ]
            , Html.cite
                [ style
                    [ ( "display", "block" )
                    , ( "text-align", "right" )
                    ]
                ]
                [ text ("- " ++ model.author) ]
            ]
        , div
            [ style
                [ ( "width", "85%" )
                , ( "text-align", "center" )
                ]
            ]
            [ a
                [ href "#"
                , onClick GetQuote
                ]
                [ text "New Quote!" ]
            , a
                [ target "_blank"
                , href
                    ("https://twitter.com/share?text="
                        ++ model.quote
                        ++ " -"
                        ++ model.author
                    )
                ]
                [ text "Tweet!" ]
            ]
        ]



--SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
