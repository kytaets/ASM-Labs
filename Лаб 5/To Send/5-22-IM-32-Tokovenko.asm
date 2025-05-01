.386
.model flat, stdcall
option casemap:none

include \masm32\include\masm32rt.inc

.data?
    kytaecMessageBufferOutput             db 256 dup (?)
    kytaecFormattedResultString           db 256 dup (?)
    kytaecComputedResultValue             dd ?
    kytaecDenominatorValueHold            dd ?
    kytaecNumeratorValueHold              dd ?
    kytaecExtraDebugVariable              dd ?
    kytaecComputationShadowCopy           dd ?
    kytaecTemporaryDenominatorStore       dd ?
    kytaecDivisionSafeguardPlaceholder    dd ?
    kytaecUnusedBufferArea                db 64 dup (?)
    kytaecResultMirrorCopy                dd ?

.data
    kytaecInputValuesSetA        dd 4,  3,    3,    3,    3
    kytaecInputValuesSetB        dd 8,  20,   -12,  -24,   12
    kytaecInputValuesSetC        dd 10, 8,    6,    -6,    9
    kytaecInputValuesSetD        dd 2,  4,    -3,   -2,    2


    kytaecAppWindowTitle         db "Lab 5. Tokovenko IM-32. Var-22", 0
    kytaecMainDisplayContent     db "Expression: (3*a*d - 12) / (c - b/4 - 6)", 10, 10,
                                 "Value of Input A: %d", 10,
                                 "Value of Input B: %d", 10,
                                 "Value of Input C: %d", 10,
                                 "Value of Input D: %d", 10, 10,
                                 "(3 * %d * %d - 12) / (%d - %d / 4 - 6)", 10, 10,
                                 "%s", 0
    kytaecResultDisplayFormatText db "Calculation Step Result: %d", 10,
                                 "Processed Final Result: %d", 0
    kytaecZeroDivisionErrorText  db "Error Encountered: Division by Zero!", 0
    kytaecIterationCounter       dd 0

.code
start:
    mov esi, kytaecIterationCounter

kytaecCalculationLoopStart:
    ; Calculate denominator: (c - b / 4 - 6)
    mov eax, kytaecInputValuesSetB[4 * esi]
    mov ecx, 4
    cdq
    idiv ecx                          ; eax = b / 4

    mov edi, kytaecInputValuesSetC[4 * esi]
    sub edi, eax                      ; edi = c - (b / 4)
    sub edi, 6                        ; edi = c - (b / 4) - 6

    .if edi == 0
        invoke wsprintf, addr kytaecMessageBufferOutput, addr kytaecMainDisplayContent,
            kytaecInputValuesSetA[4 * esi], kytaecInputValuesSetB[4 * esi], 
            kytaecInputValuesSetC[4 * esi], kytaecInputValuesSetD[4 * esi],
            kytaecInputValuesSetA[4 * esi], kytaecInputValuesSetD[4 * esi], 
            kytaecInputValuesSetC[4 * esi], kytaecInputValuesSetB[4 * esi],
            addr kytaecZeroDivisionErrorText
    .else
        mov kytaecDenominatorValueHold, edi

        ; Calculate numerator: (3 * a * d - 12)
        mov eax, kytaecInputValuesSetA[4 * esi]
        mov ebx, 3
        imul ebx
        mov ecx, kytaecInputValuesSetD[4 * esi]
        imul ecx
        mov kytaecNumeratorValueHold, eax
        sub eax, 12

        ; Perform division
        mov ebx, kytaecDenominatorValueHold
        cdq
        idiv ebx
        mov kytaecComputedResultValue, eax

        ; Check parity
        test eax, 1
        jz kytaecHandleEvenResult
        jmp kytaecHandleOddResult

    kytaecDisplayFinalOutput:
        invoke wsprintf, addr kytaecFormattedResultString, addr kytaecResultDisplayFormatText,
            kytaecComputedResultValue, eax
        invoke wsprintf, addr kytaecMessageBufferOutput, addr kytaecMainDisplayContent,
            kytaecInputValuesSetA[4 * esi], kytaecInputValuesSetB[4 * esi], kytaecInputValuesSetC[4 * esi], kytaecInputValuesSetD[4 * esi],
            kytaecInputValuesSetA[4 * esi], kytaecInputValuesSetD[4 * esi], kytaecInputValuesSetC[4 * esi], kytaecInputValuesSetB[4 * esi],
            addr kytaecFormattedResultString
    .endif

    invoke MessageBox, 0, addr kytaecMessageBufferOutput, addr kytaecAppWindowTitle, MB_OK

    inc esi
    cmp esi, 5
    jne kytaecCalculationLoopStart

    invoke ExitProcess, 0

kytaecHandleEvenResult:
    mov ebx, 2
    cdq
    idiv ebx
    jmp kytaecDisplayFinalOutput

kytaecHandleOddResult:
    mov ebx, 5
    imul ebx
    jmp kytaecDisplayFinalOutput

end start
