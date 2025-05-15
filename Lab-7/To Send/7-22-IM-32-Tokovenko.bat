@echo off

ml /c /coff 7-22-IM-32-Tokovenko-PUBLIC.asm
ml /c /coff 7-22-IM-32-Tokovenko.asm

link /SUBSYSTEM:WINDOWS 7-22-IM-32-Tokovenko.obj 7-22-IM-32-Tokovenko-PUBLIC.obj

7-22-IM-32-Tokovenko.exe
pause
