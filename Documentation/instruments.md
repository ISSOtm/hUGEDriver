# Instruments

Instruments are made of four bytes. The first byte is the same for all instruments, other bytes have meanings dependent on the channel.

Note that instrument bytes are mostly directly written to hardware registers, so the format is really [the hardware register's](https://gbdev.gg8.se/wiki/articles/Sound_Controller). What's documented below is what you should know if you don't want to delve into how Game Boy sound works.

#### NRx4 mask (All channels)

<dl>
    <dt>Bit 7 - Retrigger channel</dt>
    <dd>If set, the channel will restart when the instrument is played. If this is not set, values written to NRx2 (volume) will be ignored by the hardware.</dd>
    <dt>Bit 6 - Enable length</dt>
    <dd>If reset, values written to NRx1 (length) will be ignored by the hardware.</dd>
</dl>

#### Square channels (CH1, CH2)

##### Second byte: NRx2 (volume/envelope)

<dl>
    <dt>Bits 7-4 - Initial volume</dt>
    <dd>This is the volume the channel will start at. Note that if this is zero and sweep isn't set to "Increase", the channel will instantly die.</dd>
    <dt>Bit 3 - Sweep direction</dt>
    <dd>If this is reset, sweep is in "Decrease" mode. If this is set, sweep is in "Increase" mode.</dd>
    <dt>Bits 2-0 - Number of sweep steps</dt>
    <dd>If this is set to anything non-zero, the volume will be incremented or decremented, depending on bit 3, at 64 Hz. This selects how many increments or decrements will occur.</dd>
</dl>

##### Third byte: NRx1 (length, duty cycle)

<dl>
    <dt>Bits 7-6 - Duty cycle selection</dt>
    <dd>This sets how often the channel is low. 0 = 12.5% of the time, 1 = 25%, 2 = 50%, 3 = 75%</dd>
    <dt>Bits 5-0 - Note length</dt>
    <dd>How long until the note is cut off, in 256 Hz cycles. The higher this is, the <strong>less</strong> the note will last. Note that this is ignored unless bit 6 of the NRx4 mask is set!</dd>
</dl>

##### Fourth byte: NR10 (CH1-only frequency sweep)

Note that this byte is ignored by the hardware for CH2!

TODO: finish this document; it's mostly a rehashed version of the wiki anyways
