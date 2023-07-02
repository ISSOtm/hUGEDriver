; This file serves as a stub to make a GBS file. It must not be assembled normally, hence being outside of `src/`.

INCLUDE "obj/syms.asm"

SECTION "GBS", ROM0[0]

	db "GBS" ; Magic.
	db 1 ; Version.

	db 1 ; How many songs?
	db 1 ; ID of the first song (ignored by our stub).
	dw MusicDriverLoadAddr ; Load address.
	dw InitMusic ; Init address.
	dw hUGE_TickSound ; Play address.
	dw wStackBottom ; Initial stack pointer.
	db 0 ; Timer modulo (unused).
	db 0 ; Timer control ("use VBlank").

	db "Jaded City" ; Title string.
	ds $30 - @, 0

	db "Cello2WC" ; Author string.
	ds $50 - @, 0

	db "2023" ; Copyright string.
	ds $70 - @, 0

INCBIN "bin/fO_demo.gb", MusicDriverLoadAddr
