port module Main exposing (Model, Msg(..), fromElm, fromElmWithInteger, fromJavaScript, main, subscriptions, update, view)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Json.Decode as Decode exposing (Decoder, Value, bool, int, list, string)
import Json.Decode.Pipeline exposing (optional, required)
import Json.Encode as Encode
import String
import Task


main : Program () Model Msg
main =
    Browser.element
        { init = \() -> init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- SUBSCRIPTIONS


port fromElmWithInteger : Encode.Value -> Cmd msg


port fromElmWithData : Encode.Value -> Cmd msg


port fromElm : () -> Cmd msg


port fromJavaScript : (Int -> msg) -> Sub msg

port echoDataFromJavaScript: (SomeData -> msg) -> Sub msg

subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch [
        fromJavaScript ReceiveIntegerFromJavaScript,
        echoDataFromJavaScript ReceiveSomeDataFromJavaScript
    ]



-- MODEL


type alias SomeData =
    { name : String
    , age : Int
    }


type alias Model =
    { number : Int }


someDataDecoder : Decoder SomeData
someDataDecoder =
    Decode.succeed SomeData
        |> required "name" string
        |> required "age" int


someDataEncoder : SomeData -> Encode.Value
someDataEncoder data =
    Encode.object
        [ ( "name", Encode.string data.name )
        , ( "age", Encode.int data.age )
        ]


testData : SomeData
testData =
    { name = "ciccio", age = 33 }


-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ button [ style "border" "none", style "color" "white", style "background-color" "#4CAF50", style "width" "100px", onClick (SendDataToJavaScript testData) ] [ text "Send JSON" ]
        , br [] []
        , button [ style "border" "none", style "color" "white", style "background-color" "#4CAF50", style "width" "100px", onClick RequestIntegerFromJavaScript ] [ text "Gen Random" ]
        , br [] []
        , button [ style "border" "none", style "color" "white", style "background-color" "#4CAF50", style "width" "100px", onClick (SendIntegerToJavaScript model.number) ] [ text "Double" ]
        , p [] []
        , text (String.fromInt model.number)
        ]



-- UPDATE


type Msg
    = ReceiveIntegerFromJavaScript Int
    | ReceiveSomeDataFromJavaScript SomeData
    | RequestIntegerFromJavaScript
    | SendIntegerToJavaScript Int
    | SendDataToJavaScript SomeData


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case Debug.log "ELM: " msg of
        ReceiveIntegerFromJavaScript x ->
            ( {model | number = x}, Cmd.none )

        RequestIntegerFromJavaScript ->
            ( model, fromElm () )

        SendIntegerToJavaScript data ->
            ( model, fromElmWithInteger (Encode.int data) )

        SendDataToJavaScript data ->
            ( model, fromElmWithData (someDataEncoder data) )

        ReceiveSomeDataFromJavaScript data ->
            ( model, Cmd.none )



-- INIT


init : ( Model, Cmd Msg )
init =
    {- Send a message through port upon initialization. -}
    ( Model 0, Cmd.none )
