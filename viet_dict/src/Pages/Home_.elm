module Pages.Home_ exposing (Model, Msg, page)

import Effect exposing (Effect)
import Html
import Html.Events exposing (onInput)
import Http
import Json.Decode
import Page exposing (Page)
import Route exposing (Route)
import Shared
import String exposing (words)
import Url exposing (Protocol(..))
import View exposing (View)


page : Shared.Model -> Route () -> Page Model Msg
page _ _ =
    Page.new
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- API


type ApiData a
    = Loading
    | Failure String
    | Success a


type alias Words =
    List Word


type alias Word =
    { id : String
    , unicode : String
    , freq : Int
    , han : String
    , quoc_ngu : String
    , english : String
    }


wordsDecoder : Json.Decode.Decoder Words
wordsDecoder =
    Json.Decode.list wordDecoder


wordDecoder : Json.Decode.Decoder Word
wordDecoder =
    Json.Decode.map6 Word
        (Json.Decode.field "id" Json.Decode.string)
        (Json.Decode.field "unicode" Json.Decode.string)
        (Json.Decode.field "freq" Json.Decode.int)
        (Json.Decode.field "han" Json.Decode.string)
        (Json.Decode.field "quoc_ngu" Json.Decode.string)
        (Json.Decode.field "english" Json.Decode.string)


getWords : Effect Msg
getWords =
    Http.get
        { url = "http://localhost:3000/words"
        , expect = Http.expectJson GotWords wordsDecoder
        }
        |> Effect.sendCmd


searchWord : String -> Effect Msg
searchWord word =
    Http.get
        { url = "http://localhost:3000/words?quoc_ngu=" ++ word
        , expect = Http.expectJson GotWords wordsDecoder
        }
        |> Effect.sendCmd



-- INIT


type alias Model =
    { words : Words
    , searchString : String
    , receivedWords : ApiData Words
    }


init : () -> ( Model, Effect Msg )
init () =
    ( { words = []
      , searchString = ""
      , receivedWords = Loading
      }
    , getWords
    )



-- UPDATE


type Msg
    = GotWords (Result Http.Error Words)
    | Change String


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        GotWords (Ok words) ->
            ( { model | receivedWords = Success words }
            , Effect.none
            )

        GotWords (Err err) ->
            ( { model | receivedWords = Failure "Error" }
            , Effect.none
            )

        Change string ->
            let
                newWords =
                    case model.receivedWords of
                        Success wordList ->
                            List.filter (\word -> String.contains string word.quoc_ngu) wordList

                        Loading ->
                            []

                        Failure err ->
                            []
            in
            ( { model | searchString = string, words = newWords }
            , Effect.none
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> View Msg
view model =
    { title = "Pages.Home_"
    , body =
        [ Html.div []
            [ Html.input [ onInput Change ] [] ]
        , if String.isEmpty model.searchString then
            Html.text ""

          else
            showWords model
        ]
    }


showWord : Word -> Html.Html msg
showWord word =
    tableRow
        [ Html.text word.han
        , Html.text word.quoc_ngu
        , Html.text word.english
        ]


tableRow : List (Html.Html msg) -> Html.Html msg
tableRow items =
    Html.tr []
        (List.map (\item -> Html.td [] [ item ]) items)


showWords : Model -> Html.Html msg
showWords model =
    Html.table []
        (List.map showWord model.words)
