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

.data?
    kytaecVVTok32_outputBuffer        db 2048 dup (?)
    kytaecVVTok32_tempNumerator       dt ?      ; Проміжний результат чисельника (long double)  
    kytaecVVTok32_tempDenominator     dt ?      ; Проміжний результат знаменника (long double)
    kytaecVVTok32_resultDouble        dq ?      ; Кінцевий результат (double)  
    kytaecVVTok32_denominatorValid    dd ?
    kytaecVVTok32_logValid            dd ?

.data
    kytaecVVTok32_inputA dq 2.5, 1.5, 0.5, 0.1, 7.5, -1.1
    kytaecVVTok32_inputB dq 1.2, 3.5, 2.5, 0.7, 2.2, 2.1
    kytaecVVTok32_inputC dq 0.8, 2.6, 0.1, 0.3, 9.6, 0.25
    kytaecVVTok32_inputD dq 0.4, 6.3, 0.6, 5.5, 3.3, 3.7

    kytaecVVTok32_windowTitle db "Lab 6. Tokovenko IM-32. Var-22", 0
    kytaecVVTok32_messageFormat db "Expression: (ln(a + 4*c) - 1) / (3*b - 2*d)", 10, 10,
                 "Value of a: %s", 10,
                 "Value of b: %s", 10,
                 "Value of c: %s", 10,
                 "Value of d: %s", 10, 10,
                 "(ln(%s + 4*%s) - 1)", 10,
                 "------------------------", 10,
                 "(3*%s - 2*%s)", 10, 10,
                 "Result: %s", 0
    kytaecVVTok32_zeroDenominatorMsg db "Error: Division by zero (3*b - 2*d = 0)", 0
    kytaecVVTok32_logErrorMsg db "Error: Invalid logarithm argument (a + 4*c <= 0)", 0
    kytaecVVTok32_bothErrorsMsg db "Error: Both division by zero and invalid logarithm", 0

    kytaecVVTok32_iteration dd 0
    kytaecVVTok32_strA db 64 dup(?)
    kytaecVVTok32_strB db 64 dup(?)
    kytaecVVTok32_strC db 64 dup(?)
    kytaecVVTok32_strD db 64 dup(?)
    kytaecVVTok32_strResult db 64 dup(?)

    kytaecVVTok32_one      real8 1.0
    kytaecVVTok32_two      real8 2.0
    kytaecVVTok32_three    real8 3.0
    kytaecVVTok32_four     real8 4.0
    kytaecVVTok32_epsilon  real8 1.0e-10

.code
start:
    mov esi, [kytaecVVTok32_iteration]

calculationLoop:
    finit
    mov [kytaecVVTok32_denominatorValid], 1
    mov [kytaecVVTok32_logValid], 1

    ; Обчислення знаменника (3*b - 2*d)
    fld qword ptr [kytaecVVTok32_inputB + 8*esi]   
    fmul [kytaecVVTok32_three]                     
    fld qword ptr [kytaecVVTok32_inputD + 8*esi]   
    fmul [kytaecVVTok32_two]                       
    fsubp st(1), st(0)                             
    fstp tbyte ptr [kytaecVVTok32_tempDenominator]

    ; Перевірка на нуль
    fld tbyte ptr [kytaecVVTok32_tempDenominator]
    fabs
    fcomp [kytaecVVTok32_epsilon]
    fstsw ax
    sahf
    jb denominator_zero

    ; Перевірка аргументу логарифма (a + 4*c)
    fld qword ptr [kytaecVVTok32_inputC + 8*esi]   
    fmul [kytaecVVTok32_four]                      
    fadd qword ptr [kytaecVVTok32_inputA + 8*esi]  
    ftst                              
    fstsw ax
    sahf
    ja log_ok
    mov [kytaecVVTok32_logValid], 0
    jmp check_errors

denominator_zero:
    mov [kytaecVVTok32_denominatorValid], 0
    fstp st(0)
    fld qword ptr [kytaecVVTok32_inputC + 8*esi]
    fmul [kytaecVVTok32_four]
    fadd qword ptr [kytaecVVTok32_inputA + 8*esi]
    ftst
    fstsw ax
    sahf
    ja check_errors
    mov [kytaecVVTok32_logValid], 0
    jmp check_errors

log_ok:
    fld qword ptr [kytaecVVTok32_inputC + 8*esi]
    fmul [kytaecVVTok32_four]
    fadd qword ptr [kytaecVVTok32_inputA + 8*esi]
    fldln2
    fxch
    fyl2x
    fsub [kytaecVVTok32_one]
    fstp tbyte ptr [kytaecVVTok32_tempNumerator]

    fld tbyte ptr [kytaecVVTok32_tempNumerator]
    fld tbyte ptr [kytaecVVTok32_tempDenominator]
    fdivp st(1), st(0)
    fstp qword ptr [kytaecVVTok32_resultDouble]

    invoke FloatToStr2, [kytaecVVTok32_inputA + 8*esi], addr kytaecVVTok32_strA
    invoke FloatToStr2, [kytaecVVTok32_inputB + 8*esi], addr kytaecVVTok32_strB
    invoke FloatToStr2, [kytaecVVTok32_inputC + 8*esi], addr kytaecVVTok32_strC
    invoke FloatToStr2, [kytaecVVTok32_inputD + 8*esi], addr kytaecVVTok32_strD
    invoke FloatToStr2, [kytaecVVTok32_resultDouble], addr kytaecVVTok32_strResult

    invoke wsprintf, addr kytaecVVTok32_outputBuffer, addr kytaecVVTok32_messageFormat,
        addr kytaecVVTok32_strA, addr kytaecVVTok32_strB, addr kytaecVVTok32_strC, addr kytaecVVTok32_strD,
        addr kytaecVVTok32_strA, addr kytaecVVTok32_strC,
        addr kytaecVVTok32_strB, addr kytaecVVTok32_strD,
        addr kytaecVVTok32_strResult

    jmp showResult

check_errors:
    finit
    invoke FloatToStr2, [kytaecVVTok32_inputA + 8*esi], addr kytaecVVTok32_strA
    invoke FloatToStr2, [kytaecVVTok32_inputB + 8*esi], addr kytaecVVTok32_strB
    invoke FloatToStr2, [kytaecVVTok32_inputC + 8*esi], addr kytaecVVTok32_strC
    invoke FloatToStr2, [kytaecVVTok32_inputD + 8*esi], addr kytaecVVTok32_strD

    cmp [kytaecVVTok32_denominatorValid], 1
    je log_error_only
    cmp [kytaecVVTok32_logValid], 1
    je denominator_error_only

    invoke wsprintf, addr kytaecVVTok32_outputBuffer, addr kytaecVVTok32_messageFormat,
        addr kytaecVVTok32_strA, addr kytaecVVTok32_strB, addr kytaecVVTok32_strC, addr kytaecVVTok32_strD,
        addr kytaecVVTok32_strA, addr kytaecVVTok32_strC,
        addr kytaecVVTok32_strB, addr kytaecVVTok32_strD,
        addr kytaecVVTok32_bothErrorsMsg
    jmp showResult

denominator_error_only:
    invoke wsprintf, addr kytaecVVTok32_outputBuffer, addr kytaecVVTok32_messageFormat,
        addr kytaecVVTok32_strA, addr kytaecVVTok32_strB, addr kytaecVVTok32_strC, addr kytaecVVTok32_strD,
        addr kytaecVVTok32_strA, addr kytaecVVTok32_strC,
        addr kytaecVVTok32_strB, addr kytaecVVTok32_strD,
        addr kytaecVVTok32_zeroDenominatorMsg
    jmp showResult

log_error_only:
    invoke wsprintf, addr kytaecVVTok32_outputBuffer, addr kytaecVVTok32_messageFormat,
        addr kytaecVVTok32_strA, addr kytaecVVTok32_strB, addr kytaecVVTok32_strC, addr kytaecVVTok32_strD,
        addr kytaecVVTok32_strA, addr kytaecVVTok32_strC,
        addr kytaecVVTok32_strB, addr kytaecVVTok32_strD,
        addr kytaecVVTok32_logErrorMsg

showResult:
    invoke MessageBox, 0, addr kytaecVVTok32_outputBuffer, addr kytaecVVTok32_windowTitle, MB_OK

    inc esi
    cmp esi, 6
    jne calculationLoop

    invoke ExitProcess, 0

end start