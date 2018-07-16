module MidiConversionsTests exposing (..)

import Test exposing (..)
import Expect
import Types.PitchClass exposing (..)
import Types.Pitch exposing (..)
import MidiConversions exposing (toMidiNumber)
import Types.Octave as Octave exposing (..)


all : Test
all =
    describe "Pitch to MIDI number"
        [ test "A0 should be 21" <|
            \_ ->
                Expect.equal (Pitch (PitchClass A Natural) Octave.zero |> toMidiNumber) 21
        , test "C8 should be 108" <|
            \_ ->
                Expect.equal (Pitch (PitchClass C Natural) Octave.eight |> toMidiNumber) 108
        , test "C4 should be 60" <|
            \_ ->
                Expect.equal (Pitch (PitchClass C Natural) Octave.four |> toMidiNumber) 60
        , test "F#5 should be 78" <|
            \_ ->
                Expect.equal (Pitch (PitchClass F Sharp) Octave.five |> toMidiNumber) 78
        , test "Gb5 should be 78" <|
            \_ ->
                Expect.equal (Pitch (PitchClass G Flat) Octave.five |> toMidiNumber) 78
        ]
