@echo off

mkdir obj
mkdir bin

rgbgfx -o obj/chicago8x8.2bpp @src/chicago8x8.flags src/chicago8x8.png
if %errorlevel% neq 0 call :exit 1
rgbasm -h -p 0xFF -i src/include/ -i src/fortISSimO/ -o obj\music.o      src\music.asm
if %errorlevel% neq 0 call :exit 1
rgbasm -h -p 0xFF -i src/include/ -i src/fortISSimO/ -o obj\main.o       src\main.asm
if %errorlevel% neq 0 call :exit 1

rgblink -p 0xFF -d -m bin\example.map -n bin\example.sym -o bin\example.gb obj\music.o obj\main.o
if %errorlevel% neq 0 call :exit 1
rgbfix -p 0xFF -v bin\example.gb
if %errorlevel% neq 0 call :exit 1
call :exit 0

:exit
