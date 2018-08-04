module Types exposing (PlayingState(..), Dialog(..), Device, Model, Msg(..))

import Types.Range exposing (Range)
import Types.PitchClass exposing (PitchClass)
import Types.Formula exposing (Formula)
import Types.Scale exposing (ScaleDef)
import SelectList exposing (SelectList)
import Types.TimeSignature exposing (TimeSignature)
import Types.Note as Note


type PlayingState
    = Stopped
    | Playing


type Dialog
    = SelectRoot
    | SelectScale
    | SelectFormula
    | SelectStartingNote


type alias Device =
    { width : Int
    , height : Int
    , phone : Bool
    , tablet : Bool
    , desktop : Bool
    , bigDesktop : Bool
    , portrait : Bool
    }


type alias Model =
    { range : Range
    , scales : SelectList ( String, ScaleDef )
    , formulas : SelectList Formula
    , roots : SelectList PitchClass
    , startingNote : PitchClass
    , dialog : Maybe Dialog
    , playingState : PlayingState
    , samplesLoaded : Bool
    , device : Device
    , timeSignature : TimeSignature
    , noteDuration : Note.Duration
    }


type Msg
    = TogglePlay
    | DownloadPdf
    | RootSelected PitchClass
    | StartingNoteSelected PitchClass
    | ScaleSelected ScaleDef
    | FormulaSelected Formula
    | Open Dialog
    | SamplesLoaded
    | UnknownSub String
    | WindowResize Device
    | SetTimeSignature TimeSignature
    | ToggleNoteValue
    | RangeMinStepDown
    | RangeMinStepUp
    | RangeMinSkipDown
    | RangeMinSkipUp
    | RangeMaxStepDown
    | RangeMaxStepUp
    | RangeMaxSkipDown
    | RangeMaxSkipUp
    | CloseDialog
