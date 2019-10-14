# Format

## Song

A song is composed of a tempo and four order tables (+ instrument translation tables).

The first byte specifies the tempo; it's really the number of ticks between which updates will take place. Specifically, a value of 1 means a new row will be played on each tick, 2 means every other tick, and so on; 0 means every 256 ticks.

The eight next bytes are each a (little-endian) pointer to a channel's order table.

## Order table

An order table contains pointers to patterns, but also an table to translate "local" instruments to "global" ones.

### Pattern table

The first byte of an order table is the number of patterns in it. Note that right after the last pattern finishes playing, the driver automatically wraps to the first one.

The rest of the table is little-endian pointers to the patterns, which are simply 64 rows in a row (pun not intended).

### Instrument translation table

For compacity, patterns can only address up to 15 instruments (0 is special-cased, see [below](#instrument)). To allow songs to use more than this tiny amount, a translation table is used.

Each byte in the table, which is located right after the pattern pointers, is the ID (in the global table) of one of the patterns' instruments. Instrument 1 maps to the first byte, and so on.

## Row

Each row is encoded in three bytes. The first encodes the FX arguments, the second the FX and instrument, the third the note to be played.

```
 FX args   FX  Instr  Note
0000.0000-0000-0000-0000.0000
```

### Note

Note values are defined in `notes.inc`, from 0 (`C_3`) to 71 (`B_8`). 72 and above are "control notes"; they cause nothing to be played, but signal a special action to the driver; they may alter the meaning of other bytes. See [notes.md](notes.md).

### FX

See [effects.md](effects.md). Note that FX 0 with argument 00 specifically means "no FX".

### Instrument

0 is an empty instrument cell. If a note is specified on the same row, the channel's frequency will be changed, but the instrument will not be reloaded (envelope, etc.) and the note won't be retriggered.

For the instrument format, see [instruments.md](instruments.md).

## TODO

- Some form of RLE compression?
