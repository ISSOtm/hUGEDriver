# Notes

This document is for "special" notes only (ie. values of 72 or above). The rest of the notes fit the general descriptions found elsewhere.

## 72 - Jump

This note causes the driver to immediately jump to a specific row, and **immediately** read that row. This means the note doesn't consume a tick, and that it's possible to trap the driver in an infinite loop using this.

This note alters the meaning of the other 2 bytes: the first byte (FX arguments) is the index of the row within the pattern, the second byte (FX + instrument) is the index of the pattern within the order table.
