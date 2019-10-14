# Driver documentation

- [Terms and concepts](terms-and-concepts.md)
- [Format](format.md)

## Usage

What you want is the contents of the `fortISSimO` directory. Copy that anywhere in your projects, though it's recommended to keep it inside a directory and add an include path using RGBASM's `-i` option (see the example build scripts). Simply include `fortISSimO/main.asm` in a file, then define your music data! In this example, this file is `music.asm`.

If you do not start a new `section` after `include`ing `fortISSimO.asm`, the music data will be placed in the same ROM bank as the driver's code; this is useful if you want all the sound stuff to be in a single bank.

First, ensure to set the `whUGE_Enabled` byte to 0 **before any calls to `hUGE_TickSound` are made**. Calling `hUGE_StartSong` works as well.

Then, call `hUGE_TickSound` repeatedly (typically once per frame, or from the timer interrupt).

## Customizing

You can pass various customization options to hUGE in the form of EQUS strings; that can be done either from within the file, or via command-line `-D` options. Here are the supported options:

| Constant               | Default value | Explanation |
|------------------------|---------------|-------------------------------------------------------------------|
| hUGE_CODE_SECTION_DECL | `ROM0`        | The attributes for the `section` hUGE's code will be placed in.   |
| hUGE_RAM_SECTION_DECL  | `WRAM0`       | The attributes for the `section` hUGE's memory will be placed in. |

## License

MIT
