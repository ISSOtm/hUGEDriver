
INCLUDE "hardware.inc/hardware.inc"


SECTION "init", ROM0[$0100]
	di
	jr EntryPoint

	ds $150 - @, 0 ; Allocate header space.


EntryPoint:
	; Do some general init. Go to `MusicInit` below for the relevant stuff.
	ld sp, wStackBottom

	; Turn LCD off, safely.
.waitVBlank
	ldh a, [rLY]
	cp SCRN_Y
	jr c, .waitVBlank
	xor a
	ldh [rLCDC], a

	ld de, FontTiles
	ld hl, $9200
.copyFont
	ld a, [de]
	ld [hli], a
	inc de
	bit 3, h ; The "8" in "$9800".
	jr z, .copyFont

	ld c, SCRN_Y_B
.copyMap
	ld b, SCRN_X_B
.copyRow
	ld a, [de]
	ld [hli], a
	inc de
	dec b
	jr nz, .copyRow
	; Switch to next row.
	ld a, l
	add a, SCRN_VX_B - SCRN_X_B
	ld l, a
	adc a, h
	sub l
	ld h, a
	; More where that came from?
	dec c
	jr nz, .copyMap

	ld hl, MusicDriverEnd - MusicDriver
	ld de, $99E8
	call PrintU16
	ld hl, SIZEOF("Song Data")
	ld de, $9A08
	call PrintU16

	ld a, LCDCF_ON | LCDCF_BGON
	ldh [rLCDC], a
	xor a
	ldh [rSCX], a
	ldh [rSCY], a
	ld a, $E4
	ldh [rBGP], a


MusicInit:
	; You must do this at least once during game startup.
	xor a
	ldh [hUGE_MutedChannels], a
	ld a, hUGE_NO_WAVE
	ld [hUGE_LoadedWaveID], a


	; Turn on the APU, and set the panning & volume to reasonable defaults.
	ld a, AUDENA_ON
	ldh [rNR52], a
	ld a, $FF
	ldh [rNR51], a
	ld a, $77
	ldh [rNR50], a

	ld de, wyrmhole ;;;; <<<<<< CHANGE THIS TO YOUR SONG DESCRIPTOR <<<<<< ;;;;
	call hUGE_StartSong


	; Set up STAT.
	ld a, STATF_LYC
	ldh [rSTAT], a ; This can request a STAT interrupt, so do it before enabling it.
	; The first scanline is longer than the rest, which is cheating slightly; however,
	; we also need a bit of time before we actually start executing the driver, so it's fair.
	xor a
	ldh [rLYC], a

	; Enable the VBlank handler.
	ld a, IEF_STAT
	ldh [rIE], a
	; Clear pending interrupts before the master enable.
	xor a
	ei
	ldh [rIF], a


	; Init main loop variables.
	ld a, $80
	ld [wGraph.columnMask], a
	ld [wGraph.tileID], a

MainLoop:
	halt ; Wait for the beginning of scanline #0

	; Make the palette fully black, to help visualizing the time taken.
	xor a
	ldh [rBGP], a

	call hUGE_TickSound

	ld a, $E4
	ldh [rBGP], a


	; Update the CPU graph.
	ldh a, [rLY]
	ld c, a
	ld a, GRAPH_HEIGHT
	sub c
	ld c, a ; How many rows to clear for.
	; Continue setting up registers.
	ld b, 0 ; Which pixel value to plot.
	; Compute starting address.
	ld a, [wGraph.tileID]
	swap a
	ld h, a
	and $F0
	ld l, a
	ld a, h
	and $0F
	or $80
	ld h, a
	; Cache the mask, for ORing.
	ld a, [wGraph.columnMask]
	ld e, a
.drawColumn
	; Wait for VRAM to be accessible.
:	ldh a, [rSTAT]
	and STATF_BUSY
	jr nz, :-
	; Clear the column first, then possibly set the bitplane back.
	ld a, e
	cpl
	and [hl]
	bit 0, b ; Should we set the lower bitplane?
	jr z, .clearLowBitplane
	or e
.clearLowBitplane
	ld [hli], a
	; Wait for VRAM to be accessible.
:	ldh a, [rSTAT]
	and STATF_BUSY
	jr nz, :-
	; Again, but with the higher bitplane.
	ld a, e
	cpl
	and [hl]
	bit 1, b
	jr z, .clearHighBitplane
	or e
.clearHighBitplane
	ld [hl], a
	inc l ; Don't increment h!
	; Are we done writing blank pixels?
	dec c
	jr nz, .noPixelChange
	ld a, $B0 >> 4
	sub h
	ld b, a
	; c underflowed, we'll exit the outer loop way before it reaches 0 again.
.noPixelChange
	; Are we done with this tile?
	ld a, l
	and $0F
	jr nz, .drawColumn
	ld a, l
	sub $10
	ld l, a
	inc h
	ld a, h
	cp $8B
	jr c, .drawColumn
	; TODO


	; Switch to next column.
	ld hl, wGraph.columnMask
	rrc [hl]
	jr nc, .noNextTile
	inc hl
	assert wGraph.columnMask + 1 == wGraph.tileID
	inc [hl] ; Switch to next tile.
	res 4, [hl] ; Wrap after 16 tiles.
.noNextTile

	jr MainLoop


PrintU16:
	push de
	call bcd16
	pop hl

	ld a, c
	add a, "0"
	ld [hli], a

	ld a, d
	swap a
	and $0F
	add a, "0"
	ld [hli], a

	ld a, d
	and $0F
	add a, "0"
	ld [hli], a

	ld a, e
	swap a
	and $0F
	add a, "0"
	ld [hli], a

	ld a, e
	and $0F
	add a, "0"
	ld [hli], a
	ret


SECTION "Variables", WRAM0

wGraph:
.columnMask: db
.tileID: db


SECTION "Gfx data", ROM0

FontTiles:
INCBIN "obj/chicago8x8.2bpp"

; Tilemap.
	ds SCRN_X_B, " "
	ds SCRN_X_B, " "
	ds SCRN_X_B, " "
	db "                    "
	db "fortISSimO by ISSOtm"
	db "                    "
	db "Greetz to SuperDisk,"
	db "Coffee Bat, and Pino"
	db "                    "
	db "                    "
	db "CPU:                "
	db "  ",$80,$81,$82,$83,$84,$85,$86,$87,$88,$89,$8A,$8B,$8C,$8D,$8E,$8F,"  "
	db "  ",$90,$91,$92,$93,$94,$95,$96,$97,$98,$99,$9A,$9B,$9C,$9D,$9E,$9F,"  "
	db "  ",$A0,$A1,$A2,$A3,$A4,$A5,$A6,$A7,$A8,$A9,$AA,$AB,$AC,$AD,$AE,$AF,"  "
	db "                    "
	db "Driver: xxxxx bytes "
	db "Song:   xxxxx bytes "
	db "                    "

DEF GRAPH_HEIGHT equ 3 * 8 ; pixels.


SECTION "STAT handler", ROM0[$0048]
	reti


SECTION "Stack space", WRAM0

def STACK_SIZE equ 32
wStack:
	ds STACK_SIZE
wStackBottom:
