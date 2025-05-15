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

extern kytaecVVTok32CalcDenominator:proto
public kytaecVVTok32inputB, kytaecVVTok32inputD, kytaecVVTok32three, kytaecVVTok32two, kytaecVVTok32tempDenominator

.data?
    kytaecVVTok32tempNumerator       tbyte ?
    kytaecVVTok32tempDenominator     tbyte ?
    kytaecVVTok32resultDouble        qword ?
    kytaecVVTok32denominatorValid    dd ?
    kytaecVVTok32logValid            dd ?
    kytaecVVTok32logResult           tbyte ?

.data
    kytaecVVTok32inputA dq 2.5, 1.5, 0.5, 0.1, 7.5, -1.1
    kytaecVVTok32inputB dq 1.2, 3.5, 2.5, 0.7, 2.2, 2.1
    kytaecVVTok32inputC dq 0.8, 2.6, 0.1, 0.3, 9.6, 0.25
    kytaecVVTok32inputD dq 0.4, 6.3, 0.6, 5.5, 3.3, 3.7

    kytaecVVTok32windowTitle db "Lab 7. Tokovenko IM-32. Var-22", 0
    kytaecVVTok32messageFormat db "Expression: (ln(a + 4*c) - 1) / (3*b - 2*d)", 10, 10,
        "a: %s",10,"b: %s",10,"c: %s",10,"d: %s",10,10,
        "(ln(%s + 4*%s) - 1)",10,"------------------------",10,
        "(3*%s - 2*%s)",10,10,"Result: %s", 0
    kytaecVVTok32outputBuffer db 1024 dup(?)
    kytaecVVTok32zeroDenominatorMsg db "Error: Division by zero (3*b - 2*d = 0)", 0
    kytaecVVTok32logErrorMsg        db "Error: Invalid logarithm argument (a + 4*c <= 0)", 0
    kytaecVVTok32bothErrorsMsg      db "Error: Both division by zero and invalid logarithm", 0

    kytaecVVTok32iteration dd 0
    kytaecVVTok32strA db 64 dup(?)
    kytaecVVTok32strB db 64 dup(?)
    kytaecVVTok32strC db 64 dup(?)
    kytaecVVTok32strD db 64 dup(?)
    kytaecVVTok32strResult db 64 dup(?)
    kytaecVVTok32one      real8 1.0
    kytaecVVTok32two      real8 2.0
    kytaecVVTok32three    real8 3.0
    kytaecVVTok32four     real8 4.0
    kytaecVVTok32epsilon  real8 1.0e-10

.code

; === Обчислення логарифму через регістри: ln(a + 4 * c)
kytaecVVTok32CalcLogarithm proc
    ; eax = адреса a, edx = адреса c
    fld qword ptr [edx]     ; завантажити c
    fld real8 ptr [kytaecVVTok32four] ; 4
    fmul                    ; 4 * c
    fld qword ptr [eax]     ; a
    fadd                    ; a + 4 * c
    fldln2
    fxch
    fyl2x                   ; ln(a + 4*c)
    ret
kytaecVVTok32CalcLogarithm endp

; === Отримання -1 через стек
kytaecVVTok32NegateConstantViaStack proc
    push ebp
    mov ebp, esp
    fld real8 ptr [ebp + 8]
    fchs                    ; зміна знака
    pop ebp
    ret 4
kytaecVVTok32NegateConstantViaStack endp

start:
    mov esi, [kytaecVVTok32iteration]

kytaecVVTok32calculationLoop:
    finit
    mov [kytaecVVTok32denominatorValid], 1
    mov [kytaecVVTok32logValid], 1

    ; === Обчислення знаменника
    push esi
    call kytaecVVTok32CalcDenominator
    add esp, 4

    fld tbyte ptr [kytaecVVTok32tempDenominator]
    fabs
    fcomp [kytaecVVTok32epsilon]
    fstsw ax
    sahf
    jb kytaecVVTok32denominator_zero

    ; === Перевірка логарифма (a + 4*c > 0)
    fld qword ptr [kytaecVVTok32inputC + 8*esi]
    fmul [kytaecVVTok32four]
    fadd qword ptr [kytaecVVTok32inputA + 8*esi]
    ftst
    fstsw ax
    sahf
    ja kytaecVVTok32log_ok
    mov [kytaecVVTok32logValid], 0
    jmp kytaecVVTok32check_errors

kytaecVVTok32denominator_zero:
    mov [kytaecVVTok32denominatorValid], 0
    fstp st(0)
    fld qword ptr [kytaecVVTok32inputC + 8*esi]
    fmul [kytaecVVTok32four]
    fadd qword ptr [kytaecVVTok32inputA + 8*esi]
    ftst
    fstsw ax
    sahf
    ja kytaecVVTok32check_errors
    mov [kytaecVVTok32logValid], 0
    jmp kytaecVVTok32check_errors

kytaecVVTok32log_ok:
    ; === Обчислення чисельника
    lea eax, kytaecVVTok32inputA[esi*8]
    lea edx, kytaecVVTok32inputC[esi*8]
    call kytaecVVTok32CalcLogarithm
    fstp tbyte ptr [kytaecVVTok32logResult]

    sub esp, 8
    fld real8 ptr [kytaecVVTok32one]
    fstp qword ptr [esp]
    call kytaecVVTok32NegateConstantViaStack
    add esp, 8

    fld tbyte ptr [kytaecVVTok32logResult]
    fadd st(0), st(1)
    fstp tbyte ptr [kytaecVVTok32tempNumerator]
    fstp st(0)

    ; === Ділення чисельника на знаменник
    fld tbyte ptr [kytaecVVTok32tempNumerator]
    fld tbyte ptr [kytaecVVTok32tempDenominator]
    fdivp st(1), st(0)
    fstp qword ptr [kytaecVVTok32resultDouble]

    ; === Форматування та вивід результату
    invoke FloatToStr2, [kytaecVVTok32inputA + 8*esi], addr kytaecVVTok32strA
    invoke FloatToStr2, [kytaecVVTok32inputB + 8*esi], addr kytaecVVTok32strB
    invoke FloatToStr2, [kytaecVVTok32inputC + 8*esi], addr kytaecVVTok32strC
    invoke FloatToStr2, [kytaecVVTok32inputD + 8*esi], addr kytaecVVTok32strD
    invoke FloatToStr2, kytaecVVTok32resultDouble, addr kytaecVVTok32strResult
    invoke wsprintf, addr kytaecVVTok32outputBuffer, addr kytaecVVTok32messageFormat,
        addr kytaecVVTok32strA, addr kytaecVVTok32strB, addr kytaecVVTok32strC, addr kytaecVVTok32strD,
        addr kytaecVVTok32strA, addr kytaecVVTok32strC, addr kytaecVVTok32strB, addr kytaecVVTok32strD,
        addr kytaecVVTok32strResult
    jmp kytaecVVTok32show

kytaecVVTok32check_errors:
    finit
    invoke FloatToStr2, [kytaecVVTok32inputA + 8*esi], addr kytaecVVTok32strA
    invoke FloatToStr2, [kytaecVVTok32inputB + 8*esi], addr kytaecVVTok32strB
    invoke FloatToStr2, [kytaecVVTok32inputC + 8*esi], addr kytaecVVTok32strC
    invoke FloatToStr2, [kytaecVVTok32inputD + 8*esi], addr kytaecVVTok32strD

    cmp [kytaecVVTok32denominatorValid], 1
    je kytaecVVTok32only_log_error
    cmp [kytaecVVTok32logValid], 1
    je kytaecVVTok32only_denom_error

    invoke wsprintf, addr kytaecVVTok32outputBuffer, addr kytaecVVTok32messageFormat,
        addr kytaecVVTok32strA, addr kytaecVVTok32strB, addr kytaecVVTok32strC, addr kytaecVVTok32strD,
        addr kytaecVVTok32strA, addr kytaecVVTok32strC, addr kytaecVVTok32strB, addr kytaecVVTok32strD,
        addr kytaecVVTok32bothErrorsMsg
    jmp kytaecVVTok32show

kytaecVVTok32only_denom_error:
    invoke wsprintf, addr kytaecVVTok32outputBuffer, addr kytaecVVTok32messageFormat,
        addr kytaecVVTok32strA, addr kytaecVVTok32strB, addr kytaecVVTok32strC, addr kytaecVVTok32strD,
        addr kytaecVVTok32strA, addr kytaecVVTok32strC, addr kytaecVVTok32strB, addr kytaecVVTok32strD,
        addr kytaecVVTok32zeroDenominatorMsg
    jmp kytaecVVTok32show

kytaecVVTok32only_log_error:
    invoke wsprintf, addr kytaecVVTok32outputBuffer, addr kytaecVVTok32messageFormat,
        addr kytaecVVTok32strA, addr kytaecVVTok32strB, addr kytaecVVTok32strC, addr kytaecVVTok32strD,
        addr kytaecVVTok32strA, addr kytaecVVTok32strC, addr kytaecVVTok32strB, addr kytaecVVTok32strD,
        addr kytaecVVTok32logErrorMsg

kytaecVVTok32show:
    invoke MessageBox, 0, addr kytaecVVTok32outputBuffer, addr kytaecVVTok32windowTitle, MB_OK

    inc esi
    cmp esi, 6
    jne kytaecVVTok32calculationLoop

    invoke ExitProcess, 0
end start
