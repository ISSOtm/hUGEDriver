
INCLUDE "fortISSimO/main.asm"

TestSong::
    db 7 ; Tempo
    dw order1 ; CH1 order table
    dw order2 ; CH2 order table
    dw order3 ; CH3 order table
    dw order4 ; CH4 order table

order1:
    db 1
    dw walkup
    ; Table of the IDs of the 15 instruments this pattern will use
    db 0

order2:
    db 1
    dw testpatt
    ; Table of the IDs of the 15 instruments this pattern will use
    db 0

order3:
    db 1
    dw empty

order4:
    db 1
    dw drums
    ; Table of the IDs of the 15 instruments this pattern will use
    db 2


lunawaves:
include "TestPatterns/lunawaves.inc"

unreal:
include "TestPatterns/unreal.inc"

unreal_arps:
include "TestPatterns/unreal_arps.inc"

tfau_arps:
include "TestPatterns/tfau_arps.inc"

tfau_bass:
include "TestPatterns/tfau_bass.inc"

empty:
rept 64
    row ___, 0, 0
endr

silence:
    row C_4, 1, $C00
rept 63
    row ___, 0, $000
endr

silence3:
    row C_4, 2, $C00
rept 63
    row ___, 0, $000
endr

testpatt:
rept 16
    row C_4, 1, $000
    row ___, 0, $000
    row ___, 0, $000
    row ___, 0, $000
    row ___, 0, $000
    row ___, 0, $000
    row ___, 0, $000
    row ___, 0, $000
endr

testpatt2:
    row C_4, 1, $000
rept 16
    row D_4, 0, $000
    row ___, 0, $000
    row ___, 0, $000
    row ___, 0, $000
    row ___, 0, $000
    row ___, 0, $000
    row ___, 0, $000
    row ___, 0, $000
endr

drums:
rept 16
    row C_4, 1, 0
    row ___, 0, 0
    row ___, 0, 0
    row ___, 0, 0
    row ___, 0, 0
    row ___, 0, 0
    row ___, 0, 0
    row ___, 0, 0
endr

walkup:
_ASDF = C_3
rept 64
    row _ASDF, 1, 0
_ASDF = _ASDF + 1
endr

slideup:
  row C_3, 00, $000
rept 63
    row ___, 00, $101
endr

arps:
rept 64
    row C_5, 00, $047
endr

vib:
    row C_5, 00, $000
rept 63
    row ___, 00, $443
endr

updown:
    row C_4, 00, $105
rept 31
    row ___, 00, $105
endr
rept 32
    row ___, 00, $205
endr

volset:
    row C_5, 00, $000
rept 32
    row ___, 00, $C90
    row ___, 00, $CF0
endr

notecut:
rept 32
    row C_5, 00, $E04
    row ___, 00, $000
endr

notedelay:
rept 32
    row C_5, 00, 00
    row D#5, 00, $704
endr

volslide:
    row C_5, 00, 00
rept 63
    row ___, 00, $A01
endr

setduty:
    row C_5, 00, $F04
rept 21
    row ___, 00, $900
    row ___, 00, $940
    row ___, 00, $980
    row ___, 00, $9C0
endr

setpan:
    row C_5, 00, $811
    rept 15
    row ___, 00, 00
    endr
    row C_5, 00, $801
    rept 15
    row ___, 00, 00
    endr
    row C_5, 00, $810
    rept 15
    row ___, 00, 00
    endr
    row C_5, 00, $800
    rept 15
    row ___, 00, 00
    endr


;;;;;;;;;;;;;;;;
;; Instruments
;;;;;;;;;;;;;;;;

;; Instruments come in blocks.

hUGE_Instruments::

;; Format for channels 1 and 2:

square_instrument:
.highmask:        db %11000000
.envelope:        db %11110000 ; rNRx2
.length_and_duty: db %10000001 ; rNRx1
.sweep:           db 0 ; rNRx0, ignored for CH2

;; Format for channel 3:

voice_instrument:
.highmask: db %10000000
.volume:   db %00100000 ; rNR32
.length:   db 0 ; rNR31
.wave:     db 0 ; Index into wave collection, multiplied by 16

;; Format for channel 4:

noise_instrument:
.highmask:        db %10000000
.step_and_ratio:  db 0 ; rNR43
.envelope:        db %10100001 ; rNR42
.length:          db 0 ; rNR41


;;;;;;;;;;;;;
;; Routines
;;;;;;;;;;;;;

hUGE_UserRoutines::

;; This must be a table of pointers to the routines
;; A routine will first be called with carry reset, on tick 0; then with carry set on all ticks (including a second time on tick 0)
;; If a routine returns carry set, then it will stop being called


;;;;;;;;;;
;; Waves
;;;;;;;;;;

hUGE_Waves::

;; nothing yet
