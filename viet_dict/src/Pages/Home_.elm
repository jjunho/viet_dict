module Pages.Home_ exposing (Model, Msg, page)

import Browser.Dom exposing (Element)
import Effect exposing (Effect)
import Element exposing (Element, centerX, column, el, fill, maximum, spacing, width)
import Element.Input
import Http
import Json.Decode
import Page exposing (Page, element)
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
    { han : String
    , quoc_ngu : String
    , english : String
    }


wordsDecoder : Json.Decode.Decoder Words
wordsDecoder =
    Json.Decode.list wordDecoder


wordDecoder : Json.Decode.Decoder Word
wordDecoder =
    Json.Decode.map3 Word
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
            ( { model | receivedWords = Success <| unique words }
            , Effect.none
            )

        GotWords (Err _) ->
            ( { model | receivedWords = Failure "Error" }
            , Effect.none
            )

        Change string ->
            let
                newWords =
                    case model.receivedWords of
                        Success wordList ->
                            List.filter (\word -> String.contains string word.quoc_ngu) wordList
                                ++ List.filter (\word -> String.contains string word.han) wordList
                                |> unique

                        Loading ->
                            []

                        Failure _ ->
                            []
            in
            ( { model | searchString = string, words = newWords }
            , Effect.none
            )


unique : List a -> List a
unique l =
    let
        incUnique : a -> List a -> List a
        incUnique elem lst =
            if List.member elem lst then
                lst

            else
                elem :: lst
    in
    List.foldr incUnique [] l



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> View Msg
view model =
    { title = "Chu Nom"
    , attributes = [] --Element.explain Debug.todo ]
    , element = element model
    }


element : Model -> Element Msg
element model =
    let
        title =
            column [ width fill, spacing 20 ]
                [ el [ centerX ]
                    (Element.text "Từ điển chữ Nôm (dựa trên danh sách từ của ChuNom.org)")
                , el [ centerX ]
                    (Element.text "詞典𡦂喃(豫𨕭名册詞𧵑ChuNom.org)")
                ]

        textInputOptions m =
            { onChange = Change
            , text = m.searchString
            , placeholder = Just (Element.Input.placeholder [] (Element.text "Chữ Quốc ngữ hoặc Chữ Nôm 𡦂國語或𡦂喃"))
            , label = Element.Input.labelLeft [] (Element.text "Tìm kiếm 尋劍:")
            }

        textInput m =
            Element.Input.text [ spacing 40, width (fill |> maximum 1000), centerX ] (textInputOptions m)

        results m =
            let
                showWords m_ =
                    Element.table [ width (fill |> maximum 1000), centerX ] (tableOptions m_)

                tableOptions m_ =
                    { data = m_.words
                    , columns =
                        [ { header = Element.text "Chữ Nôm"
                          , width = fill
                          , view = \word -> Element.text word.han
                          }
                        , { header = Element.text "Chữ Quốc ngữ"
                          , width = fill
                          , view = \word -> Element.text word.quoc_ngu
                          }
                        , { header = Element.text "English"
                          , width = fill
                          , view = \word -> Element.text word.english
                          }
                        ]
                    }
            in
            if String.isEmpty m.searchString then
                Element.none

            else
                showWords m
    in
    column [ width fill, spacing 20 ]
        [ title
        , textInput model
        , results model
        ]
