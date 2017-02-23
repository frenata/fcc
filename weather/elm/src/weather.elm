module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (style, placeholder)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode exposing (float, string, Decoder)
import Json.Decode.Pipeline exposing (decode, required, hardcoded, requiredAt)
import Geolocation exposing (Location)
import Task


main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



--MODEL


type alias Model =
    { weather : Maybe Weather
    , location : Maybe Location
    , city : String
    , error : Maybe Http.Error
    }


type alias Weather =
    { name : String, temp : Float, description : String }


init : ( Model, Cmd Msg )
init =
    ( Model Nothing Nothing "" Nothing, getLocation )



--UPDATE


type Msg
    = GetWeather (Result Http.Error Weather)
    | UpdateLocation (Result Geolocation.Error Location)
    | NewCity String
    | GetCity


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GetWeather (Ok weather) ->
            ( { model | weather = Just weather, error = Nothing }, Cmd.none )

        GetWeather (Err e) ->
            ( { model | error = Just e }, Cmd.none )

        UpdateLocation (Ok location) ->
            ( { model | location = Just location }, pullWeatherFromLocation location )

        UpdateLocation (Err e) ->
            ( model, Cmd.none )

        NewCity city ->
            ( { model | city = city }, Cmd.none )

        GetCity ->
            ( model, pullWeatherFromCity model.city )



--WEATHER functions


pullWeatherFromLocation : Location -> Cmd Msg
pullWeatherFromLocation location =
    let
        url =
            "http://api.openweathermap.org/data/2.5/weather"
                ++ "?lat="
                ++ toString location.latitude
                ++ "&lon="
                ++ toString location.longitude
                ++ "&APPID=d27113dcf76a61aee27d2ce328629630"
    in
        Http.send GetWeather <| get url decodeWeather


pullWeatherFromCity : String -> Cmd Msg
pullWeatherFromCity city =
    let
        url =
            "http://api.openweathermap.org/data/2.5/weather"
                ++ "?q="
                ++ city
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



--LOCATION functions


getLocation : Cmd Msg
getLocation =
    Task.attempt UpdateLocation Geolocation.now



--VIEW


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
        [ div []
            (viewLocation model.location)
        , div []
            (viewWeather model.city model.weather)
        ]


viewLocation : Maybe Location -> List (Html Msg)
viewLocation location =
    case location of
        Nothing ->
            [ h3 [] [ text "Location Blocked" ]
            , p [] [ text "Sorry, I don't know where you are..." ]
            , input [ onInput NewCity, placeholder "Try your City" ] []
            , button [ onClick GetCity ] [ text "Submit" ]
            ]

        Just location ->
            [ h3 [] [ text "Your Location" ]
            , p [] [ text (toString location.latitude) ]
            , p [] [ text (toString location.longitude) ]
            ]


viewWeather : String -> Maybe Weather -> List (Html msg)
viewWeather location weather =
    case weather of
        Just weather ->
            [ h3 [] [ text "Current Weather" ]
            , p [] [ text weather.name ]
            , p [] [ text (toString weather.temp) ]
            , p [] [ text weather.description ]
            ]

        Nothing ->
            []



--SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
