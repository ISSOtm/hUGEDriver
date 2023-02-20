; This file serves both to pull in fortISSimO, and to ensure that the GBS can compile correctly.

SECTION "Music driver", ROM0[$700] ; Lower than this breaks some GBS players.

MusicDriverLoadAddr:

MusicDriver:: ; For computing the size.
DEF FORTISSIMO_ROM equs ""
DEF FORTISSIMO_RAM equs "WRAM0"
INCLUDE "fortISSimO.asm"
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

	ld de, wyrmhole
	jp hUGE_StartSong
