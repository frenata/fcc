module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (style)
import Http
import Json.Decode exposing (float, string, Decoder)
import Json.Decode.Pipeline exposing (decode, required, hardcoded, requiredAt)


main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



--MODEL


type alias Model =
    { weather : Weather
    , error : Http.Error
    }


type alias Weather =
    { name : String, temp : Float, description : String }


init : ( Model, Cmd Msg )
init =
    ( Model (Weather "" 0 "") Http.Timeout, pullWeather )



--UPDATE


type Msg
    = GetWeather (Result Http.Error Weather)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GetWeather (Ok weather) ->
            ( { model | weather = weather }, Cmd.none )

        GetWeather (Err e) ->
            ( { model | error = e }, Cmd.none )


pullWeather : Cmd Msg
pullWeather =
    let
        url =
            "http://api.openweathermap.org/data/2.5/weather"
                ++ "?q=jakarta"
                ++ "&APPID=d27113dcf76a61aee27d2ce328629630"
    in
        Http.send GetWeather <| get url decodeWeather


get : String -> Decoder Weather -> Http.Request Weather
get url decoder =
    Http.request
        { method = "GET"
        , headers =
            []
        , url = url
        , body = Http.emptyBody
        , expect = Http.expectJson (decoder)
        , timeout = Nothing
        , withCredentials = False
        }


decodeWeather : Decoder Weather
decodeWeather =
    decode Weather
        |> required "name" string
        |> requiredAt [ "main", "temp" ] float
        |> requiredAt [ "weather", "0", "description" ] string


view : Model -> Html Msg
view model =
    div
        [ style
            [ ( "width", "85%" )
            , ( "text-align", "center" )
            , ( "display", "block" )
            , ( "margin", "auto" )
            ]
        ]
        [ p [] [ text model.weather.name ]
        , p [] [ text (toString model.weather.temp) ]
        , p [] [ text model.weather.description ]
        ]



--SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
