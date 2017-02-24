module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (placeholder, class, type_, name, checked, id, style, autofocus)
import Html.Events exposing (onClick, onInput, onSubmit)
import Http
import Json.Decode exposing (float, string, int, Decoder)
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
    , degrees : Degrees
    , error : Maybe String
    }


type Degrees
    = Celsius
    | Farenheit


type alias Weather =
    { city : String, temp : Float, main : String, description : String, id : Int }


init : ( Model, Cmd Msg )
init =
    ( { weather = Nothing
      , location = Nothing
      , city = ""
      , degrees = Celsius
      , error = Nothing
      }
    , getLocation
    )



--UPDATE


type Msg
    = GetWeather (Result Http.Error Weather)
    | UpdateLocation (Result Geolocation.Error Location)
    | NewCity String
    | GetCity
    | SwitchDegrees Degrees


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GetWeather (Ok weather) ->
            if model.city == "" || (String.toLower weather.city) == (String.toLower model.city) then
                ( { model | weather = Just weather, error = Nothing }, Cmd.none )
            else
                ( { model | error = Just ("Sorry, I don't recognize that place.\nDid you mean " ++ weather.city ++ "?") }, Cmd.none )

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

        SwitchDegrees degrees ->
            ( { model | degrees = degrees }, Cmd.none )



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
        |> requiredAt [ "weather", "0", "main" ] string
        |> requiredAt [ "weather", "0", "description" ] string
        |> requiredAt [ "weather", "0", "id" ] int



--LOCATION functions


getLocation : Cmd Msg
getLocation =
    Task.attempt UpdateLocation Geolocation.now



--VIEW


view : Model -> Html Msg
view model =
    div
        [ id "app"
        , style [ ( "background-color", bgColor model.weather ) ]
        ]
        [ (viewWeather model.city model.weather model.degrees)
        , (viewLocation model.location model.city model.error)
        ]


bgColor weather =
    case weather of
        Nothing ->
            ""

        Just weather ->
            case weather.main of
                "Thunderstorm" ->
                    "#f4ea7a"

                "Drizzle" ->
                    "#bac8ef"

                "Rain" ->
                    "#819eef"

                "Snow" ->
                    "#efd7ee"

                "Atmosphere" ->
                    "#7c7678"

                "Clear" ->
                    "#a0d8a3"

                "Clouds" ->
                    "#e3e5b7"

                "Extreme" ->
                    "#f77851"

                "Haze" ->
                    "#827487"

                _ ->
                    ""


viewLocation : Maybe Location -> String -> Maybe String -> Html Msg
viewLocation location city error =
    div
        [ id "settings" ]
        [ h3 [] [ text "Settings" ]
        , (viewError error)
        , (viewCity location city)
        , viewDegreesForm
        ]


viewError : Maybe String -> Html Msg
viewError error =
    case error of
        Nothing ->
            p [] []

        Just error ->
            p [] [ text error ]


viewCity : Maybe Location -> String -> Html Msg
viewCity location city =
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
            [ input [ onInput NewCity, placeholder place, autofocus True ] [] ]


viewDegreesForm : Html Msg
viewDegreesForm =
    fieldset []
        [ label []
            [ input
                [ name "degrees"
                , type_ "radio"
                , checked True
                , onClick (SwitchDegrees Celsius)
                ]
                []
            , text "Celsius"
            ]
        , label []
            [ input
                [ name "degrees"
                , type_ "radio"
                , onClick (SwitchDegrees Farenheit)
                ]
                []
            , text "Farenheit"
            ]
        ]


viewWeather : String -> Maybe Weather -> Degrees -> Html Msg
viewWeather location weather degrees =
    case weather of
        Just weather ->
            div
                [ id "weather" ]
                [ h3 [] [ text "Weather" ]
                , p [] [ text weather.city ]
                , (displayTemp weather.temp degrees)
                , p []
                    [ i [ class ("wi wi-owm-" ++ (toString weather.id)) ] []
                    , text (" " ++ weather.description)
                    ]
                ]

        Nothing ->
            div [ id "weather" ] []


displayTemp : Float -> Degrees -> Html Msg
displayTemp kelvin degrees =
    let
        ( temp, letter ) =
            case degrees of
                Celsius ->
                    ( kelvin - 273, " °C" )

                Farenheit ->
                    ( 1.8 * (kelvin - 273) + 32, " °F" )
    in
        p [] [ text (toString (round (temp)) ++ letter) ]



--SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
