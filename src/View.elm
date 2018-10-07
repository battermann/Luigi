module View exposing (view)

import Element exposing (Attribute, Element, alignBottom, alignLeft, alignRight, centerX, centerY, column, el, fill, height, image, inFront, link, padding, paddingEach, paddingXY, paragraph, px, rgb255, row, scrollbarX, scrollbars, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (onClick)
import Element.Font as Font
import Element.Input exposing (button)
import Html
import Html.Attributes
import Libs.SelectList as SelectList
import List.Extra
import Score
import Styles
import Types exposing (Dialog(..), Model, Msg(..), PlayingState(..))
import Types.Formula as Formula exposing (Formula)
import Types.Note as Note
import Types.Pitch exposing (displayPitch)
import Types.PitchClass as PitchClass exposing (PitchClass)
import Types.Range as Range
import Types.Scale as Scale exposing (Scale(..), ScaleDef)
import Types.Switch as Switch
import Types.TimeSignature exposing (BeatDuration(..), NumberOfBeats(..), TimeSignature(..), beatDuration, timeSignatureToString)
import View.FontAwesome as Icons
import View.RangeInput as RangeInput


smallSpacing : Attribute msg
smallSpacing =
    spacing 2


standardPadding : Attribute msg
standardPadding =
    padding 10


id : String -> Attribute msg
id value =
    Element.htmlAttribute <| Html.Attributes.id value


viewControlWithLabel : List (Attribute msg) -> String -> Element msg -> Element msg
viewControlWithLabel attributes label control =
    column
        (smallSpacing :: attributes)
        [ el Styles.smallText (text label)
        , control
        ]


viewNoteDurationControls : Model -> Element Msg
viewNoteDurationControls model =
    let
        attributes duration =
            if duration == model.noteDuration then
                standardPadding :: Styles.lightButton

            else
                standardPadding :: Styles.page

        fileName duration baseName =
            if duration == model.noteDuration then
                baseName ++ ".svg"

            else
                baseName ++ "-light" ++ ".svg"
    in
    row
        [ smallSpacing ]
        [ button
            (Note.Eighth Note.None |> attributes)
            { label = image [ height (px 20) ] { src = fileName (Note.Eighth Note.None) "eighthnotes", description = "" }
            , onPress = Just ToggleNoteValue
            }
        , if [ Quarter, Half ] |> List.member (model.timeSignature |> beatDuration) then
            button
                (Note.Eighth Note.Triplet |> attributes)
                { label = image [ height (px 20) ] { src = fileName (Note.Eighth Note.Triplet) "triplet", description = "" }
                , onPress = Just ToggleNoteValue
                }

          else
            el (Note.Eighth Note.Triplet |> attributes) <|
                image [ Styles.opacity 0.2, height (px 20) ] { src = fileName (Note.Eighth Note.Triplet) "triplet", description = "" }
        ]


viewTempoSlider : Model -> Element Msg
viewTempoSlider model =
    row
        [ spacing 15 ]
        [ el [ spacing 10, padding 2, height (px 40) ] (RangeInput.input model.tempo UpdateTempo)
            |> viewControlWithLabel [ width fill ] ("Tempo: " ++ String.fromFloat model.tempo ++ " bpm")
        , button
            (standardPadding :: Switch.fold Styles.lightButton Styles.page model.clickTrack)
            { label = el [] (model.clickTrack |> Switch.fold Icons.volumeUp Icons.volumeOff), onPress = Just ToggleClick }
            |> viewControlWithLabel [ width (px 40) ] "Click"
        ]


viewTimeSignatureControls : Model -> Element Msg
viewTimeSignatureControls model =
    let
        attributes ts =
            if ts == model.timeSignature then
                Styles.lightButton

            else
                Styles.page

        rowLength =
            if model.device.phone && model.device.portrait then
                5

            else
                10

        buttons =
            [ TimeSignature Three Quarter
            , TimeSignature Four Quarter
            , TimeSignature Five Quarter
            , TimeSignature Six Quarter
            , TimeSignature Three Eighth
            , TimeSignature Five Eighth
            , TimeSignature Six Eighth
            , TimeSignature Seven Eighth
            , TimeSignature Nine Eighth
            , TimeSignature Twelve Eighth
            ]
                |> List.map (\ts -> button (attributes ts ++ [ width fill, standardPadding ]) { label = ts |> timeSignatureToString |> text, onPress = Just (SetTimeSignature ts) })
                |> List.Extra.greedyGroupsOf rowLength
                |> List.map (row [ smallSpacing ])
                |> column [ spacing 6 ]
    in
    buttons |> viewControlWithLabel [ width fill, Styles.userSelectNone ] "Time Signature"


viewRangeControls : Model -> Element Msg
viewRangeControls model =
    let
        colOrRow =
            if model.device.phone || (model.device.tablet && model.device.portrait) then
                column

            else
                row

        buttonAttributes =
            Styles.page ++ [ width fill, standardPadding, Styles.userSelectNone ]
    in
    colOrRow
        [ smallSpacing ]
        [ row
            [ smallSpacing ]
            [ button buttonAttributes { label = Icons.doubleAngleLeft, onPress = Just RangeMinSkipDown }
            , button buttonAttributes { label = Icons.angleLeft, onPress = Just RangeMinStepDown }
            , button buttonAttributes { label = Icons.angleRight, onPress = Just RangeMinStepUp }
            , button buttonAttributes { label = Icons.doubleAngleRight, onPress = Just RangeMinSkipUp }
            ]
        , column (Styles.page ++ [ centerX, centerY, standardPadding, smallSpacing, width fill, Styles.userSelectNone ])
            [ row [ spacing 10 ]
                [ text (displayPitch (Range.lowest model.range))
                , text "-"
                , text (displayPitch (Range.highest model.range))
                ]
            ]
        , row
            [ smallSpacing ]
            [ button buttonAttributes { label = Icons.doubleAngleLeft, onPress = Just RangeMaxSkipDown }
            , button buttonAttributes { label = Icons.angleLeft, onPress = Just RangeMaxStepDown }
            , button buttonAttributes { label = Icons.angleRight, onPress = Just RangeMaxStepUp }
            , button buttonAttributes { label = Icons.doubleAngleRight, onPress = Just RangeMaxSkipUp }
            ]
        ]
        |> viewControlWithLabel [ width fill, smallSpacing, Styles.userSelectNone ] "Range"


viewPlayControl : Model -> Element Msg
viewPlayControl model =
    let
        attributes =
            Styles.lightButton ++ [ alignBottom, standardPadding, Styles.userSelectNone, height (px 60), width (px 60), id "play-button" ]
    in
    case ( model.playingState, model.samplesLoaded ) of
        ( _, False ) ->
            column (attributes ++ [ centerX, centerY, spacing 4 ]) [ Icons.spinner, el Styles.verySmallText (text "loading…") ]

        ( Stopped, _ ) ->
            button attributes { label = Icons.play, onPress = Just TogglePlay }

        ( Playing, _ ) ->
            button attributes { label = Icons.stop, onPress = Just TogglePlay }


viewMainSettingsControls : Model -> Element Msg
viewMainSettingsControls model =
    let
        columns =
            if model.device.phone || model.device.tablet then
                2

            else
                4

        buttonAttributes =
            Styles.page ++ [ standardPadding, Styles.userSelectNone, width fill ]
    in
    [ button
        buttonAttributes
        { label = PitchClass.toString (SelectList.selected model.roots) |> text, onPress = Just <| Open SelectRoot }
        |> viewControlWithLabel [ width fill ] "Root"
    , button
        buttonAttributes
        { label = text (model.scales |> SelectList.selected |> Tuple.first), onPress = Just <| Open SelectScale }
        |> viewControlWithLabel [ width fill ] "Scale"
    , button
        buttonAttributes
        { label = model.formulas |> SelectList.selected |> Formula.toString |> text, onPress = Just <| Open SelectFormula }
        |> viewControlWithLabel [ width fill ] "Formula"
    , button
        buttonAttributes
        { label = PitchClass.toString model.startingNote |> text, onPress = Just <| Open SelectStartingNote }
        |> viewControlWithLabel [ width fill ] "Starting note"
    ]
        |> List.Extra.greedyGroupsOf columns
        |> List.map (row [ smallSpacing ])
        |> column [ spacing 6 ]


viewModalDialog : Element Msg -> Element Msg
viewModalDialog element =
    el (Styles.page ++ [ centerX, padding 20 ]) element
        |> el
            (Styles.dialog
                ++ [ width fill
                   , height fill
                   , onClick CloseDialog
                   , paddingEach { top = 100, left = 0, bottom = 0, right = 0 }
                   , scrollbars
                   ]
            )


darkButtonAttributes : List (Attribute msg)
darkButtonAttributes =
    Styles.darkButton ++ [ Styles.userSelectNone, standardPadding, width fill ]


viewSelectNoteButton : (PitchClass -> Msg) -> PitchClass -> Element Msg
viewSelectNoteButton event pitchClass =
    button darkButtonAttributes { label = PitchClass.toString pitchClass |> text, onPress = Just <| event pitchClass }


viewSelectScaleButton : ( String, ScaleDef ) -> Element Msg
viewSelectScaleButton ( name, scale ) =
    button darkButtonAttributes { label = text name, onPress = Just <| ScaleSelected scale }


viewSelectFormulaButton : Formula -> Element Msg
viewSelectFormulaButton formula =
    button darkButtonAttributes { label = formula |> Formula.toString |> text, onPress = Just <| FormulaSelected formula }


viewSelectScaleDialog : Model -> Element Msg
viewSelectScaleDialog model =
    viewModalDialog <|
        column
            [ smallSpacing ]
            (el (centerX :: Styles.h2) (text "Scale")
                :: (SelectList.toList model.scales |> List.map viewSelectScaleButton)
            )


viewSelectRootDialog : Model -> Element Msg
viewSelectRootDialog model =
    viewModalDialog <|
        column
            [ smallSpacing, width (px 220) ]
            (el (centerX :: Styles.h2) (text "Root")
                :: (SelectList.toList model.roots |> List.map (viewSelectNoteButton RootSelected) |> List.Extra.greedyGroupsOf 3 |> List.map (row [ smallSpacing ]))
            )


viewSelectStartingNoteDialog : Model -> Element Msg
viewSelectStartingNoteDialog model =
    viewModalDialog <|
        column
            [ smallSpacing, width (px 220) ]
            (el (centerX :: Styles.h2) (text "Starting note")
                :: (SelectList.selected model.scales
                        |> (Tuple.second >> Scale (SelectList.selected model.roots) >> Scale.notes)
                        |> List.map (viewSelectNoteButton StartingNoteSelected)
                        |> List.Extra.greedyGroupsOf 3
                        |> List.map (row [ smallSpacing ])
                   )
            )


viewSelectFormulaDialog : Model -> Element Msg
viewSelectFormulaDialog model =
    viewModalDialog <|
        column
            [ smallSpacing ]
            (el (centerX :: Styles.h2) (text "Formula")
                :: (SelectList.toList model.formulas |> List.map viewSelectFormulaButton |> List.Extra.greedyGroupsOf 2 |> List.map (row [ smallSpacing ]))
            )


viewSelectedDialog : Model -> Element Msg
viewSelectedDialog model =
    case model.dialog of
        Just SelectRoot ->
            viewSelectRootDialog model

        Just SelectScale ->
            viewSelectScaleDialog model

        Just SelectFormula ->
            viewSelectFormulaDialog model

        Just SelectStartingNote ->
            viewSelectStartingNoteDialog model

        Nothing ->
            text ""


view : Model -> Html.Html Msg
view model =
    let
        ( scoreLayout, pagePaddingTop, settingsWidth ) =
            if model.device.phone || model.device.tablet then
                ( row (scrollbarX :: Styles.score) [ el (Styles.score ++ [ id Score.elementId, centerX, width fill ]) (text "") ]
                , paddingEach { top = 20, bottom = 0, left = 0, right = 0 }
                , width fill
                )

            else
                ( row (centerX :: Styles.score) [ el (Styles.score ++ [ id Score.elementId, centerX ]) (text "") ]
                , paddingEach { top = 100, bottom = 0, left = 0, right = 0 }
                , width fill
                )
    in
    Element.layout [] <|
        column (Styles.page ++ [ spacing 40, paddingXY 10 10, pagePaddingTop ])
            [ el (centerX :: Styles.h1) (text "Luigi")
            , paragraph
                (Styles.subTitle ++ [ paddingEach { top = 0, bottom = 40, left = 0, right = 0 }, centerX ])
                [ text "Generate lines for jazz improvisation based on scales and formulas." ]
            , column
                [ smallSpacing ]
                [ column
                    []
                    [ row
                        [ centerX, width fill ]
                        [ column [ smallSpacing, settingsWidth ]
                            [ viewPlayControl model
                            , column (Styles.settings ++ [ padding 20, spacing 6 ])
                                [ viewTempoSlider model
                                , viewMainSettingsControls model
                                , viewRangeControls model
                                , viewTimeSignatureControls model
                                , viewNoteDurationControls model
                                ]
                            ]
                        ]
                    ]
                , scoreLayout
                ]
            , column
                (spacing 5 :: Styles.footer)
                [ row [ centerX ]
                    [ text "v0.2.1 | created with "
                    , link Styles.link { url = "http://elm-lang.org/", label = text "Elm" }
                    ]
                , row [ centerX ]
                    [ text "sound samples from "
                    , link Styles.link { url = "https://archive.org/details/SalamanderGrandPianoV3", label = text "Salamander Grand Piano" }
                    ]
                , row [ centerX ]
                    [ text "Inspired by "
                    , link Styles.link { url = "https://learningmusic.ableton.com/", label = text "Ableton Learning Music" }
                    ]
                , el (centerX :: Styles.gitHubIcon) <| link [] { url = "https://github.com/battermann/Luigi", label = Icons.github }
                ]
            , viewSelectedDialog model
            ]
