module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (style, placeholder)
import Html.Events exposing (onClick, onInput, onSubmit)
import Http
import Json.Decode exposing (float, string, Decoder)
import Json.Decode.Pipeline exposing (decode, required, hardcoded, requiredAt)
import Geolocation exposing (Location)
import Task
import Regex


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
    , error : Maybe String
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
            if model.city == "" || (String.toLower weather.name) == (String.toLower model.city) then
                ( { model | weather = Just weather, error = Nothing }, Cmd.none )
            else
                ( { model | error = Just ("Sorry, I don't recognize that place.\nDid you mean " ++ weather.name ++ "?") }, Cmd.none )

        GetWeather (Err e) ->
            ( { model | error = Just "Sorry, I can't detect where you are." }, Cmd.none )

        UpdateLocation (Ok location) ->
            ( { model | location = Just location }, pullWeatherFromLocation location )

        UpdateLocation (Err e) ->
            ( { model | error = Just "Sorry, I can't detect where you are." }, Cmd.none )

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
    case city of
        "" ->
            Cmd.none

        _ ->
            let
                url =
                    "http://api.openweathermap.org/data/2.5/weather"
                        ++ "?type=like&q="
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
            [ h3 [] [ text "Location" ]
            , (viewError model.error)
            , (viewLocation model.location model.city)
            , div []
                (viewWeather model.city model.weather)
            ]
        ]


viewError error =
    case error of
        Nothing ->
            p [] []

        Just error ->
            p [] [ text error ]


viewLocation location city =
    case location of
        Nothing ->
            cityForm ""

        Just location ->
            cityForm city


cityForm : String -> Html Msg
cityForm city =
    let
        place =
            if city == "" then
                "Where are you?"
            else
                city
    in
        form [ onSubmit GetCity ]
            [ input [ onInput NewCity, placeholder place ] [] ]


viewWeather : String -> Maybe Weather -> List (Html Msg)
viewWeather location weather =
    case weather of
        Just weather ->
            [ h3 [] [ text "Current Weather" ]
            , p [] [ text weather.name ]
            , p []
                [ text
                    ((toString (round (celsius weather.temp))) ++ " C")
                ]
            , p [] [ text weather.description ]
            ]

        Nothing ->
            []


celsius : Float -> Float
celsius temp =
    temp - 273



--SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
