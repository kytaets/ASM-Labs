; main.asm
.386
.model flat, stdcall
option casemap:none

include \masm32\include\windows.inc
include \masm32\include\masm32.inc
include \masm32\include\kernel32.inc
include \masm32\include\user32.inc
include \masm32\include\debug.inc

includelib \masm32\lib\masm32.lib
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\user32.lib
includelib \masm32\lib\debug.lib

extern CalcDenominator:proto
public inputB, inputD, three, two, tempDenominator

.data?
    tempNumerator       tbyte ?
    tempDenominator     tbyte ?
    resultDouble        qword ?
    denominatorValid    dd ?
    logValid           dd ?

.data
    inputA dq 2.5, 1.5, 0.5, 0.1, 7.5, -1.1
    inputB dq 1.2, 3.5, 2.5, 0.7, 2.2, 2.1
    inputC dq 0.8, 2.6, 0.1, 0.3, 9.6, 0.25
    inputD dq 0.4, 6.3, 0.6, 5.5, 3.3, 3.7

    windowTitle db "Lab 6. Tokovenko IM-32. Var-22", 0
    messageFormat db "Expression: (ln(a + 4*c) - 1) / (3*b - 2*d)", 10, 10,
                 "a: %s",10,"b: %s",10,"c: %s",10,"d: %s",10,10,
                 "(ln(%s + 4*%s) - 1)",10,"------------------------",10,
                 "(3*%s - 2*%s)",10,10,"Result: %s", 0
    outputBuffer db 1024 dup(?)  ; Додатковий буфер для повного виводу
    zeroDenominatorMsg db "Error: Division by zero (3*b - 2*d = 0)", 0
    logErrorMsg        db "Error: Invalid logarithm argument (a + 4*c <= 0)", 0
    bothErrorsMsg      db "Error: Both division by zero and invalid logarithm", 0

    iteration dd 0
    strA db 64 dup(?)
    strB db 64 dup(?)
    strC db 64 dup(?)
    strD db 64 dup(?)
    strResult db 64 dup(?)
    one      real8 1.0
    two     real8 2.0
    three   real8 3.0
    four     real8 4.0
    epsilon  real8 1.0e-10

.code
start:
    mov esi, [iteration]

calculationLoop:
    finit
    mov [denominatorValid], 1
    mov [logValid], 1

    ; -- Виклик процедури обчислення знаменника
    push esi
    call CalcDenominator
    add esp, 4

    ; Перевірка знаменника на ≈0
    fld tbyte ptr [tempDenominator]
    fabs
    fcomp [epsilon]
    fstsw ax
    sahf
    jb denominator_zero

    ; Перевірка логарифма
    fld qword ptr [inputC + 8*esi]
    fmul [four]
    fadd qword ptr [inputA + 8*esi]
    ftst
    fstsw ax
    sahf
    ja log_ok
    mov [logValid], 0
    jmp check_errors

denominator_zero:
    mov [denominatorValid], 0
    fstp st(0)
    fld qword ptr [inputC + 8*esi]
    fmul [four]
    fadd qword ptr [inputA + 8*esi]
    ftst
    fstsw ax
    sahf
    ja check_errors
    mov [logValid], 0
    jmp check_errors

log_ok:
    fld qword ptr [inputC + 8*esi]
    fmul [four]
    fadd qword ptr [inputA + 8*esi]
    fldln2
    fxch
    fyl2x
    fsub [one]
    fstp tbyte ptr [tempNumerator]

    fld tbyte ptr [tempNumerator]
    fld tbyte ptr [tempDenominator]
    fdivp st(1), st(0)
    fstp qword ptr [resultDouble]

    ; Виведення
    invoke FloatToStr2, [inputA + 8*esi], addr strA
    invoke FloatToStr2, [inputB + 8*esi], addr strB
    invoke FloatToStr2, [inputC + 8*esi], addr strC
    invoke FloatToStr2, [inputD + 8*esi], addr strD
    invoke FloatToStr2, resultDouble, addr strResult
    
    ; Використовуємо окремий буфер для повного виводу
    invoke wsprintf, addr outputBuffer, addr messageFormat,
        addr strA, addr strB, addr strC, addr strD,
        addr strA, addr strC, addr strB, addr strD,
        addr strResult
    jmp show

check_errors:
    finit
    invoke FloatToStr2, [inputA + 8*esi], addr strA
    invoke FloatToStr2, [inputB + 8*esi], addr strB
    invoke FloatToStr2, [inputC + 8*esi], addr strC
    invoke FloatToStr2, [inputD + 8*esi], addr strD

    cmp [denominatorValid], 1
    je only_log_error
    cmp [logValid], 1
    je only_denom_error

    invoke wsprintf, addr outputBuffer, addr messageFormat,
        addr strA, addr strB, addr strC, addr strD,
        addr strA, addr strC, addr strB, addr strD,
        addr bothErrorsMsg
    jmp show

only_denom_error:
    invoke wsprintf, addr outputBuffer, addr messageFormat,
        addr strA, addr strB, addr strC, addr strD,
        addr strA, addr strC, addr strB, addr strD,
        addr zeroDenominatorMsg
    jmp show

only_log_error:
    invoke wsprintf, addr outputBuffer, addr messageFormat,
        addr strA, addr strB, addr strC, addr strD,
        addr strA, addr strC, addr strB, addr strD,
        addr logErrorMsg

show:
    invoke MessageBox, 0, addr outputBuffer, addr windowTitle, MB_OK

    inc esi
    cmp esi, 6
    jne calculationLoop

    invoke ExitProcess, 0
end start