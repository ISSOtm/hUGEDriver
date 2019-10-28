@echo off

mkdir obj
mkdir bin

rgbasm -p 0xFF -h -i src/ -i src/include/ -i src/fortISSimO/ -o obj\music.o      src\music.asm
if %errorlevel% neq 0 call :exit 1
rgbasm -p 0xFF -h -i src/ -i src/include/ -i src/fortISSimO/ -o obj\main.o       src\main.asm
if %errorlevel% neq 0 call :exit 1

rgblink -p 0xFF-d  -m bin\example.map -n bin\example.sym -o bin\example.gb obj\music.o obj\main.o
if %errorlevel% neq 0 call :exit 1
rgbfix -p 0xFF -v -i HUGE -k HB -l 0x33 -m 0 -n 0 -r 0 -t hUGEDriver bin\example.gb
if %errorlevel% neq 0 call :exit 1
call :exit 0

:exit
exit
