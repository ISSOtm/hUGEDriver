
INCLUDE "hardware.inc/hardware.inc"


SECTION "Vectors", ROM0[$0000]

rst00:
    ret
	ds 7

rst08:
    ret
	ds 7
rst10:
    ret
	ds 7

rst18:
    ret
	ds 7

rst20:
    ret
	ds 7

rst28:
    ret
	ds 7

rst30:
    ret
    ds 7

rst38:
    ret
    ds 7


; VBlank
    call hUGE_TickSound
    reti
    ds 4

; STAT
    reti
    ds 7

; Timer
    reti
    ds 7

; Serial
    reti
    ds 7

; Joypad
    reti


; Control starts here, but there's more ROM header several bytes later, so the
; only thing we can really do is immediately jump to after the header
SECTION "init", ROM0[$0100]
    di
    jr EntryPoint
    nop

    ds $150 - $104 ; Allocate header space


DiagonalTile:
    dw `10000000
    dw `01000000
    dw `00100000
    dw `00010000
    dw `00001000
    dw `00000100
    dw `00000010
    dw `00000001

EntryPoint:
    ; Set LCD palette for grayscale mode; yes, it has a palette
    ld a, %11100100
    ld [rBGP], a

    ;; Fill with pattern
    ld hl, $8000
    ld de, DiagonalTile
    ld c, 16
.copyTile
    ldh a, [rSTAT]
    and STATF_BUSY
    jr nz, .copyTile
    ld a, [de]
    ld [hli], a
    inc de
    dec c
    jr nz, .copyTile


    ld de, TestSong
    call hUGE_StartSong


    ld a, IEF_VBLANK
    ld [rIE], a
    xor a
    ei
    ldh [rIF], a

.wait
    halt
    jr .wait


STACK_SIZE equ $20
SECTION "Stack space", WRAM0[$E000 - STACK_SIZE]

    ds STACK_SIZE
wStackBottom:
