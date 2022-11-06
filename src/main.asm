
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

	; Clear top two rows of the window tilemap.
	ld hl, $9C00
	ld a, " "
	ld c, SCRN_VX_B * 2
.clearWinTilemap
	ld [hli], a
	dec c
	jr nz, .clearWinTilemap

	ld hl, MusicDriverEnd - MusicDriver
	ld de, $99E8
	call PrintU16
	ld hl, SIZEOF("Song Data")
	ld de, $9A08
	call PrintU16

	ld a, LCDCF_ON | LCDCF_WINON | LCDCF_WIN9C00 | LCDCF_BGON
	ldh [rLCDC], a
	xor a
	ldh [rSCX], a
	ldh [rSCY], a
	ld a, $E4
	ldh [rBGP], a
	ldh [rWX], a ; Please be off-screen for the time being.
	ld a, WIN_SCANLINE
	ldh [rWY], a


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
	ld a, 7
	ld [wWX], a
	ld hl, Greetz
	push hl

MainLoop:
	halt ; Wait for the beginning of scanline #0

	; Make the palette fully black, to help visualizing the time taken.
	xor a
	ldh [rBGP], a

	call hUGE_TickSound

	ld a, $E4
	ldh [rBGP], a


	; Allow the window to start showing when scheduled.
	ld a, [wWX]
	ldh [rWX], a


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

	; Switch to next column.
	ld hl, wGraph.columnMask
	rrc [hl]
	jr nc, .noNextTile
	inc hl
	assert wGraph.columnMask + 1 == wGraph.tileID
	inc [hl] ; Switch to next tile.
	res 4, [hl] ; Wrap after 16 tiles.
.noNextTile


	; Wait to hide the window.
.waitWinHide
	ldh a, [rLY]
	cp WIN_SCANLINE + 8
	jr c, .waitWinHide
	ld a, SCRN_X + 7
	ldh [rWX], a

	; Move the window left.
	ld a, [wWX]
	dec a
	jr nz, .noNewGreetzChar
	; Shift all chars left.
	ld hl, $9C00 + SCRN_X_B + 1
.shiftGreetzLeft
:
	ldh a, [rSTAT]
	and STATF_BUSY
	jr nz, :-
	dec l
	ld a, d
	ld d, [hl]
	ld [hl], a
	jr nz, .shiftGreetzLeft
	; Print a new char.
	pop hl
:
	ldh a, [rSTAT]
	and STATF_BUSY
	jr nz, :-
	ld a, [hli]
	and a
	jr nz, .noGreetzWrap
	ld hl, Greetz
	ld a, [hli]
.noGreetzWrap
	ld [$9C00 + SCRN_X_B], a
	push hl
	; Move window back right.
	ld a, 8
.noNewGreetzChar
	ld [wWX], a

	jp MainLoop


PrintU16:
	push de
	call bcd16
	pop hl

	ld a, c
	add a, "0"
	cp "0"
	jr nz, .some10000s
	ld a, " "
.some10000s
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

wWX: db


SECTION "Gfx data", ROM0

FontTiles:
INCBIN "obj/chicago8x8.2bpp"

; Tilemap.
	ds SCRN_X_B, " "
	ds SCRN_X_B, " "
	ds SCRN_X_B, " "
	db "                    "
	db "fortISSimO by ISSOtm"
	db "and SuperDisk.      "
	db "                    "
	db "Special thanks to:  "
	db "              HI MOM"
	db "                    "
	db "CPU usage:          "
	db "  ",$80,$81,$82,$83,$84,$85,$86,$87,$88,$89,$8A,$8B,$8C,$8D,$8E,$8F,"  "
	db "  ",$90,$91,$92,$93,$94,$95,$96,$97,$98,$99,$9A,$9B,$9C,$9D,$9E,$9F,"  "
	db "  ",$A0,$A1,$A2,$A3,$A4,$A5,$A6,$A7,$A8,$A9,$AA,$AB,$AC,$AD,$AE,$AF,"  "
	db "                    "
	db "Driver: xxxxx bytes "
	db "Song:   xxxxx bytes "
	db "                    "

def GRAPH_HEIGHT equ 3 * 8 ; pixels.
def WIN_SCANLINE equ 8 * 8 ; pixels.


SECTION "Greetz", ROM0

Greetz:
	db "Coffee Bat (music), nitro2k01 & calc84maniac (optimisations), Eievui & PinoBatch (support code), GBDev (https://gbdev.io), ", 0, "and you (hacking)!"


SECTION "STAT handler", ROM0[$0048]
	reti


SECTION "Stack space", WRAM0

def STACK_SIZE equ 32
wStack:
	ds STACK_SIZE
wStackBottom:
