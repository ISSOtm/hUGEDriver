# fortISSimO-demo

[fortISSimO](https://github.com/ISSOtm/fortISSimO) is a from-scratch reimplementation of SuperDisk's [hUGEDriver](https://github.com/SuperDisk/hUGEDriver).
For instructions on how to use fortISSimO in your project, [please check out its readme](https://github.com/ISSOtm/fortISSimO#readme).
This repo is a simple-ish example project that allows you to create a GB ROM and a GBS file from a hUGETracker export:

0. **Prerequisites**: have [RGBDS](https://rgbds.gbdev.io) v0.9.0 or later, and GNU Make installed.
   (Windows users will probably need [WSL](https://learn.microsoft.com/en-us/windows/wsl/), [MSYS2](https://www.msys2.org), or Cygwin.)
   If you want to make a GBS file, you must also have `sed` in your PATH.
1. `src/fortISSImO/` is a Git submodule, so it will be empty by default.
   With Git, use `git clone --recursive`, or run `git submodule update --init` after cloning.
   If you downloaded this repo as a ZIP, you must download and extract fortISSimO separately.
2. Replace `demo_song.uge` in the `src/` directory with the song you want to play.
3. From the same directory as the `Makefile`, run `make` (or `make gbs` if you want the GBS, or `make all` for both).
   By default, this will attempt to build [teNOR](https://eldred.fr/fortISSimO/teNOR) from source, which requires [Rust to be installed](https://www.rust-lang.org/tools/install); alternatively, you can point the `teNOR` variable at a teNOR binary, e.g. `make gbs teNOR=./teNOR.exe`.
4. Enjoy `bin/example.gb` and/or `bin/example.gbs`, best served hot!

Having trouble?
Please [file an issue](https://github.com/ISSOtm/fortISSimO-demo/issues/new), or contact me!

Do you have something in mind you want to discuss?
The [discussions tab](https://github.com/ISSOtm/fortISSimO-demo/discussions) is here for that, but you can also chat with me on GBDev or in the hUGETracker Discord if you don't have a GitHub account.

Your song sounds different from with hUGEDriver?
Please [file an issue on fortISSimO](https://github.com/ISSOtm/fortISSimO/issues/new); the driver aims for 100% compatibility, so I'll want to fix that.

## Notes

This repo started as a fork of hUGEDriver, but now it's moved pretty far from that.

The demo ROM contains two fancy features: some size information, and CPU usage stats.
The size information is simply the size, in bytes, of the driver itself, and of the exported song.

### CPU usage

You can see the instantaneous measure at the top of the screen: the flickering white pixels indicate for how long the driver was running.
On average, fortISSimO appears to be a handful of scanlines faster than hUGEDriver.

The CPU graph shows how many scanlines (screen lines, equivalent to 114 CPU M-cycles) the driver took to perform its update.
The measure is rounded down.
Bars are coloured depending on their height:

- \[0; 7\] pixels: light gray
- \[8; 15\] pixels: dark gray
- \[16; 23\] pixels: black
- 24 or more: this shouldn't happen, and will be signalled by the bar being empty. Please [file an issue](https://github.com/ISSOtm/fortISSimO-demo/issues/new) if this happens to you.

The graph can look fairly static, but this is normal if your song contains mostly repeated rows.

## Acknowledgements

- **[SuperDisk](https://github.com/SuperDisk)** created [the original driver](https://github.com/SuperDisk/hUGEDriver), composed the demo song, and has helped a lot throughout the project.
  Thanks a _lot_, man!
- [Cello2WC](https://www.cello2wc.com/portfolio-pixel.php) composed the music used in this demo.
- [Evie](https://github.com/eievui5) and [PinoBatch](https://github.com/pinobatch) provided some support code.

## See also

- [gbsdiff](https://github.com/ISSOtm/gbsdiff) was used to identify differences between this driver and hUGEDriver.
- [Emulicious](https://emulicious.net) and [BGB](https://bgb.bircd.org) were used to debug the driver.

## License

hUGETracker and hUGEDriver are dedicated to the public domain.
fortISSimO and all of this demo's code is the same, unless otherwise stated; for example, `bcd.asm` from [PinoBatch](https://github.com/pinobatch) is under the Zlib license.
