@echo off

ml /c /coff public.asm
ml /c /coff main.asm

link /SUBSYSTEM:WINDOWS main.obj public.obj

main.exe
pause
