@echo off

if not exist obj mkdir obj
if not exist bin mkdir bin

rgbgfx -o obj/chicago8x8.2bpp @src/chicago8x8.flags src/chicago8x8.png
if %errorlevel% neq 0 call :exit 1
rgbasm -Wall -Wextra -h -p 0xFF -I src/include/ -I src/fortISSimO/include/ -o obj/bcd.o src/bcd.asm -DPRINT_DEBUGFILE >obj/bcd.dbg
if %errorlevel% neq 0 call :exit 1
rgbasm -Wall -Wextra -h -p 0xFF -I src/include/ -I src/fortISSimO/include/ -o obj/main.o src/main.asm -DPRINT_DEBUGFILE >obj/main.dbg
if %errorlevel% neq 0 call :exit 1
rgbasm -Wall -Wextra -h -p 0xFF -I src/include/ -I src/fortISSimO/include/ -o obj/music_driver.o src/music_driver.asm -DPRINT_DEBUGFILE >obj/music_driver.dbg
if %errorlevel% neq 0 call :exit 1
src\fortISSimO\teNOR\teNOR.exe src/demo_song.uge obj/demo_song.asm --section-type ROMX --song-descriptor DemoSong
if %errorlevel% neq 0 call :exit 1
rgbasm -Wall -Wextra -h -p 0xFF -I src/include/ -I src/fortISSimO/include/ -o obj/demo_song.o obj/demo_song.asm -DPRINT_DEBUGFILE >obj/demo_song.dbg
if %errorlevel% neq 0 call :exit 1

echo @debugfile 1.0.0 >bin/fO_demo.dbg
for %%f in (obj/*.dbg) do echo @include "../%%f" >>bin/fO_demo.dbg
rgblink -p 0xFF -d -m bin/fO_demo.map -n bin/fO_demo.sym -o bin/fO_demo.gb obj/bcd.o obj/demo_song.o obj/main.o obj/music_driver.o
if %errorlevel% neq 0 call :exit 1
rgbfix -p 0xFF -v bin/fO_demo.gb
if %errorlevel% neq 0 call :exit 1
call :exit 0

:exit
