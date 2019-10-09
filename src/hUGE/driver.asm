
SECTION "hUGE driver code", hUGE_CODE_SECTION_DECL

; Begin playing a song
; @param de A pointer to the song that should be played
; @return a 1
hUGE_StartSong::
    ; Prevent playback while we tamper with the state
    xor a
    ld [whUGE_Enabled], a

init_channel: MACRO
    ld hl, whUGE_CH\1OrderPtr
    ; Copy order table ptr
    ld a, [de]
    ld [hli], a
    ld a, [de]
    ld [hli], a
    ; Init row num (will be 0 after 1st increment)
    ld a, -3
    ld [hli], a
    ; Init order index
    xor a
    ld [hli], a
ENDM
    init_channel 1
    init_channel 2
    init_channel 3
    init_channel 4
PURGE init_channel

    ; Schedule next playback immediately
    ld a, 1
    ld [whUGE_RemainingTicks], a

    ; Re-enable playback
    ; ld a, 1
    ld [whUGE_Enabled], a
    ret


hUGE_TickSound::
    ld a, [whUGE_Enabled]
    and a
    ret z

    xor a
    ld [whUGE_CurChannel], a

    ld hl, whUGE_RemainingTicks
    dec [hl]
    jr nz, .noNewNote
    ; Reload tempo
    dec hl
    ld a, [hli]
    ld [hli], a

    ;; Play notes
    ; ld hl, whUGE_CH1OrderIndex
    ld c, LOW(rNR12)
    call hUGE_TickChannel
    ld hl, whUGE_CH2OrderIndex
    ld c, LOW(rNR22)
    call hUGE_TickChannel
    ld hl, whUGE_CH3OrderIndex
    ld c, LOW(rNR32)
    call hUGE_TickChannel
    ld hl, whUGE_CH4OrderIndex
    ld c, LOW(rNR43)
    call hUGE_TickChannel
.noNewNote

    ; TODO: Process effects "update"
    ret

    ; For volume slide:
    ; Add a signed 5-bit offset to the current volume


hUGE_ChannelJump:
    dec hl
    ; Write new order index
    ld a, b
    ld [hli], a
    ; Write new row index
    ld a, [whUGE_FXParams]
    ld [hli], a
    dec hl

; @param hl Pointer to the channel's data
; @param c Pointer to the first register the instrument will write to
hUGE_TickChannel:
    ; Read order ptr
    ld a, [hli]
    ld e, a
    ld a, [hli]
    ld d, a
    ; Increase row index
    ld a, 3
    add a, [hl]
    ; Check if we need to wrap
    cp PATTERN_LENGTH * 3
    jr c, .samePattern
    xor a
.samePattern
    ld [hli], a
    ld b, a ; Save this for later

    jr c, .noCarry
    inc [hl]
    ld a, [de] ; Read nb of orders
    inc de
    sub [hl] ; Check if we need to wrap
    jr c, .noCarry
    ld [hl], a ; Apply wrap
.noCarry

    ; Compute ptr to current row in pattern
    ld a, [hli] ; Read order index
    add a, a ; FIXME: assumes order tables are at most 128 orders long
    add a, e
    ld e, a
    adc a, d
    sub e
    ld d, a
    ld a, [de]
    add a, b
    ld b, a
    inc de
    ld a, [de]
    adc a, 0
    ld d, a

    ; Read effect params
    ld a, [de]
    inc de
    ld [whUGE_FXParams], a
    ; Read effect + instrument
    ld a, [de]
    inc de
    ld b, a
    ; Read note byte
    ld a, [de]
    cp NOTE_JUMP
    jr z, hUGE_ChannelJump
    ld [whUGE_CurChanNote], a
    ld [hli], a
    ; TODO: what if a >= LAST_NOTE?

    ; Read ptr to instrument translation table
    ld a, [hli]
    ld e, a
    ld a, [hli]
    ld d, a

    ; Reset "restart" bit of NRx4 mask
    res 7, [hl]

    ; Get instrument ptr
    ld a, b
    and $0F ; Mask out other bits
    jr z, .noNewNote
    ; Index into translation table
    add a, e
    ld e, a
    adc a, d
    sub e
    ld d, a
    ; Read global instrument ID
    ld a, [de]
    ; Compute ptr to that instrument
    ; FIXME: limits the number of instruments to 64
    add a, a
    add a, a
    add a, LOW(hUGE_Instruments)
    ld e, a
    adc a, HIGH(hUGE_Instruments)
    sub e
    ld d, a

    ; Read NRx4 mask
    ld a, [de]
    inc de
    ld [hl], a
    ; Write last three bytes to hardware regs
    ld a, [de]
    inc de
    ldh [c], a
    dec c
    ld a, [de]
    inc de
    ldh [c], a
    dec c
    ld a, [whUGE_CurChannel]
    cp 3 - 1
    ld a, [de]
    call z, .loadWave ; This works a tad differently for CH3
    ldh [c], a
.noNewNote
    ld a, [hli]
    ld [whUGE_NRx4Mask], a

    ; Do effect's first tick
    ld a, b
    and $F0
    jr nz, .doFX
    ; Maybe this isn't a FX?
    or c ; Are arguments 0 as well?
    jp z, .noMoreFX
    xor a ; Restore arpeggio ID
.doFX
    ; Get ID *2
    rra
    rra
    rra
    ld [hli], a
    add a, LOW(.fxTable)
    ld e, a
    adc a, HIGH(.fxTable)
    sub e
    ld d, a
    ld a, [whUGE_FXParams] ; Read this now because most FX use it right away
    push de
    ret

.loadWave
    push hl
    ; Compute ptr to wave
    ; FIXME: limits the number of waves to 16
    add a, LOW(hUGE_Waves)
    ld l, a
    adc a, HIGH(hUGE_Waves)
    sub e
    ld h, a

    ; Kill CH3 while we load the wave
    xor a
    ldh [rNR30], a
hUGE_TARGET = $FF30 ; Wave RAM
REPT 16
    ld a, [hli]
    ldh [hUGE_TARGET], a
hUGE_TARGET = hUGE_TARGET + 1
ENDR
PURGE hUGE_TARGET
    pop hl

    ; Return back to main code, enabling CH3 again
    ld c, LOW(rNR30)
    ld a, $80
    ret


; Each routine gets its params in A
; Some value to put in "param working memory" should be returned in A
; HL must be preserved
.fxTable
    jr .doneWithFX ; NYI .fx_arpeggio
    jr .doneWithFX ; NYI .fx_portaUp
    jr .doneWithFX ; NYI .fx_portaDown
    jr .doneWithFX ; NYI .fx_toneporta
    jr .doneWithFX ; NYI .fx_vibrato
    jr .fx_setMasterVolume
    jr .fx_callRoutine
    jr .fx_noteDelay
    jr .fx_setPan
    jr .fx_setDuty
    jr .fx_volSlide
    jr .doneWithFX ; Free slot
    jr .fx_setVolume
    jr .doneWithFX ; Free slot
    jr .doneWithFX ; Does not do any init
    ; jr .fx_setSpeed

.fx_setSpeed ; No need for a `jr` for this one
    ld [whUGE_Tempo], a
    jr .noMoreFX

.fx_setMasterVolume
    ldh [rNR51], a
    jr .noMoreFX

.fx_callRoutine
    push hl
    add a, LOW(hUGE_UserRoutines)
    ld l, a
    adc a, HIGH(hUGE_UserRoutines)
    sub l
    ld h, a
    ld a, [hli]
    ld h, [hl]
    ld l, a
    and a
    call .hl
    pop hl
    jr c, .noMoreFX
    jr .doneWithFX

.fx_noteDelay
    ; Cancel playing the note
    ld a, [whUGE_CurChanNote]
    ld b, a
    ld a, LAST_NOTE
    ld [whUGE_CurChanNote], a
    ; The note will be played back later
    ld a, b
    jr .doneWithFX

.fx_setPan
    ldh [rNR50], a
    jr .noMoreFX

.fx_setDuty
    ld b, a
    ld a, [whUGE_CurChanEnvPtr]
    dec c
    ld c, a
    ld a, b
    ldh [c], a
    jr .noMoreFX

.fx_volSlide
    ; Schedule effect to happen on this tick
    ld a, 1
    jr .doneWithFX

.fx_setVolume
    ; TODO: take the instrument's envelope into account?
    ld b, a
    ld a, [whUGE_CurChanEnvPtr]
    ld c, a
    ld a, b
    ldh [c], a
    ; jr .noMoreFX


.noMoreFX
    dec hl
    ld a, 1
    ld [hli], a
    ; FX storage doesn't matter, write a dummy value there
.doneWithFX
    ; Write FX storage
    ld [hli], a
    ; Write FX params
    ld a, [whUGE_FXParams]
    ld [hli], a

    ; Play the channel's note
    ld a, [whUGE_CurChanNote]
    cp LAST_NOTE
    call c, hUGE_PlayNote

    ; Switch to next channel
    ld hl, whUGE_CurChannel
    inc [hl]
    ret

    WARN "Move this elsewhere!"
.hl
    jp hl


hUGE_PlayNote:
    ld a, [whUGE_CurChanNote]
    add a, a
    add a, LOW(hUGE_NoteTable)
    ld e, a
    adc a, HIGH(hUGE_NoteTable)
    sub e
    ld d, a
    ; Read period
    ld a, [de]
    ld b, a
    inc de
    ld a, [de]
    ld d, a

    ; Get ptr to NRx3
    ld a, [whUGE_CurChannel]
    ld c, a
    add a, a
    add a, a
    add a, c
    add a, LOW(rNR13)
    ld c, a
    cp LOW(rNR43)
    jr z, .ch4

    ld a, b
    ldh [c], a
    inc c
    ld a, [whUGE_NRx4Mask]
    or d
    ldh [c], a
    ret

.ch4
    ; Quantize the note by turning it into a sort of "scientific notation"
    ; e = shift amount
    ; db = Frequency, shifted right until it's only 3 bits
    ld e, 0
    ; First, enforce working on a single byte for efficiency
    ld a, d
    and %111
    jr z, .emptyHighByte
    ; Shift right by 4 (5 would be remove an iteration but be slower)
    xor b
    and %1111
    xor b
    swap a
    ld b, a
    ld e, 4
.emptyHighByte
    ; b = Frequency
    ; Shift right until only 3 significants bits remain
.shiftFreqRight
    ld a, b
    and ~%111
    jr z, .done
    srl b
    inc e
    jr .shiftFreqRight
.done
    swap e
    ldh a, [c] ; Keep length bit
    and %1000
    or b
    or e
    ldh [c], a
    ld a, [whUGE_NRx4Mask]
    ldh [rNR44], a
    ret


hUGE_NoteTable:
INCLUDE "note_table.inc"
