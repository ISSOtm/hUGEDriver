# Terms and concepts

## Tick

A "tick" is an unit of time as seen by the driver. Basically, every time the `hUGE_Tick` function is called, the driver state is advanced by one such tick. Usually, this is done at each VBlank, or sometimes via the timer interrupt.

The tempo of a song is set by determining how many ticks should elapse between notes: the higher that amount, the lower the tempo (= the slower the song). [Notes](#note) are only played once per N ticks, but [effects](#effect) can apply on all of them.

## Pattern

A pattern is a row of 64 [notes](#note). In trackers, this would typically be *four* rows of 64 notes; but in this driver, each channel is managed independently, so there are four patterns playing independently.

## Order table

An order table tells which patterns should be played in which order (eg. "play 1, 2, 2, 3, 1"). The goal is to be able to repeat patterns with little cost, to save on space.

## Note

A note has three parts to it, split unevenly across three bytes: a pitch, an instrument, and an effect.

### Pitch

The pitch tells which note is intended to play; the available notes are listed in [note_table.inc](../src/include/note_table.inc).

### Instrument

Instruments are somewhat like real-world instruments: when a certain note is played on one, it sounds different than on an other one. In practice, an instrument is a list of what to write to the Game Boy's sound registers when a note is played.

TODO: write more about the structure of instruments

### Effect

Effects tamper with playback; most of the time of the current note, but sometimes they affect global playback (example: changing the master volume).

For a list of the effects, see [effects.md](effects.md).
