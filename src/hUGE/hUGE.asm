
INCLUDE "config.inc"
INCLUDE "constants.inc"

INCLUDE "notes.inc"

INCLUDE "driver_mem.asm"
INCLUDE "driver.asm" ; Make sure to define this last, so music data can go in the same section


; Stuff for user definitions

dn: MACRO ;; (note, instr, effect)
    db \1
    db ((\2 << 4) | (\3 >> 8))
    db LOW(\3)
ENDM
