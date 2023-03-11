; This file serves to ensure that the GBS can compile correctly.
; In a real project, you should directly `rgbasm src/fortISSimO/fortISSimO.asm` instead.

SECTION "Music driver", ROM0[$700] ; Lower than this breaks some GBS players.

MusicDriverLoadAddr:

MusicDriver:: ; For computing the size.
DEF FORTISSIMO_ROM equs ""
DEF FORTISSIMO_RAM equs "WRAM0"
INCLUDE "src/fortISSimO/fortISSimO.asm"
MusicDriverEnd:: ; Idem.

InitMusic::
	xor a
	ld [hUGE_MutedChannels], a
	ld a, hUGE_NO_WAVE
	ld [hUGE_LoadedWaveID], a

	; Turn on the APU, and set the panning & volume to reasonable defaults.
	ld a, AUDENA_ON
	ldh [rNR52], a
	ld a, $FF
	ldh [rNR51], a
	ld a, $77
	ldh [rNR50], a

	ld de, DemoSong
	jp hUGE_StartSong
